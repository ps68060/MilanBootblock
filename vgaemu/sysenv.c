/****************************************************************************
 * $Id: sysenv.c,v 1.4 2003/12/28 22:14:15 rincewind Exp $
 ****************************************************************************
 * $Log: sysenv.c,v $
 * Revision 1.4  2003/12/28 22:14:15  rincewind
 * - fix CVS headers
 *
 * Revision 1.3  2000/07/15 22:42:21  rincewind
 * - Use global variables set by bootblock to find VGA card
 ****************************************************************************/

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <ext.h>

#include "sysenv.h"

#include "pci.h"
#include "debug.h"

#define KB		1024
#define MEM_SIZE	(32*KB)		/* should be plenty for now */

char VGA_BIOS[32768l];		 	/* Speicher fÅr VGA-BIOS */
static char SysMem[32768l];		/* Speicher fÅr Systemvariablen */

# define WORD_SWAP(a,b)  if (1) {                         \
                           (*((u8*)&a)   = *((u8*)&b+1)); \
                           (*((u8*)&a+1) = *((u8*)&b));   \
                         }
# define LONG_SWAP(a,b)  if (1) {                         \
                           (*((u8*)&a)   = *((u8*)&b+3)); \
                           (*((u8*)&a+1) = *((u8*)&b+2)); \
                           (*((u8*)&a+2) = *((u8*)&b+1)); \
                           (*((u8*)&a+3) = *((u8*)&b));   \
                         }  

SysEnv sys;

extern void fastcopy(ULONG BiosOffset);
extern UBYTE VGA_devfn;

int sys_init (void)
{
  /* Wegen BSS und so */
  memset(&SysMem,0,sizeof(SysMem));
  memset(&sys,0,sizeof(sys));
  sys.shortcut[0] = &sys.x86.R_AL;
  sys.shortcut[1] = &sys.x86.R_CL;
  sys.shortcut[2] = &sys.x86.R_DL;
  sys.shortcut[3] = &sys.x86.R_BL;
  sys.shortcut[4] = &sys.x86.R_AH;
  sys.shortcut[5] = &sys.x86.R_CH;
  sys.shortcut[6] = &sys.x86.R_DH;
  sys.shortcut[7] = &sys.x86.R_BH;

  if (!VGA_devfn)
  {
#ifdef ERROR_OUTPUT
    mprintf("Keine VGA Karte gefunden\n");   	
#endif    
    return 0;
  }
  {
    ULONG BiosOffset;
#ifdef ERROR_OUTPUT
    mprintf("VGA Karte gefunden\n");
#endif
    BiosOffset = EnableVgaRom();
#ifdef ERROR_OUTPUT
    mprintf("VGA BIOS enabled at %08lX\n",BiosOffset);
#endif
    fastcopy(BiosOffset);        /* BIOS Signatur testen ! */
    DisableVgaRom();
#ifdef ERROR_OUTPUT
    mprintf("VGA BIOS copied at %08lX\n",&VGA_BIOS);
#endif
  }

  sys.BIOS_base = (long)VGA_BIOS;
/* mem_base = Zeiger auf Systemspeicher */
  sys.mem_base = (unsigned long)SysMem;
  sys.mem_size = sizeof(SysMem);
  return 1;
}

