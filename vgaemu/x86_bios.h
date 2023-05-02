/****************************************************************************
 * $Id: x86_bios.h,v 1.3 2003/12/28 22:14:15 rincewind Exp $
 ****************************************************************************
 * $Log: x86_bios.h,v $
 * Revision 1.3  2003/12/28 22:14:15  rincewind
 * - fix CVS headers
 *
 ****************************************************************************/

#ifndef x86_bios_h
#define x86_bios_h

#define BIOS_SEG	0xfff0

extern void (*bios_intr_tab[])(void);
extern void x86_bios_init (void);

#endif /* x86_bios_h */
