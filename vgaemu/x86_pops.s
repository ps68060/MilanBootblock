;****************************************************************************
; $Id: x86_pops.s,v 1.3 2003/12/28 22:14:16 rincewind Exp $
;****************************************************************************
; $Log: x86_pops.s,v $
; Revision 1.3  2003/12/28 22:14:16  rincewind
; - fix CVS headers
;
; Revision 1.2  2000/06/19 20:52:35  rincewind
; - misc cleanup
;****************************************************************************

            IMPORT  TestZeroFlag
            IMPORT  TestCarryFlag
            IMPORT  sys

            XREF    asm_inb
            XREF    asm_inw
            XREF    asm_inl
            XREF    asm_outb
            XREF    asm_outw
            XREF    asm_outl

; Externals aus X86_DEC.S
            XREF    asm_rdb
            XREF    asm_rdw
            XREF    asm_wrb
            XREF    asm_wrw
            XREF    asm_rdl
            XREF    asm_wrl
            XREF    GetOffsetSeg
            XREF    sub_long                ; aus X86_OP32 reimportieren

            INCLUDE "X86_REGS.INC"

            TEXT

            XDEF    FlagsToPC
            XDEF    FlagsFromPC
            XDEF    aam_word
            XDEF    aad_word
            XDEF    adc_byte
            XDEF    adc_word
            XDEF    add_byte
            XDEF    add_word
            XDEF    and_byte
            XDEF    and_word
            XDEF    dec_byte
            XDEF    dec_word
            XDEF    dec_long
            XDEF    div_byte
            XDEF    div_word
;           XDEF    div_long
            XDEF    idiv_byte
            XDEF    idiv_word
;           XDEF    idiv_long
            XDEF    imul_byte
            XDEF    imul_word
;           XDEF    imul_long
            XDEF    inc_byte
            XDEF    inc_word
            XDEF    inc_long
            XDEF    mul_byte
            XDEF    mul_word
;           XDEF    mul_long
            XDEF    neg_byte
            XDEF    neg_word
            XDEF    neg_long
            XDEF    or_byte
            XDEF    or_word
            XDEF    rcl_byte
            XDEF    rcl_word
            XDEF    rcr_byte
            XDEF    rcr_word
            XDEF    rol_byte
            XDEF    rol_word
            XDEF    ror_byte
            XDEF    ror_word
            XDEF    sbb_byte
            XDEF    sbb_word
            XDEF    sar_byte
            XDEF    sar_word
            XDEF    shl_byte
            XDEF    shl_word
            XDEF    shr_byte
            XDEF    shr_word
            XDEF    sub_byte
            XDEF    sub_word
            XDEF    xor_byte
            XDEF    xor_word

            XDEF    movs
            XDEF    cmps
            XDEF    stos
            XDEF    lods
            XDEF    scas
            XDEF    ins
            XDEF    outs

            INCLUDE "X86_POPS.INC"          ; Macro Definitionen

            XDEF    TestTeroFlag
TestZeroFlag:
            TEST_ZERO
            RTS

            XDEF    ParityTab
ParityTab:  DC.B    $96,$69,$69,$96,$69,$96,$96,$69
            DC.B    $69,$96,$96,$69,$96,$69,$69,$96
            DC.B    $69,$96,$96,$69,$96,$69,$69,$96
            DC.B    $96,$69,$69,$96,$69,$96,$96,$69

;***************************************************************
;  D6 - FlagReg
;    Bit 31-24 - CC fÅr Nibble Carry
;           27 - Nibble Carry
;    Bit 23-16 - Res. Byte fÅr Parity
;    Bit 15- 8 - 0x00 fÅr gÅltig
;                0xFF fÅr ungÅltig
;    Bit  7- 0 - Condition Codes
;            0 - Carry Flag
;            1 - Overflow Flag
;            2 - Zero Flag
;            3 - Sign Flag
;            4 - Aux Flag
;  PC- Flags:
;    LoFlags
;      Bit 0   - Carry Flag
;      Bit 2   - Parity Flag
;      Bit 4   - Aux (Nibble Carry) Flag
;      Bit 6   - Zero Flag
;      Bit 7   - Sign Flag
;    HiFlags
;      Bit 1   - Interrupt Flag
;      Bit 2   - Dir Flag
;      Bit 3   - Overflow Flag
;
; ! D0 zerstîrt
;
;***************************************************************
FlagsToPC:  MOVE.W  #0,Flags(A6)            ; Flags rÅcksetzen
            MOVE    D6,CCR
            BNE.S   .FTP_NoZero
            BSET.B  #6,LoFlags(A6)
.FTP_NoZero: BPL.S  .FTP_NoSign
            BSET.B  #7,LoFlags(A6)
.FTP_NoSign: BCC.S  .FTP_NoCarry
            BSET.B  #0,LoFlags(A6)
.FTP_NoCarry: BVC.S .FTP_NoOver
            BSET.B  #3,HiFlags(A6)
.FTP_NoOver: BTST.L #27,D6
            BEQ.S   .FTP_NoAux
            BSET.B  #4,LoFlags(A6)
.FTP_NoAux: MOVE.L  D6,D0
            SWAP    D0
            AND.L   #$FF,D0
            BFTST   (ParityTab,PC){D0:1}
            BEQ.S   .FTP_NoParity
            BSET.B  #2,LoFlags(A6)
.FTP_NoParity: RTS

FlagsFromPC: MOVEQ  #0,D6                   ; Flags lîschen
            BTST.B  #2,LoFlags(A6)          ;
            BNE.S   .FFP_IsParity
            MOVE.B  #$01,D6
.FFP_IsParity:
            BTST.B  #4,LoFlags(A6)

            BEQ.S   .FFP_NoAux
            OR.W    #$0800,D6
.FFP_NoAux: SWAP    D6                      ; Ab nach oben
            BTST.B  #3,HiFlags(A6)
            BEQ.S   .FFP_NoOver
            OR.B    #$02,D6
.FFP_NoOver: BTST.B #0,LoFlags(A6)
            BEQ.S   .FFP_NoCarry
            OR.B    #$01,D6
.FFP_NoCarry: BTST.B #7,LoFlags(A6)
            BEQ.S   .FFP_NoSign
            OR.B    #$08,D6
.FFP_NoSign: BTST.B #6,LoFlags(A6)
            BEQ.S   .FFP_NoZero
            OR.B    #$04,D6
.FFP_NoZero: RTS

;***************************************************************
; adc_byte
;   entry:
;     D0.B - Op1
;     D1.B - Op2
;   exit:
;     D0.B - D0.B + D1.B + Carry
;   changed:
;***************************************************************
adc_byte:   CARRY_TO_X
            MOVE.B  D0,D2                   ; D2 = d sichern
            ADDX.B  D1,D0                   ; D0 = res = D0 - D1
            CARRY   D1,D2,D0                ; Flags setzen
            RTS

;***************************************************************
; adc_word
;   entry:
;     D0.W - Op1
;     D1.W - Op2
;   exit:
;     D0.W - D0.W + D1.W + Carry
;   changed:
;***************************************************************
adc_word:   CARRY_TO_X
            MOVE.W  D0,D2                   ; D2 = d sichern
            ADDX.W  D1,D0                   ; D0 = res = D0 - D1
            CARRY   D1,D2,D0                ; Flags setzen
            RTS

;***************************************************************
; add_byte
;   entry:
;     D0.B - Op1
;     D1.B - Op2
;   exit:
;     D0.B - D0.B + D1.B
;   changed:
;***************************************************************
add_byte:   MOVE.B  D0,D2                   ; D2 = d sichern
            ADD.B   D1,D0                   ; D0 = res = D0 - D1
            CARRY   D1,D2,D0                ; Flags setzen
            RTS

;***************************************************************
; add_word
;   entry:
;     D0.W - Op1
;     D1.W - Op2
;   exit:
;     D0.W - D0.W + D1.W
;   changed:
;***************************************************************
add_word:   MOVE.W  D0,D2                   ; D2 = d sichern
            ADD.W   D1,D0                   ; D0 = res = D0 - D1
            CARRY   D1,D2,D0                ; Flags setzen
            RTS

;***************************************************************
; and_byte
;   entry:
;     D0.B - Op1
;     D1.B - Op2
;   exit:
;     D0.B - D0.B & D1.B
;   changed:
;***************************************************************
and_byte:   AND.B   D1,D0                   ; D0 = res = D0 - D1
            NORMAL_FLAGS D0                 ; Flags setzen
            RTS

;***************************************************************
; and_word
;   entry:
;     D0.W - Op1
;     D1.W - Op2
;   exit:
;     D0.W - D0.W & D1.W
;   changed:
;***************************************************************
and_word:   AND.W   D1,D0                   ; D0 = res = D0 - D1
            NORMAL_FLAGS D0                 ; Flags setzen
            RTS

;***************************************************************
; dec_byte
;   entry:
;     D0.B - Op1
;   exit:
;     D0.B = D0.B - 1
;     D6.L = Flags
;   changed:
;     D2
;***************************************************************
dec_byte:   MOVE.B  D0,D1                   ; D1 = d sichern
            MOVE.B  D6,D2                   ; Carry sichern
            SUBQ.B  #1,D0                   ; D0 = res = D0 - 1
            BORROW_CARRY #1,D1,D0           ; Flags setzen
            AND.B   #1,D2                   ; Carry maskieren
            AND.B   #$FE,D6                 ; Neues Carry Flag lîschen
            OR.B    D2,D6                   ; altes Flag einblenden
            RTS

;***************************************************************
; dec_word
;   entry:
;     D0.W - Op1
;   exit:
;     D0.W = D0.W - 1
;     D6.L = Flags
;   changed:
;     D2
;***************************************************************
dec_word:   MOVE.W  D0,D1                   ; D1 = d sichern
            MOVE.B  D6,D2                   ; Carry sichern
            SUBQ.W  #1,D0                   ; D0 = res = D0 - 1
            BORROW_CARRY #1,D1,D0           ; Flags setzen
            AND.B   #1,D2                   ; Carry maskieren
            AND.B   #$FE,D6                 ; Neues Carry Flag lîschen
            OR.B    D2,D6                   ; altes Flag einblenden
            RTS

;***************************************************************
; dec_long
;   entry:
;     D0.L - Op1
;   exit:
;     D0.L = D0.L - 1
;     D6.L = Flags
;   changed:
;     D2
;***************************************************************
dec_long:   MOVE.L  D0,D1                   ; D1 = d sichern
            MOVE.B  D6,D2                   ; Carry sichern
            SUBQ.L  #1,D0                   ; D0 = res = D0 - 1
            BORROW_CARRY #1,D1,D0           ; Flags setzen
            AND.B   #1,D2                   ; Carry maskieren
            AND.B   #$FE,D6                 ; Neues Carry Flag lîschen
            OR.B    D2,D6                   ; altes Flag einblenden
            RTS

;***************************************************************
; div_byte
;   entry:
;     D0.B - Op1
;   exit:
;     AL = AX / D0.B
;     AH = Rest
;     D6.L = Flags
;   changed:
;     D1
;***************************************************************
div_byte:   MOVEQ   #0,D6                   ; Flags lîschen
            AND.W   #$00FF,D0               ; obere Bits lîschen
            BEQ.S   raise_INT0              ; durch Null dÅrfen wir nicht teilen
            MOVEQ   #0,D1                   ; 68k kann nur 32 Bit
            MOVE.W  AX(A6),D1               ; 2. Quelloperand
            DIVU    D0,D1
            MOVE.B  D1,AL(A6)
            SWAP    D1
            MOVE.B  D1,AH(A6)
            SWAP    D1
            AND.W   #$FF00,D1               ; Overflow zu Fuû
            BNE     raise_INT0
.NoOver:    RTS

;***************************************************************
; div_word
;   entry:
;     D0.W - Op1
;   exit:
;     AX = DX:AX /D0.W
;     DX = Rest
;     D6.L = Flags
;   changed:
;     D1
;***************************************************************
div_word:   MOVEQ   #0,D6                   ; Flags lîschen
            TST.W   D0
            BEQ.S   raise_INT0              ; durch Null dÅrfen wir nicht teilen
            MOVE.W  DX(A6),D1               ; 2. Quelloperand
            SWAP    D1
            MOVE.W  AX(A6),D1               ; 2. Quelloperand
            DIVU    D0,D1
            BVS     raise_INT0
            MOVE.W  D1,AX(A6)
            SWAP    D1
            MOVE.W  D1,DX(A6)
.NoOver:    RTS

;***************************************************************
; Special fÅr die Divisionsbefehle
; wird bei Divisor = 0 oder BereichsÅberschreitung ausgelîst
;***************************************************************
raise_INT0: CLR.B   intno(A6)               ; INT 0
            OR.W    #1,intr(A6)             ; und auslîsen
            RTS

;***************************************************************
; idiv_byte
;   entry:
;     D0.B - Op1
;   exit:
;     AL = AX / D0.B
;     AH = Rest
;     D6.L = Flags
;   changed:
;     D1
;***************************************************************
idiv_byte:  MOVEQ   #0,D6                   ; Flags lîschen
            EXT.W   D0                      ; Vorzeichen nicht vergessen
            BEQ.S   raise_INT0              ; durch Null dÅrfen wir nicht teilen
            MOVE.W  AX(A6),D1               ; 2. Quelloperand
            EXT.L   D1                      ; auf 32 Bit
            DIVS    D0,D1
            MOVE.B  D1,AL(A6)
            SWAP    D1
            MOVE.B  D1,AH(A6)
            SWAP    D1
            AND.W   #$FF00,D1               ; Overflow zu Fuû
            BEQ.S   .NoOver
            CMP.W   #$FF00,D1
            BNE     raise_INT0
.NoOver:    RTS

;***************************************************************
; idiv_word
;   entry:
;     D0.W - Op1
;   exit:
;     AX = DX:AX /D0.W
;     DX = Rest
;     D6.L = Flags
;   changed:
;     D1
;***************************************************************
idiv_word:  MOVEQ   #0,D6                   ; Flags lîschen
            TST.W   D0
            BEQ.S   raise_INT0              ; durch Null dÅrfen wir nicht teilen
            MOVE.W  DX(A6),D1               ; 2. Quelloperand
            SWAP    D1
            MOVE.W  AX(A6),D1               ; 2. Quelloperand
            DIVS    D0,D1
            BVS     raise_INT0
            MOVE.W  D1,AX(A6)
            SWAP    D1
            MOVE.W  D1,DX(A6)
.NoOver:    RTS

;***************************************************************
; imul_byte
;   entry:
;     D0.B - Op1
;   exit:
;     AX = AL * D0
;     D6.L = Flags
;   changed:
;     D1
;***************************************************************
imul_byte:  MOVEQ   #0,D6                   ; Flags lîschen
            MOVE.B  AL(A6),D1               ; 2. Quelloperand
            EXT.W   D0                      ; Vorzeichen nicht vergessen
            EXT.W   D1
            MULS    D1,D0
            MOVE.W  D0,AX(A6)
            AND.W   #$FF00,D0
            BEQ.S   .NoCarry
            CMP.W   #$FF00,D0
            BEQ.S   .NoCarry
            OR.B    #$3,D6                  ; Carry + Overflow
.NoCarry:   RTS

;***************************************************************
; imul_word
;   entry:
;     D0.W - Op1
;   exit:
;     DX:AX = AX * D0
;     D6.L = Flags
;   changed:
;     D1
;***************************************************************
imul_word:  MOVEQ   #0,D6                   ; Flags lîschen
            MOVE.W  AX(A6),D1               ; 2. Quelloperand
            MULS    D1,D0
            MOVE.W  D0,AX(A6)
            SWAP    D0
            MOVE.W  D0,DX(A6)
            BEQ.S   .NoCarry
            CMP.W   #$FFFF,D0
            BEQ.S   .NoCarry
            OR.B    #$3,D6                  ; Carry + Overflow
.NoCarry:   RTS

;***************************************************************
; inc_byte
;   entry:
;     D0.B - Op1
;   exit:
;     D0.B = D0.B + 1
;     D6.L = Flags
;   changed:
;     D2
;***************************************************************
inc_byte:   MOVE.B  D0,D1                   ; D1 = d sichern
            MOVE.B  D6,D2                   ; Carry sichern
            ADDQ.B  #1,D0                   ; D0 = res = D0 + 1
            CARRY   #1,D1,D0                ; Flags setzen
            AND.B   #1,D2                   ; Carry maskieren
            AND.B   #$FE,D6                 ; Neues Carry Flag lîschen
            OR.B    D2,D6                   ; altes Flag einblenden
            RTS

;***************************************************************
; inc_word
;   entry:
;     D0.W - Op1
;   exit:
;     D0.W = D0.W + 1
;     D6.L = Flags
;   changed:
;     D2
;***************************************************************
inc_word:   MOVE.W  D0,D1                   ; D1 = d sichern
            MOVE.B  D6,D2                   ; Carry sichern
            ADDQ.W  #1,D0                   ; D0 = res = D0 + 1
            CARRY   #1,D1,D0                ; Flags setzen
            AND.B   #1,D2                   ; Carry maskieren
            AND.B   #$FE,D6                 ; Neues Carry Flag lîschen
            OR.B    D2,D6                   ; altes Flag einblenden
            RTS

;***************************************************************
; inc_long
;   entry:
;     D0.L - Op1
;   exit:
;     D0.L = D0.L + 1
;     D6.L = Flags
;   changed:
;     D2
;***************************************************************
inc_long:   MOVE.L  D0,D1                   ; D1 = d sichern
            MOVE.B  D6,D2                   ; Carry sichern
            ADDQ.L  #1,D0                   ; D0 = res = D0 +- 1
            CARRY   #1,D1,D0                ; Flags setzen
            AND.B   #1,D2                   ; Carry maskieren
            AND.B   #$FE,D6                 ; Neues Carry Flag lîschen
            OR.B    D2,D6                   ; altes Flag einblenden
            RTS

;***************************************************************
; mul_byte
;   entry:
;     D0.B - Op1
;   exit:
;     AX = AL * D0
;     D6.L = Flags
;   changed:
;     D1
;***************************************************************
mul_byte:   MOVEQ   #0,D6                   ; Flags lîschen
            MOVE.B  AL(A6),D1               ; 2. Quelloperand
            AND.W   #$00FF,D0
            AND.W   #$00FF,D1
            MULU    D1,D0
            MOVE.W  D0,AX(A6)
            AND.W   #$FF00,D0
            BEQ.S   .NoCarry
            CMP.W   #$FF00,D0
            BEQ.S   .NoCarry
            OR.B    #$3,D6                  ; Carry + Overflow
.NoCarry:   RTS

;***************************************************************
; mul_word
;   entry:
;     D0.W - Op1
;   exit:
;     D0.W = D0.W + 1
;     D6.L = Flags
;   changed:
;     D1
;***************************************************************
mul_word:   MOVEQ   #0,D6                   ; Flags lîschen
            MOVE.W  AX(A6),D1               ; 2. Quelloperand
            MULU    D1,D0
            MOVE.W  D0,AX(A6)
            SWAP    D0
            MOVE.W  D0,DX(A6)
            BEQ.S   .NoCarry
            CMP.W   #$FFFF,D0
            BEQ.S   .NoCarry
            OR.B    #$3,D6                  ; Carry + Overflow
.NoCarry:   RTS

;***************************************************************
; neg_byte
;   entry:
;     D0.B - Op1
;     D1.B - Op2
;   exit:
;     D0.B = -D0.B
;     D6.L = Flags
;   changed:
;     D2
;***************************************************************
neg_byte:   MOVE.B  D0,D2                   ; D2 = d sichern
            NEG.B   D0                      ; D0 = res = D0 - D1
;                  BORROW_CARRY D2,#0,D0      ; Flags setzen
; Ist Spezialfall:
            MOVE.W  CCR,D6
            SWAP    D6
            MOVE.B  D2,D6                   ; D6 = s
            OR.B    D0,D6                   ; D6 = BC = res | s
            LSL.W   #8,D6
            MOVE.B  D0,D6
            SWAP    D6
            RTS

;***************************************************************
; neg_word
;   entry:
;     D0.W - Op1
;     D1.W - Op2
;   exit:
;     D0.W = -D0.W
;     D6.L = Flags
;   changed:
;     D2
;***************************************************************
neg_word:   MOVE.W  D0,D2                   ; D2 = d sichern
            NEG.W   D0                      ; D0 = res = D0 - D1
;                  BORROW_CARRY D2,#0,D0      ; Flags setzen
; Ist Spezialfall:
            MOVE.W  CCR,D6
            SWAP    D6
            MOVE.B  D2,D6                   ; D6 = s
            OR.B    D0,D6                   ; D6 = BC = res | s
            LSL.W   #8,D6
            MOVE.B  D0,D6
            SWAP    D6
            RTS

;***************************************************************
; neg_long
;   entry:
;     D0.L - Op1
;     D1.L - Op2
;   exit:
;     D0.L = -D0.W
;     D6.L = Flags
;   changed:
;     D2
;***************************************************************
neg_long:   MOVE.L  D0,D2                   ; D2 = d sichern
            NEG.L   D0                      ; D0 = res = D0 - D1
;                  BORROW_CARRY D2,#0,D0      ; Flags setzen
; Ist Spezialfall:
            MOVE.W  CCR,D6
            SWAP    D6
            MOVE.B  D2,D6                   ; D6 = s
            OR.B    D0,D6                   ; D6 = BC = res | s
            LSL.W   #8,D6
            MOVE.B  D0,D6
            SWAP    D6
            RTS

;***************************************************************
; or_byte
;   entry:
;     D0.B - Op1
;     D1.B - Op2
;   exit:
;     D0.B - D0.B | D1.B
;   changed:
;***************************************************************
or_byte:    OR.B    D1,D0                   ; D0 = res = D0 - D1
            NORMAL_FLAGS D0                 ; Flags setzen
            RTS

;***************************************************************
; or_word
;   entry:
;     D0.W - Op1
;     D1.W - Op2
;   exit:
;     D0.W - D0.W | D1.W
;   changed:
;***************************************************************
or_word:    OR.W    D1,D0                   ; D0 = res = D0 - D1
            NORMAL_FLAGS D0                 ; Flags setzen
            RTS

;***************************************************************
; rcl_byte
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L rcl D1.L
;   changed:
;***************************************************************
rcl_byte:   CARRY_TO_X
            MOVE.B  D0,D2                   ; D2 = d sichern
            AND.B   #$1F,D1                 ; modulo 31
            AND.B   #$FC,D6                 ; CF und OV lîschen
            ROXL.B  D1,D0
            BCC.S   .NoCarry
            OR.B    #$1,D6                  ; Carry setzen
.NoCarry:   CMP.B   #1,D1                   ; Over testen ?
            BNE.S   .NoOver
            EOR.B   D0,D2                   ; Oberstes Bit XORen
            BPL.S   .NoOver                 ; Null, kein Over
            OR.B    #2,D6                   ; Overflow setzen
.NoOver:    RTS

;***************************************************************
; rcl_word
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L rol D1.L
;   changed:
;***************************************************************
rcl_word:   CARRY_TO_X
            MOVE.W  D0,D2                   ; D2 = d sichern
            AND.B   #$1F,D1                 ; modulo 31
            AND.B   #$FC,D6                 ; CF und OV lîschen
            ROXL.W  D1,D0
            BCC.S   .NoCarry
            OR.B    #$1,D6                  ; Carry setzen
.NoCarry:   CMP.B   #1,D1                   ; Over testen ?
            BNE.S   .NoOver
            EOR.W   D0,D2                   ; Oberstes Bit XORen
            BPL.S   .NoOver                 ; Null, kein Over
            OR.B    #2,D6                   ; Overflow setzen
.NoOver:    RTS

;***************************************************************
; rcr_byte
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L rcr D1.L
;   changed:
;***************************************************************
rcr_byte:   CARRY_TO_X
            MOVE.B  D0,D2                   ; D2 = d sichern
            AND.B   #$1F,D1                 ; modulo 31
            AND.B   #$FC,D6                 ; CF und OV lîschen
            ROXR.B  D1,D0
            BCC.S   .NoCarry
            OR.B    #$1,D6                  ; Carry setzen
.NoCarry:   CMP.B   #1,D1                   ; Over testen ?
            BNE.S   .NoOver
            EOR.B   D0,D2                   ; Oberstes Bit XORen
            BPL.S   .NoOver                 ; Null, kein Over
            OR.B    #2,D6                   ; Overflow setzen
.NoOver:    RTS

;***************************************************************
; rcr_word
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L rcr D1.L
;   changed:
;***************************************************************
rcr_word:   CARRY_TO_X
            MOVE.W  D0,D2                   ; D2 = d sichern
            AND.B   #$1F,D1                 ; modulo 31
            AND.B   #$FC,D6                 ; CF und OV lîschen
            ROXR.W  D1,D0
            BCC.S   .NoCarry
            OR.B    #$1,D6                  ; Carry setzen
.NoCarry:   CMP.B   #1,D1                   ; Over testen ?
            BNE.S   .NoOver
            EOR.W   D0,D2                   ; Oberstes Bit XORen
            BPL.S   .NoOver                 ; Null, kein Over
            OR.B    #2,D6                   ; Overflow setzen
.NoOver:    RTS

;***************************************************************
; rol_byte
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L rol D1.L
;   changed:
;***************************************************************
rol_byte:   MOVE.B  D0,D2                   ; D2 = d sichern
            AND.B   #$1F,D1                 ; modulo 31
            AND.B   #$FC,D6                 ; CF und OV lîschen
            ROL.B   D1,D0
            BCC.S   .NoCarry
            OR.B    #$1,D6                  ; Carry setzen
.NoCarry:   CMP.B   #1,D1                   ; Over testen ?
            BNE.S   .NoOver
            EOR.B   D0,D2                   ; Oberstes Bit XORen
            BPL.S   .NoOver                 ; Null, kein Over
            OR.B    #2,D6                   ; Overflow setzen
.NoOver:    RTS

;***************************************************************
; rol_word
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L rol D1.L
;   changed:
;***************************************************************
rol_word:   MOVE.W  D0,D2                   ; D2 = d sichern
            AND.B   #$1F,D1                 ; modulo 31
            AND.B   #$FC,D6                 ; CF und OV lîschen
            ROL.W   D1,D0
            BCC.S   .NoCarry
            OR.B    #$1,D6                  ; Carry setzen
.NoCarry:   CMP.B   #1,D1                   ; Over testen ?
            BNE.S   .NoOver
            EOR.W   D0,D2                   ; Oberstes Bit XORen
            BPL.S   .NoOver                 ; Null, kein Over
            OR.B    #2,D6                   ; Overflow setzen
.NoOver:    RTS

;***************************************************************
; ror_byte
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L ror D1.L
;   changed:
;***************************************************************
ror_byte:   MOVE.B  D0,D2                   ; D2 = d sichern
            AND.B   #$1F,D1                 ; modulo 31
            AND.B   #$FC,D6                 ; CF und OV lîschen
            ROR.B   D1,D0
            BCC.S   .NoCarry
            OR.B    #$1,D6                  ; Carry setzen
.NoCarry:   CMP.B   #1,D1                   ; Over testen ?
            BNE.S   .NoOver
            EOR.B   D0,D2                   ; Oberstes Bit XORen
            BPL.S   .NoOver                 ; Null, kein Over
            OR.B    #2,D6                   ; Overflow setzen
.NoOver:    RTS

;***************************************************************
; ror_word
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L ror D1.L
;   changed:
;***************************************************************
ror_word:   MOVE.W  D0,D2                   ; D2 = d sichern
            AND.B   #$1F,D1                 ; modulo 31
            AND.B   #$FC,D6                 ; CF und OV lîschen
            ROR.W   D1,D0
            BCC.S   .NoCarry
            OR.B    #$1,D6                  ; Carry setzen
.NoCarry:   CMP.B   #1,D1                   ; Over testen ?
            BNE.S   .NoOver
            EOR.W   D0,D2                   ; Oberstes Bit XORen
            BPL.S   .NoOver                 ; Null, kein Over
            OR.B    #2,D6                   ; Overflow setzen
.NoOver:    RTS

;***************************************************************
; sar_byte
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L sar D1.L
;   changed:
;***************************************************************
sar_byte:   AND.B   #$1F,D1                 ; modulo 31
            ASR.B   D1,D0
            NORMAL_FLAGS D0
            RTS

;***************************************************************
; sar_word
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L sar D1.L
;   changed:
;***************************************************************
sar_word:   AND.B   #$1F,D1                 ; modulo 31
            ASR.W   D1,D0
            NORMAL_FLAGS D0
            RTS

;***************************************************************
; sbb_byte
;   entry:
;     D0.B - Op1
;     D1.B - Op2
;   exit:
;     D0.B = D0.B - D1.B - Carry
;     D6.L = Flags
;   changed:
;     D2
;***************************************************************
sbb_byte:   CARRY_TO_X
            MOVE.B  D0,D2                   ; D2 = d sichern
            SUBX.B  D1,D0                   ; D0 = res = D0 - D1
            BORROW_CARRY D1,D2,D0           ; Flags setzen
            RTS

;***************************************************************
; sbb_word
;   entry:
;     D0.W - Op1
;     D1.W - Op2
;   exit:
;     D0.W = D0.W - D1.W - Carry
;     D6.L = Flags
;   changed:
;     D2
;***************************************************************
sbb_word:   CARRY_TO_X
            MOVE.W  D0,D2                   ; D2 = d sichern
            SUBX.W  D1,D0                   ; D0 = res = D0 - D1
            BORROW_CARRY D1,D2,D0           ; Flags setzen
            RTS

;***************************************************************
; shl_byte
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L shl D1.L
;   changed:
;***************************************************************
shl_byte:   AND.B   #$1F,D1                 ; modulo 31
            ASL.B   D1,D0
            NORMAL_FLAGS D0
            RTS

;***************************************************************
; shl_word
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L shl D1.L
;   changed:
;***************************************************************
shl_word:   AND.B   #$1F,D1                 ; modulo 31
            ASL.W   D1,D0
            NORMAL_FLAGS D0
            RTS

;***************************************************************
; shr_byte
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L shr D1.L
;   changed:
;***************************************************************
shr_byte:   AND.B   #$1F,D1                 ; modulo 31
            LSR.B   D1,D0
            NORMAL_FLAGS D0
            RTS

;***************************************************************
; shr_word
;   entry:
;     D0.L - Op1
;     D1.L - count
;   exit:
;     D0.L - D0.L shr D1.L
;   changed:
;***************************************************************
shr_word:   AND.B   #$1F,D1                 ; modulo 31
            LSR.W   D1,D0
            NORMAL_FLAGS D0
            RTS

;***************************************************************
; sub_byte
;   entry:
;     D0.B - Op1
;     D1.B - Op2
;   exit:
;     D0.B = D0.B - D1.B
;     D6.L = Flags
;   changed:
;     D2
;***************************************************************
sub_byte:   MOVE.B  D0,D2                   ; D2 = d sichern
            SUB.B   D1,D0                   ; D0 = res = D0 - D1
            BORROW_CARRY D1,D2,D0           ; Flags setzen
            RTS

;***************************************************************
; sub_word
;   entry:
;     D0.W - Op1
;     D1.W - Op2
;   exit:
;     D0.W = D0.W - D1.W
;     D6.L = Flags
;   changed:
;     D2
;***************************************************************
sub_word:   MOVE.W  D0,D2                   ; D2 = d sichern
            SUB.W   D1,D0                   ; D0 = res = D0 - D1
            BORROW_CARRY D1,D2,D0           ; Flags setzen
            RTS

;***************************************************************
; xor_byte
;   entry:
;     D0.B - Op1
;     D1.B - Op2
;   exit:
;     D0.B - D0.B ^ D1.B
;   changed:
;***************************************************************
xor_byte:   EOR.B   D1,D0                   ; D0 = res = D0 - D1
            NORMAL_FLAGS D0                 ; Flags setzen
            RTS

;***************************************************************
; xor_word
;   entry:
;     D0.W - Op1
;     D1.W - Op2
;   exit:
;     D0.W - D0.W ^ D1.W
;   changed:
;***************************************************************
xor_word:   EOR.W   D1,D0                   ; D0 = res = D0 - D1
            NORMAL_FLAGS D0                 ; Flags setzen
            RTS

;***************************************************************
; movs
;***************************************************************
movs:       MOVE.L  D0,D4                   ; D4 = inc
            MOVE.W  D0,D2
            BTST.B  #2,HiFlags(A6)          ; DF testen
            BEQ.S   .DirUp
            NEG.L   D4                      ; invertieren
.DirUp:     BSR     GetOffsetSeg            ; A2 = Segment
            MOVEQ   #0,D1
            MOVE.W  SI(A6),D1
            ADD.L   D1,A2                   ; A2 = srcptr
            MOVE.L  ES(A6),A3
            MOVE.W  DI(A6),D1
            ADD.L   D1,A3                   ; A3 = destptr
            TST.W   REP(A6)                 ; REP ?
            BEQ     .NoRep
; REP
            MOVE.W  CX(A6),D3               ; D3 = count
            BEQ     .ende                   ; = 0, nichts tun
            SUBQ.W  #1,D3                   ; DBRA Korrektur
            SUBQ.W  #1,D2
            BNE.S   .NoRS1
; Byte Size
.RS1:       BSR     asm_rdb
            EXG.L   A2,A3
            BSR     asm_wrb
            EXG.L   A2,A3
            ADD.L   D4,A2
            ADD.L   D4,A3
            DBRA    D3,.RS1
            BRA     .Rende

.NoRS1:     SUBQ.W  #1,D2
            BNE.S   .RS4
; Word size
.RS2:       BSR     asm_rdw
            EXG.L   A2,A3
            BSR     asm_wrw
            EXG.L   A2,A3
            ADD.L   D4,A2
            ADD.L   D4,A3
            DBRA    D3,.RS2
            BRA     .Rende
; Long size
.RS4:       BSR     asm_rdl
            EXG.L   A2,A3
            BSR     asm_wrl
            EXG.L   A2,A3
            ADD.L   D4,A2
            ADD.L   D4,A3
            DBRA    D3,.RS4

; Register zurÅckschreiben
.Rende:     CLR.W   CX(A6)                  ; count
            CLR.W   REP(A6)
            SUB.L   D7,A2
            MOVE.W  A2,SI(A6)
            SUB.L   ES(A6),A3
            MOVE.W  A3,DI(A6)
.ende:      RTS

.NoRep:
            ADD.W   D4,SI(A6)
            ADD.W   D4,DI(A6)
            SUBQ.W  #1,D2
            BNE.S   .NoS1
; Byte Size
.S1:        BSR     asm_rdb
            MOVE.L  A3,A2
            BRA     asm_wrb

.NoS1:      SUBQ.W  #1,D2
            BNE.S   .S4
; Word size
.S2:        BSR     asm_rdw
            MOVE.L  A3,A2
            BRA     asm_wrw

.S4:        BSR     asm_rdl
            MOVE.L  A3,A2
            BRA     asm_wrl

;***************************************************************
; cmps
;***************************************************************
cmps:       MOVE.L  D0,D4                   ; D4 = inc
            MOVE.W  D0,D2
            BTST.B  #2,HiFlags(A6)          ; DF testen
            BEQ.S   .DirUp
            NEG.L   D4                      ; invertieren
.DirUp:     BSR     GetOffsetSeg            ; A2 = Segment
            MOVEQ   #0,D1
            MOVE.W  SI(A6),D1
            ADD.L   D1,A2                   ; A2 = srcptr
            MOVE.L  ES(A6),A3
            MOVE.W  DI(A6),D1
            ADD.L   D1,A3                   ; A3 = destptr
            TST.W   REP(A6)                 ; REP ?
            BEQ     .NoRep
; REP
            MOVE.W  CX(A6),D3               ; D3 = count
            BEQ     .ende                   ; = 0, nichts tun
            SUBQ.W  #1,D3                   ; DBRA Korrektur
            SUBQ.W  #1,D2
            BNE.S   .NoRS1
; Byte Size
.RS1:       EXG.L   A2,A3
            BSR     asm_rdb                 ; destbyte
            EXG.L   A2,A3
            MOVE.B  D0,D1                   ; nach D1
            BSR     asm_rdb                 ; srcbyte nach D0
            BSR     sub_byte
            ADD.L   D4,A2                   ; erst Pointer Ñndern
            ADD.L   D4,A3
            BSR     TestZeroFlag            ; Abbruch testen
            MOVE.W  REP(A6),D2
            EOR.W   D2,D0
            AND     #1,D0
            BNE     .Rende
            DBRA    D3,.RS1
            BRA     .Rende2

.NoRS1:     SUBQ.W  #1,D2
            BNE.S   .RS4
; Word Size
.RS2:       EXG.L   A2,A3
            BSR     asm_rdw                 ; destword
            EXG.L   A2,A3
            MOVE.W  D0,D1                   ; nach D1
            BSR     asm_rdw                 ; srcword nach D0
            BSR     sub_word
            ADD.L   D4,A2                   ; erst Pointer Ñndern
            ADD.L   D4,A3
            BSR     TestZeroFlag            ; Abbruch testen
            MOVE.W  REP(A6),D2
            EOR.W   D2,D0
            AND     #1,D0
            BNE     .Rende
            DBRA    D3,.RS2
            BRA     .Rende2

; Long size
.RS4:       EXG.L   A2,A3
            BSR     asm_rdl                 ; destlong
            EXG.L   A2,A3
            MOVE.L  D0,D1                   ; nach D1
            BSR     asm_rdl                 ; srclong nach D0
            BSR     sub_long
            ADD.L   D4,A2                   ; erst Pointer Ñndern
            ADD.L   D4,A3
            BSR     TestZeroFlag            ; Abbruch testen
            MOVE.W  REP(A6),D2
            EOR.W   D2,D0
            AND     #1,D0
            BNE     .Rende
            DBRA    D3,.RS4

; Register zurÅckschreiben
.Rende2:    MOVEQ   #0,D3                   ; Ende ohne Abbruch
.Rende:     MOVE.W  D3,CX(A6)               ; count
            CLR.W   REP(A6)
            SUB.L   D7,A2
            MOVE.W  A2,SI(A6)
            SUB.L   ES(A6),A3
            MOVE.W  A3,DI(A6)
.ende:      RTS

.NoRep:
            ADD.W   D4,SI(A6)
            ADD.W   D4,DI(A6)
            SUBQ.W  #1,D2
            BNE.S   .NoS1
; Byte Size
.S1:        EXG.L   A2,A3
            BSR     asm_rdb
            MOVE.B  D0,D1                   ; nach D1
            MOVE.L  A3,A2
            BSR     asm_rdb
            BRA     sub_byte

.NoS1:      SUBQ.W  #1,D2
            BNE.S   .S4
; Word size
.S2:        BSR     asm_rdw
            MOVE.W  D0,D1                   ; nach D1
            MOVE.L  A3,A2
            BSR     asm_rdw
            BRA     sub_word

.S4:        BSR     asm_rdl
            MOVE.L  D0,D1                   ; nach D1
            MOVE.L  A3,A2
            BSR     asm_rdl
            BRA     sub_long

;***************************************************************
; stos
;***************************************************************
stos:       MOVE.L  D0,D4                   ; D4 = inc
            MOVE.W  D0,D2
            BTST.B  #2,HiFlags(A6)          ; DF testen
            BEQ.S   .DirUp
            NEG.L   D4                      ; invertieren
.DirUp:     MOVEQ   #0,D1
            MOVE.L  ES(A6),A2
            MOVE.W  DI(A6),D1
            ADD.L   D1,A2                   ; A2 = destptr
            TST.W   REP(A6)                 ; REP ?
            BEQ     .NoRep
; REP
            MOVE.W  CX(A6),D3               ; D3 = count
            BEQ     .ende                   ; = 0, nichts tun
            SUBQ.W  #1,D3                   ; DBRA Korrektur
            SUBQ.W  #1,D2
            BNE.S   .NoRS1
; Byte Size
            MOVE.B  AL(A6),D0
.RS1:       BSR     asm_wrb
            ADD.L   D4,A2
            DBRA    D3,.RS1
            BRA     .Rende

.NoRS1:     SUBQ.W  #1,D2
            BNE.S   .RS4
; Word size
.RS2:       MOVE.W  AX(A6),D0
            BSR     asm_wrw
            ADD.L   D4,A2
            DBRA    D3,.RS2
            BRA     .Rende
; Long size
.RS4:       MOVE.L  EAX(A6),D0
            BSR     asm_wrl
            ADD.L   D4,A2
            DBRA    D3,.RS4

; Register zurÅckschreiben
.Rende:     CLR.W   CX(A6)                  ; count
            CLR.W   REP(A6)
            SUB.L   ES(A6),A2
            MOVE.W  A2,DI(A6)
.ende:      RTS

.NoRep:
            ADD.W   D4,DI(A6)
            SUBQ.W  #1,D2
            BNE.S   .NoS1
; Byte Size
.S1:        MOVE.B  AL(A6),D0
            BRA     asm_wrb

.NoS1:      SUBQ.W  #1,D2
            BNE.S   .S4
; Word size
.S2:        MOVE.W  AX(A6),D0
            BRA     asm_wrw

.S4:        MOVE.L  EAX(A6),D0
            BRA     asm_wrl

;***************************************************************
; lods
;***************************************************************
lods:       MOVE.L  D0,D4                   ; D4 = inc
            MOVE.W  D0,D2
            BTST.B  #2,HiFlags(A6)          ; DF testen
            BEQ.S   .DirUp
            NEG.L   D4                      ; invertieren
.DirUp:     BSR     GetOffsetSeg            ; A2 = Segment
            MOVEQ   #0,D1
            MOVE.W  SI(A6),D1
            ADD.L   D1,A2                   ; A2 = srcptr
            TST.W   REP(A6)                 ; REP ?
            BEQ     .NoRep
; REP
            MOVE.W  CX(A6),D3               ; D3 = count
            BEQ     .ende                   ; = 0, nichts tun
            SUBQ.W  #1,D3                   ; DBRA Korrektur
            SUBQ.W  #1,D2
            BNE.S   .NoRS1
; Byte Size
.RS1:       BSR     asm_rdb
            MOVE.B  D0,AL(A6)
            ADD.L   D4,A2
            DBRA    D3,.RS1
            BRA     .Rende

.NoRS1:     SUBQ.W  #1,D2
            BNE.S   .RS4
; Word size
.RS2:       BSR     asm_rdw
            MOVE.W  D0,AX(A6)
            ADD.L   D4,A2
            DBRA    D3,.RS2
            BRA     .Rende
; Long size
.RS4:       BSR     asm_rdl
            MOVE.L  D0,EAX(A6)
            ADD.L   D4,A2
            DBRA    D3,.RS4

; Register zurÅckschreiben
.Rende:     CLR.W   CX(A6)                  ; count
            CLR.W   REP(A6)
            SUB.L   D7,A2
            MOVE.W  A2,SI(A6)
.ende:      RTS

.NoRep:
            ADD.W   D4,SI(A6)
            SUBQ.W  #1,D2
            BNE.S   .NoS1
; Byte Size
.S1:        BSR     asm_rdb
            MOVE.B  D0,AL(A6)
            RTS

.NoS1:      SUBQ.W  #1,D2
            BNE.S   .S4
; Word size
.S2:        BSR     asm_rdw
            MOVE.W  D0,AX(A6)
            RTS

.S4:        BSR     asm_rdl
            MOVE.L  D0,EAX(A6)
            RTS

;***************************************************************
; scas
;***************************************************************
scas:       MOVE.L  D0,D4                   ; D4 = inc
            MOVE.W  D0,D2
            BTST.B  #2,HiFlags(A6)          ; DF testen
            BEQ.S   .DirUp
            NEG.L   D4                      ; invertieren
.DirUp:     MOVEQ   #0,D1
            MOVE.L  ES(A6),A2
            MOVE.W  DI(A6),D1
            ADD.L   D1,A2                   ; A2 = destptr
            TST.W   REP(A6)                 ; REP ?
            BEQ     .NoRep
; REP
            MOVE.W  CX(A6),D3               ; D3 = count
            BEQ     .ende                   ; = 0, nichts tun
            SUBQ.W  #1,D3                   ; DBRA Korrektur
            SUBQ.W  #1,D2
            BNE.S   .NoRS1
; Byte Size
.RS1:       BSR     asm_rdb                 ; destbyte
            MOVE.B  D0,D1                   ; nach D1
            MOVE.B  AL(A6),D0
            BSR     sub_byte
            ADD.L   D4,A2                   ; erst Pointer Ñndern
                                               ; D3 ist durch DBRA bereits ok
            BSR     TestZeroFlag            ; Abbruch testen
            MOVE.W  REP(A6),D2
            EOR.W   D2,D0
            AND     #1,D0
            BNE     .Rende
            DBRA    D3,.RS1
            BRA     .Rende2

.NoRS1:     SUBQ.W  #1,D2
            BNE.S   .RS4
; Word Size
.RS2:       BSR     asm_rdw                 ; destword
            MOVE.W  D0,D1                   ; nach D1
            MOVE.W  AX(A6),D0
            BSR     sub_word
            ADD.L   D4,A2                   ; erst Pointer Ñndern
            BSR     TestZeroFlag            ; Abbruch testen
            MOVE.W  REP(A6),D2
            EOR.W   D2,D0
            AND     #1,D0
            BNE     .Rende
            DBRA    D3,.RS2
            BRA     .Rende2

; Long size
.RS4:       BSR     asm_rdl                 ; destlong
            MOVE.L  D0,D1                   ; nach D1
            MOVE.L  EAX(A6),D0
            BSR     sub_long
            ADD.L   D4,A2                   ; erst Pointer Ñndern
            BSR     TestZeroFlag            ; Abbruch testen
            MOVE.W  REP(A6),D2
            EOR.W   D2,D0
            AND     #1,D0
            BNE     .Rende
            DBRA    D3,.RS4

; Register zurÅckschreiben
.Rende2:    MOVEQ   #0,D3                   ; Ende ohne Abbruch
.Rende:     MOVE.W  D3,CX(A6)               ; count
            CLR.W   REP(A6)
            SUB.L   D7,A2
            MOVE.W  A2,SI(A6)
.ende:      RTS

.NoRep:     ADD.W   D4,SI(A6)
            SUBQ.W  #1,D2
            BNE.S   .NoS1
; Byte Size
.S1:        BSR     asm_rdb
            MOVE.B  D0,D1                   ; nach D1
            MOVE.B  AL(A6),D0
            BRA     sub_byte

.NoS1:      SUBQ.W  #1,D2
            BNE.S   .S4
; Word size
.S2:        BSR     asm_rdw
            MOVE.W  D0,D1                   ; nach D1
            MOVE.W  AX(A6),D0
            BRA     sub_word

.S4:        BSR     asm_rdl
            MOVE.L  D0,D1                   ; nach D1
            MOVE.L  EAX(A6),D0
            BRA     sub_long

;***************************************************************
; ins
;***************************************************************
ins:        MOVE.L  D0,D4                   ; D4 = inc
            MOVE.W  D0,D2
            BTST.B  #2,HiFlags(A6)          ; DF testen
            BEQ.S   .DirUp
            NEG.L   D4                      ; invertieren
.DirUp:     MOVEQ   #0,D1
            MOVE.L  ES(A6),A2
            MOVE.W  DI(A6),D1
            ADD.L   D1,A2                   ; A3 = destptr
            TST.W   REP(A6)                 ; REP ?
            BEQ     .NoRep
; REP
            MOVE.W  CX(A6),D3               ; D3 = count
            BEQ     .ende                   ; = 0, nichts tun
            SUBQ.W  #1,D3                   ; DBRA Korrektur
            SUBQ.W  #1,D2
            BNE.S   .NoRS1
; Byte Size
.RS1:       MOVE.W  DX(A6),D0
            BSR     asm_inb
            BSR     asm_wrb
            ADD.L   D4,A2
            DBRA    D3,.RS1
            BRA     .Rende

.NoRS1:     SUBQ.W  #1,D2
            BNE.S   .RS4
; Word size
.RS2:       MOVE.W  DX(A6),D0
            BSR     asm_inw
            BSR     asm_wrw
            ADD.L   D4,A2
            DBRA    D3,.RS2
            BRA     .Rende
; Long size
.RS4:       MOVE.W  DX(A6),D0
            BSR     asm_inl
            BSR     asm_wrl
            ADD.L   D4,A2
            DBRA    D3,.RS4

; Register zurÅckschreiben
.Rende:     CLR.W   CX(A6)                  ; count
            CLR.W   REP(A6)
            SUB.L   ES(A6),A2
            MOVE.W  A2,DI(A6)
.ende:      RTS

.NoRep:
            ADD.W   D4,DI(A6)
            SUBQ.W  #1,D2
            BNE.S   .NoS1
; Byte Size
.S1:        MOVE.W  DX(A6),D0
            BSR     asm_inb
            BRA     asm_wrb

.NoS1:      SUBQ.W  #1,D2
            BNE.S   .S4
; Word size
.S2:        MOVE.W  DX(A6),D0
            BSR     asm_inw
            BRA     asm_wrw

.S4:        MOVE.W  DX(A6),D0
            BSR     asm_inl
            BRA     asm_wrl

;***************************************************************
; outs
;***************************************************************
outs:       MOVE.L  D0,D4                   ; D4 = inc
            MOVE.W  D0,D2
            BTST.B  #2,HiFlags(A6)          ; DF testen
            BEQ.S   .DirUp
            NEG.L   D4                      ; invertieren
.DirUp:     BSR     GetOffsetSeg            ; A2 = Segment
            MOVEQ   #0,D1
            MOVE.W  SI(A6),D1
            ADD.L   D1,A2                   ; A2 = srcptr
            TST.W   REP(A6)                 ; REP ?
            BEQ     .NoRep
; REP
            MOVE.W  CX(A6),D3               ; D3 = count
            BEQ     .ende                   ; = 0, nichts tun
            SUBQ.W  #1,D3                   ; DBRA Korrektur
            SUBQ.W  #1,D2
            BNE.S   .NoRS1
; Byte Size
.RS1:       BSR     asm_rdb
            MOVE.W  DX(A6),D1
            BSR     asm_outb
            ADD.L   D4,A2
            DBRA    D3,.RS1
            BRA     .Rende

.NoRS1:     SUBQ.W  #1,D2
            BNE.S   .RS4
; Word size
.RS2:       BSR     asm_rdw
            MOVE.W  DX(A6),D1
            BSR     asm_outw
            ADD.L   D4,A2
            DBRA    D3,.RS2
            BRA     .Rende
; Long size
.RS4:       BSR     asm_rdl
            MOVE.W  DX(A6),D1
            BSR     asm_outl
            ADD.L   D4,A2
            DBRA    D3,.RS4

; Register zurÅckschreiben
.Rende:     CLR.W   CX(A6)                  ; count
            CLR.W   REP(A6)
            SUB.L   D7,A2
            MOVE.W  A2,SI(A6)
.ende:      RTS

.NoRep:
            ADD.W   D4,SI(A6)
            SUBQ.W  #1,D2
            BNE.S   .NoS1
; Byte Size
.S1:        BSR     asm_rdb
            MOVE.W  DX(A6),D1
            BRA     asm_outb

.NoS1:      SUBQ.W  #1,D2
            BNE.S   .S4
; Word size
.S2:        BSR     asm_rdw
            MOVE.W  DX(A6),D1
            BRA     asm_outw

.S4:        BSR     asm_rdl
            MOVE.W  DX(A6),D1
            BRA     asm_outl

