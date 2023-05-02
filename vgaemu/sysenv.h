/****************************************************************************
 * $Id: sysenv.h,v 1.3 2003/12/28 22:14:15 rincewind Exp $
 ****************************************************************************
 * $Log: sysenv.h,v $
 * Revision 1.3  2003/12/28 22:14:15  rincewind
 * - fix CVS headers
 *
 ****************************************************************************/

#ifndef sysenv_h
#define sysenv_h

#include "x86_regs.h"

typedef struct {
  unsigned long	mem_base;
  unsigned long	mem_size;
  unsigned long	busmem_base;
  unsigned long	BIOS_base;	 /* Special zum debuggen */
  X86Regs       x86;
  u8           *shortcut[8];
} SysEnv;

extern SysEnv sys;		/* System Variablen global definieren */

extern u8	asm_inb (u16 port);
extern void	asm_outb (u8  val, u16 port);

extern int	sys_init (void);

#endif /* sysenv_h */
