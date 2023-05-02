;****************************************************************************
; $Id: x86_dec.s,v 1.3 2003/12/28 22:14:15 rincewind Exp $
;****************************************************************************
; $Log: x86_dec.s,v $
; Revision 1.3  2003/12/28 22:14:15  rincewind
; - fix CVS headers
;
; Revision 1.2  2000/06/19 20:52:35  rincewind
; - misc cleanup
;****************************************************************************

            XREF    halt_sys
            XREF    halt_sys_clear

            XDEF    push_word
            XDEF    push_long
            XDEF    pop_word
            XDEF    pop_long
            XDEF    push_segword
            XDEF    pop_segword
            XDEF    push_seglong
            XDEF    pop_seglong

            XDEF    asm_fetchbyte
            XDEF    asm_fetchbyte_word
            XDEF    asm_fetchword
            XDEF    asm_fetchword_long
            XDEF    asm_fetchlong
            XDEF    asm_rdb
            XDEF    asm_rdw
            XDEF    asm_rdl
            XDEF    asm_wrb
            XDEF    asm_wrw
            XDEF    asm_wrl
            XDEF    asm_inb
            XDEF    asm_inw
            XDEF    asm_inl
            XDEF    asm_outb
            XDEF    asm_outw
            XDEF    asm_outl
            XDEF    get_src_byte
            XDEF    get_src_word
            XDEF    get_src_long
            XDEF    GetOffsetSeg
            XDEF    Get_rm_Offset

            IMPORT  sys

            INCLUDE "X86_REGS.INC"

            TEXT

;***************************************************************
; push_word
;   entry:
;     D0.W - Wert der auf den Stack gelegt werden soll
;   exit:
;   changed:
;     SP(A6) -= 2
;     A0
;***************************************************************
push_segword:
            LSR.L   #4,D0
push_word:  CLR.L   A0
            SUB.W   #2,SP(A6)
            MOVE.W  SP(A6),A0
            ADD.L   SS(A6),A0
; Stack darf nur im RAM liegen
            CMP.L   4(A6),A0                ; mem_size
            BCC     halt_sys_clear
            ADD.L   (A6),A0                 ; + mem_base
            ROR.W   #8,D0                   ; Little endian
            MOVE.W  D0,(A0)
            RTS

;***************************************************************
; push_long
;   entry:
;     D0.L - Wert der auf den Stack gelegt werden soll
;   exit:
;   changed:
;     SP(A6) -= 4
;     A0
;***************************************************************
push_seglong:
            LSR.L   #4,D0
push_long:  CLR.L   A0
            SUB.W   #4,SP(A6)
            MOVE.W  SP(A6),A0
            ADD.L   SS(A6),A0
; Stack darf nur im RAM liegen
            CMP.L   4(A6),A0                ; mem_size
            BCC     halt_sys_clear
            ADD.L   (A6),A0                 ; + mem_base
            ROR.W   #8,D0                   ; Little endian
            SWAP    D0
            ROR.W   #8,D0
            MOVE.L  D0,(A0)
            RTS

;***************************************************************
; pop_word
;   entry:
;   exit:
;     D0.W - Wert der vom Stack geholt werden soll
;  changed:
;     SP(A6) += 2
;     A0
;***************************************************************
pop_segword:
            MOVEQ   #0,D0                   ; obere HÑlfte lîschen
            BSR.S   pop_word
            LSL.L   #4,D0
            RTS

pop_word:   CLR.L   A0
            MOVE.W  SP(A6),A0
            ADD.L   SS(A6),A0
; Stack darf nur im RAM liegen
            CMP.L   4(A6),A0                ; mem_size
            BCC     halt_sys_clear
            ADD.L   (A6),A0                 ; + mem_base
            MOVE.W  (A0),D0
            ROR.W   #8,D0                   ; Little endian
            ADD.W   #2,SP(A6)
            RTS
;***************************************************************
; pop_long
;   entry:
;   exit:
;     D0.L - Wert der vom Stack geholt werden soll
;  changed:
;     SP(A6) += 2
;     A0
;***************************************************************
pop_seglong: BSR.S  pop_long
            LSL.L   #4,D0
            RTS

pop_long:   CLR.L   A0
            MOVE.W  SP(A6),A0
            ADD.L   SS(A6),A0
; Stack darf nur im RAM liegen
            CMP.L   4(A6),A0                ; mem_size
            BCC     halt_sys_clear
            ADD.L   (A6),A0                 ; + mem_base
            MOVE.L  (A0),D0
            ROR.W   #8,D0                   ; Little endian
            SWAP    D0
            ROR.W   #8,D0
            ADD.W   #4,SP(A6)
            RTS

;***************************************************************
; asm_fetchbyte
;   entry:
;   exit:
;     D0.B - Inhalt von (EIP)
;   changed:
;     A0 EIP++
;***************************************************************
asm_fetchbyte_word:
            CLR.W   D0                      ; Hi Byte lîschen
asm_fetchbyte:
            MOVE.L  EIP(A6),A0
            ADDQ.L  #1,EIP(A6)
            CMP.L   #$C0000,A0
            BCS.S   .Memory
            CMP.L   #$C7FFF,A0
            BHI.S   .error
; ist VGA ROM
            ADD.L   12(A6),A0               ; BIOS_base
            ADD.L   #$FFF40000,A0           ; - 0xC0000
            MOVE.B  (A0),D0
            RTS
; ist Memory
.Memory:    CMP.L   4(A6),A0                ; mem_size
            BCC.S   .error
            ADD.L   (A6),A0                 ; mem_base
            MOVE.B  (A0),D0
            RTS

.error:     BRA     halt_sys_clear

;***************************************************************
; asm_fetchword
;   entry:
;   exit:
;     D0.W - Inhalt von (EIP)
;   changed:
;     A0 EIP+=2
;***************************************************************
asm_fetchword_long:
            MOVEQ   #0,D0
asm_fetchword:
            MOVE.L  EIP(A6),A0
            ADDQ.L  #2,EIP(A6)
            CMP.L   #$C0000,A0
            BCS.S   .Memory
            CMP.L   #$C7FFF,A0
            BHI.S   .error
; ist VGA ROM
            ADD.L   12(A6),A0               ; BIOS_base
            ADD.L   #$FFF40000,A0           ; - 0xC0000
            MOVE.W  (A0),D0
            ROR.W   #8,D0                   ; Big endian
            RTS
; ist Memory
.Memory:    CMP.L   4(A6),A0                ; mem_size
            BCC.S   .error
            ADD.L   (A6),A0                 ; mem_base
            MOVE.W  (A0),D0
            ROR.W   #8,D0                   ; Big endian
            RTS

.error:     BRA     halt_sys_clear

;***************************************************************
; asm_fetchlong
;   entry:
;   exit:
;     D0.L - Inhalt von (EIP)
;   changed:
;     A0 EIP+=4
;***************************************************************
            MODULE  asm_fetchlong
            MOVE.L  EIP(A6),A0
            ADDQ.L  #4,EIP(A6)
            CMP.L   #$C0000,A0
            BCS.S   Memory
            CMP.L   #$C7FFF,A0
            BHI.S   error
; ist VGA ROM
            ADD.L   12(A6),A0               ; BIOS_base
            ADD.L   #$FFF40000,A0           ; - 0xC0000
            MOVE.L  (A0),D0
            ROR.W   #8,D0                   ; Big endian
            SWAP    D0
            ROR.W   #8,D0
            RTS
; ist Memory
Memory:     CMP.L   4(A6),A0                ; mem_size
            BCC.S   error
            ADD.L   (A6),A0                 ; mem_base
            MOVE.L  (A0),D0
            ROR.W   #8,D0                   ; Big endian
            SWAP    D0
            ROR.W   #8,D0
            RTS

error:      BRA     halt_sys_clear
            ENDMOD

;***************************************************************
; Get_rm_Offset
;   entry:
;     D0 - mod 000 000
;     D4 -  00 000 rmByte
;   exit:
;     A2 - Offset
;   Changed:
;     D0 D4 D7
;***************************************************************
            MODULE  Get_rm_Offset
;                  AND.W     #7,D4
            BCLR.L  #31,D7                  ; Prefix testen und lîschen
            BEQ     is_16                   ; Ohne Prefix, springen
; 32 Bit Adressierung
; D4 = mod & 7
; D7 = OverSeg
; D0 = mod & 0xC0
            CMP.W   #4,D4
            BNE.S   no_mod_4
; ist mod = 4 (s-i-b)
;                  BSR       Get_sib_Offset   ; mod in D0 Åbergeben
            MOVE.L  D0,A2
            BRA     no_disp
no_mod_4:
            CMP.W   #5,D4
            BNE.S   no_mod_5
; ist mod = 5
            TST.B   D0
            BNE.S   no_disp_32
; ist disp 32
            BSR     asm_fetchlong           ; D0.L = (EIP)
            MOVE.L  D0,A2
            BRA     no_disp
; ist SS:[EBP]
no_disp_32:
            TST.L   D7                      ; Override, weiter
            BNE.S   no_mod_5
            MOVE.L  SS(A6),D7               ; default ist SS
no_mod_5:   MOVE.L  (EAX,A6,D4*4),A2        ; Adressregister holen
            TST.B   D0
            BEQ     no_disp
            CMP.B   #$80,D0
            BNE     short_imi
            BSR     asm_fetchlong           ; 32 Bit disp holen
            BRA     add_disp
; 16 Bit Adressierung
; D4 = mod & 7
; D7 = OverSeg
; D0 = mod & 0xC0
is_16:      MOVE.W  (switchtab.B,PC,D4.W*2),D4
            JMP     switchtab(PC,D4.W)

switchtab:  DC.W    mod_0 - switchtab
            DC.W    mod_1 - switchtab
            DC.W    mod_2 - switchtab
            DC.W    mod_3 - switchtab
            DC.W    mod_4 - switchtab
            DC.W    mod_5 - switchtab
            DC.W    mod_6 - switchtab
            DC.W    mod_7 - switchtab

mod_0:      MOVE.W  SI(A6),D4
            ADD.W   BX(A6),D4
            BRA.S   no_disp16

mod_1:      MOVE.W  DI(A6),D4
            ADD.W   BX(A6),D4
            BRA.S   no_disp16

mod_2:      MOVE.W  SI(A6),D4
            BRA.S   mod_3_add

mod_3:      MOVE.W  DI(A6),D4
mod_3_add:  ADD.W   BP(A6),D4
            TST.L   D7
            BNE.S   no_disp16               ; Override, springe
            MOVE.L  SS(A6),D7               ; default ist SS
            BRA.S   no_disp16

mod_4:      MOVE.W  SI(A6),D4
            BRA.S   no_disp16

mod_5:      MOVE.W  DI(A6),D4
            BRA.S   no_disp16

mod_6:      CLR.W   D4                      ; Wegen dem ADD nicht vergessen
            TST.B   D0
            BNE.S   mod_3_add
            BSR     asm_fetchword_long
            MOVE.L  D0,A2
            BRA.S   no_disp

mod_7:      MOVE.W  BX(A6),D4               ; DS:[BX]

no_disp16:  AND.L   #$FFFF,D4               ; MÅssen wir so machen
            MOVE.L  D4,A2
            TST.B   D0
            BEQ.S   no_disp
            CMP.B   #$80,D0
            BNE.S   short_imi
            BSR     asm_fetchword           ; 16 Bit disp holen
            EXT.L   D0
            BRA.S   add_disp
short_imi:  BSR     asm_fetchbyte           ; 8 Bit disp
            EXTB.L  D0
add_disp:   ADD.L   D0,A2
; Offset steht in A2
; OverSeg in D7
no_disp:    TST.L   D7
            BNE.S   IsOver
            MOVE.L  DS(A6),D7               ; Default ist DS
IsOver:     ADD.L   D7,A2
            RTS
            ENDMOD

;***************************************************************
; GetOffsetSeg
;   entry:
;   exit:
;     A2 = Current Segment
;   chagnged:
;     OverSeg = Current Segment
;***************************************************************
            MODULE  GetOffsetSeg
            BCLR.L  #31,D7
            MOVE.L  D7,A2
            TST.L   A2
            BNE.S   IsOver
            MOVE.L  DS(A6),A2
            MOVE.L  A2,D7
IsOver:     RTS
            ENDMOD

;***************************************************************
; asm_rdb
;   entry:
;     A2.L - Adresse
;   exit:
;     D0.B - Inhalt der Adresse
;  changed:
;     A0
;***************************************************************

            MODULE  asm_rdb
            MOVE.L  A2,A0
            CMP.L   #$A0000,A0
            BCS.S   mem
            CMP.L   #$BFFFF,A0
            BHI.S   rom
            ADD.L   #$40000000,A0           ; PCI - Base
            MOVE.B  (A0),D0
            RTS

rom:        CMP.L   #$C7FFF,A0
            BHI.S   error
            ADD.L   12(A6),A0               ; BIOS_base
            ADD.L   #$FFF40000,A0           ; - 0xC0000
            MOVE.B  (A0),D0
            RTS

mem:        CMP.L   4(A6),A0                ; mem_size
            BCC.S   error
            ADD.L   (A6),A0                 ; mem_base
            MOVE.B  (A0),D0
            RTS

error:      BRA     halt_sys_clear
            ENDMOD

;***************************************************************
; asm_wrb
;   entry:
;     D0.B - Wert
;     A2.L - Adresse
;   exit:
;   changed:
;     A0
;***************************************************************
            MODULE  asm_wrb
            MOVE.L  A2,A0
            CMP.L   #$A0000,A0
            BCS.S   mem
            CMP.L   #$BFFFF,A0
            BHI.S   rom
            ADD.L   #$40000000,A0
            MOVE.B  D0,(A0)
            RTS

rom:        CMP.L   #$C7FFF,A0
            BHI.S   error
            ADD.L   12(A6),A0               ; BIOS_base
            ADD.L   #$FFF40000,A0           ; - 0xC0000
            MOVE.B  D0,(A0)
            RTS

mem:        CMP.L   4(A6),A0                ; mem_size
            BCC.S   error
            ADD.L   (A6),A0
            MOVE.B  D0,(A0)
            RTS

error:      BRA     halt_sys_clear
            ENDMOD

;***************************************************************
; get_src_byte
;   entry:
;   exit:
;     D1.B - Sourcebyte
;     D3.W - reg von fetchbyte = xx reg xxx
;   changed:
;     D0 D2 D4 A0 A2
;***************************************************************
            MODULE  get_src_byte
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D3             ; D3 = reg
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   IsMem

            MOVEA.L (shortcut,A6,D4.W*4),A2
            MOVE.B  (A2),D1                 ; Quelle nach D1
            RTS

IsMem:      BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdb                 ; D0 = (A2)
            MOVE.B  D0,D1
            RTS
            ENDMOD

;***************************************************************
; asm_rdw
;   entry:
;     A2.L - Adresse
;   exit:
;     D0.W - Inhalt der Adresse
;  changed:
;     A0
;***************************************************************

            MODULE  asm_rdw
            MOVE.L  A2,A0
            CMP.L   #$A0000,A0
            BCS.S   mem
            CMP.L   #$BFFFF,A0
            BHI.S   rom
            ADD.L   #$40000000,A0           ; PCI - Base
            MOVE.W  (A0),D0
            ROR.W   #8,D0                   ; Big endian
            RTS

rom:        CMP.L   #$C7FFF,A0
            BHI.S   error
            ADD.L   12(A6),A0               ; BIOS_base
            ADD.L   #$FFF40000,A0           ; - 0xC0000
            MOVE.W  (A0),D0
            ROR.W   #8,D0                   ; Big endian
            RTS

mem:        CMP.L   4(A6),A0                ; mem_size
            BCC.S   error
            ADD.L   (A6),A0                 ; mem_base
            MOVE.W  (A0),D0
            ROR.W   #8,D0                   ; Big endian
            RTS

error:      BRA     halt_sys_clear
            ENDMOD

;***************************************************************
; asm_wrw
;   entry:
;     D0.W - Wert
;     A2.L - Adresse
;   exit:
;   changed:
;     A0
;***************************************************************
            MODULE  asm_wrw
            ROR.W   #8,D0                   ; Little endian
            MOVE.L  A2,A0
            CMP.L   #$A0000,A0
            BCS.S   mem
            CMP.L   #$BFFFF,A0
            BHI.S   rom
            ADD.L   #$40000000,A0
            MOVE.W  D0,(A0)
            RTS

rom:        CMP.L   #$C7FFF,A0
            BHI.S   error
            ADD.L   12(A6),A0               ; BIOS_base
            ADD.L   #$FFF40000,A0           ; - 0xC0000
            MOVE.W  D0,(A0)
            RTS

mem:        CMP.L   4(A6),A0                ; mem_size
            BCC.S   error
            ADD.L   (A6),A0
            MOVE.W  D0,(A0)
            RTS

error:      BRA     halt_sys_clear
            ENDMOD

;***************************************************************
; get_src_word
;   entry:
;   exit:
;     D1.W - Sourceword
;     D3.W - reg von fetchbyte = xx reg xxx
;   changed:
;     D0 D2 D4 A0 A2
;***************************************************************
            MODULE  get_src_word
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D3             ; D3 = reg
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   IsMem

            MOVE.W  (AX,A6,D4.W*4),D1       ; Quelle nach D1
            RTS

IsMem:      BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdw                 ; D0 = (A2)
            MOVE.W  D0,D1
            RTS
            ENDMOD

;***************************************************************
; asm_rdl
;   entry:
;     A2.L - Adresse
;   exit:
;     D0.L - Inhalt der Adresse
;  changed:
;     A0
;***************************************************************

            MODULE  asm_rdl
            MOVE.L  A2,A0
            CMP.L   #$A0000,A0
            BCS.S   mem
            CMP.L   #$BFFFF,A0
            BHI.S   rom
            ADD.L   #$40000000,A0           ; PCI - Base
            MOVE.L  (A0),D0
            ROR.W   #8,D0                   ; Big endian
            SWAP    D0
            ROR.W   #8,D0
            RTS

rom:        CMP.L   #$C7FFF,A0
            BHI.S   error
            ADD.L   12(A6),A0               ; BIOS_base
            ADD.L   #$FFF40000,A0           ; - 0xC0000
            MOVE.L  (A0),D0
            ROR.W   #8,D0                   ; Big endian
            SWAP    D0
            ROR.W   #8,D0
            RTS

mem:        CMP.L   4(A6),A0                ; mem_size
            BCC.S   error
            ADD.L   (A6),A0                 ; mem_base
            MOVE.L  (A0),D0
            ROR.W   #8,D0                   ; Big endian
            SWAP    D0
            ROR.W   #8,D0
            RTS

error:      BRA     halt_sys_clear
            ENDMOD

;***************************************************************
; asm_wrl
;   entry:
;     D0.L - Wert
;     A2.L - Adresse
;   exit:
;   changed:
;     A0
;***************************************************************
            MODULE  asm_wrl
            ROR.W   #8,D0                   ; Little endian
            SWAP    D0
            ROR.W   #8,D0
            MOVE.L  A2,A0
            CMP.L   #$A0000,A0
            BCS.S   mem
            CMP.L   #$BFFFF,A0
            BHI.S   rom
            ADD.L   #$40000000,A0
            MOVE.L  D0,(A0)
            RTS

rom:        CMP.L   #$C7FFF,A0
            BHI.S   error
            ADD.L   12(A6),A0               ; BIOS_base
            ADD.L   #$FFF40000,A0           ; - 0xC0000
            MOVE.L  D0,(A0)
            RTS

mem:        CMP.L   4(A6),A0                ; mem_size
            BCC.S   error
            ADD.L   (A6),A0
            MOVE.L  D0,(A0)
            RTS

error:      BRA     halt_sys_clear
            ENDMOD

;***************************************************************
; get_src_long
;   entry:
;   exit:
;     D1.W - Sourceword
;     D3.W - reg von fetchbyte = xx reg xxx
;   changed:
;     D0 D2 D4 A0 A2
;***************************************************************
            MODULE  get_src_long
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D3             ; D3 = reg
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   IsMem

            MOVE.L  (EAX,A6,D4.W*4),D1      ; Quelle nach D1
            RTS

IsMem:      BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdl                 ; D0 = (A2)
            MOVE.W  D0,D1
            RTS
            ENDMOD

;***************************************************************
; asm_inb
;   entry:
;     D0.W = Port (muû < $8000 sein)
;   exit:
;     D0.B = Wert
;   changed:
;     A0
;***************************************************************
asm_inb:    LEA.L   $80000000,A0
            AND.L   #$0000FFFF,D0
            EOR.B   #3,D0
            MOVE.B  (D0.l,A0),D0
            RTS

;***************************************************************
; asm_inw
;   entry:
;     D0.W = Port (muû < $8000 sein)
;   exit:
;     D0.W = Wert
;   changed:
;     A0
;***************************************************************
asm_inw:    LEA.L   $80000000,A0
            AND.L   #$0000FFFF,D0
            EOR.B   #2,D0
            MOVE.W  (D0.l,A0),D0
            RTS

;***************************************************************
; asm_inl
;   entry:
;     D0.W = Port (muû < $8000 sein)
;   exit:
;     D0.L = Wert
;   changed:
;     A0
;***************************************************************
asm_inl:    LEA.L   $80000000,A0
            AND.L   #$0000FFFF,D0
            MOVE.L  (D0.l,A0),D0
            RTS

;***************************************************************
; asm_outb
;   entry:
;     D0.B = Wert
;     D1.W = Port (muû < $8000 sein)
;   exit:
;   changed:
;     A0
;***************************************************************
asm_outb:   LEA.L   $80000000,A0
            AND.L   #$0000FFFF,D1
            EOR.B   #3,D1
            MOVE.B  D0,(D1.l,A0)
            RTS

;***************************************************************
; asm_outw
;   entry:
;     D0.W = Wert
;     D1.W = Port (muû < $8000 sein)
;   exit:
;   changed:
;     D0 A0
;***************************************************************
asm_outw:   LEA.L   $80000000,A0
            AND.L   #$0000FFFF,D1
            EOR.B   #2,d1
            MOVE.W  D0,(D1.l,A0)
            RTS

;***************************************************************
; asm_outl
;   entry:
;     D0.L = Wert
;     D1.W = Port (muû < $8000 sein)
;   exit:
;   changed:
;     D0 A0
;***************************************************************
asm_outl:   LEA.L   $80000000,A0
            AND.L   #$0000FFFF,D1
            MOVE.L  D0,(D1.l,A0)
            RTS
