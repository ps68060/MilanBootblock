;****************************************************************************
; $Id: x86_exec.s,v 1.4 2003/12/28 22:14:15 rincewind Exp $
;****************************************************************************
; $Log: x86_exec.s,v $
; Revision 1.4  2003/12/28 22:14:15  rincewind
; - fix CVS headers
;
; Revision 1.2  2000/06/19 20:52:35  rincewind
; - misc cleanup
;****************************************************************************

            INCLUDE "X86_REGS.INC"

            TEXT

IMPORT      asm_fetchbyte_word
IMPORT      x86_optab
IMPORT      VGA_BIOS
IMPORT      sys
IMPORT      asm_wrl
IMPORT      asm_outb
IMPORT      DebugRegDump
IMPORT      DebugOutB
IMPORT      DebugOutW
IMPORT      DebugInt
IMPORT      IP_Save

            XREF    FlagsToPC

XDEF        x86_exec
XDEF        MainLoopEnd_OSC32
XDEF        MainLoopEnd_OSC
XDEF        MainLoopEnd
XDEF        halt_sys_clear
XDEF        halt_sys
XDEF        fastcopy
XDEF        asm_bios_init
XDEF        isa_timer_init
XDEF        isa_timer_exit

; !!! der MOVE 16 funktioniert scheinbar nicht zuverlÑssig
MODULE      fastcopy
            if      0
            LEA     VGA_BIOS,A1             ; DestZeiger
            LEA     $64000000,A0            ; Source Zeiger
            MOVE.W  #127,D0                 ; Loop Count
LOOP1:      MOVE16  (A0)+,(A1)+             ; 16
            MOVE16  (A0)+,(A1)+             ; 32
            MOVE16  (A0)+,(A1)+             ;
            MOVE16  (A0)+,(A1)+             ; 64 Byte
            MOVE16  (A0)+,(A1)+             ;
            MOVE16  (A0)+,(A1)+             ;
            MOVE16  (A0)+,(A1)+             ;
            MOVE16  (A0)+,(A1)+             ; 128 Byte
            MOVE16  (A0)+,(A1)+             ;
            MOVE16  (A0)+,(A1)+             ;
            MOVE16  (A0)+,(A1)+             ;
            MOVE16  (A0)+,(A1)+             ;
            MOVE16  (A0)+,(A1)+             ;
            MOVE16  (A0)+,(A1)+             ;
            MOVE16  (A0)+,(A1)+             ;
            MOVE16  (A0)+,(A1)+             ; 256 Byte
            DBRA    D0,LOOP1
            RTS
            else
            MOVEM.L D3-D7/A2-A6,-(A7)
            LEA     VGA_BIOS,A1             ; DestZeiger
            MOVE.L  D0,A0                   ; Source Zeiger
;           LEA     $64000000,A0            ; Source Zeiger
            MOVE.W  #63,D7                  ; Loop Count
LOOP:       MOVEM.L (A0)+,D0-D6/A2-A6
            MOVEM.L D0-D6/A2-A6,(A1)        ; 12
            MOVEM.L (A0)+,D0-D6/A2-A6
            MOVEM.L D0-D6/A2-A6,12*4(A1)    ; 24
            MOVEM.L (A0)+,D0-D6/A2-A6
            MOVEM.L D0-D6/A2-A6,24*4(A1)    ; 36
            MOVEM.L (A0)+,D0-D6/A2-A6
            MOVEM.L D0-D6/A2-A6,36*4(A1)    ; 48 = $30
            MOVEM.L (A0)+,D0-D6/A2-A6
            MOVEM.L D0-D6/A2-A6,48*4(A1)    ; 60
            MOVEM.L (A0)+,D0-D6/A2-A6
            MOVEM.L D0-D6/A2-A6,60*4(A1)    ; 72
            MOVEM.L (A0)+,D0-D6/A2-A6
            MOVEM.L D0-D6/A2-A6,72*4(A1)    ; 84
            MOVEM.L (A0)+,D0-D6/A2-A6
            MOVEM.L D0-D6/A2-A6,84*4(A1)    ; 96 = $60
            MOVEM.L (A0)+,D0-D6/A2-A6
            MOVEM.L D0-D6/A2-A6,96*4(A1)    ; 108
            MOVEM.L (A0)+,D0-D6/A2-A6
            MOVEM.L D0-D6/A2-A6,108*4(A1)   ; 120
            MOVEM.L (A0)+,D0-D6/A2
            MOVEM.L D0-D6/A2,120*4(A1)      ; 128
            LEA     128*4(A1),A1
            DBRA    D7,LOOP
            MOVEM.L (A7)+,D3-D7/A2-A6
            RTS
            endif
ENDMOD

; Initialize ISA Timer 0 to standard PC values
MODULE      isa_timer_init
            move.b  #$36,D0                 ; Timer 0 Modus 3
            move.w  #$0043,D1
            bsr     asm_outb
            moveq   #0,D0                   ; Count = 0 (max)
            move.w  #$0040,D1
            bsr     asm_outb
            bsr     asm_outb
            rts
ENDMOD

; turn off ISA timer 0
MODULE      isa_timer_exit
            move.b  #$30,D0                 ; Timer 0 Modus 0
            move.w  #$0043,D1
            bsr     asm_outb
            moveq   #1,D0                   ; Count = $0001
            move.w  #$0040,D1
            bsr     asm_outb
            moveq   #0,D0                   ; Count = $0001
            bsr     asm_outb
            rts
ENDMOD



x86_intr_handle:
            if      0
            .mem_call_f: MOVE.W    D0,D3        ; D0 sichern
            MOVE.L  EIP(A6),D4
            MOVE.L  CS(A6),D0
            SUB.L   D0,D4
            BSR     push_segword
            MOVE.W  D4,D0
            BSR     push_word
            MOVE.W  D3,D0

.mem_jmp_f: MOVE.W  D0,D4                   ; IP sichern
            MOVEQ   #0,D0
            ADDQ    #2,A2                   ; Segment holen
            BSR     asm_rdw
            LSL.L   #4,D0
            MOVE.L  D0,CS(A6)
            MOVE.W  D4,D0                   ; IP zurÅckholen
            endif
            RTS

            MODULE  x86_exec
            bsr     isa_timer_init
            MOVEM.L A2-A6/D3-D7,-(A7)
            LEA     sys,A6
            MOVEQ   #-1,D6                  ; Flags ungÅltig
            CLR.W   intr(A6)
            clr.l   IP_Save
            BRA.S   MainLoopEnd_OSC32

halt_sys_clear: ADDQ #4,A7                  ; Returnadresse vom Stack
halt_sys:   OR.W    #4,intr(A6)
            BRA.S   MainLoopEnd

            ALIGN   16
MainLoopEnd_OSC32: LEA x86_optab(PC),A5     ; Tabelle zurÅcksetzen
MainLoopEnd_OSC: MOVEQ #0,D7                ; OverSeg lîschen
MainLoopEnd: TST.W  intr(A6)
            BNE.S   DoInt

; Hier kînnen wir debuggen
;           move.l  EIP(A6),D1
;           cmp.l   #$FFFFFFFF,IP_Save
;           bne.s   MainLoop
;           cmp.l   #$000C0550,D1
;           bcs.s   MainLoop
;           cmp.l   #$000C0560,D1
;           bcc.s   MainLoop
;           move.l  #$FFFFFFFF,IP_Save
M_IsDump:
;           cmp.l   #$000C04AF,D1
;           bcs.s   MainLoop
;           cmp.l   #$000C05D0,D1
;           bcc.s   MainLoop
;           cmp.l   #$000C58D2,D1
;           bcs.s   MainLoop

;           and.l   #$FFFFFFF0,D1
;           cmp.l   IP_Save,D1
;           BEQ.S   MainLoop
;           move.l  D1,IP_Save
M_IsDump2:
;           BSR     DebugRegDump

MainLoop:   BSR     asm_fetchbyte_word
	.if 1 ; debug in/out
           move.l  D0,-(A7)
           CMP.B   #$EF,D0
           BNE.S   ML_001
           BSR     DebugOutW
ML_001:    CMP.B   #$EE,D0
           BNE.S   ML_002
           BSR     DebugOutB
ML_002:    CMP.B   #$CD,D0
           BNE.S   ML_003
           BSR     DebugInt
           cmp.w   #$1010,AX(A6)
           bne.s   ML_003
           cmp.w   #$1004,BX(A6)
           bne.s   ML_003
           move.l  #$FFFFFFFF,IP_Save
ML_003:    move.l  (A7)+,D0
	.endif
            MOVE.W  (A5,D0.W*2),D1
            JMP     (A5,D1.W)

DoInt:      MOVEQ   #4,D0
            AND.W   intr(A6),D0
            BNE.S   exit
            MOVEQ   #1,D0
            AND.W   intr(A6),D0
            BEQ.S   L00E0
            MOVE.B  intno(A6),D0
            BEQ.S   L00E1
            SUBQ.B  #2,D0
            BEQ.S   L00E1
L00E0:      MOVE.W  Flags(A6),D0
            AND.W   #$200,D0
            BNE.S   MainLoop
L00E1:      BSR     x86_intr_handle
            BRA.S   MainLoop

exit:       MOVEM.L (A7)+,A2-A6/D3-D7
            bsr     isa_timer_exit
            RTS
            ENDMOD

            END
