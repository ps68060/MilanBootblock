/****************************************************************************
 * Definition of the x86 registers.
 ****************************************************************************
 * $Id: x86_regs.h,v 1.3 2003/12/28 22:14:16 rincewind Exp $
 ****************************************************************************
 * $Log: x86_regs.h,v $
 * Revision 1.3  2003/12/28 22:14:16  rincewind
 * - fix CVS headers
 *
 ****************************************************************************/

#ifndef x86_REGS_H
#define x86_REGS_H

typedef char		s8;
typedef short		s16;
typedef long int	s32;

typedef unsigned char	u8;
typedef unsigned short	u16;
typedef unsigned long	u32;

/*
 * General EAX, EBX, ECX, EDX type registers.  Note that for
 * portability, and speed, the issue of byte swapping is not addressed
 * in the registers.  All registers are stored in the default format
 * available on the host machine.  The only critical issue is that the
 * registers should line up EXACTLY in the same manner as they do in
 * the 386.  That is:
 *
 * EAX & 0xff  === AL
 * EAX & 0xffff == AX
 *
 * etc.  The result is that alot of the calculations can then be
 * done using the native instruction set fully.
 */

typedef struct {
    u32 e_reg;
} I32_reg_t;

typedef struct {
    u16 filler0, x_reg;
} I16_reg_t;

typedef struct {
    u8 filler0, filler1, h_reg, l_reg;
} I8_reg_t;

typedef union {
    I32_reg_t	I32_reg;
    I16_reg_t	I16_reg;
    I8_reg_t	I8_reg;
} i386_general_register;

/* Wichtig
 * Die Reihenfolge der Register ist
 * EAX ECX EDX EBX ESP EBP ESI EDI
 */

/* 8 bit registers */
#define R_AH  genregs[0].I8_reg.h_reg
#define R_AL  genregs[0].I8_reg.l_reg
#define R_CH  genregs[1].I8_reg.h_reg
#define R_CL  genregs[1].I8_reg.l_reg
#define R_DH  genregs[2].I8_reg.h_reg
#define R_DL  genregs[2].I8_reg.l_reg
#define R_BH  genregs[3].I8_reg.h_reg
#define R_BL  genregs[3].I8_reg.l_reg

/* 16 bit registers */
#define R_AX  genregs[0].I16_reg.x_reg
#define R_CX  genregs[1].I16_reg.x_reg
#define R_DX  genregs[2].I16_reg.x_reg
#define R_BX  genregs[3].I16_reg.x_reg

/* 32 bit extended registers */
#define R_EAX genregs[0].I32_reg.e_reg
#define R_ECX genregs[1].I32_reg.e_reg
#define R_EDX genregs[2].I32_reg.e_reg
#define R_EBX genregs[3].I32_reg.e_reg

/* 16 bit special registers */
#define R_SP  genregs[4].I16_reg.x_reg
#define R_BP  genregs[5].I16_reg.x_reg
#define R_SI  genregs[6].I16_reg.x_reg
#define R_DI  genregs[7].I16_reg.x_reg

/* 32 bit special registers */
#define R_ESP genregs[4].I32_reg.e_reg
#define R_EBP genregs[5].I32_reg.e_reg
#define R_ESI genregs[6].I32_reg.e_reg
#define R_EDI genregs[7].I32_reg.e_reg

/* 16 bit special registers */
#define R_IP  spcregs1.I16_reg.x_reg
#define R_FLG spcregs2.I16_reg.x_reg

/* 32 bit special registers */
#define R_EIP  spcregs1.I32_reg.e_reg
#define R_EFLG spcregs2.I32_reg.e_reg

/* segment registers */
#define R_ES  segregs[0]
#define R_CS  segregs[1]
#define R_SS  segregs[2]
#define R_DS  segregs[3]
#define R_FS  segregs[4]
#define R_GS  segregs[5]

/* flag conditions   */
#define FB_CF 0x0001		/* CARRY flag  */
#define FB_PF 0x0004		/* PARITY flag */
#define FB_AF 0x0010		/* AUX  flag   */
#define FB_ZF 0x0040		/* ZERO flag   */
#define FB_SF 0x0080		/* SIGN flag   */
#define FB_TF 0x0100		/* TRAP flag   */
#define FB_IF 0x0200		/* INTERRUPT ENABLE flag */
#define FB_DF 0x0400		/* DIR flag    */
#define FB_OF 0x0800		/* OVERFLOW flag */

/* 8088 has top 4 bits of the flags set to 1.  Also, bit#1 is set.
 * This is (not well) documented behavior.  See note in userman.tex
 * about the subtleties of dealing with code which attempts to detect
 * the host processor.  This is defined as F_ALWAYS_ON.
 */
#define F_ALWAYS_ON  (0xf002)	/* flag bits always on */

/*
 * Define a mask for only those flag bits we will ever pass back 
 * (via PUSHF) 
 */
#define F_MSK (FB_CF|FB_PF|FB_AF|FB_ZF|FB_SF|FB_TF|FB_IF|FB_DF|FB_OF)

/* following bits masked in to a 16bit quantity */

#define F_CF 0x0001l		/* CARRY flag  */
#define F_PF 0x0004l		/* PARITY flag */
#define F_AF 0x0010l		/* AUX  flag   */
#define F_ZF 0x0040l		/* ZERO flag   */
#define F_SF 0x0080l		/* SIGN flag   */
#define F_TF 0x0100l		/* TRAP flag   */
#define F_IF 0x0200l		/* INTERRUPT ENABLE flag */
#define F_DF 0x0400l		/* DIR flag    */
#define F_OF 0x0800l		/* OVERFLOW flag */

#define TOGGLE_FLAG(flag)	(sys.x86.R_FLG ^= (flag))
#define SET_FLAG(flag)		(sys.x86.R_FLG |= (flag))
#define CLEAR_FLAG(flag)	(sys.x86.R_FLG &= ~(flag))
#define ACCESS_FLAG(flag)	(sys.x86.R_FLG & (flag))
#define CLEARALL_FLAG()		(sys.x86.R_FLG = 0)

#define CONDITIONAL_SET_FLAG(COND,FLAG) \
  if (COND) SET_FLAG(FLAG); else CLEAR_FLAG(FLAG)

#define F_PF_CALC 0x010000l	/* PARITY flag has been calced    */
#define F_ZF_CALC 0x020000l	/* ZERO flag has been calced      */
#define F_SF_CALC 0x040000l	/* SIGN flag has been calced      */

#define F_ALL_CALC	0xff0000l	/* All have been calced   */

/*
 * Emulator machine state.
 * Segment usage control.
 */

#define SYSMODE_CLRMASK	(SYSMODE_PREFIX_DATA	| \
			 SYSMODE_PREFIX_ADR)
#define SYSMODE_PREFIX_DATA	0x40000000l
#define SYSMODE_PREFIX_ADR	0x80000000l

#define SYSMODE_PREFIX_REPE	0x0001
#define SYSMODE_PREFIX_REPNE	0x0002
#define SYSMODE_PREFIX_REPZ     0x0011
#define SYSMODE_PREFIX_REPNZ    0x0010
#define SYSMODE_INTR_PENDING	0x1000
#define SYSMODE_EXTRN_INTR	0x2000
#define SYSMODE_HALTED		0x4000

#define  INTR_SYNCH           0x1
#define  INTR_ASYNCH          0x2
#define  INTR_HALTED          0x4

struct modrm {
  u16 mod, rh, rl;
};

typedef struct {
  i386_general_register genregs[8];
  u32                   segregs[6];
  i386_general_register spcregs1;
  i386_general_register spcregs2;
  /*
   * MODE contains information on:
   *	REPE prefix		2 bits  repe,repne
   *	SEGMENT overrides	5 bits  normal,DS,SS,CS,ES
   *	Delayed flag set	3 bits  (zero, signed, parity)
   *	reserved		6 bits
   *	interrupt #		8 bits  instruction raised interrupt
   *	BIOS video segregs	4 bits  
   *	Interrupt Pending	1 bits  
   *	Extern interrupt	1 bits
   *	Halted			1 bits
   */
  u32                         OverSeg;  /* Segment Override Wert */
  int				REP;
  u8				intno;
  volatile int		intr;	/* mask of pending interrupts */
} X86Regs;

#endif
