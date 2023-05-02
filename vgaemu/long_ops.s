;****************************************************************************
; $Id: long_ops.s,v 1.3 2003/12/28 22:14:15 rincewind Exp $
;****************************************************************************
; $Log: long_ops.s,v $
; Revision 1.3  2003/12/28 22:14:15  rincewind
; - fix CVS headers
;
;****************************************************************************
	
            INCLUDE     "X86_POPS.INC"

;***************************************************************
; rcl_long
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L rol D1.L
;   changed:
;***************************************************************
rcl_long:   CARRY_TO_X
            MOVE.L  D0,D2                   ; D2 = d sichern
            AND.B   #$1F,D1                 ; modulo 31
            AND.B   #$FC,D6                 ; CF und OV l”schen
            ROXL.L  D1,D0
            BCC.S   .NoCarry
            OR.B    #$1,D6                  ; Carry setzen
.NoCarry:   CMP.B   #1,D1                   ; Over testen ?
            BNE.S   .NoOver
            EOR.L   D0,D2                   ; Oberstes Bit XORen
            BPL.S   .NoOver                 ; Null, kein Over
            OR.B    #2,D6                   ; Overflow setzen
.NoOver:    RTS

;***************************************************************
; rcr_long
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L rcr D1.L
;   changed:
;***************************************************************
rcr_long:   CARRY_TO_X
            MOVE.L  D0,D2                   ; D2 = d sichern
            AND.B   #$1F,D1                 ; modulo 31
            AND.B   #$FC,D6                 ; CF und OV l”schen
            ROXR.L  D1,D0
            BCC.S   .NoCarry
            OR.B    #$1,D6                  ; Carry setzen
.NoCarry:   CMP.B   #1,D1                   ; Over testen ?
            BNE.S   .NoOver
            EOR.L   D0,D2                   ; Oberstes Bit XORen
            BPL.S   .NoOver                 ; Null, kein Over
            OR.B    #2,D6                   ; Overflow setzen
.NoOver:    RTS

;***************************************************************
; rol_long
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L rol D1.L
;   changed:
;***************************************************************
rol_long:   MOVE.L  D0,D2                   ; D2 = d sichern
            AND.B   #$1F,D1                 ; modulo 31
            AND.B   #$FC,D6                 ; CF und OV l”schen
            ROL.L   D1,D0
            BCC.S   .NoCarry
            OR.B    #$1,D6                  ; Carry setzen
.NoCarry:   CMP.B   #1,D1                   ; Over testen ?
            BNE.S   .NoOver
            EOR.L   D0,D2                   ; Oberstes Bit XORen
            BPL.S   .NoOver                 ; Null, kein Over
            OR.B    #2,D6                   ; Overflow setzen
.NoOver:    RTS

;***************************************************************
; ror_long
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L ror D1.L
;   changed:
;***************************************************************
ror_long:   MOVE.L  D0,D2                   ; D2 = d sichern
            AND.B   #$1F,D1                 ; modulo 31
            AND.B   #$FC,D6                 ; CF und OV l”schen
            ROR.L   D1,D0
            BCC.S   .NoCarry
            OR.B    #$1,D6                  ; Carry setzen
.NoCarry:   CMP.B   #1,D1                   ; Over testen ?
            BNE.S   .NoOver
            EOR.L   D0,D2                   ; Oberstes Bit XORen
            BPL.S   .NoOver                 ; Null, kein Over
            OR.B    #2,D6                   ; Overflow setzen
.NoOver:    RTS

;***************************************************************
; sar_long
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L sar D1.L
;   changed:
;***************************************************************
sar_long:   AND.B   #$1F,D1                 ; modulo 31
            ASR.L   D1,D0
            NORMAL_FLAGS D0
            RTS

;***************************************************************
; shl_long
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L shl D1.L
;   changed:
;***************************************************************
shl_long:   AND.B   #$1F,D1                 ; modulo 31
            ASL.L   D1,D0
            NORMAL_FLAGS D0
            RTS

;***************************************************************
; shr_long
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L shr D1.L
;   changed:
;***************************************************************
shr_long:   AND.B   #$1F,D1                 ; modulo 31
            LSR.L   D1,D0
            NORMAL_FLAGS D0
            RTS

;***************************************************************
; adc_long
;   entry:
;     D0.L - Op1
;     D1.L - Op2
;   exit:
;     D0.L - D0.L + D1.L + Carry
;   changed:
;***************************************************************
adc_long:   CARRY_TO_X
            MOVE.L  D0,D2                   ; D2 = d sichern
            ADDX.L  D1,D0                   ; D0 = res = D0 - D1
            CARRY   D1,D2,D0                ; Flags setzen
            RTS

;***************************************************************
; add_long
;   entry:
;     D0.L - Op1
;     D1.L - Op2
;   exit:
;     D0.L - D0.L + D1.L
;   changed:
;***************************************************************
add_long:   MOVE.L  D0,D2                   ; D2 = d sichern
            ADD.L   D1,D0                   ; D0 = res = D0 - D1
            CARRY   D1,D2,D0                ; Flags setzen
            RTS

;***************************************************************
; and_long
;   entry:
;     D0.L - Op1
;     D1.L - Op2
;   exit:
;     D0.L - D0.L & D1.L
;   changed:
;***************************************************************
and_long:   AND.L   D1,D0                   ; D0 = res = D0 - D1
            NORMAL_FLAGS D0                 ; Flags setzen
            RTS

;***************************************************************
; or_long
;   entry:
;     D0.L - Op1
;     D1.L - Op2
;   exit:
;     D0.L - D0.L | D1.L
;   changed:
;***************************************************************
or_long:    OR.L    D1,D0                   ; D0 = res = D0 - D1
            NORMAL_FLAGS D0                 ; Flags setzen
            RTS

;***************************************************************
; sbb_long
;   entry:
;     D0.L - Op1
;     D1.L - Op2
;   exit:
;     D0.L = D0.L - D1.L - Carry
;     D6.L = Flags
;   changed:
;     D2
;***************************************************************
sbb_long:   CARRY_TO_X
            MOVE.L  D0,D2                   ; D2 = d sichern
            SUBX.L  D1,D0                   ; D0 = res = D0 - D1
            BORROW_CARRY D1,D2,D0           ; Flags setzen
            RTS

;***************************************************************
; sub_long
;   entry:
;     D0.L - Op1
;     D1.L - Op2
;   exit:
;     D0.L = D0.L - D1.L
;     D6.L = Flags
;   changed:
;     D2
;***************************************************************
sub_long:   MOVE.L  D0,D2                   ; D2 = d sichern
            SUB.L   D1,D0                   ; D0 = res = D0 - D1
            BORROW_CARRY D1,D2,D0           ; Flags setzen
            RTS

;***************************************************************
; xor_long
;   entry:
;     D0.L - Op1
;     D1.L - Op2
;   exit:
;     D0.L - D0.L ^ D1.L
;   changed:
;***************************************************************
xor_long:   EOR.L   D1,D0                   ; D0 = res = D0 - D1
            NORMAL_FLAGS D0                 ; Flags setzen
            RTS

