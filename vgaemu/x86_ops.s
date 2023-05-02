;****************************************************************************
; $Id: x86_ops.s,v 1.3 2003/12/28 22:14:16 rincewind Exp $
;****************************************************************************
; $Log: x86_ops.s,v $
; Revision 1.3  2003/12/28 22:14:16  rincewind
; - fix CVS headers
;
; Revision 1.2  2000/06/19 20:52:35  rincewind
; - misc cleanup
;****************************************************************************

            IMPORT  push_segword
            IMPORT  pop_segword
            IMPORT  push_word
            IMPORT  pop_word

            if      0
            IMPORT  adc_byte
            IMPORT  adc_word
            IMPORT  add_byte
            IMPORT  add_word
            IMPORT  and_byte
            IMPORT  and_word
            IMPORT  dec_byte
            IMPORT  dec_word
            IMPORT  inc_byte
            IMPORT  inc_word
            IMPORT  or_byte
            IMPORT  or_word
            IMPORT  neg_byte
            IMPORT  neg_word
            IMPORT  not_byte
            IMPORT  not_word
            IMPORT  rcl_byte
            IMPORT  rcl_word
            IMPORT  rcr_byte
            IMPORT  rcr_word
            IMPORT  rol_byte
            IMPORT  rol_word
            IMPORT  ror_byte
            IMPORT  ror_word
            IMPORT  shl_byte
            IMPORT  shl_word
            IMPORT  shr_byte
            IMPORT  shr_word
            IMPORT  sar_byte
            IMPORT  sar_word
            IMPORT  sbb_byte
            IMPORT  sbb_word
            IMPORT  sub_byte
            IMPORT  sub_word
            IMPORT  xor_byte
            IMPORT  xor_word
            IMPORT  imul_byte
            IMPORT  imul_word
            IMPORT  mul_byte
            IMPORT  mul_word
            IMPORT  idiv_byte
            IMPORT  idiv_word
            IMPORT  div_byte
            IMPORT  div_word
            IMPORT  movs
            IMPORT  cmps
            IMPORT  stos
            IMPORT  lods
            IMPORT  scas
            IMPORT  ins
            IMPORT  outs
            else
            INCLUDE "X86_POPS.S"
            endif
            IMPORT  asm_inb
            IMPORT  asm_inw
            IMPORT  asm_outb
            IMPORT  asm_outw

            IMPORT  TestZeroFlag
            IMPORT  FlagsToPC
            IMPORT  FlagsFromPC
            IMPORT  halt_sys

            IMPORT  bios_intr_tab

            IMPORT  ParityTab
            IMPORT  x86_parity_tab
            IMPORT  x86_optab32

            IMPORT  sys

            IMPORT  MainLoopEnd_OSC
            IMPORT  MainLoopEnd

; Externals aus X86_DEC.S
            XREF    asm_fetchbyte
            XREF    asm_fetchbyte_word
            XREF    asm_fetchword
            XREF    asm_fetchword_long
            XREF    asm_fetchlong
            XREF    asm_rdb
            XREF    asm_rdw
            XREF    asm_wrb
            XREF    asm_wrw
            XREF    get_src_byte
            XREF    get_src_word
            XREF    GetOffsetSeg
            XREF    Get_rm_Offset

            EXPORT  x86_optab

;           INCLUDE "X86_REGS.INC"

            TEXT

            MACRO   TBL  fkt
            DC.W    fkt - x86_optab
            ENDM

x86_optab:  TBL     x86op_add_byte_RM_R
            TBL     x86op_add_word_RM_R
            TBL     x86op_add_byte_R_RM
            TBL     x86op_add_word_R_RM
            TBL     x86op_add_byte_AL_IMM
            TBL     x86op_add_word_AX_IMM
            TBL     x86op_push_ES
            TBL     x86op_pop_ES

            TBL     x86op_or_byte_RM_R
            TBL     x86op_or_word_RM_R
            TBL     x86op_or_byte_R_RM
            TBL     x86op_or_word_R_RM
            TBL     x86op_or_byte_AL_IMM
            TBL     x86op_or_word_AX_IMM
            TBL     x86op_push_CS
            TBL     x86op_two_byte

            TBL     x86op_adc_byte_RM_R
            TBL     x86op_adc_word_RM_R
            TBL     x86op_adc_byte_R_RM
            TBL     x86op_adc_word_R_RM
            TBL     x86op_adc_byte_AL_IMM
            TBL     x86op_adc_word_AX_IMM
            TBL     x86op_push_SS
            TBL     x86op_pop_SS

            TBL     x86op_sbb_byte_RM_R
            TBL     x86op_sbb_word_RM_R
            TBL     x86op_sbb_byte_R_RM
            TBL     x86op_sbb_word_R_RM
            TBL     x86op_sbb_byte_AL_IMM
            TBL     x86op_sbb_word_AX_IMM
            TBL     x86op_push_DS
            TBL     x86op_pop_DS

            TBL     x86op_and_byte_RM_R
            TBL     x86op_and_word_RM_R
            TBL     x86op_and_byte_R_RM
            TBL     x86op_and_word_R_RM
            TBL     x86op_and_byte_AL_IMM
            TBL     x86op_and_word_AX_IMM
            TBL     x86op_segovr_ES
            TBL     x86op_daa

            TBL     x86op_sub_byte_RM_R
            TBL     x86op_sub_word_RM_R
            TBL     x86op_sub_byte_R_RM
            TBL     x86op_sub_word_R_RM
            TBL     x86op_sub_byte_AL_IMM
            TBL     x86op_sub_word_AX_IMM
            TBL     x86op_segovr_CS
            TBL     x86op_das

            TBL     x86op_xor_byte_RM_R
            TBL     x86op_xor_word_RM_R
            TBL     x86op_xor_byte_R_RM
            TBL     x86op_xor_word_R_RM
            TBL     x86op_xor_byte_AL_IMM
            TBL     x86op_xor_word_AX_IMM
            TBL     x86op_segovr_SS
            TBL     x86op_aaa

            TBL     x86op_cmp_byte_RM_R
            TBL     x86op_cmp_word_RM_R
            TBL     x86op_cmp_byte_R_RM
            TBL     x86op_cmp_word_R_RM
            TBL     x86op_cmp_byte_AL_IMM
            TBL     x86op_cmp_word_AX_IMM
            TBL     x86op_segovr_DS
            TBL     x86op_aas

            TBL     x86op_inc_word_reg
            TBL     x86op_inc_word_reg
            TBL     x86op_inc_word_reg
            TBL     x86op_inc_word_reg
            TBL     x86op_inc_word_reg
            TBL     x86op_inc_word_reg
            TBL     x86op_inc_word_reg
            TBL     x86op_inc_word_reg

            TBL     x86op_dec_word_reg
            TBL     x86op_dec_word_reg
            TBL     x86op_dec_word_reg
            TBL     x86op_dec_word_reg
            TBL     x86op_dec_word_reg
            TBL     x86op_dec_word_reg
            TBL     x86op_dec_word_reg
            TBL     x86op_dec_word_reg

            TBL     x86op_push_word_reg
            TBL     x86op_push_word_reg
            TBL     x86op_push_word_reg
            TBL     x86op_push_word_reg
            TBL     x86op_push_word_reg
            TBL     x86op_push_word_reg
            TBL     x86op_push_word_reg
            TBL     x86op_push_word_reg

            TBL     x86op_pop_word_reg
            TBL     x86op_pop_word_reg
            TBL     x86op_pop_word_reg
            TBL     x86op_pop_word_reg
            TBL     x86op_pop_word_reg
            TBL     x86op_pop_word_reg
            TBL     x86op_pop_word_reg
            TBL     x86op_pop_word_reg

            TBL     x86op_push_all
            TBL     x86op_pop_all
            TBL     x86op_illegal_op
            TBL     x86op_illegal_op
            TBL     x86op_segovr_FS
            TBL     x86op_segovr_GS
            TBL     x86op_prefix_data
            TBL     x86op_prefix_adr

            TBL     x86op_illegal_op
            TBL     x86op_illegal_op
            TBL     x86op_illegal_op
            TBL     x86op_illegal_op
            TBL     x86op_ins_byte
            TBL     x86op_ins_word
            TBL     x86op_outs_byte
            TBL     x86op_outs_word

            TBL     x86op_jump_O_near
            TBL     x86op_jump_NO_near
            TBL     x86op_jump_B_near
            TBL     x86op_jump_NB_near
            TBL     x86op_jump_Z_near
            TBL     x86op_jump_NZ_near
            TBL     x86op_jump_BE_near
            TBL     x86op_jump_NBE_near

            TBL     x86op_jump_S_near
            TBL     x86op_jump_NS_near
            TBL     x86op_jump_P_near
            TBL     x86op_jump_NP_near
            TBL     x86op_jump_L_near
            TBL     x86op_jump_NL_near
            TBL     x86op_jump_LE_near
            TBL     x86op_jump_NLE_near

            TBL     x86op_opc80_byte_RM_IMM
            TBL     x86op_opc81_word_RM_IMM
            TBL     x86op_opc80_byte_RM_IMM
            TBL     x86op_opc83_word_RM_IMM
            TBL     x86op_test_byte_RM_R
            TBL     x86op_test_word_RM_R
            TBL     x86op_xchg_byte_RM_R
            TBL     x86op_xchg_word_RM_R

            TBL     x86op_mov_byte_RM_R
            TBL     x86op_mov_word_RM_R
            TBL     x86op_mov_byte_R_RM
            TBL     x86op_mov_word_R_RM
            TBL     x86op_mov_word_RM_SR
            TBL     x86op_lea_word_R_M
            TBL     x86op_mov_word_SR_RM
            TBL     x86op_pop_RM

            TBL     x86op_xchg_word_AX_R
            TBL     x86op_xchg_word_AX_R
            TBL     x86op_xchg_word_AX_R
            TBL     x86op_xchg_word_AX_R
            TBL     x86op_xchg_word_AX_R
            TBL     x86op_xchg_word_AX_R
            TBL     x86op_xchg_word_AX_R
            TBL     x86op_xchg_word_AX_R

            TBL     x86op_cbw
            TBL     x86op_cwd
            TBL     x86op_call_far_IMM
            TBL     x86op_wait
            TBL     x86op_pushf
            TBL     x86op_popf
            TBL     x86op_sahf
            TBL     x86op_lahf

            TBL     x86op_mov_AL_M_IMM
            TBL     x86op_mov_AX_M_IMM
            TBL     x86op_mov_M_AL_IMM
            TBL     x86op_mov_M_AX_IMM
            TBL     x86op_movs_byte
            TBL     x86op_movs_word
            TBL     x86op_cmps_byte
            TBL     x86op_cmps_word

            TBL     x86op_test_AL_IMM
            TBL     x86op_test_AX_IMM
            TBL     x86op_stos_byte
            TBL     x86op_stos_word
            TBL     x86op_lods_byte
            TBL     x86op_lods_word
            TBL     x86op_scas_byte
            TBL     x86op_scas_word

            TBL     x86op_mov_byte_R_IMM
            TBL     x86op_mov_byte_R_IMM
            TBL     x86op_mov_byte_R_IMM
            TBL     x86op_mov_byte_R_IMM
            TBL     x86op_mov_byte_R_IMM
            TBL     x86op_mov_byte_R_IMM
            TBL     x86op_mov_byte_R_IMM
            TBL     x86op_mov_byte_R_IMM

            TBL     x86op_mov_word_R_IMM
            TBL     x86op_mov_word_R_IMM
            TBL     x86op_mov_word_R_IMM
            TBL     x86op_mov_word_R_IMM
            TBL     x86op_mov_word_R_IMM
            TBL     x86op_mov_word_R_IMM
            TBL     x86op_mov_word_R_IMM
            TBL     x86op_mov_word_R_IMM

            TBL     x86op_opcC0_byte_RM_MEM
            TBL     x86op_opcC1_word_RM_MEM
            TBL     x86op_ret_near_IMM
            TBL     x86op_ret_near
            TBL     x86op_les_R_IMM
            TBL     x86op_lds_R_IMM
            TBL     x86op_mov_byte_RM_IMM
            TBL     x86op_mov_word_RM_IMM

            TBL     x86op_illegal_op
            TBL     x86op_illegal_op
            TBL     x86op_ret_far_IMM
            TBL     x86op_ret_far
            TBL     x86op_int3
            TBL     x86op_int_IMM
            TBL     x86op_into
            TBL     x86op_iret

            TBL     x86op_opcD0_byte_RM_1
            TBL     x86op_opcD1_word_RM_1
            TBL     x86op_opcD2_byte_RM_CL
            TBL     x86op_opcD3_word_RM_CL
            TBL     x86op_aam
            TBL     x86op_aad
            TBL     x86op_illegal_op
            TBL     x86op_xlat

            TBL     x86op_illegal_op
            TBL     x86op_illegal_op
            TBL     x86op_illegal_op
            TBL     x86op_illegal_op
            TBL     x86op_illegal_op
            TBL     x86op_illegal_op
            TBL     x86op_illegal_op
            TBL     x86op_illegal_op

            TBL     x86op_loopne
            TBL     x86op_loope
            TBL     x86op_loop
            TBL     x86op_jcxz
            TBL     x86op_in_byte_AL_IMM
            TBL     x86op_in_word_AX_IMM
            TBL     x86op_out_byte_IMM_AL
            TBL     x86op_out_word_IMM_AX

            TBL     x86op_call_near_IMM
            TBL     x86op_jump_near_IMM
            TBL     x86op_jump_far_IMM
            TBL     x86op_jump_byte_IMM
            TBL     x86op_in_byte_AL_DX
            TBL     x86op_in_word_AX_DX
            TBL     x86op_out_byte_DX_AL
            TBL     x86op_out_word_DX_AX

            TBL     x86op_lock
            TBL     x86op_illegal_op
            TBL     x86op_repne
            TBL     x86op_repe
            TBL     x86op_halt
            TBL     x86op_cmc
            TBL     x86op_opcF6_byte_RM
            TBL     x86op_opcF7_word_RM

            TBL     x86op_clc
            TBL     x86op_stc
            TBL     x86op_cli
            TBL     x86op_sti
            TBL     x86op_cld
            TBL     x86op_std
            TBL     x86op_opcFE_byte_RM
            TBL     x86op_opcFF_word_RM

x86op_illegal_op: BRA halt_sys

;***************************************************************
; x86op_add_byte_RM_R
;***************************************************************
x86op_add_byte_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVEA.L (shortcut,A6,D4.W*4),A1
            MOVE.B  (A1),D1                 ; Quelle nach D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVEA.L (shortcut,A6,D4.W*4),A2
            MOVE.B  (A2),D0
            BSR     add_byte
            MOVE.B  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdb                 ; D0 = (A2)
            BSR     add_byte                ; D0 = D0 + D1
            BSR     asm_wrb                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_add_word_RM_R
;***************************************************************
x86op_add_word_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (AX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (AX,A6,D4.W*4),A2
            MOVE.W  (A2),D0
            BSR     add_word
            MOVE.W  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdw                 ; D0 = (A2)
            BSR     add_word                ; D0 = D0 + D1
            BSR     asm_wrw                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_add_byte_R_RM
;***************************************************************
x86op_add_byte_R_RM:
            BSR     get_src_byte            ; D1 = byte , D3 = reg
            MOVEA.L (shortcut,A6,D3.W*4),A2
            MOVE.B  (A2),D0
            BSR     add_byte
            MOVE.B  D0,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_add_word_R_RM
;***************************************************************
x86op_add_word_R_RM:
            BSR     get_src_word            ; D1 = word , D3 = reg
            LEA     (AX,A6,D3.W*4),A2
            MOVE.W  (A2),D0
            BSR     add_word
            MOVE.W  D0,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_add_byte_AL_IMM
;***************************************************************
x86op_add_byte_AL_IMM:
            BSR     asm_fetchbyte           ; D0 = IMM
            MOVE.B  AL(A6),D1
            BSR     add_byte
            MOVE.B  D0,AL(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_add_word_AX_IMM
;***************************************************************
x86op_add_word_AX_IMM:
            BSR     asm_fetchword           ; D0 = IMM
            MOVE.W  AX(A6),D1
            BSR     add_word
            MOVE.W  D0,AX(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_push_ES
;***************************************************************
x86op_push_ES:
            MOVE.L  (ES,A6),D0
            BSR     push_segword
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_pop_ES
;***************************************************************
x86op_pop_ES:
            BSR     pop_segword
            MOVE.L  D0,(ES,A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_or_byte_RM_R
;***************************************************************
x86op_or_byte_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVEA.L (shortcut,A6,D4.W*4),A1
            MOVE.B  (A1),D1                 ; Quelle nach D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVEA.L (shortcut,A6,D4.W*4),A2
            MOVE.B  (A2),D0
            BSR     or_byte
            MOVE.B  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdb                 ; D0 = (A2)
            BSR     or_byte                 ; D0 = D0 # D1
            BSR     asm_wrb                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_or_word_RM_R
;***************************************************************
x86op_or_word_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (AX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (AX,A6,D4.W*4),A2
            MOVE.W  (A2),D0
            BSR     or_word
            MOVE.W  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdw                 ; D0 = (A2)
            BSR     or_word                 ; D0 = D0 # D1
            BSR     asm_wrw                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_or_byte_R_RM
;***************************************************************
x86op_or_byte_R_RM:
            BSR     get_src_byte            ; D1 = byte , D3 = reg
            MOVEA.L (shortcut,A6,D3.W*4),A2
            MOVE.B  (A2),D0
            BSR     or_byte
            MOVE.B  D0,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_or_word_R_RM
;***************************************************************
x86op_or_word_R_RM:
            BSR     get_src_word            ; D1 = word , D3 = reg
            LEA     (AX,A6,D3.W*4),A2
            MOVE.W  (A2),D0
            BSR     or_word
            MOVE.W  D0,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_or_byte_AL_IMM
;***************************************************************
x86op_or_byte_AL_IMM:
            BSR     asm_fetchbyte           ; D0 = IMM
            MOVE.B  (AL,A6),D1
            BSR     or_byte
            MOVE.B  D0,(AL,A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_or_word_AX_IMM
;***************************************************************
x86op_or_word_AX_IMM:
            BSR     asm_fetchword           ; D0 = IMM
            MOVE.W  (AX,A6),D1
            BSR     or_word
            MOVE.W  D0,(AX,A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_push_CS
;***************************************************************
x86op_push_CS:
            MOVE.L  (CS,A6),D0
            BSR     push_segword
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_two_byte
;***************************************************************
x86op_two_byte:
            bsr     asm_fetchbyte_word      ; Hi Byte 0
            MOVE.B  D0,D3
            SUB.B   #$80,D0
            CMP.B   #$3F,D0
            BHI     .default
            MOVE.W  (.optab.B,PC,D0.W*2),D0
            JMP     .optab(PC,D0.W)

.optab:     DC.W    .jo   - .optab              ; 80
            DC.W    .jno  - .optab
            DC.W    .jb   - .optab
            DC.W    .jnb  - .optab
            DC.W    .jz   - .optab
            DC.W    .jnz  - .optab
            DC.W    .jbe  - .optab
            DC.W    .jnbe - .optab
            DC.W    .js   - .optab              ; 88
            DC.W    .jns  - .optab
            DC.W    .jp   - .optab
            DC.W    .jnp  - .optab
            DC.W    .jl   - .optab
            DC.W    .jnl  - .optab
            DC.W    .jle  - .optab
            DC.W    .jnle - .optab
            DC.W    .default - .optab            ; 90
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab            ; 98
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .default - .optab
            DC.W    .push_fs - .optab            ; A0
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

.jo:        BSR     asm_fetchword
            MOVE.W  D6,CCR
            BVS.S   .DoJump
            BRA     MainLoopEnd_OSC

.jno:       BSR     asm_fetchword
            MOVE.W  D6,CCR
            BVC.S   .DoJump
            BRA     MainLoopEnd_OSC

.jb:        BSR     asm_fetchword
            MOVE.W  D6,CCR
            BCS.S   .DoJump
            BRA     MainLoopEnd_OSC

.jnb:       BSR     asm_fetchword
            MOVE.W  D6,CCR
            BCC.S   .DoJump
            BRA     MainLoopEnd_OSC

.jz:        BSR     asm_fetchword
            MOVE.W  D6,CCR
            BEQ.S   .DoJump
            BRA     MainLoopEnd_OSC

.jnz:       BSR     asm_fetchword
            MOVE.W  D6,CCR
            BNE.S   .DoJump
            BRA     MainLoopEnd_OSC

.jbe:       BSR     asm_fetchword
            MOVE.W  D6,CCR
            BLS.S   .DoJump
            BRA     MainLoopEnd_OSC

.jnbe:      BSR     asm_fetchword
            MOVE.W  D6,CCR
            BHI.S   .DoJump
            BRA     MainLoopEnd_OSC

.js:        BSR     asm_fetchword
            MOVE.W  D6,CCR
            BMI.S   .DoJump
            BRA     MainLoopEnd_OSC

.DoJump:    EXT.L   D0
            ADD.L   D0,EIP(A6)
            BRA     MainLoopEnd_OSC

.jns:       BSR     asm_fetchword
            MOVE.W  D6,CCR
            BPL.S   .DoJump
            BRA     MainLoopEnd_OSC

.jp:        BSR     asm_fetchword
            MOVE.L  D6,D1
            SWAP    D1
            AND.L   #$FF,D1
            BFTST   (ParityTab,PC){D1:1}
            BNE.S   .DoJump
            BRA     MainLoopEnd_OSC

.jnp:       BSR     asm_fetchword
            MOVE.L  D6,D1
            SWAP    D1
            AND.L   #$FF,D1
            BFTST   (ParityTab,PC){D1:1}
            BEQ.S   .DoJump
            BRA     MainLoopEnd_OSC

.jl:        BSR     asm_fetchword
            MOVE.W  D6,CCR
            BLT.S   .DoJump
            BRA     MainLoopEnd_OSC

.jnl:       BSR     asm_fetchword
            MOVE.W  D6,CCR
            BGE.S   .DoJump
            BRA     MainLoopEnd_OSC

.jle:       BSR     asm_fetchword
            MOVE.W  D6,CCR
            BLE.S   .DoJump
            BRA     MainLoopEnd_OSC

.jnle:      BSR     asm_fetchword
            MOVE.W  D6,CCR
            BGT.S   .DoJump
            BRA     MainLoopEnd_OSC

.push_fs:   MOVE.L  FS(A6),D0
            BSR     push_segword
            BRA.S   .ende

.pop_fs:    BSR     pop_segword
            MOVE.L  D0,FS(A6)
            BRA.S   .ende

.push_gs:   MOVE.L  GS(A6),D0
            BSR     push_segword
            BRA.S   .ende

.pop_gs:    BSR     pop_segword
            MOVE.L  D0,GS(A6)
            BRA.S   .ende

.movezxb:   BSR     get_src_byte            ; D1 = byte , D3 = reg
            CLR.W   D0
            MOVE.B  D1,D0
            MOVE.W  D0,(AX,A6,D3.W*4)
            BRA.S   .ende

.movezxw:   BSR     get_src_word            ; D1 = byte , D3 = reg
            MOVE.W  D1,(AX,A6,D3.W*4)
            BRA.S   .ende

.movesxb:   BSR     get_src_byte            ; D1 = byte , D3 = reg
            EXT.W   D1
            MOVE.W  D1,(AX,A6,D3.W*4)
            BRA.S   .ende

.movesxw:   BSR     get_src_word            ; D1 = byte , D3 = reg
            MOVE.W  D1,(AX,A6,D3.W*4)
            BRA.S   .ende

.default:   BRA     halt_sys
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_adc_byte_RM_R
;***************************************************************
x86op_adc_byte_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVEA.L (shortcut,A6,D4.W*4),A1
            MOVE.B  (A1),D1                 ; Quelle nach D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVEA.L (shortcut,A6,D4.W*4),A2
            MOVE.B  (A2),D0
            BSR     adc_byte
            MOVE.B  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdb                 ; D0 = (A2)
            BSR     adc_byte                ; D0 = D0 + D1
            BSR     asm_wrb                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_adc_word_RM_R
;***************************************************************
x86op_adc_word_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (AX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (AX,A6,D4.W*4),A2
            MOVE.W  (A2),D0
            BSR     adc_word
            MOVE.W  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdw                 ; D0 = (A2)
            BSR     adc_word                ; D0 = D0 + D1
            BSR     asm_wrw                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_adc_byte_R_RM
;***************************************************************
x86op_adc_byte_R_RM:
            BSR     get_src_byte            ; D1 = byte , D3 = reg
            MOVEA.L (shortcut,A6,D3.W*4),A2
            MOVE.B  (A2),D0
            BSR     adc_byte
            MOVE.B  D0,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_adc_word_R_RM
;***************************************************************
x86op_adc_word_R_RM:
            BSR     get_src_word            ; D1 = word , D3 = reg
            LEA     (AX,A6,D3.W*4),A2
            MOVE.W  (A2),D0
            BSR     adc_word
            MOVE.W  D0,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_adc_byte_AL_IMM
;***************************************************************
x86op_adc_byte_AL_IMM:
            BSR     asm_fetchbyte           ; D0 = IMM
            MOVE.B  AL(A6),D1
            BSR     adc_byte
            MOVE.B  D0,AL(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_adc_word_AX_IMM
;***************************************************************
x86op_adc_word_AX_IMM:
            BSR     asm_fetchword           ; D0 = IMM
            MOVE.W  AX(A6),D1
            BSR     adc_word
            MOVE.W  D0,AX(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_push_SS
;***************************************************************
x86op_push_SS:
            MOVE.L  SS(A6),D0
            BSR     push_segword
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_pop_SS
;***************************************************************
x86op_pop_SS:
            BSR     pop_segword
            MOVE.L  D0,SS(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_sbb_byte_RM_R
;***************************************************************
x86op_sbb_byte_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVEA.L (shortcut,A6,D4.W*4),A1
            MOVE.B  (A1),D1                 ; Quelle nach D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVEA.L (shortcut,A6,D4.W*4),A2
            MOVE.B  (A2),D0
            BSR     sbb_byte
            MOVE.B  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdb                 ; D0 = (A2)
            BSR     sbb_byte                ; D0 = D0 + D1
            BSR     asm_wrb                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_sbb_word_RM_R
;***************************************************************
x86op_sbb_word_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (AX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (AX,A6,D4.W*4),A2
            MOVE.W  (A2),D0
            BSR     sbb_word
            MOVE.W  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdw                 ; D0 = (A2)
            BSR     sbb_word                ; D0 = D0 + D1
            BSR     asm_wrw                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_sbb_byte_R_RM
;***************************************************************
x86op_sbb_byte_R_RM:
            BSR     get_src_byte            ; D1 = byte , D3 = reg
            MOVEA.L (shortcut,A6,D3.W*4),A2
            MOVE.B  (A2),D0
            BSR     sbb_byte
            MOVE.B  D0,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_sbb_word_R_RM
;***************************************************************
x86op_sbb_word_R_RM:
            BSR     get_src_word            ; D1 = word , D3 = reg
            LEA     (AX,A6,D3.W*4),A2
            MOVE.W  (A2),D0
            BSR     sbb_word
            MOVE.W  D0,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_sbb_byte_AL_IMM
;***************************************************************
x86op_sbb_byte_AL_IMM:
            BSR     asm_fetchbyte           ; D0 = IMM
            MOVE.B  D0,D1
            MOVE.B  AL(A6),D0
            BSR     sbb_byte
            MOVE.B  D0,(AL,A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_sbb_word_AX_IMM
;***************************************************************
x86op_sbb_word_AX_IMM:
            BSR     asm_fetchword           ; D0 = IMM
            MOVE.W  D0,D1
            MOVE.W  AX(A6),D0
            BSR     sbb_word
            MOVE.W  D0,(AX,A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_push_DS
;***************************************************************
x86op_push_DS:
            MOVE.L  DS(A6),D0
            BSR     push_segword
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_pop_SS
;***************************************************************
x86op_pop_DS:
            BSR     pop_segword
            MOVE.L  D0,DS(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_and_byte_RM_R
;***************************************************************
x86op_and_byte_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVEA.L (shortcut,A6,D4.W*4),A1
            MOVE.B  (A1),D1                 ; Quelle nach D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVEA.L (shortcut,A6,D4.W*4),A2
            MOVE.B  (A2),D0
            BSR     and_byte
            MOVE.B  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdb                 ; D0 = (A2)
            BSR     and_byte                ; D0 = D0 & D1
            BSR     asm_wrb                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_and_word_RM_R
;***************************************************************
x86op_and_word_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (AX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (AX,A6,D4.W*4),A2
            MOVE.W  (A2),D0
            BSR     and_word
            MOVE.W  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdw                 ; D0 = (A2)
            BSR     and_word                ; D0 = D0 & D1
            BSR     asm_wrw                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_and_byte_R_RM
;***************************************************************
x86op_and_byte_R_RM:
            BSR     get_src_byte            ; D1 = byte , D3 = reg
            MOVEA.L (shortcut,A6,D3.W*4),A2
            MOVE.B  (A2),D0
            BSR     and_byte
            MOVE.B  D0,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_and_word_R_RM
;***************************************************************
x86op_and_word_R_RM:
            BSR     get_src_word            ; D1 = word , D3 = reg
            LEA     (AX,A6,D3.W*4),A2
            MOVE.W  (A2),D0
            BSR     and_word
            MOVE.W  D0,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_and_byte_AL_IMM
;***************************************************************
x86op_and_byte_AL_IMM:
            BSR     asm_fetchbyte           ; D0 = IMM
            MOVE.B  AL(A6),D1
            BSR     and_byte
            MOVE.B  D0,AL(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_and_word_AX_IMM
;***************************************************************
x86op_and_word_AX_IMM:
            BSR     asm_fetchword           ; D0 = IMM
            MOVE.W  AX(A6),D1
            BSR     and_word
            MOVE.W  D0,AX(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_segovr_ES
;***************************************************************
x86op_segovr_ES:
            MOVE.L  ES(A6),D0
            OR.L    D0,D7
            BRA     MainLoopEnd

;***************************************************************
; x86op_daa
; if (AF | (AL & 0xf) > 9) then
;    AL += 6
;    AF = 1
; else
;    AF = 0            ; nicht nîtig
; endif
; if (CF | (AL > 0x9F)) then
;    AL += 0x60
;    CF = 1
; else
;    CF = 0            ; nicht nîtig
; endif
;***************************************************************
x86op_daa:  MOVE.B  AL(A6),D3
            BTST.L  #27,D6                  ; AF testen
            BNE.S   .is_AF
            MOVEQ   #$F,D1
            AND.B   D3,D1                   ; D1 = AL & 0xf
            CMP.B   #9,D1
            BLE.S   .cont1
            BSET.L  #27,D6                  ; AF setzen
.is_AF:     ADDQ.B  #6,D3

.cont1:     BTST.L  #0,D6                   ; CF testen
            BNE.S   .is_CF
            CMP.B   #$9F,D3
            BLE.S   .cont2
            ORI.W   #1,D6                   ; CF setzen
.is_CF:     ADD.B   #$60,D3

.cont2:     AND.W   #$1,D6                  ; Alle Flags bis auf Carry rÅcksetzen
            SWAP    D6
            MOVE.B  D3,D6                   ; Parity nicht vergessen
            SWAP    D6
            MOVE.B  D3,AL(A6)               ; zurÅckschreiben
            MOVE.W  CCR,D3                  ; Flags holen (CF = 0)
            OR.B    D3,D6                   ; Flags nach D6 Åbernehmen
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_sub_byte_RM_R
;***************************************************************
x86op_sub_byte_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVEA.L (shortcut,A6,D4.W*4),A1
            MOVE.B  (A1),D1                 ; Quelle nach D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVEA.L (shortcut,A6,D4.W*4),A2
            MOVE.B  (A2),D0
            BSR     sub_byte
            MOVE.B  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdb                 ; D0 = (A2)
            BSR     sub_byte                ; D0 = D0 + D1
            BSR     asm_wrb                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_sub_word_RM_R
;***************************************************************
x86op_sub_word_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (AX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (AX,A6,D4.W*4),A2
            MOVE.W  (A2),D0
            BSR     sub_word
            MOVE.W  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdw                 ; D0 = (A2)
            BSR     sub_word                ; D0 = D0 + D1
            BSR     asm_wrw                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_sub_byte_R_RM
;***************************************************************
x86op_sub_byte_R_RM:
            BSR     get_src_byte            ; D1 = byte , D3 = reg
            MOVEA.L (shortcut,A6,D3.W*4),A2
            MOVE.B  (A2),D0
            BSR     sub_byte
            MOVE.B  D0,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_sub_word_R_RM
;***************************************************************
x86op_sub_word_R_RM:
            BSR     get_src_word            ; D1 = word , D3 = reg
            LEA     (AX,A6,D3.W*4),A2
            MOVE.W  (A2),D0
            BSR     sub_word
            MOVE.W  D0,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_sub_byte_AL_IMM
;***************************************************************
x86op_sub_byte_AL_IMM:
            BSR     asm_fetchbyte           ; D0 = IMM
            MOVE.B  D0,D1
            MOVE.B  AL(A6),D0
            BSR     sub_byte
            MOVE.B  D0,AL(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_sub_word_AX_IMM
;***************************************************************
x86op_sub_word_AX_IMM:
            BSR     asm_fetchword           ; D0 = IMM
            MOVE.W  D0,D1
            MOVE.W  AX(A6),D0
            BSR     sub_word
            MOVE.W  D0,(AX,A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_segovr_CS
;***************************************************************
x86op_segovr_CS:
            MOVE.L  CS(A6),D0
            OR.L    D0,D7
            BRA     MainLoopEnd

;***************************************************************
; x86op_das
; if (AF | (AL & 0xf) > 9) then
;    AL -= 6
;    AF = 1
; else
;    AF = 0            ; nicht nîtig
; endif
; if (CF | (AL > 0x9F)) then
;    AL -= 0x60
;    CF = 1
; else
;    CF = 0            ; nicht nîtig
; endif
;***************************************************************
x86op_das:  MOVE.B  AL(A6),D3
            BTST.L  #27,D6                  ; AF testen
            BNE.S   .is_AF
            MOVEQ   #$F,D1
            AND.B   D3,D1                   ; D1 = AL & 0xf
            CMP.B   #9,D1
            BLE.S   .cont1
            BSET.L  #27,D6                  ; AF setzen
.is_AF:     SUBQ.B  #6,D3

.cont1:     BTST.L  #0,D6                   ; CF testen
            BNE.S   .is_CF
            CMP.B   #$9F,D3
            BLE.S   .cont2
            ORI.W   #1,D6                   ; CF setzen
.is_CF:     SUB.B   #$60,D3

.cont2:     AND.W   #$1,D6                  ; Alle Flags bis auf Carry rÅcksetzen
            SWAP    D6
            MOVE.B  D3,D6                   ; Parity nicht vergessen
            SWAP    D6
            MOVE.B  D3,AL(A6)               ; zurÅckschreiben
            MOVE.W  CCR,D3                  ; Flags holen (CF = 0)
            OR.B    D3,D6                   ; Flags nach D6 Åbernehmen
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_xor_byte_RM_R
;***************************************************************
x86op_xor_byte_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVEA.L (shortcut,A6,D4.W*4),A1
            MOVE.B  (A1),D1                 ; Quelle nach D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVEA.L (shortcut,A6,D4.W*4),A2
            MOVE.B  (A2),D0
            BSR     xor_byte
            MOVE.B  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdb                 ; D0 = (A2)
            BSR     xor_byte                ; D0 = D0 ^  D1
            BSR     asm_wrb                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_xor_word_RM_R
;***************************************************************
x86op_xor_word_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (AX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (AX,A6,D4.W*4),A2
            MOVE.W  (A2),D0
            BSR     xor_word
            MOVE.W  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdw                 ; D0 = (A2)
            BSR     xor_word                ; D0 = D0 ^  D1
            BSR     asm_wrw                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_xor_byte_R_RM
;***************************************************************
x86op_xor_byte_R_RM:
            BSR     get_src_byte            ; D1 = byte , D3 = reg
            MOVEA.L (shortcut,A6,D3.W*4),A2
            MOVE.B  (A2),D0
            BSR     xor_byte
            MOVE.B  D0,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_xor_word_R_RM
;***************************************************************
x86op_xor_word_R_RM:
            BSR     get_src_word            ; D1 = word , D3 = reg
            LEA     (AX,A6,D3.W*4),A2
            MOVE.W  (A2),D0
            BSR     xor_word
            MOVE.W  D0,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_xor_byte_AL_IMM
;***************************************************************
x86op_xor_byte_AL_IMM:
            BSR     asm_fetchbyte           ; D0 = IMM
            MOVE.B  AL(A6),D1
            BSR     xor_byte
            MOVE.B  D0,AL(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_xor_word_AX_IMM
;***************************************************************
x86op_xor_word_AX_IMM:
            BSR     asm_fetchword           ; D0 = IMM
            MOVE.W  AX(A6),D1
            BSR     xor_word
            MOVE.W  D0,AX(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_segovr_SS
;***************************************************************
x86op_segovr_SS:
            MOVE.L  SS(A6),D0
            OR.L    D0,D7
            BRA     MainLoopEnd

;***************************************************************
; x86op_aaa
; if (AF | (AL & 0xf) > 9) then
;    AL = (AL + 6) & 0xf
;    AH += 1;
;    CF = AF = 1
; else
;    CF = AF = 0            ; AF nicht nîtig
; endif
;***************************************************************
x86op_aaa:  MOVE.B  AL(A6),D3
            CLR.W   D6                      ; CF SF etc. lîschen
            BTST.L  #27,D6                  ; AF testen
            BNE.S   .is_AF
            MOVEQ   #$F,D1
            AND.B   D3,D1
            CMP.B   #9,D1
            BLE.S   .cont1
            BSET.L  #27,D6                  ; AF setzen
.is_AF:     ORI.W   #1,D6                   ; CF setzen
            ADDQ.B  #6,D3
            AND.B   #$F,D3
            ADDQ.B  #1,AH(A6)

.cont1:     SWAP    D6
            MOVE.B  D3,D6                   ; Parity nicht vergessen
            SWAP    D6
            MOVE.B  D3,AL(A6)               ; zurÅckschreiben
            MOVE.W  CCR,D3                  ; Flags holen (CF = 0)
            OR.B    D3,D6                   ; Flags nach D6 Åbernehmen
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_cmp_byte_RM_R
;***************************************************************
x86op_cmp_byte_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVEA.L (shortcut,A6,D4.W*4),A1
            MOVE.B  (A1),D1                 ; Quelle nach D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVEA.L (shortcut,A6,D4.W*4),A2
            MOVE.B  (A2),D0
            BSR     sub_byte
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdb                 ; D0 = (A2)
            BSR     sub_byte                ; D0 = D0 + D1
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_cmp_word_RM_R
;***************************************************************
x86op_cmp_word_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (AX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVE.W  (AX,A6,D4.W*4),D0
            BSR     sub_word
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdw                 ; D0 = (A2)
            BSR     sub_word                ; D0 = D0 + D1
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_cmp_byte_R_RM
;***************************************************************
x86op_cmp_byte_R_RM:
            BSR     get_src_byte            ; D1 = byte , D3 = reg
            MOVEA.L (shortcut,A6,D3.W*4),A2
            MOVE.B  (A2),D0
            BSR     sub_byte
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_cmp_word_R_RM
;***************************************************************
x86op_cmp_word_R_RM:
            BSR     get_src_word            ; D1 = word , D3 = reg
            MOVE.W  (AX,A6,D3.W*4),D0
            BSR     sub_word
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_cmp_byte_AL_IMM
;***************************************************************
x86op_cmp_byte_AL_IMM:
            BSR     asm_fetchbyte           ; D0 = IMM
            MOVE.B  D0,D1
            MOVE.B  AL(A6),D0
            BSR     sub_byte
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_cmp_word_AX_IMM
;***************************************************************
x86op_cmp_word_AX_IMM:
            BSR     asm_fetchword           ; D0 = IMM
            MOVE.W  D0,D1
            MOVE.W  AX(A6),D0
            BSR     sub_word
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_segovr_DS
;***************************************************************
x86op_segovr_DS:
            MOVE.L  DS(A6),D0
            OR.L    D0,D7
            BRA     MainLoopEnd

;***************************************************************
; x86op_aas
; if (AF | (AL & 0xf) > 9) then
;    AL = (AL - 6) & 0xf
;    AH -= 1;
;    CF = AF = 1
; else
;    CF = AF = 0            ; AF nicht nîtig
; endif
;***************************************************************
x86op_aas:  MOVE.B  AL(A6),D3
            CLR.W   D6                      ; CF SF etc. lîschen
            BTST.L  #27,D6                  ; AF testen
            BNE.S   .is_AF
            MOVEQ   #$F,D1
            AND.B   D3,D1
            CMP.B   #9,D1
            BLE.S   .cont1
            BSET.L  #27,D6                  ; AF setzen
.is_AF:     ORI.W   #1,D6                   ; CF setzen
            SUBQ.B  #6,D3
            AND.B   #$F,D3
            SUBQ.B  #1,AH(A6)

.cont1:     SWAP    D6
            MOVE.B  D3,D6                   ; Parity nicht vergessen
            SWAP    D6
            MOVE.B  D3,AL(A6)               ; zurÅckschreiben
            MOVE.W  CCR,D3                  ; Flags holen (CF = 0)
            OR.B    D3,D6                   ; Flags nach D6 Åbernehmen
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_inc_word_reg
;***************************************************************
x86op_inc_word_reg:
            AND.W   #7,D0                   ; opcode steht noch in D0
            LEA     (AX,A6,D0.W*4),A2
            MOVE.W  (A2),D0
            BSR     inc_word
            MOVE.W  D0,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_dec_word_reg
;***************************************************************
x86op_dec_word_reg:
            AND.W   #7,D0                   ; opcode steht noch in D0
            LEA     (AX,A6,D0.W*4),A2
            MOVE.W  (A2),D0
            BSR     dec_word
            MOVE.W  D0,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_push_word_reg
;***************************************************************
x86op_push_word_reg:
            SUBQ.W  #2,SP(A6)
            MOVEQ   #0,D1
            MOVE.W  SP(A6),D1
            ADD.L   SS(A6),D1
            AND.W   #7,D0                   ; opcode steht noch in D0
            MOVE.W  (AX,A6,D0.W*4),D0
            MOVE.L  D1,A2
            BSR     asm_wrw
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_pop_word_reg
;***************************************************************
x86op_pop_word_reg:
            MOVEQ   #0,D1
            MOVE.W  SP(A6),D1
            ADD.L   SS(A6),D1
            MOVE.L  D1,A2
            AND.W   #7,D0                   ; opcode steht noch in D0
            MOVE.W  D0,D1                   ; sichern
            BSR     asm_rdw
            MOVE.W  D0,(AX,A6,D1.W*4)
            ADDQ.W  #2,SP(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_push_all
;***************************************************************
x86op_push_all:
            MOVE.W  SP(A6),D3               ; Stack sichern
            MOVE.W  AX(A6),D0
            BSR     push_word
            MOVE.W  CX(A6),D0
            BSR     push_word
            MOVE.W  DX(A6),D0
            BSR     push_word
            MOVE.W  BX(A6),D0
            BSR     push_word
            MOVE.W  D3,D0
            BSR     push_word
            MOVE.W  BP(A6),D0
            BSR     push_word
            MOVE.W  SI(A6),D0
            BSR     push_word
            MOVE.W  DI(A6),D0
            BSR     push_word
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_pop_all
;***************************************************************
x86op_pop_all:
            BSR     pop_word
            MOVE.W  D0,DI(A6)
            BSR     pop_word
            MOVE.W  D0,SI(A6)
            BSR     pop_word
            MOVE.W  D0,BP(A6)
            ADDQ.W  #2,SP(A6)               ; SP ignorieren
            BSR     pop_word
            MOVE.W  D0,BX(A6)
            BSR     pop_word
            MOVE.W  D0,DX(A6)
            BSR     pop_word
            MOVE.W  D0,CX(A6)
            BSR     pop_word
            MOVE.W  D0,AX(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_segovr_FS
;***************************************************************
x86op_segovr_FS:
            MOVE.L  FS(A6),D0
            OR.L    D0,D7
            BRA     MainLoopEnd

;***************************************************************
; x86op_segovr_GS
;***************************************************************
x86op_segovr_GS:
            MOVE.L  GS(A6),D0
            OR.L    D0,D7
            BRA     MainLoopEnd

;***************************************************************
; x86op_prefix_data
;***************************************************************
x86op_prefix_data:
            LEA     x86_optab32(PC),A5
            BRA     MainLoopEnd

;***************************************************************
; x86op_prefix_adr
;***************************************************************
x86op_prefix_adr:
            BSET.L  #31,D7
            BRA     MainLoopEnd

;***************************************************************
; x86op_ins_byte
;***************************************************************
x86op_ins_byte:
            MOVEQ   #1,D0
            BSR     ins
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_ins_word
;***************************************************************
x86op_ins_word:
            MOVEQ   #2,D0
            BSR     ins
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_outs_byte
;***************************************************************
x86op_outs_byte:
            MOVEQ   #1,D0
            BSR     outs
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_outs_word
;***************************************************************
x86op_outs_word:
            MOVEQ   #2,D0
            BSR     outs
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_O_near
;***************************************************************
x86op_jump_O_near:
            BSR     asm_fetchbyte
            MOVE.W  D6,CCR
            BVS.S   DoNearJump
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_NO_near
;***************************************************************
x86op_jump_NO_near:
            BSR     asm_fetchbyte
            MOVE.W  D6,CCR
            BVC.S   DoNearJump
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_B_near
;***************************************************************
x86op_jump_B_near:
            BSR     asm_fetchbyte
            MOVE.W  D6,CCR
            BCS.S   DoNearJump
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_NB_near
;***************************************************************
x86op_jump_NB_near:
            BSR     asm_fetchbyte
            MOVE.W  D6,CCR
            BCC.S   DoNearJump
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_Z_near
;***************************************************************
x86op_jump_Z_near:
            BSR     asm_fetchbyte
            MOVE.W  D6,CCR
            BEQ.S   DoNearJump
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_NZ_near
;***************************************************************
x86op_jump_NZ_near:
            BSR     asm_fetchbyte
            MOVE.W  D6,CCR
            BNE.S   DoNearJump
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_BE_near
;***************************************************************
x86op_jump_BE_near:
            BSR     asm_fetchbyte
            MOVE.W  D6,CCR
            BLS.S   DoNearJump
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_NBE_near
;***************************************************************
x86op_jump_NBE_near:
            BSR     asm_fetchbyte
            MOVE.W  D6,CCR
            BHI.S   DoNearJump
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_S_near
;***************************************************************
x86op_jump_S_near:
            BSR     asm_fetchbyte
            MOVE.W  D6,CCR
            BMI.S   DoNearJump
            BRA     MainLoopEnd_OSC

DoNearJump: EXTB.L  D0                      ; ist schneller als EXT.W
            ADD.W   D0,IP(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_NS_near
;***************************************************************
x86op_jump_NS_near:
            BSR     asm_fetchbyte
            MOVE.W  D6,CCR
            BPL.S   DoNearJump
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_P_near
;***************************************************************
x86op_jump_P_near:
            BSR     asm_fetchbyte
            MOVE.L  D6,D1
            SWAP    D1
            AND.L   #$FF,D1
            BFTST   (ParityTab,PC){D1:1}
            BNE.S   DoNearJump
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_NP_near
;***************************************************************
x86op_jump_NP_near:
            BSR     asm_fetchbyte
            MOVE.L  D6,D1
            SWAP    D1
            AND.L   #$FF,D1
            BFTST   (ParityTab,PC){D1:1}
            BEQ.S   DoNearJump
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_L_near
;***************************************************************
x86op_jump_L_near:
            BSR     asm_fetchbyte
            MOVE.W  D6,CCR
            BLT.S   DoNearJump
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_NL_near
;***************************************************************
x86op_jump_NL_near:
            BSR     asm_fetchbyte
            MOVE.W  D6,CCR
            BGE.S   DoNearJump
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_LE_near
;***************************************************************
x86op_jump_LE_near:
            BSR     asm_fetchbyte
            MOVE.W  D6,CCR
            BLE.S   DoNearJump
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_NLE_near
;***************************************************************
x86op_jump_NLE_near:
            BSR     asm_fetchbyte
            MOVE.W  D6,CCR
            BGT.S   DoNearJump
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_opc80_byte_RM_IMM
;***************************************************************
op80_byte_operation:
            DC.W    add_byte - op80_byte_operation
            DC.W    or_byte  - op80_byte_operation
            DC.W    adc_byte - op80_byte_operation
            DC.W    sbb_byte - op80_byte_operation
            DC.W    and_byte - op80_byte_operation
            DC.W    sub_byte - op80_byte_operation
            DC.W    xor_byte - op80_byte_operation
            DC.W    sub_byte - op80_byte_operation

x86op_opc80_byte_RM_IMM:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D3             ; Funktion in D3 merken
            MOVE.W  (op80_byte_operation.B,PC,D3.W*2),D5
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVEA.L (shortcut,A6,D4.W*4),A2
            BSR     asm_fetchbyte
            MOVE.B  D0,D1                   ; IMM nach D1
            MOVE.B  (A2),D0
            JSR     op80_byte_operation(PC,D5.W)
            CMP.W   #7,D3                   ; CMP ?
            BEQ.S   .ende
            MOVE.B  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_fetchbyte           ; IMM immer nach Offset
            MOVE.B  D0,D1                   ; IMM nach D1
            BSR     asm_rdb                 ; D0 = (A2)
            JSR     op80_byte_operation(PC,D5.W)
            CMP.W   #7,D3                   ; CMP ?
            BEQ.S   .ende
            BSR     asm_wrb                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

op81_word_operation:
            DC.W    add_word - op81_word_operation
            DC.W    or_word  - op81_word_operation
            DC.W    adc_word - op81_word_operation
            DC.W    sbb_word - op81_word_operation
            DC.W    and_word - op81_word_operation
            DC.W    sub_word - op81_word_operation
            DC.W    xor_word - op81_word_operation
            DC.W    sub_word - op81_word_operation

;***************************************************************
; x86op_opc81_word_RM_IMM
;***************************************************************
x86op_opc81_word_RM_IMM:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D3             ; Funktion in D3 merken
            MOVE.W  (op81_word_operation.B,PC,D3.W*2),D5
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   opc81_IsMem
; Ziel ist Register
            LEA     (AX,A6,D4.W*4),A2
            BSR     asm_fetchword
opc83_cont_reg: MOVE.W D0,D1                ; IMM nach D1
            MOVE.W  (A2),D0
            JSR     op81_word_operation(PC,D5.W)
            CMP.W   #7,D3                   ; CMP ?
            BEQ.S   opc81_ende
            MOVE.W  D0,(A2)
            BRA.S   opc81_ende
; Ziel ist Speicher
opc81_IsMem: BSR    Get_rm_Offset           ; Adresse nach A2
            BSR     asm_fetchword           ; IMM immer nach Offset
opc83_cont_mem: MOVE.W D0,D1                ; IMM nach D1
            BSR     asm_rdw                 ; D0 = (A2)
            JSR     op81_word_operation(PC,D5.W)
            CMP.W   #7,D3                   ; CMP ?
            BEQ.S   opc81_ende
            BSR     asm_wrw                 ; (A2) = D0
opc81_ende: BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_opc83_word_RM_IMM
;***************************************************************
x86op_opc83_word_RM_IMM:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D3
            MOVE.W  (op81_word_operation.B,PC,D3.W*2),D5
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (AX,A6,D4.W*4),A2
            BSR     asm_fetchbyte
            EXTB.L  D0                      ; EXTB ist schneller
            BRA.S   opc83_cont_reg
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_fetchbyte           ; IMM immer nach Offset
            EXTB.L  D0                      ; EXTB ist schneller
            BRA.S   opc83_cont_mem

;***************************************************************
; x86op_test_byte_RM_R
;***************************************************************
x86op_test_byte_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVEA.L (shortcut,A6,D4.W*4),A1
            MOVE.B  (A1),D1                 ; Quelle nach D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVEA.L (shortcut,A6,D4.W*4),A2
            MOVE.B  (A2),D0
            BSR     and_byte
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdb                 ; D0 = (A2)
            BSR     and_byte                ; D0 = D0 + D1
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_test_word_RM_R
;***************************************************************
x86op_test_word_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (AX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVE.W  (AX,A6,D4.W*4),D0
            BSR     and_word
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdw                 ; D0 = (A2)
            BSR     and_word                ; D0 & D1
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_xchg_byte_RM_R
;***************************************************************
x86op_xchg_byte_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVEA.L (shortcut,A6,D4.W*4),A1
            MOVE.B  (A1),D1                 ; Quelle nach D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVEA.L (shortcut,A6,D4.W*4),A2
            MOVE.B  (A2),D0
            MOVE.B  D0,(A1)
            MOVE.B  D1,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdb                 ; D0 = (A2)
            MOVE.B  D0,(A1)
            MOVE.B  D1,D0
            BSR     asm_wrb                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_xchg_word_RM_R
;***************************************************************
x86op_xchg_word_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            LEA     (AX,A6,D4.W*4),A1
            MOVE.W  (A1),D1                 ; Quelle nach D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (AX,A6,D4.W*4),A2
            MOVE.W  (A2),D0
            MOVE.W  D0,(A1)
            MOVE.W  D1,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_rdw                 ; D0 = (A2)
            MOVE.W  D0,(A1)
            MOVE.W  D1,D0
            BSR     asm_wrw                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_mov_byte_RM_R
;***************************************************************
x86op_mov_byte_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVEA.L (shortcut,A6,D4.W*4),A1
            MOVE.B  (A1),D1                 ; Quelle nach D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVEA.L (shortcut,A6,D4.W*4),A2
            MOVE.B  D1,(A2)
            BRA     MainLoopEnd_OSC
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            MOVE.B  D1,D0
            BSR     asm_wrb                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_mov_word_RM_R
;***************************************************************
x86op_mov_word_RM_R:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (AX,A6,D4.W*4),D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVE.W  D1,(AX,A6,D4.W*4)
            BRA     MainLoopEnd_OSC
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            MOVE.W  D1,D0
            BSR     asm_wrw                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_mov_byte_R_RM
;***************************************************************
x86op_mov_byte_R_RM:
            BSR     get_src_byte            ; D1 = byte , D3 = reg
            MOVEA.L (shortcut,A6,D3.W*4),A2
            MOVE.B  D1,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_mov_word_R_RM
;***************************************************************
x86op_mov_word_R_RM:
            BSR     get_src_word            ; D1 = word , D3 = reg
            MOVE.W  D1,(AX,A6,D3.W*4)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_mov_word_RM_SR
;***************************************************************
x86op_mov_word_RM_SR:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.L  (segregs,A6,D4.W*4),D1
            LSR.L   #4,D1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVE.W  D1,(AX,A6,D4.W*4)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            MOVE.W  D1,D0
            BSR     asm_wrw                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_lea_word_R_M
;***************************************************************
x86op_lea_word_R_M:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            LEA     (AX,A6,D4.W*4),A1
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
            MOVE.W  A2,(A1)
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_mov_word_SR_RM
;***************************************************************
x86op_mov_word_SR_RM:
            MOVEQ   #0,D1
            BSR     get_src_word            ; D1 = word , D3 = reg
            LSL.L   #4,D1
            MOVE.L  D1,(segregs,A6,D3.W*4)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_pop_RM
;***************************************************************
x86op_pop_RM:
            BSR     asm_fetchbyte
            MOVE.W  D0,D1                   ; fetchbyte sichern
            BFEXTU  D0{29:3},D4
            BFTST   D0{26:3}                ; reg muû 0 sein
            BNE     halt_sys
            BSR     pop_word
            EXG     D0,D1                   ; tauschen
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVE.W  D1,(AX,A6,D4.W*4)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            MOVE.W  D1,D0
            BSR     asm_wrw                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_xchg_word_AX_R
;***************************************************************
x86op_xchg_word_AX_R:
            AND.W   #7,D0
            LEA     (AX,A6,D0*4),A2
            MOVE.W  (A2),D0
            MOVE.W  AX(A6),(A2)
            MOVE.W  D0,AX(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_cbw
;***************************************************************
x86op_cbw:
            MOVE.B  AL(A6),D0
            EXT.W   D0
            MOVE.W  D0,AX(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_cwd
;***************************************************************
x86op_cwd:
            MOVE.W  AX(A6),D0
            EXT.L   D0
            SWAP    D0
            MOVE.W  D0,DX(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_call_far_IMM
;***************************************************************
x86op_call_far_IMM:
            MOVE.L  EIP(A6),D3
            MOVE.L  CS(A6),D0
            SUB.L   D0,D3                   ; 16 Bit IP in D3
            BSR     push_segword
            MOVE.W  D3,D0
            BSR     push_word
            bsr     asm_fetchword_long      ; Offset holen
            MOVE.L  D0,D3
            bsr     asm_fetchword_long      ; Segment holen
            LSL.L   D0
            ADD.L   D0,D3
            MOVE.L  D0,CS(A6)
            MOVE.L  D3,EIP(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_wait
;***************************************************************
x86op_wait:
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_pushf
;***************************************************************
x86op_pushf:
            BSR     FlagsToPC
            MOVE.W  Flags(A6),D0
            AND.W   #$FD5,D0
            OR.W    #$F002,D0
            BSR     push_word
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_popf
;***************************************************************
x86op_popf:
            BSR     pop_word
            MOVE.W  D0,Flags(A6)
            BSR     FlagsFromPC
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_sahf
;***************************************************************
x86op_sahf:
            MOVE.B  AH(A6),LoFlags(A6)
            BSR     FlagsFromPC
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_lahf
;***************************************************************
x86op_lahf:
            BSR     FlagsToPC
            MOVE.B  LoFlags(A6),D0
            ORI.B   #2,D0
            MOVE.B  D0,AH(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_mov_AL_M_IMM
;***************************************************************
x86op_mov_AL_M_IMM:
            BSR     asm_fetchword_long
            BSR     GetOffsetSeg            ; A2 = Segment
            ADD.L   D0,A2
            BSR     asm_rdb
            MOVE.B  D0,AL(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_mov_AX_M_IMM
;***************************************************************
x86op_mov_AX_M_IMM:
            BSR     asm_fetchword_long
            BSR     GetOffsetSeg            ; A2 = Segment
            ADD.L   D0,A2
            BSR     asm_rdw
            MOVE.W  D0,AX(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_mov_M_AL_IMM
;***************************************************************
x86op_mov_M_AL_IMM:
            BSR     asm_fetchword_long
            BSR     GetOffsetSeg            ; A2 = Offset
            ADDA.L  D0,A2
            MOVE.B  AL(A6),D0
            BSR     asm_wrb
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_mov_M_AX_IMM
;***************************************************************
x86op_mov_M_AX_IMM:
            BSR     asm_fetchword_long
            BSR     GetOffsetSeg            ; A2 = Offset
            ADDA.L  D0,A2
            MOVE.W  AX(A6),D0
            BSR     asm_wrw
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_movs_byte
;***************************************************************
x86op_movs_byte:
            MOVEQ   #1,D0
            BSR     movs
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_movs_word
;***************************************************************
x86op_movs_word:
            MOVEQ   #2,D0
            BSR     movs
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_cmps_byte
;***************************************************************
x86op_cmps_byte:
            MOVEQ   #1,D0
            BSR     cmps
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_cmps_word
;***************************************************************
x86op_cmps_word:
            MOVEQ   #2,D0
            BSR     cmps
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_test_AL_IMM
;***************************************************************
x86op_test_AL_IMM:
            BSR     asm_fetchbyte
            MOVE.B  AL(A6),D1
            BSR     and_byte
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_test_AX_IMM
;***************************************************************
x86op_test_AX_IMM:
            BSR     asm_fetchword
            MOVE.W  AX(A6),D1
            BSR     and_word
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_stos_byte
;***************************************************************
x86op_stos_byte:
            MOVEQ   #1,D0
            BSR     stos
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_stos_word
;***************************************************************
x86op_stos_word:
            MOVEQ   #2,D0
            BSR     stos
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_lods_byte
;***************************************************************
x86op_lods_byte:
            MOVEQ   #1,D0
            BSR     lods
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_lods_word
;***************************************************************
x86op_lods_word:
            MOVEQ   #2,D0
            BSR     lods
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_scas_byte
;***************************************************************
x86op_scas_byte:
            MOVEQ   #1,D0
            BSR     scas
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_scas_word
;***************************************************************
x86op_scas_word:
            MOVEQ   #2,D0
            BSR     scas
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_mov_byte_R_IMM
;***************************************************************
x86op_mov_byte_R_IMM:
            AND.W   #7,D0
            MOVEA.L (shortcut,A6,D0.W*4),A2
            BSR     asm_fetchbyte
            MOVE.B  D0,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_mov_word_R_IMM
;***************************************************************
x86op_mov_word_R_IMM:
            AND.W   #7,D0
            LEA     (AX,A6,D0.W*4),A2
            BSR     asm_fetchword
            MOVE.W  D0,(A2)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_ret_near_IMM
;***************************************************************
x86op_ret_near_IMM:
            BSR     pop_word                ; IP holen
            MOVEQ   #0,D1
            MOVE.W  D0,D1
            ADD.L   CS(A6),D1               ; in EIP wandeln
            BSR     asm_fetchword
            ADD.W   D0,SP(A6)               ; Stack korrigieren
            MOVE.L  D1,EIP(A6)              ; EIP zurÅckschreiben
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_ret_near
;***************************************************************
x86op_ret_near:
            BSR     pop_word                ; IP holen
            MOVEQ   #0,D1
            MOVE.W  D0,D1
            ADD.L   CS(A6),D1               ; in EIP wandeln
            MOVE.L  D1,EIP(A6)              ; EIP zurÅckschreiben
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_les_R_IMM
;***************************************************************
x86op_les_R_IMM:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            LEA     (AX,A6,D4.W*4),A1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0                 ; Register ist nicht
            BEQ.S   .ende
            BSR     Get_rm_Offset
            BSR     asm_rdw
            MOVE.W  D0,(A1)
            ADD.L   #2,A2
            MOVEQ   #0,D0
            BSR     asm_rdw
            LSL.L   #4,D0
            MOVE.L  D0,ES(A6)
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_lds_R_IMM
;***************************************************************
x86op_lds_R_IMM:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            LEA     (AX,A6,D4.W*4),A1
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0                 ; Register ist nicht
            BEQ.S   .ende
            BSR     Get_rm_Offset
            BSR     asm_rdw
            MOVE.W  D0,(A1)
            ADD.L   #2,A2
            MOVEQ   #0,D0
            BSR     asm_rdw
            LSL.L   #4,D0
            MOVE.L  D0,DS(A6)
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_mov_byte_RM_IMM
;***************************************************************
x86op_mov_byte_RM_IMM:
            BSR     asm_fetchbyte
            BFTST   D0{26:3}                ; reg muû 0 sein
            BNE     halt_sys
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            BSR     asm_fetchbyte
            MOVE.L  (AX,A6,D4.W*4),A2
            MOVE.W  D0,(A2)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_fetchbyte
            BSR     asm_wrb                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_mov_word_RM_IMM
;***************************************************************
x86op_mov_word_RM_IMM:
            BSR     asm_fetchbyte
            BFTST   D0{26:3}                ; reg muû 0 sein
            BNE     halt_sys
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            BSR     asm_fetchword
            MOVE.W  D0,(AX,A6,D4.W*4)
            BRA.S   .ende
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_fetchword
            BSR     asm_wrw                 ; (A2) = D0
.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_ret_far_IMM
;***************************************************************
x86op_ret_far_IMM:
            BSR     pop_word                ; IP holen
            MOVEQ   #0,D1
            MOVE.W  D0,D1
            BSR     pop_segword             ; CS holen
            ADD.L   D0,D1                   ; in EIP wandeln
            MOVE.L  D0,D2                   ; sichern
            BSR     asm_fetchword
            ADD.W   D0,SP(A6)               ; Stack korrigieren
            MOVE.L  D1,EIP(A6)              ; EIP zurÅckschreiben
            MOVE.L  D2,CS(A6)               ; CS zurÅckschreiben
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_ret_far
;***************************************************************
x86op_ret_far:
            MOVE.L  4(A6),D0                ; mem_size holen
            CMP.W   SP(A6),D0               ; SP zu groû ?
            BCS     halt_sys                ; muû halt sein
            BSR     pop_word                ; IP holen
            MOVEQ   #0,D1
            MOVE.W  D0,D1
            BSR     pop_segword             ; CS holen
            ADD.L   D0,D1                   ; in EIP wandeln
            MOVE.L  D1,EIP(A6)              ; EIP zurÅckschreiben
            MOVE.L  D0,CS(A6)               ; CS zurÅckschreiben
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_int3
;***************************************************************
x86op_int3:
            IMPORT  DoNormalInt
            MOVEQ   #3,D0
            BRA     DoNormalInt

;***************************************************************
; x86op_int_IMM
;***************************************************************
x86op_int_IMM:
            BSR     asm_fetchbyte_word      ; D0 = INT#
; Einsprung fÅr INT3 und INTO
DoNormalInt: MOVE.W D0,D3
            LSL.W   #2,D0                   ; * 4
;                  ADDQ      #2,D0                 ; + 2
            MOVEA.W D0,A2                   ; auf 32 Bit
            BSR     asm_rdl
            SWAP    D0
;                  CMP.W     #$FFF0,D0             ; == BIOS_SEG ?
            CMP.W   #$F000,D0               ; == BIOS_SEG ?
            BNE.S   .is_real_int
            SWAP    D0
            CMP.W   #$F065,D0               ; INT 10 Einsprung
            BNE.S   .NormalIntEmu
            MOVE.W  #$0010,D3               ; Machen wir INT 10 draus
.NormalIntEmu: MOVEA.L (bios_intr_tab,D3.W*4),A0
            JSR     (A0)                    ; ab nach C
            BSR     FlagsFromPC             ; Falls C die Flags setzt
            BRA     MainLoopEnd_OSC

.is_real_int: BSR   FlagsToPC
            MOVE.W  Flags(A6),D0
            BSR     push_word               ; Flags auf Stack
            ANDI.W  #$FCFF,Flags(A6)        ; IF und TF rÅcksetzen
            MOVE.L  EIP(A6),D4
            MOVE.L  CS(A6),D0
            SUB.L   D0,D4                   ; EIP korrigieren
            BSR     push_segword            ; CS auf den Stack
            MOVE.W  D4,D0
            BSR     push_word               ; IP auf Stack
            MOVEQ   #0,D0
;                  SUBQ      #2,A2                 ; A2 Zeiger auf Offset
            BSR     asm_rdw                 ; Segment holen (A2)
            MOVE.L  D0,D1                   ; EIP merken
            MOVEQ   #0,D0
            ADDQ    #2,A2                   ; Zeiger auf Segment
            BSR     asm_rdw                 ; Segment holen (A2)
            LSL.L   #4,D0
            MOVE.L  D0,CS(A6)
            ADD.L   D0,D1                   ; EIP neu berechnen
            MOVE.L  D1,EIP(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_into
;***************************************************************
x86op_into:
            IMPORT  DoNormalInt
            MOVEQ   #4,D0
            BTST.B  #3,HiFlags(A6)
            BNE     DoNormalInt
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_iret
;***************************************************************
x86op_iret:
            BSR     pop_word
            MOVEQ   #0,D4
            MOVE.W  D0,D4                   ; IP merken
            BSR     pop_segword
            ADD.L   D0,D4
            MOVE.L  D0,CS(A6)
            MOVE.L  D4,EIP(A6)
            BSR     pop_word
            MOVE.W  D0,Flags(A6)
            BSR     FlagsFromPC
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_opcC0_byte_RM_MEM
;***************************************************************
x86op_opcC0_byte_RM_MEM:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (opD0_byte_operation.B,PC,D4.W*2),D5
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVEA.L (shortcut,A6,D4.W*4),A2
            BSR     asm_fetchbyte
            MOVE.B  D0,D1                   ; IMM nach D1
            BRA.S   opcD0_cont_reg          ; hier weitermachen
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_fetchbyte           ; IMM immer nach Offset
            MOVE.B  D0,D1                   ; IMM nach D1
            BRA.S   opcD0_cont_mem          ; hier weitermachen

;***************************************************************
; x86op_opcD0_byte_RM_1
;***************************************************************
opD0_byte_operation:
            DC.W    rol_byte - opD0_byte_operation
            DC.W    ror_byte - opD0_byte_operation
            DC.W    rcl_byte - opD0_byte_operation
            DC.W    rcr_byte - opD0_byte_operation
            DC.W    shl_byte - opD0_byte_operation
            DC.W    shr_byte - opD0_byte_operation
            DC.W    shl_byte - opD0_byte_operation
            DC.W    sar_byte - opD0_byte_operation

x86op_opcD0_byte_RM_1:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (opD0_byte_operation.B,PC,D4.W*2),D5
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   opcD0_IsMem
; Ziel ist Register
            MOVEA.L (shortcut,A6,D4.W*4),A2
            MOVEQ   #1,D1                   ; count = 1
opcD0_cont_reg: MOVE.B (A2),D0
            JSR     opD0_byte_operation(PC,D5.W)
            MOVE.B  D0,(A2)
            BRA.S   opcD0_ende
; Ziel ist Speicher
opcD0_IsMem: BSR    Get_rm_Offset           ; Adresse nach A2
            MOVEQ   #1,D1                   ; count = 1
opcD0_cont_mem: BSR asm_rdb                 ; D0 = (A2)
            JSR     opD0_byte_operation(PC,D5.W)
            BSR     asm_wrb                 ; (A2) = D0
opcD0_ende: BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_opcD2_byte_RM_CL
;***************************************************************
x86op_opcD2_byte_RM_CL:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (opD0_byte_operation.B,PC,D4.W*2),D5
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            MOVEA.L (shortcut,A6,D4.W*4),A2
            MOVE.B  CL(A6),D1               ; count = CL
            BRA.S   opcD0_cont_reg          ; hier weitermachen
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            MOVE.B  CL(A6),D1               ; count = CL
            BRA.S   opcD0_cont_mem          ; hier weitermachen

;***************************************************************
; x86op_opcC1_word_RM_MEM
;***************************************************************
x86op_opcC1_word_RM_MEM:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (opD1_word_operation.B,PC,D4.W*2),D5
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (AX,A6,D4.W*4),A2
            BSR     asm_fetchbyte
            MOVE.B  D0,D1                   ; IMM nach D1
            BRA.S   opcD1_cont_reg
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            BSR     asm_fetchbyte           ; IMM immer nach Offset
            MOVE.B  D0,D1                   ; IMM nach D1
            BRA.S   opcD1_cont_mem

;***************************************************************
; x86op_opcD1_word_RM_1
;***************************************************************
opD1_word_operation:
            DC.W    rol_word - opD1_word_operation
            DC.W    ror_word - opD1_word_operation
            DC.W    rcl_word - opD1_word_operation
            DC.W    rcr_word - opD1_word_operation
            DC.W    shl_word - opD1_word_operation
            DC.W    shr_word - opD1_word_operation
            DC.W    shl_word - opD1_word_operation
            DC.W    sar_word - opD1_word_operation

x86op_opcD1_word_RM_1:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (opD1_word_operation.B,PC,D4.W*2),D5
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   opcD1_IsMem
; Ziel ist Register
            LEA     (AX,A6,D4.W*4),A2
            MOVEQ   #1,D1                   ; count = 1
opcD1_cont_reg: MOVE.W (A2),D0
            JSR     opD1_word_operation(PC,D5.W)
            MOVE.W  D0,(A2)
            BRA.S   opcD1_ende
; Ziel ist Speicher
opcD1_IsMem: BSR    Get_rm_Offset           ; Adresse nach A2
            MOVEQ   #1,D1                   ; count = 1
opcD1_cont_mem: BSR asm_rdw                 ; D0 = (A2)
            JSR     opD1_word_operation(PC,D5.W)
            BSR     asm_wrw                 ; (A2) = D0
opcD1_ende: BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_opcD3_word_RM_CL
;***************************************************************
x86op_opcD3_word_RM_CL:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D4
            MOVE.W  (opD1_word_operation.B,PC,D4.W*2),D5
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE.S   .IsMem
; Ziel ist Register
            LEA     (AX,A6,D4.W*4),A2
            MOVE.B  CL(A6),D1               ; count = CL
            BRA.S   opcD1_cont_reg
; Ziel ist Speicher
.IsMem:     BSR     Get_rm_Offset           ; Adresse nach A2
            MOVE.B  CL(A6),D1               ; count = CL
            BRA.S   opcD1_cont_mem

;***************************************************************
; x86op_aam
; AH = AL div 10
; AL = AL mod 10
;***************************************************************
x86op_aam:
            BSR     asm_fetchbyte
            CMP.B   #$A,D0
            BNE     halt_sys
            MOVEQ   #0,D6                   ; Flags lîschen
            MOVEQ   #0,D0
            MOVE.B  AL(A6),D0
            DIVU    #10,D0
            MOVE.B  D0,AH(A6)               ; div 10
            SWAP    D0
            MOVE.B  D0,AL(A6)               ; mod 10
            MOVE.W  CCR,D6                  ; Flags setzen
            SWAP    D6
            MOVE.B  D0,D6                   ; fÅr Parity
            SWAP    D6
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_aad
; AL = AL + AH * 10
; AH = 0
;***************************************************************
x86op_aad:
            BSR     asm_fetchbyte
            CMP.B   #$A,D0
            BNE     halt_sys
            MOVEQ   #0,D6                   ; Flags lîschen
            CLR.W   D0
            MOVE.B  AH(A6),D0
            MULU    #10,D0
            ADD.B   D0,AL(A6)
            MOVE.W  CCR,D6                  ; Flags setzen
            SWAP    D6
            MOVE.B  AL(A6),D6               ; fÅr Parity
            SWAP    D6
            CLR.B   AH(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_xlat
;***************************************************************
x86op_xlat:
            MOVEQ   #0,D0
            MOVE.B  AL(A6),D0
            ADD.W   BX(A6),D0
            BSR     GetOffsetSeg            ; A2 = Segment
            ADD.L   D0,A2
            BSR     asm_rdb
            MOVE.B  D0,AL(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_loopne
;***************************************************************
x86op_loopne:
            BSR     asm_fetchbyte
            SUBQ.W  #1,CX(A6)
            BEQ.S   .abort
            MOVE.W  D6,CCR                  ; ZF testen
            BEQ.S   .abort
            EXTB.L  D0
            ADD.W   D0,IP(A6)
.abort:     BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_loope
;***************************************************************
x86op_loope: BSR    asm_fetchbyte
            SUBQ.W  #1,CX(A6)
            BEQ.S   .abort
            MOVE.W  D6,CCR                  ; ZF testen
            BNE.S   .abort
            EXTB.L  D0
            ADD.W   D0,IP(A6)
.abort:     BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_loop
;***************************************************************
x86op_loop: BSR     asm_fetchbyte
            SUBQ.W  #1,CX(A6)
            BEQ     MainLoopEnd_OSC
            EXTB.L  D0
            ADD.W   D0,IP(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jcxz
;***************************************************************
x86op_jcxz: BSR     asm_fetchbyte
            TST.W   CX(A6)
            BNE.S   .abort
            EXTB.L  D0
            ADD.W   D0,IP(A6)
.abort:     BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_in_byte_AL_IMM
;***************************************************************
x86op_in_byte_AL_IMM:
            BSR     asm_fetchbyte
            BSR     asm_inb
            MOVE.B  D0,AL(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_in_word_AX_IMM
;***************************************************************
x86op_in_word_AX_IMM:
            BSR     asm_fetchbyte
            BSR     asm_inw
            MOVE.W  D0,AX(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_out_byte_IMM_AL
;***************************************************************
x86op_out_byte_IMM_AL:
            BSR     asm_fetchbyte
            MOVE.W  D0,D1
            MOVE.B  AL(A6),D0
            BSR     asm_outb
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_out_word_IMM_AX
;***************************************************************
x86op_out_word_IMM_AX:
            BSR     asm_fetchbyte
            MOVE.W  D0,D1
            MOVE.W  AX(A6),D0
            BSR     asm_outw
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_call_near_IMM
;***************************************************************
x86op_call_near_IMM:
            BSR     asm_fetchword
            MOVE.W  D0,D3
            MOVE.L  EIP(A6),D0
            SUB.L   CS(A6),D0               ; EIP korrigieren
            BSR     push_word
            ADD.W   D3,IP(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_near_IMM
;***************************************************************
x86op_jump_near_IMM:
            BSR     asm_fetchword
            ADD.W   D0,IP(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_far_IMM
;***************************************************************
x86op_jump_far_IMM:
            BSR     asm_fetchword_long      ; Offset holen
            MOVE.L  D0,D1
            BSR     asm_fetchword_long      ; Segment holen
            LSL.L   #4,D0
            ADD.L   D0,D1
            MOVE.L  D1,EIP(A6)
            MOVE.L  D0,CS(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_jump_byte_IMM
;***************************************************************
x86op_jump_byte_IMM:
            BSR     asm_fetchbyte
            EXTB.L  D0
            ADD.W   D0,IP(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_in_byte_AL_DX
;***************************************************************
x86op_in_byte_AL_DX:
            MOVE.W  DX(A6),D0
            BSR     asm_inb
            MOVE.B  D0,AL(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_in_word_AX_DX
;***************************************************************
x86op_in_word_AX_DX:
            MOVE.W  DX(A6),D0
            BSR     asm_inw
            MOVE.W  D0,AX(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_out_byte_DX_AL
;***************************************************************
x86op_out_byte_DX_AL:
            MOVE.W  DX(A6),D1
            MOVE.B  AL(A6),D0
            BSR     asm_outb
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_out_word_DX_AX
;***************************************************************
x86op_out_word_DX_AX:
            MOVE.W  DX(A6),D1
            MOVE.W  AX(A6),D0
            BSR     asm_outw
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_lock
;***************************************************************
x86op_lock:
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_repne
;***************************************************************
x86op_repne:
            MOVE.W  #$10,REP(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_repe
;***************************************************************
x86op_repe:
            MOVE.W  #$11,REP(A6)
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_halt
;***************************************************************
x86op_halt:
            BRA     halt_sys

;***************************************************************
; x86op_cmc
;***************************************************************
x86op_cmc:
            EORI.B  #$01,D6
            BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_opcF6_byte_RM
;***************************************************************
x86op_opcF6_byte_RM:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D3             ; D3 = Fkt Nr.
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE     .IsMem
            MOVEA.L (shortcut,A6,D4.W*4),A2
            MOVE.B  (A2),D0                 ; Source Byte
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

.reg_not:   NOT.B   D0
            MOVE.B  D0,(A2)
            BRA.S   .ende

.reg_neg:   BSR     neg_byte
            MOVE.B  D0,(A2)
            BRA.S   .ende

.IsMem:     BSR     Get_rm_Offset
            BSR     asm_rdb                 ; D0 = (A2)
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
            BSR     asm_fetchbyte
            BSR     and_byte                ; test ist kommutativ
            BRA.S   .ende

.mem_not:   NOT.B   D0
            BSR     asm_wrb
            BRA.S   .ende

.mem_neg:   BSR     neg_byte
            BSR     asm_wrb
            BRA.S   .ende

.fkt_mul:   BSR     mul_byte
            BRA.S   .ende

.fkt_imul:  BSR     imul_byte
            BRA.S   .ende

.fkt_div:   BSR     div_byte
            BRA.S   .ende

.fkt_idiv:  BSR     idiv_byte

.ende:      BRA     MainLoopEnd_OSC

;***************************************************************
; x86op_opcF7_word_RM
;***************************************************************
x86op_opcF7_word_RM:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D3             ; D3 = Fkt Nr.
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE     .IsMem
            LEA     (AX,A6,D4.W*4),A2
            MOVE.W  (A2),D0                 ; Source Byte
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

.reg_not:   NOT.W   D0
            MOVE.W  D0,(A2)
            BRA.S   .ende

.reg_neg:   BSR     neg_word
            MOVE.W  D0,(A2)
            BRA.S   .ende

.IsMem:     BSR     Get_rm_Offset
            BSR     asm_rdw                 ; D0 = (A2)
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

.fkt_test:  MOVE.W  D0,D1
            BSR     asm_fetchword
            BSR     and_word                ; test ist kommutativ
            BRA.S   .ende

.mem_not:   NOT.W   D0
            BSR     asm_wrw
            BRA.S   .ende

.mem_neg:   BSR     neg_word
            BSR     asm_wrw
            BRA.S   .ende

.fkt_mul:   BSR     mul_word
            BRA.S   .ende

.fkt_imul:  BSR     imul_word
            BRA.S   .ende

.fkt_div:   BSR     div_word
            BRA.S   .ende

.fkt_idiv:  BSR     idiv_word

.ende:      BRA     MainLoopEnd_OSC



;***************************************************************
; x86op_clc
;***************************************************************
x86op_clc:
            AND.B   #$FE,D6
            BRA     MainLoopEnd_OSC



;***************************************************************
; x86op_stc
;***************************************************************
x86op_stc:
            OR.B    #$01,D6
            BRA     MainLoopEnd_OSC



;***************************************************************
; x86op_cli
;***************************************************************
x86op_cli:
            ANDI.W  #$FDFF,Flags(A6)
            BRA     MainLoopEnd_OSC



;***************************************************************
; x86op_sti
;***************************************************************
x86op_sti:
            ORI.W   #$200,Flags(A6)
            BRA     MainLoopEnd_OSC



;***************************************************************
; x86op_cld
;***************************************************************
x86op_cld:
            ANDI.W  #$FBFF,Flags(A6)
            BRA     MainLoopEnd_OSC



;***************************************************************
; x86op_std
;***************************************************************
x86op_std:
            ORI.W   #$400,Flags(A6)
            BRA     MainLoopEnd_OSC



;***************************************************************
; x86op_opcFE_byte_RM
;***************************************************************
x86op_opcFE_byte_RM:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D3             ; D3 = Fkt Nr.
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE     .IsMem
            MOVEA.L (shortcut,A6,D4.W*4),A2
            MOVE.B  (A2),D0                 ; Source Byte
            TST.W   D3                      ; D3 = Fkt Nr.
            BNE.S   .not_0
; INC.B
            BSR     inc_byte
            MOVE.B  D0,(A2)
            BRA.S   .ende

.not_0:     SUBQ.W  #1,D3
            BNE.S   .default
; DEC.B
            BSR     dec_byte
            MOVE.B  D0,(A2)
            BRA.S   .ende

.default:   BRA     halt_sys

.IsMem:     BSR     Get_rm_Offset
            BSR     asm_rdb
            TST.W   D3                      ; D3 = Fkt Nr.
            BNE.S   .not_mem0
; INC.B
            BSR     inc_byte
            BRA.S   .mem_ende

.not_mem0:  SUBQ.W  #1,D3
            BNE.S   .default
; DEC.B
            BSR     dec_byte
.mem_ende:  BSR     asm_wrb
.ende:      BRA     MainLoopEnd_OSC



;***************************************************************
; x86op_opcFF_word_RM
;***************************************************************
x86op_opcFF_word_RM:
            BSR     asm_fetchbyte
            BFEXTU  D0{26:3},D3             ; D3 = Fkt Nr.
            BFEXTU  D0{29:3},D4
            AND.W   #$C0,D0
            CMP.W   #$C0,D0
            BNE     .IsMem
            LEA     (AX,A6,D4.W*4),A2
            MOVE.W  (A2),D0                 ; Source Byte
            MOVE.W  (.reg_optab.B,PC,D3.W*2),D3
            JMP     .reg_optab(PC,D3.W)

.reg_optab: DC.W    .reg_inc    - .reg_optab
            DC.W    .reg_dec    - .reg_optab
            DC.W    .fkt_call_w - .reg_optab
            DC.W    .default    - .reg_optab
            DC.W    .fkt_jmp_w  - .reg_optab
            DC.W    .default    - .reg_optab
            DC.W    .fkt_push   - .reg_optab
            DC.W    .default    - .reg_optab

.default:   BRA     halt_sys

.IsMem:     BSR     Get_rm_Offset
            BSR     asm_rdw                 ; D0 = (A2)
            MOVE.W  (.mem_optab.B,PC,D3.W*2),D3
            JMP     .mem_optab(PC,D3.W)

.mem_optab: DC.W    .mem_inc    - .mem_optab
            DC.W    .mem_dec    - .mem_optab
            DC.W    .fkt_call_w - .mem_optab
            DC.W    .mem_call_f - .mem_optab
            DC.W    .fkt_jmp_w  - .mem_optab
            DC.W    .mem_jmp_f  - .mem_optab
            DC.W    .fkt_push   - .mem_optab
            DC.W    .default    - .mem_optab

.reg_inc:   BSR     inc_word
            MOVE.W  D0,(A2)
            BRA.S   .ende

.reg_dec:   BSR     dec_word
            MOVE.W  D0,(A2)
            BRA.S   .ende

.mem_inc:   BSR     inc_word
            BSR     asm_wrw
            BRA.S   .ende

.mem_dec:   BSR     dec_word
            BSR     asm_wrw
            BRA.S   .ende

.fkt_call_w: MOVE.W D0,D3                   ; D0 sichern
            MOVE.L  EIP(A6),D0
            SUB.L   CS(A6),D0               ; EIP zurÅckrechnen
            BSR     push_word
            MOVE.W  D3,D0
            BRA.S   .fkt_jmp_w

.mem_call_f: MOVE.W D0,D3                   ; D0 sichern
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

.fkt_jmp_w: MOVEQ   #0,D1                   ; obere HÑlfte lîschen
            MOVE.W  D0,D1
            ADD.L   CS(A6),D1
            MOVE.L  D1,EIP(A6)
            BRA.S   .ende

.fkt_push:  BSR     push_word

.ende:      BRA     MainLoopEnd_OSC


