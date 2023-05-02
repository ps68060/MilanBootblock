/****************************************************************************
 * $Id: libvga.c,v 1.4 2003/12/28 22:14:15 rincewind Exp $
 ****************************************************************************
 * $Log: libvga.c,v $
 * Revision 1.4  2003/12/28 22:14:15  rincewind
 * - fix CVS headers
 *
 ****************************************************************************/

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ext.h>
#include <time.h>

#include "x86_regs.h"
#include "x86_bios.h"
#include "debug.h"
#include "sysenv.h"
#include "pci.h"

#include "libvga.h"

#define OFF(addr)	(((addr) >> 0) & 0xffff)
#define SEG(addr)	(((addr) >> 4) & 0xf000)

/* Prototyp fÅr Routine aus X86_EXEC.S */
void x86_exec (void);

int vgaemu_init(void)
{
#ifdef ERROR_OUTPUT
  mprintf("Starte emulation\n");
#endif    
	
  if (!sys_init())
    return 0;
#ifdef ERROR_OUTPUT
  mprintf("sysinit done.\n");
#endif
  x86_bios_init();
  sys.x86.R_CS  = 0x000C0000l;
  sys.x86.R_EIP = 0x000C0003l;              /* enthÑlt komplette Adresse */
  sys.x86.R_AH  = VGA_bus;
  sys.x86.R_AL  = VGA_devfn;
  sys.x86.R_SS = SEG(sys.mem_size);
  sys.x86.R_SP = OFF(sys.mem_size);
  x86_exec();

  return 0;
}

void vgaemu_switchgraphics(void)
{
  int i;
#if 1
  ((char *) sys.mem_base)[0x4000] = 0xcd;   /* INT 10 */
  ((char *) sys.mem_base)[0x4001] = 0x10;
  ((char *) sys.mem_base)[0x4002] = 0xcb;   /* RET far */
  sys.x86.R_AH = 0x00;			    /* set video mode 3 */
  /* sys.x86.R_AL = 0x11 | (1 << 7);*/
  sys.x86.R_AL = 0x11;
  sys.x86.R_CS  = 0x00000000l;
  sys.x86.R_EIP = 0x00004000l;
  sys.x86.R_SS  = SEG(sys.mem_size);
  sys.x86.R_SP  = OFF(sys.mem_size);
  x86_exec();
#endif
#if 1
  ((char *) sys.mem_base)[0x4000] = 0xcd;   /* INT 10 */
  ((char *) sys.mem_base)[0x4001] = 0x10;
  ((char *) sys.mem_base)[0x4002] = 0xcb;   /* RET far */
  for (i=0; i <= 15; i+=15)
  {
    sys.x86.R_AH = 0x10;                    /* set Palette */
    sys.x86.R_AL = 0x00;
    sys.x86.R_BL = i;
    sys.x86.R_BH = i ? 15 : 0;
    sys.x86.R_CS = 0x00000000l;
    sys.x86.R_EIP = 0x00004000l;
    sys.x86.R_SS = SEG(sys.mem_size);
    sys.x86.R_SP = OFF(sys.mem_size);
    x86_exec();
  }
#endif      
#if 1	/* damit man in PureC was lesen kann */
  for (i=0; i <= 15; i+=15) {
    sys.x86.R_AH = 0x10;                    /* set Palette */
    sys.x86.R_AL = 0x10;
    sys.x86.R_BX = i;
    if (i==0) 
      sys.x86.R_CH = sys.x86.R_CL = sys.x86.R_DH = 63;
    else  
      sys.x86.R_CH = sys.x86.R_CL = sys.x86.R_DH = 0;
    sys.x86.R_CS = 0x00000000l;
    sys.x86.R_EIP = 0x00004000l;
    sys.x86.R_SS = SEG(sys.mem_size);
    sys.x86.R_SP = OFF(sys.mem_size);
    x86_exec();
  }
#endif
}
