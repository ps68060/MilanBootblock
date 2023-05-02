/****************************************************************************
 * $Id: main.c,v 1.3 2003/12/28 22:14:15 rincewind Exp $
 ****************************************************************************
 * $Log: main.c,v $
 * Revision 1.3  2003/12/28 22:14:15  rincewind
 * - fix CVS headers
 *
 * Revision 1.3  2000/07/15 22:41:15  rincewind
 * - Add FindVgaCard code (removed from common code since bootblock does this
 *   during PCI init)
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

#include "libvga.h"

#define OFF(addr)	(((addr) >> 0) & 0xffff)
#define SEG(addr)	(((addr) >> 4) & 0xf000)

/* Prototyp fÅr Routine aus X86_EXEC.S */
void x86_exec (void);

UBYTE VGA_bus;
UBYTE VGA_devfn;

int FindVgaCard(void)
{
  int slot;
	
  for(slot=2; slot<=5; slot++)
  {
    ULONG id, class;
    id = pci_read_config(0, slot, 0, 0);       /* 89015333 */
    class = pci_read_config(0, slot, 0, 8)>>8; /* 00030000 */
    
    mprintf("Dev %d: id %08lX, class %08lX\n",slot, id, class);
    if (((class & 0xFF0000L) == 0x030000L) ||
        ((class            ) == 0x000100L) )
    {
      VGA_bus = 0;
      VGA_devfn = slot<<3;
      return 1;
    }
  }
  return 0;
}

int main (void)
{
  int i;

  FindVgaCard();
    
#ifdef ERROR_OUTPUT
  mprintf("Starte emulation\n");
#endif    
	
  if (!sys_init())
    return 0;

  x86_bios_init();
  sys.x86.R_CS  = 0x000C0000l;
  sys.x86.R_EIP = 0x000C0003l;              /* enthÑlt komplette adresse */
  sys.x86.R_AX  = 0x0010;	            /* Bus 0 Device 2 Func 0 */
  sys.x86.R_SS = SEG(sys.mem_size);
  sys.x86.R_SP = OFF(sys.mem_size);
  x86_exec();

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
  for (i=0; i <= 15; i+=15) {
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

  return 0;
}
