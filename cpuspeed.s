;*****************************************************************************
; $Id: cpuspeed.s,v 1.7 2003/12/28 22:14:01 rincewind Exp $ 
;*****************************************************************************
; $Log: cpuspeed.s,v $
; Revision 1.7  2003/12/28 22:14:01  rincewind
; - fix CVS headers
;
; Revision 1.6  2003/12/28 21:10:56  rincewind
; - fix LC040 detection
;*****************************************************************************
            include "regdef.inc"

; Taktfrequenz der CPU ermitteln (bisher nur fÅr 68040).
; Liefert 10* Takt in MHz in D0 (also 250 fÅr 25.0 MHz)
; Instruction-Cache muû an sein!

            EXPORT  detect_cpu, cpu_type, cpu_strtab
detect_cpu:
            move.w  sr,-(sp)
            ori.w   #$0700,sr
            move.l  sp,a1

            lea     detect_040(pc),a0
            move.l  a0,$10.w
            nop
            dc.w    $4E7A,$0808             ; movec PCR,d0
; PCR:
; $0430xxxx = MC68060
; $0431xxxx = MC68LC060/MC68EC060

detect_60:
            moveq   #2,d1
            btst    #16,d0
            bne     detect_060_a
            moveq   #3,d1
detect_060_a:
            move.w  d1,cpu_type

            moveq   #0,d0
            moveq   #2,d2
            moveq   #-1,d1
            move.b  #0,MFP_TACR.w           ; stop timer
            move.b  #$ff,MFP_TADR.w
loop1:      cmp.b   #$ff,MFP_TADR.w
            nop
            bne.s   loop1
            move.b  #6,MFP_TACR.w           ; start timer
loop2:      addq.l  #1,d0
            REPT    9
            divu.w  d1,d2
            ENDM
            cmp.b   #21,MFP_TADR.w
            bcc     loop2

            lsr.l   #3,d0
            bra     ret


detect_040: move.l  a1,sp
            move.w  #0,cpu_type             ; Default is 68LC040

            lea     detect_040b(pc),a0
            move.l  a0,$2C.w		    ; Catch LineF trap
            nop
            fnop
            nop
            move.w  #1,cpu_type             ; we have a 68040
                        
detect_040b:move.l  a1,sp

            moveq   #0,d0
            move.l  #4711,d2
            move.l  #10,d1
            move.b  #0,MFP_TACR.w           ; stop timer
            move.b  #$ff,MFP_TADR.w
loop3:      cmp.b   #$ff,MFP_TADR.w
            nop
            bne.s   loop3
            move.b  #6,MFP_TACR.w           ; start timer
loop4:      addq.l  #1,d0
            REPT    36
            divu    d1,d2
            ENDM
            cmp.b   #13,MFP_TADR.w
            bcc     loop4

ret:        move.b  #0,MFP_TACR.w           ; stop timer
            move.w  (sp)+,sr
            addq    #5,d0
            rts

cpu_strtab:
            dc.l    cpu_str0
            dc.l    cpu_str1
            dc.l    cpu_str2
            dc.l    cpu_str3

cpu_str0:
            dc.b    "68LC040",0
cpu_str1:
            dc.b    "68040",0
cpu_str2:
            dc.b    "68LC060",0
cpu_str3:
            dc.b    "68060",0

; CPU-Typ:
; 0 = 68LC040
; 1 = 68040
; 2 = 68LC060
; 3 = 68060
            BSS
cpu_type:
            ds.w    1
            END

