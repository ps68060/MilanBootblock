;****************************************************************************
; $Id: x86_op32.s,v 1.3 2003/12/28 22:14:16 rincewind Exp $
;****************************************************************************
; $Log: x86_op32.s,v $
; Revision 1.3  2003/12/28 22:14:16  rincewind
; - fix CVS headers
;
; Revision 1.2  2000/06/19 20:52:35  rincewind
; - misc cleanup
;****************************************************************************


            IMPORT  push_seglong
            IMPORT  pop_seglong
            IMPORT  push_long
            IMPORT  pop_long

            INCLUDE "LONG_OPS.S"            ; Muû Åber include laufen

            IMPORT  dec_long
            IMPORT  inc_long
            IMPORT  neg_long
            IMPORT  not_long
            IMPORT  imul_long
            IMPORT  mul_long
            IMPORT  idiv_long
            IMPORT  div_long
            IMPORT  movs
            IMPORT  cmps
            IMPORT  stos
            IMPORT  lods
            IMPORT  scas
            IMPORT  ins
            IMPORT  outs

            IMPORT  asm_inl
            IMPORT  asm_outl

            IMPORT  TestZeroFlag
            IMPORT  halt_sys

            IMPORT  x86_optab

            IMPORT  sys
            IMPORT  MainLoopEnd
            IMPORT  MainLoopEnd_OSC32
            IMPORT  DebugIllegal32

            XDEF    sub_long                ; fÅr Stringroutine

; Externals aus X86_DEC.S
            XREF    asm_fetchbyte
            XREF    asm_fetchbyte_word
            XREF    asm_fetchword
            XREF    asm_fetchword_long
            XREF    asm_fetchlong
            XREF    asm_rdl
            XREF    asm_wrl
            XREF    get_src_byte
            XREF    get_src_word
            XREF    get_src_long
            XREF    GetOffsetSeg
            XREF    Get_rm_Offset

            EXPORT  x86_optab32
            EXPORT  x86_optab2

            INCLUDE "X86_REGS.INC"

            TEXT

            MACRO   TBL  fkt
            DC.W    fkt - x86_optab32
            ENDM

;***************************************************************
; x86_optab32
;***************************************************************
x86_optab32:
            TBL     x86op_illegal32_op
            TBL     x86op_add_long_RM_R
            TBL     x86op_illegal32_op
            TBL     x86op_add_long_R_RM
            TBL     x86op_illegal32_op
            TBL     x86op_add_long_EAX_IMM
            TBL     x86op_pushd_ES
            TBL     x86op_popd_ES

            TBL     x86op_illegal32_op
            TBL     x86op_or_long_RM_R
            TBL     x86op_illegal32_op
            TBL     x86op_or_long_R_RM
            TBL     x86op_illegal32_op
            TBL     x86op_or_long_EAX_IMM
            TBL     x86op_pushd_CS
            TBL     x86op_two_byte32

            TBL     x86op_illegal32_op      ;  10
            TBL     x86op_adc_long_RM_R
            TBL     x86op_illegal32_op
            TBL     x86op_adc_long_R_RM
            TBL     x86op_illegal32_op
            TBL     x86op_adc_long_EAX_IMM
            TBL     x86op_pushd_SS
            TBL     x86op_popd_SS

            TBL     x86op_illegal32_op
            TBL     x86op_sbb_long_RM_R
            TBL     x86op_illegal32_op
            TBL     x86op_sbb_long_R_RM
            TBL     x86op_illegal32_op
            TBL     x86op_sbb_long_EAX_IMM
            TBL     x86op_pushd_DS
            TBL     x86op_popd_DS

            TBL     x86op_illegal32_op      ; 20
            TBL     x86op_and_long_RM_R
            TBL     x86op_illegal32_op
            TBL     x86op_and_long_R_RM
            TBL     x86op_illegal32_op
            TBL     x86op_and_long_EAX_IMM
            TBL     x86op_segovr32_ES
            TBL     x86op_illegal32_op

            TBL     x86op_illegal32_op
            TBL     x86op_sub_long_RM_R
            TBL     x86op_illegal32_op
            TBL     x86op_sub_long_R_RM
            TBL     x86op_illegal32_op
            TBL     x86op_sub_long_EAX_IMM
            TBL     x86op_segovr32_CS
            TBL     x86op_illegal32_op

            TBL     x86op_illegal32_op      ; 30
            TBL     x86op_xor_long_RM_R
            TBL     x86op_illegal32_op
            TBL     x86op_xor_long_R_RM
            TBL     x86op_illegal32_op
            TBL     x86op_xor_long_EAX_IMM
            TBL     x86op_segovr32_SS
            TBL     x86op_illegal32_op

            TBL     x86op_illegal32_op
            TBL     x86op_cmp_long_RM_R
            TBL     x86op_illegal32_op
            TBL     x86op_cmp_long_R_RM
            TBL     x86op_illegal32_op
            TBL     x86op_cmp_long_EAX_IMM
            TBL     x86op_segovr32_DS
            TBL     x86op_illegal32_op

            TBL     x86op_inc_long_reg      ; 40
            TBL     x86op_inc_long_reg
            TBL     x86op_inc_long_reg
            TBL     x86op_inc_long_reg
            TBL     x86op_inc_long_reg
            TBL     x86op_inc_long_reg
            TBL     x86op_inc_long_reg
            TBL     x86op_inc_long_reg

            TBL     x86op_dec_long_reg
            TBL     x86op_dec_long_reg
            TBL     x86op_dec_long_reg
            TBL     x86op_dec_long_reg
            TBL     x86op_dec_long_reg
            TBL     x86op_dec_long_reg
            TBL     x86op_dec_long_reg
            TBL     x86op_dec_long_reg

            TBL     x86op_push_long_reg     ; 50
            TBL     x86op_push_long_reg
            TBL     x86op_push_long_reg
            TBL     x86op_push_long_reg
            TBL     x86op_push_long_reg
            TBL     x86op_push_long_reg
            TBL     x86op_push_long_reg
            TBL     x86op_push_long_reg

            TBL     x86op_pop_long_reg
            TBL     x86op_pop_long_reg
            TBL     x86op_pop_long_reg
            TBL     x86op_pop_long_reg
            TBL     x86op_pop_long_reg
            TBL     x86op_pop_long_reg
            TBL     x86op_pop_long_reg
            TBL     x86op_pop_long_reg

            TBL     x86op_pushd_all         ; 60
            TBL     x86op_popd_all
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_segovr32_FS
            TBL     x86op_segovr32_GS
            TBL     x86op_illegal32_op
            TBL     x86op_prefix_adr32

            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_ins_long
            TBL     x86op_illegal32_op
            TBL     x86op_outs_long

            TBL     x86op_illegal32_op      ; 70
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op

            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op

            TBL     x86op_illegal32_op      ; 80
            TBL     x86op_opc81_long_RM_IMM
            TBL     x86op_illegal32_op
            TBL     x86op_opc83_long_RM_IMM
            TBL     x86op_illegal32_op
            TBL     x86op_test_long_RM_R
            TBL     x86op_illegal32_op
            TBL     x86op_xchg_long_RM_R

            TBL     x86op_illegal32_op
            TBL     x86op_mov_long_RM_R
            TBL     x86op_illegal32_op
            TBL     x86op_mov_long_R_RM
            TBL     x86op_illegal32_op
            TBL     x86op_lea_long_R_M
            TBL     x86op_illegal32_op
            TBL     x86op_popd_RM

            TBL     x86op_xchg_long_AX_R    ; 90
            TBL     x86op_xchg_long_AX_R
            TBL     x86op_xchg_long_AX_R
            TBL     x86op_xchg_long_AX_R
            TBL     x86op_xchg_long_AX_R
            TBL     x86op_xchg_long_AX_R
            TBL     x86op_xchg_long_AX_R
            TBL     x86op_xchg_long_AX_R

            TBL     x86op_cwde
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op

            TBL     x86op_illegal32_op      ; A0
            TBL     x86op_mov_EAX_M_IMM
            TBL     x86op_illegal32_op
            TBL     x86op_mov_M_EAX_IMM
            TBL     x86op_illegal32_op
            TBL     x86op_movs_long
            TBL     x86op_illegal32_op
            TBL     x86op_cmps_long

            TBL     x86op_illegal32_op
            TBL     x86op_test_EAX_IMM
            TBL     x86op_illegal32_op
            TBL     x86op_stos_long
            TBL     x86op_illegal32_op
            TBL     x86op_lods_long
            TBL     x86op_illegal32_op
            TBL     x86op_scas_long

            TBL     x86op_illegal32_op      ; B0
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op

            TBL     x86op_mov_long_R_IMM
            TBL     x86op_mov_long_R_IMM
            TBL     x86op_mov_long_R_IMM
            TBL     x86op_mov_long_R_IMM
            TBL     x86op_mov_long_R_IMM
            TBL     x86op_mov_long_R_IMM
            TBL     x86op_mov_long_R_IMM
            TBL     x86op_mov_long_R_IMM

            TBL     x86op_illegal32_op      ; C0
            TBL     x86op_opcC1_long_RM_MEM
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_mov_long_RM_IMM

            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op

            TBL     x86op_illegal32_op      ; D0
            TBL     x86op_opcD1_long_RM_1
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op

            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op

            TBL     x86op_illegal32_op      ; E0
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_out_long_IMM_EAX

            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_out_long_DX_EAX

            TBL     x86op_illegal32_op      ; F0
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_opcF7_long_RM

            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op
            TBL     x86op_illegal32_op      ; FF

;***************************************************************
; x86op_illegal32_op
;***************************************************************
x86op_illegal32_op:
            BSR     DebugIllegal32
            LEA     x86_optab(PC),A5
            MOVE.W  (A5,D0.W*2),D1          ; Åber 16 Bit Tabelle springen
            JMP     (A5,D1.W)

;***************************************************************
; x86op_add_long_RM_R
;***************************************************************
x86op_add_long_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.L  (EAX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (EAX,A6,D4.W*4),A2
            MOVE.L  (A2),D0
            BSR     add_long
            MOVE.L  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdl                 ; D0 = (A2)
            BSR     add_long                ; D0 = D0 + D1
            BSR     asm_wrl                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_add_long_R_RM
;***************************************************************
x86op_add_long_R_RM:
            BSR     get_src_long            ; D1 = word , D3 = reg
            LEA     (EAX,A6,D3.W*4),A2
            MOVE.L  (A2),D0
            BSR     add_long
            MOVE.L  D0,(A2)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_add_long_EAX_IMM
;***************************************************************
x86op_add_long_EAX_IMM:
            BSR     asm_fetchlong           ; D0 = IMM
            MOVE.L  EAX(A6),D1
            BSR     add_long
            MOVE.L  D0,EAX(A6)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_pushd_ES
;***************************************************************
x86op_pushd_ES:
            MOVE.L  ES(A6),D0
            BSR     push_seglong
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_popd_ES
;***************************************************************
x86op_popd_ES:
            BSR     pop_seglong
            MOVE.L  D0,ES(A6)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_or_long_RM_R
;***************************************************************
x86op_or_long_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.L  (EAX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (EAX,A6,D4.W*4),A2
            MOVE.L  (A2),D0
            BSR     or_long
            MOVE.L  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdl                 ; D0 = (A2)
            BSR     or_long                 ; D0 = D0 # D1
            BSR     asm_wrl                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_or_long_R_RM
;***************************************************************
x86op_or_long_R_RM:
            BSR     get_src_long            ; D1 = word , D3 = reg
            LEA     (EAX,A6,D3.W*4),A2
            MOVE.L  (A2),D0
            BSR     or_long
            MOVE.L  D0,(A2)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_or_long_EAX_IMM
;***************************************************************
x86op_or_long_EAX_IMM:
            BSR     asm_fetchlong           ; D0 = IMM
            MOVE.W  EAX(A6),D1
            BSR     or_long
            MOVE.W  D0,EAX(A6)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_pushd_CS
;***************************************************************
x86op_pushd_CS:
            MOVE.L  CS(A6),D0
            BSR     push_seglong
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_two_byte32
;***************************************************************
x86op_two_byte32:
            bsr     asm_fetchbyte
            MOVE.B  D0,D3

            CLR.W   D1
            MOVE.B  D0,D1
            SUB.B   #$A0,D1
            CMP.B   #$1F,D1
            BHI     .default
            MOVE.W  (.optab.B,PC,D1.W*2),D1
            JMP     .optab(PC,D1.W)
.optab:     DC.W    .push_fs - .optab            ; A0
            DC.W    .pop_fs  - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .push_gs - .optab            ; A8
            DC.W    .pop_gs  - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab            ; B0
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .movezxb - .optab
            DC.W    .movezxw - .optab
            DC.W    .default - .optab            ; B8
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .movesxb - .optab
            DC.W    .movesxw - .optab

.push_fs:   MOVE.L  FS(A6),D0
            BSR     push_seglong
            BRA.S   .ende

.pop_fs:    BSR     pop_seglong
            MOVE.L  D0,FS(A6)
            BRA.S   .ende

.push_gs:   MOVE.L  GS(A6),D0
            BSR     push_seglong
            BRA.S   .ende

.pop_gs:    BSR     pop_seglong
            MOVE.L  D0,GS(A6)
            BRA.S   .ende

.movezxb:   BSR     get_src_byte            ; D1 = byte , D3 = reg
            MOVEQ   #0,D0
            MOVE.B  D1,D0
;                  move.l    #$55AA5AA5,d0
            MOVE.L  D0,(EAX,A6,D3.W*4)
            BRA.S   .ende

.movezxw:   BSR     get_src_word            ; D1 = word , D3 = reg
            MOVEQ   #0,D0
            MOVE.W  D1,D0
;                  move.l    #$12345678,D0
            MOVE.L  D0,(EAX,A6,D3.W*4)
            BRA.S   .ende

.movesxb:   BSR     get_src_byte            ; D1 = byte , D3 = reg
            EXTB.L  D1
            MOVE.L  D1,(EAX,A6,D3.W*4)
            BRA.S   .ende

.movesxw:   BSR     get_src_word            ; D1 = word , D3 = reg
            EXT.L   D1
            MOVE.L  D1,(EAX,A6,D3.W*4)
            BRA.S   .ende

.default:   BRA     halt_sys
.ende:      BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_adc_long_RM_R
;***************************************************************
x86op_adc_long_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.L  (EAX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (EAX,A6,D4.W*4),A2
            MOVE.L  (A2),D0
            BSR     adc_long
            MOVE.L  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdl                 ; D0 = (A2)
            BSR     adc_long                ; D0 = D0 + D1
            BSR     asm_wrl                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_adc_long_R_RM
;***************************************************************
x86op_adc_long_R_RM:
            BSR     get_src_long            ; D1 = word , D3 = reg
            LEA     (EAX,A6,D3.W*4),A2
            MOVE.L  (A2),D0
            BSR     adc_long
            MOVE.L  D0,(A2)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_adc_long_EAX_IMM
;***************************************************************
x86op_adc_long_EAX_IMM:
            BSR     asm_fetchlong           ; D0 = IMM
            MOVE.L  EAX(A6),D1
            BSR     adc_long
            MOVE.L  D0,EAX(A6)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_pushd_SS
;***************************************************************
x86op_pushd_SS:
            MOVE.L  SS(A6),D0
            BSR     push_seglong
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_popd_SS
;***************************************************************
x86op_popd_SS:
            BSR     pop_seglong
            MOVE.L  D0,SS(A6)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_sbb_long_RM_R
;***************************************************************
x86op_sbb_long_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.L  (EAX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (EAX,A6,D4.W*4),A2
            MOVE.L  (A2),D0
            BSR     sbb_long
            MOVE.L  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdl                 ; D0 = (A2)
            BSR     sbb_long                ; D0 = D0 + D1
            BSR     asm_wrl                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_sbb_long_R_RM
;***************************************************************
x86op_sbb_long_R_RM:
            BSR     get_src_long            ; D1 = word , D3 = reg
            LEA     (EAX,A6,D3.W*4),A2
            MOVE.L  (A2),D0
            BSR     sbb_long
            MOVE.L  D0,(A2)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_sbb_long_EAX_IMM
;***************************************************************
x86op_sbb_long_EAX_IMM:
            BSR     asm_fetchlong           ; D0 = IMM
            MOVE.L  D0,D1
            MOVE.L  EAX(A6),D0
            BSR     sbb_long
            MOVE.L  D0,(EAX,A6)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_pushd_DS
;***************************************************************
x86op_pushd_DS:
            MOVE.L  DS(A6),D0
            BSR     push_seglong
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_popd_SS
;***************************************************************
x86op_popd_DS:
            BSR     pop_seglong
            MOVE.L  D0,DS(A6)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_and_long_RM_R
;***************************************************************
x86op_and_long_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.L  (EAX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (EAX,A6,D4.W*4),A2
            MOVE.L  (A2),D0
            BSR     and_long
            MOVE.L  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdl                 ; D0 = (A2)
            BSR     and_long                ; D0 = D0 & D1
            BSR     asm_wrl                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_and_long_R_RM
;***************************************************************
x86op_and_long_R_RM:
            BSR     get_src_long            ; D1 = word , D3 = reg
            LEA     (EAX,A6,D3.W*4),A2
            MOVE.L  (A2),D0
            BSR     and_long
            MOVE.L  D0,(A2)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_and_long_EAX_IMM
;***************************************************************
x86op_and_long_EAX_IMM:
            BSR     asm_fetchlong           ; D0 = IMM
            MOVE.L  EAX(A6),D1
            BSR     and_long
            MOVE.L  D0,EAX(A6)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_segovr32_ES
;***************************************************************
x86op_segovr32_ES:
            MOVE.L  ES(A6),D0
            OR.L    D0,D7
            LEA     x86_optab(PC),A5
            BRA     MainLoopEnd

;***************************************************************
; x86op_sub_long_RM_R
;***************************************************************
x86op_sub_long_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.L  (EAX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (EAX,A6,D4.W*4),A2
            MOVE.L  (A2),D0
            BSR     sub_long
            MOVE.L  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdl                 ; D0 = (A2)
            BSR     sub_long                ; D0 = D0 + D1
            BSR     asm_wrl                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_sub_long_R_RM
;***************************************************************
x86op_sub_long_R_RM:
            BSR     get_src_long            ; D1 = word , D3 = reg
            LEA     (EAX,A6,D3.W*4),A2
            MOVE.L  (A2),D0
            BSR     sub_long
            MOVE.L  D0,(A2)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_sub_long_EAX_IMM
;***************************************************************
x86op_sub_long_EAX_IMM:
            BSR     asm_fetchlong           ; D0 = IMM
            MOVE.L  D0,D1
            MOVE.L  EAX(A6),D0
            BSR     sub_long
            MOVE.L  D0,EAX(A6)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_segovr32_CS
;***************************************************************
x86op_segovr32_CS:
            MOVE.L  CS(A6),D0
            OR.L    D0,D7
            LEA     x86_optab(PC),A5
            BRA     MainLoopEnd

;***************************************************************
; x86op_xor_long_RM_R
;***************************************************************
x86op_xor_long_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.L  (EAX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (EAX,A6,D4.W*4),A2
            MOVE.L  (A2),D0
            BSR     xor_long
            MOVE.L  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdl                 ; D0 = (A2)
            BSR     xor_long                ; D0 = D0 ^  D1
            BSR     asm_wrl                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_xor_long_R_RM
;***************************************************************
x86op_xor_long_R_RM:
            BSR     get_src_long            ; D1 = word , D3 = reg
            LEA     (EAX,A6,D3.W*4),A2
            MOVE.L  (A2),D0
            BSR     xor_long
            MOVE.L  D0,(A2)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_xor_long_EAX_IMM
;***************************************************************
x86op_xor_long_EAX_IMM:
            BSR     asm_fetchlong           ; D0 = IMM
            MOVE.L  EAX(A6),D1
            BSR     xor_long
            MOVE.L  D0,EAX(A6)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_segovr32_SS
;***************************************************************
x86op_segovr32_SS:
            MOVE.L  SS(A6),D0
            OR.L    D0,D7
            LEA     x86_optab(PC),A5
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_cmp_long_RM_R
;***************************************************************
x86op_cmp_long_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.L  (EAX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVE.L  (EAX,A6,D4.W*4),D0
            BSR     sub_long
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdl                 ; D0 = (A2)
            BSR     sub_long                ; D0 = D0 + D1
.ende:      BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_cmp_long_R_RM
;***************************************************************
x86op_cmp_long_R_RM:
            BSR     get_src_long            ; D1 = word , D3 = reg
            MOVE.L  (EAX,A6,D3.W*4),D0
            BSR     sub_long
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_cmp_long_EAX_IMM
;***************************************************************
x86op_cmp_long_EAX_IMM:
            BSR     asm_fetchlong           ; D0 = IMM
            MOVE.L  D0,D1
            MOVE.L  EAX(A6),D0
            BSR     sub_long
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_segovr32_DS
;***************************************************************
x86op_segovr32_DS:
            MOVE.L  DS(A6),D0
            OR.L    D0,D7
            LEA     x86_optab(PC),A5
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_inc_long_reg
;***************************************************************
x86op_inc_long_reg:
            AND.W   #7,D0                   ; opcode steht noch in D0
            LEA     (EAX,A6,D0.W*4),A2
            MOVE.L  (A2),D0
            BSR     inc_long
            MOVE.L  D0,(A2)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_dec_long_reg
;***************************************************************
x86op_dec_long_reg:
            AND.W   #7,D0                   ; opcode steht noch in D0
            LEA     (EAX,A6,D0.W*4),A2
            MOVE.L  (A2),D0
            BSR     dec_long
            MOVE.L  D0,(A2)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_push_long_reg
;***************************************************************
x86op_push_long_reg:
            SUBQ.W  #4,SP(A6)
            MOVEQ   #0,D1
            MOVE.W  SP(A6),D1
            ADD.L   SS(A6),D1
            AND.W   #7,D0                   ; opcode steht noch in D0
            MOVE.L  (EAX,A6,D0.W*4),D0
            MOVE.L  D1,A2
            BSR     asm_wrl
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_pop_long_reg
;***************************************************************
x86op_pop_long_reg:
            MOVEQ   #0,D1
            MOVE.W  SP(A6),D1
            ADD.L   SS(A6),D1
            MOVE.L  D1,A2
            AND.W   #7,D0                   ; opcode steht noch in D0
            MOVE.W  D0,D1                   ; sichern
            BSR     asm_rdl
            MOVE.L  D0,(EAX,A6,D1.W*4)
            ADDQ.W  #4,SP(A6)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_pushd_all
;***************************************************************
x86op_pushd_all:
            MOVE.L  ESP(A6),D3              ; Stack sichern
            MOVE.L  EAX(A6),D0
            BSR     push_long
            MOVE.L  ECX(A6),D0
            BSR     push_long
            MOVE.L  EDX(A6),D0
            BSR     push_long
            MOVE.L  EBX(A6),D0
            BSR     push_long
            MOVE.L  D3,D0
            BSR     push_long
            MOVE.L  EBP(A6),D0
            BSR     push_long
            MOVE.L  ESI(A6),D0
            BSR     push_long
            MOVE.L  EDI(A6),D0
            BSR     push_long
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_popd_all
;***************************************************************
x86op_popd_all:
            BSR     pop_long
            MOVE.L  D0,EDI(A6)
            BSR     pop_long
            MOVE.L  D0,ESI(A6)
            BSR     pop_long
            MOVE.L  D0,EBP(A6)
            ADDQ.L  #4,ESP(A6)              ; SP ignorieren
            BSR     pop_long
            MOVE.L  D0,EBX(A6)
            BSR     pop_long
            MOVE.L  D0,EDX(A6)
            BSR     pop_long
            MOVE.L  D0,ECX(A6)
            BSR     pop_long
            MOVE.L  D0,EAX(A6)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_segovr32_FS
;***************************************************************
x86op_segovr32_FS:
            MOVE.L  FS(A6),D0
            OR.L    D0,D7
            LEA     x86_optab(PC),A5
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_segovr32_GS
;***************************************************************
x86op_segovr32_GS:
            MOVE.L  GS(A6),D0
            OR.L    D0,D7
            LEA     x86_optab(PC),A5
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_prefix_adr32
;***************************************************************
x86op_prefix_adr32:
            BSET.L  #31,D7
            LEA     x86_optab(PC),A5
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_ins_long
;***************************************************************
x86op_ins_long:
            MOVEQ   #4,D0
            BSR     ins
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_outs_long
;***************************************************************
x86op_outs_long:
            MOVEQ   #4,D0
            BSR     outs
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_opc81_long_RM_IMM
;***************************************************************
x86op_opc81_long_RM_IMM:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D3             ; Funktion in D3 merken
            MOVE.W  (op81_long_operation.B,PC,D3.W*2),D5
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   opc81_IsMem
; Ziel ist Register
            LEA     (EAX,A6,D4.W*4),A2
            BSR     asm_fetchlong
opc81_cont_reg: MOVE.L D0,D1                ; IMM nach D1
            MOVE.L  (A2),D0
            JSR     op81_long_operation(PC,D5.W)
            CMP.W   #7,D3                   ; CMP ?
            BEQ.S   opc81_ende
            MOVE.L  D0,(A2)
            BRA.S   opc81_ende
; Ziel ist Speicher
opc81_IsMem: BSR    Get_rm_Offset           ; Adresse nach A2
            BSR     asm_fetchlong           ; IMM immer nach Offset
opc81_cont_mem: MOVE.L D0,D1                ; IMM nach D1
            BSR     asm_rdl                 ; D0 = (A2)
            JSR     op81_long_operation(PC,D5.W)
            CMP.W   #7,D3                   ; CMP ?
            BEQ.S   opc81_ende
            BSR     asm_wrl                 ; (A2) = D0
opc81_ende: BRA     MainLoopEnd_OSC32

op81_long_operation:
            DC.W    add_long - op81_long_operation
            DC.W    or_long  - op81_long_operation
            DC.W    adc_long - op81_long_operation
            DC.W    sbb_long - op81_long_operation
            DC.W    and_long - op81_long_operation
            DC.W    sub_long - op81_long_operation
            DC.W    xor_long - op81_long_operation
            DC.W    sub_long - op81_long_operation

;***************************************************************
; x86op_opc83_long_RM_IMM
;***************************************************************
x86op_opc83_long_RM_IMM:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D3             ; Funktion in D3 merken
            MOVE.W  (op81_long_operation.B,PC,D3.W*2),D5
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (AX,A6,D4.W*4),A2
            BSR     asm_fetchbyte
            EXTB.L  D0
            BRA.S   opc81_cont_reg

; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_fetchbyte           ; IMM immer nach Offset
            EXTB.L  D0
            BRA.S   opc81_cont_mem

;***************************************************************
; x86op_test_long_RM_R
;***************************************************************
x86op_test_long_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.L  (EAX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVE.L  (EAX,A6,D4.W*4),D0
            BSR     and_long
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdl                 ; D0 = (A2)
            BSR     and_long                ; D0 & D1
.ende:      BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_xchg_long_RM_R
;***************************************************************
x86op_xchg_long_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            LEA     (EAX,A6,D4.W*4),A1
            MOVE.L  (A1),D1                 ; Quelle nach D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (EAX,A6,D4.W*4),A2
            MOVE.L  (A2),D0
            MOVE.L  D0,(A1)
            MOVE.L  D1,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdl                 ; D0 = (A2)
            MOVE.L  D0,(A1)
            MOVE.L  D1,D0
            BSR     asm_wrl                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_mov_long_RM_R
;***************************************************************
x86op_mov_long_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.L  (EAX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVE.L  D1,(EAX,A6,D4.W*4)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            MOVE.L  D1,D0
            BSR     asm_wrl                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_mov_long_R_RM
;***************************************************************
x86op_mov_long_R_RM:
            BSR     get_src_long            ; D1 = word , D3 = reg
            MOVE.L  D1,(EAX,A6,D3.W*4)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_lea_long_R_M
;***************************************************************
x86op_lea_long_R_M:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            LEA     (EAX,A6,D4.W*4),A1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BEQ.S   .ende                   ; Register ist undefiniert
            BSR     Get_rm_Offset           ; Adresse nach A2
            BCLR.L  #31,D7                  ; Oberstes Bit ist egal
            TST.L   D7                      ; OverSeg gesetzt ?
            BNE.S   .OverOK
            MOVE.L  DS(A6),D7               ; Default ist DS
.OverOK:    SUB.L   D7,A2                   ; Offset abziehen
            MOVE.L  A2,(A1)
.ende:      BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_popd_RM
;***************************************************************
x86op_popd_RM:
            BSR     asm_fetchbyte
            MOVE.W  D0,D1                   ; fetchbyte sichern
            BFEXTU  D0{29:3},D4
            BFTST   D0{26:3}                ; reg muû 0 sein
            BNE     halt_sys
            BSR     pop_long
            EXG     D0,D1                   ; tauschen
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVE.L  D1,(EAX,A6,D4.W*4)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            MOVE.L  D1,D0
            BSR     asm_wrl                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_xchg_long_AX_R
;***************************************************************
x86op_xchg_long_AX_R:
            AND.W   #7,D0
            LEA     (EAX,A6,D0*4),A2
            MOVE.L  (A2),D0
            MOVE.L  EAX(A6),(A2)
            MOVE.L  D0,EAX(A6)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_cwde
;***************************************************************
x86op_cwde:
            MOVE.W  AX(A6),D0
            EXT.L   D0
            MOVE.L  D0,EAX(A6)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_mov_EAX_M_IMM
;***************************************************************
x86op_mov_EAX_M_IMM:
            BSR     asm_fetchword_long
            BSR     GetOffsetSeg            ; A2 = Segment
            ADD.L   D0,A2
            BSR     asm_rdl
            MOVE.L  D0,EAX(A6)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_mov_M_EAX_IMM
;***************************************************************
x86op_mov_M_EAX_IMM:
            MOVEQ   #0,D0
            BSR     asm_fetchword
            BSR     GetOffsetSeg            ; A2 = Offset
            ADDA.L  D0,A2
            MOVE.L  EAX(A6),D0
            BSR     asm_wrl
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_movs_long
;***************************************************************
x86op_movs_long:
            MOVEQ   #4,D0
            BSR     movs
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_cmps_long
;***************************************************************
x86op_cmps_long:
            MOVEQ   #4,D0
            BSR     cmps
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_test_EAX_IMM
;***************************************************************
x86op_test_EAX_IMM:
            BSR     asm_fetchlong
            MOVE.L  EAX(A6),D1
            BSR     and_long
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_stos_long
;***************************************************************
x86op_stos_long:
            MOVEQ   #4,D0
            BSR     stos
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_lods_long
;***************************************************************
x86op_lods_long:
            MOVEQ   #4,D0
            BSR     lods
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_scas_long
;***************************************************************
x86op_scas_long:
            MOVEQ   #4,D0
            BSR     scas
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_mov_long_R_IMM
;***************************************************************
x86op_mov_long_R_IMM:
            AND.W   #7,D0
            LEA     (EAX,A6,D0.W*4),A2
            BSR     asm_fetchlong
            MOVE.L  D0,(A2)
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_mov_long_RM_IMM
;***************************************************************
x86op_mov_long_RM_IMM:
            BSR     asm_fetchbyte
            BFTST   D0{26:3}                ; reg muû 0 sein
            BNE     halt_sys
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            BSR     asm_fetchlong
            MOVE.L  D0,(EAX,A6,D4.W*4)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_fetchlong
            BSR     asm_wrl                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_opcC1_long_RM_MEM
;***************************************************************
x86op_opcC1_long_RM_MEM:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (opD1_long_operation.B,PC,D4.W*2),D5
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (EAX,A6,D4.W*4),A2
            BSR     asm_fetchbyte
            MOVE.B  D0,D1                   ; IMM nach D1
            BRA.S   opcD1_cont_reg
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_fetchbyte           ; IMM immer nach Offset
            MOVE.B  D0,D1                   ; IMM nach D1
            BRA.S   opcD1_cont_mem

;***************************************************************
; x86op_opcD1_long_RM_1
;***************************************************************
opD1_long_operation:
            DC.W    rol_long - opD1_long_operation
            DC.W    ror_long - opD1_long_operation
            DC.W    rcl_long - opD1_long_operation
            DC.W    rcr_long - opD1_long_operation
            DC.W    shl_long - opD1_long_operation
            DC.W    shr_long - opD1_long_operation
            DC.W    shl_long - opD1_long_operation
            DC.W    sar_long - opD1_long_operation

x86op_opcD1_long_RM_1:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (opD1_long_operation.B,PC,D4.W*2),D5
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   opcD1_IsMem
; Ziel ist Register
            LEA     (EAX,A6,D4.W*4),A2
            MOVEQ   #1,D1                   ; count = 1
opcD1_cont_reg: MOVE.L (A2),D0
            JSR     opD1_long_operation(PC,D5.W)
            MOVE.L  D0,(A2)
            BRA.S   opcD1_ende
; Ziel ist Speicher
opcD1_IsMem: BSR    Get_rm_Offset           ; Adresse nach A2
            MOVEQ   #1,D1                   ; count = 1
opcD1_cont_mem: BSR asm_rdl                 ; D0 = (A2)
            JSR     opD1_long_operation(PC,D5.W)
            BSR     asm_wrl                 ; (A2) = D0
opcD1_ende: BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_opcD3_long_RM_CL
;***************************************************************
x86op_opcD3_long_RM_CL:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (opD1_long_operation.B,PC,D4.W*2),D5
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (EAX,A6,D4.W*4),A2
            MOVE.B  CL(A6),D1               ; count = CL
            BRA.S   opcD1_cont_reg
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            MOVE.B  CL(A6),D1               ; count = CL
            BRA.S   opcD1_cont_mem

;***************************************************************
; x86op_out_long_IMM_EAX
;***************************************************************
x86op_out_long_IMM_EAX:
            BSR     asm_fetchbyte_word
            MOVE.W  D0,D1
            MOVE.L  EAX(A6),D0
            BSR     asm_outl
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_out_long_DX_EAX
;***************************************************************
x86op_out_long_DX_EAX:
            MOVE.W  DX(A6),D1
            MOVE.L  EAX(A6),D0
            BSR     asm_outl
            BRA     MainLoopEnd_OSC32

;***************************************************************
; x86op_opcF7_long_RM
;***************************************************************
x86op_opcF7_long_RM:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D3             ; D3 = Fkt Nr.
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE     .IsMem
            LEA     (EAX,A6,D4.W*4),A2
            MOVE.L  (A2),D0                 ; Source Byte
            MOVE.W  (.reg_optab.B,PC,D3.W*2),D3
            JMP     .reg_optab(PC,D3.W)

.reg_optab: DC.W    .fkt_test - .reg_optab
            DC.W    .default  - .reg_optab
            DC.W    .reg_not  - .reg_optab
            DC.W    .reg_neg  - .reg_optab
            DC.W    .fkt_mul  - .reg_optab
            DC.W    .fkt_imul - .reg_optab
            DC.W    .fkt_div  - .reg_optab
            DC.W    .fkt_idiv - .reg_optab

.default:   BRA     halt_sys

.reg_not:   NOT.L   D0
            MOVE.L  D0,(A2)
            BRA.S   .ende

.reg_neg:   BSR     neg_long
            MOVE.L  D0,(A2)
            BRA.S   .ende

.IsMem:     BSR     Get_rm_Offset
            BSR     asm_rdl                 ; D0 = (A2)
            MOVE.W  (.mem_optab.B,PC,D3.W*2),D3
            JMP     .mem_optab(PC,D3.W)

.mem_optab: DC.W    .fkt_test - .mem_optab
            DC.W    .default  - .mem_optab
            DC.W    .mem_not  - .mem_optab
            DC.W    .mem_neg  - .mem_optab
            DC.W    .fkt_mul  - .mem_optab
            DC.W    .fkt_imul - .mem_optab
            DC.W    .fkt_div  - .mem_optab
            DC.W    .fkt_idiv - .mem_optab

.fkt_test:  MOVE.B  D0,D1
            BSR     asm_fetchlong
            BSR     and_long                ; test ist kommutativ
            BRA.S   .ende

.mem_not:   NOT.L   D0
            BSR     asm_wrl
            BRA.S   .ende

.mem_neg:   BSR     neg_long
            BSR     asm_wrl
            BRA.S   .ende

;.fkt_mul:         BSR       mul_long
;                  BRA.S     .ende
.fkt_mul:   BRA     halt_sys

;.fkt_imul:        BSR       imul_long
;                  BRA.S     .ende
.fkt_imul:  BRA     halt_sys

;.fkt_div:         BSR       div_long
;                  BRA.S     .ende
.fkt_div:   BRA     halt_sys

;.fkt_idiv:        BSR       idiv_long
.fkt_idiv:  BRA     halt_sys

.ende:      BRA     MainLoopEnd_OSC32

