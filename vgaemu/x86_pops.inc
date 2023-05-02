;****************************************************************************
; $Id: x86_pops.inc,v 1.3 2003/12/28 22:14:16 rincewind Exp $
;****************************************************************************
; $Log: x86_pops.inc,v $
; Revision 1.3  2003/12/28 22:14:16  rincewind
; - fix CVS headers
;
; Revision 1.2  2000/06/19 20:52:35  rincewind
; - misc cleanup
;****************************************************************************

MACRO       TEST_CARRY
            MOVEQ   #0,D0
            BTST.L  #0,D6                   ; Bit 0 ist Carry
            BEQ.S   .TC_ende
            MOVEQ   #1,D0
.TC_ende:
ENDM

MACRO       TEST_ZERO
            MOVEQ   #0,D0
            BTST.L  #2,D6                   ; Bit 2 ist Zero
            BEQ.S   .TZ_ende
            MOVEQ   #1,D0
.TZ_ende:
ENDM

;***************************************************************
; CARRY  berechnen
; src, res - unver„ndert
; dst      - ver„ndert
; D6       - Borrow Carry und Parity im Hi-Word
;          - Lo-Word Flags
;***************************************************************
MACRO       CARRY   src,dst,res
            MOVE.W  CCR,D6
            SWAP    D6
            MOVE.B  dst,D6
            AND.B   src,D6                  ; D6 = (d & s)
            OR.B    src,dst                 ; dst = (d | s)
            NOT.B   res
            AND.B   res,dst                 ; dst = ~res & (d | s)
            NOT.B   res                     ; res restaurieren
            OR.B    dst,D6                  ; D6 = BC
            LSL.W   #8,D6
            MOVE.B  res,D6
            SWAP    D6
ENDM

;***************************************************************
; NORMAL_FLAGS berechnen
; res      - unver„ndert
; D6       - Parity im Hi-Word
;          - Lo-Word Flags
;***************************************************************
MACRO       NORMAL_FLAGS res
            MOVE.W  CCR,D6
            SWAP    D6
            MOVE.B  res,D6
            SWAP    D6
ENDM

;***************************************************************
; BORROW_CARRY  berechnen
; src, res - unver„ndert
; dst      - ver„ndert
; D6       - Borrow Carry und Parity im Hi-Word
;          - Lo-Word Flags
;***************************************************************
MACRO       BORROW_CARRY src,dst,res
            MOVE.W  CCR,D6
            SWAP    D6
            NOT.B   dst                     ; ~d
            MOVE.B  dst,D6
            AND.B   src,D6                  ; D6 = (~d & s)
            OR.B    src,dst                 ; dst = (~d | s)
            AND.B   res,dst                 ; dst = res & (~d | s)
            OR.B    dst,D6                  ; D6 = BC
            LSL.W   #8,D6
            MOVE.B  res,D6
            SWAP    D6
ENDM

;***************************************************************
; X-Flag wie Carry setzen
; D6 - Bis auf X-Flag zerst”rt
;***************************************************************
MACRO       CARRY_TO_X
            LSL.B   #4,D6                   ; Carry an X Schieben
            AND.B   #$10,D6                 ; Andere Bits l”schen ?
            MOVE.W  D6,CCR
ENDM

