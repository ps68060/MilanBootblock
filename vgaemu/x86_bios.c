/****************************************************************************
 * $Id: x86_bios.c,v 1.4 2003/12/28 22:14:15 rincewind Exp $
 ****************************************************************************
 * $Log: x86_bios.c,v $
 * Revision 1.4  2003/12/28 22:14:15  rincewind
 * - fix CVS headers
 *
 ****************************************************************************/

#include <stdio.h>

#include "sysenv.h"
#include "x86_bios.h"
#include "pci.h"
#include "debug.h"

void (*bios_intr_tab[256])(void);

static void undefined_intr (void)
{
#ifdef ERROR_OUTPUT	    
  mprintf("x86_bios: interrupt is undefined!\n");
#endif    
}

ULONG IP_Save;

void DebugRegDump (void)
{
#ifdef ERROR_OUTPUT
  mprintf("Reg Dump:\n");
  mprintf("EAX = %08lX EBX = %08lX ECX = %08lX EDX = %08lX\n",sys.x86.R_EAX,sys.x86.R_EBX,sys.x86.R_ECX,sys.x86.R_EDX);
  mprintf("EBP = %08lX ESP = %08lX EDI = %08lX ESI = %08lX\n",sys.x86.R_EBP,sys.x86.R_ESP,sys.x86.R_EDI,sys.x86.R_ESI);
  mprintf("CS  = %08lX DS  = %08lX ES  = %08lX SS  = %08lX\n",sys.x86.R_CS,sys.x86.R_DS,sys.x86.R_ES,sys.x86.R_SS);
  mprintf("EIP = %08lX\n",sys.x86.R_EIP);       
#endif
}

void DebugInt (void)
{
#ifdef ERROR_OUTPUT
  mprintf("INT");
  DebugRegDump();
#endif
}

void DebugOutB (void)
{
#ifdef ERROR_OUTPUT
/*  mprintf("OUT DX,AL ; DX=%04X, AL=%02X\n",sys.x86.R_DX,sys.x86.R_AL);*/
  mprintf("0,0x%04X, 0x%02X,\n",sys.x86.R_DX,sys.x86.R_AL);
#endif
}

void DebugOutW (void)
{
#ifdef ERROR_OUTPUT
/*  mprintf("OUT DX,AX ; DX=%04X, AX=%04X\n",sys.x86.R_DX,sys.x86.R_AX);*/
  mprintf("1,0x%04X, 0x%02X,\n",sys.x86.R_DX,sys.x86.R_AX);
#endif
}

void DebugIllegal32 (void)
{
#ifdef ERROR_OUTPUT
  mprintf("ILLEGAL 32 Bit Opcode");
  DebugRegDump();
#endif
}

static void int10 (void)
{
#ifdef ERROR_OUTPUT
  mprintf("Calling old int 10 function %02X\n",sys.x86.R_AH);
  DebugRegDump();
#endif    
  if (sys.x86.R_AH == 0x12 && sys.x86.R_BL == 0x32)
  {
    if (sys.x86.R_AL == 0) {
      /* enable CPU accesses to video memory */
      (0x3c2, asm_inb(0x3cc) | 0x02);
    } else if (sys.x86.R_AL == 1) {
      /* disable CPU accesses to video memory */
      asm_outb(asm_inb(0x3cc) & ~0x02,0x3c2);
    } else {
#ifdef ERROR_OUTPUT	
      mprintf("x86_bios.int10: unknown function AH=0x12, BL=0x32, AL=%#02x\n",
	      sys.x86.R_AL);

#endif	    
    }
  } else
  {
#ifdef ERROR_OUTPUT    
    mprintf("x86_bios.int10: unknown function AH=%#02x, AL=%#02x\n",
	    sys.x86.R_AH, sys.x86.R_AL);
    mprintf("EIP = %08lX\n",sys.x86.R_EIP);       
    DebugRegDump();
#endif	
  }
}

static void int1a (void)
{
#ifdef ERROR_OUTPUT	
  mprintf("Calling old int 1A function %04X\n",sys.x86.R_AX);
  DebugRegDump();
#endif    
  switch (sys.x86.R_AX)
  {
    case 0xb101:			/* pci bios present? */
      sys.x86.R_AL  = 0x00;		/* no config space/special cycle generation support */
      sys.x86.R_EDX = 0x20494350l;	/* " ICP" */
      sys.x86.R_BX  = 0x0210;		/* version 2.10 */
      sys.x86.R_CL  = 0;		/* max bus number in system */
      CLEAR_FLAG(F_CF);
      break;

    case 0xb102:			/* find pci device */
      sys.x86.R_AH =
	pcibios_find_device(sys.x86.R_DX, sys.x86.R_CX, sys.x86.R_SI,
			    &sys.x86.R_BH, &sys.x86.R_BL);
      CONDITIONAL_SET_FLAG((sys.x86.R_AH != PCIBIOS_SUCCESSFUL), F_CF);
      break;

    case 0xb103:			/* find pci class code */
      sys.x86.R_AH =
	pcibios_find_class(sys.x86.R_ECX, sys.x86.R_SI,
			   &sys.x86.R_BH, &sys.x86.R_BL);
      CONDITIONAL_SET_FLAG((sys.x86.R_AH != PCIBIOS_SUCCESSFUL), F_CF);
      break;

    case 0xb108:			/* read configuration byte */
      sys.x86.R_AH =
	pcibios_read_config_byte(sys.x86.R_BH, sys.x86.R_BL,
				 sys.x86.R_DI, &sys.x86.R_CL);
      CONDITIONAL_SET_FLAG((sys.x86.R_AH != PCIBIOS_SUCCESSFUL), F_CF);
      break;

    case 0xb109:			/* read configuration word */
      sys.x86.R_AH =
	pcibios_read_config_word(sys.x86.R_BH, sys.x86.R_BL,
				 sys.x86.R_DI, &sys.x86.R_CX);
      CONDITIONAL_SET_FLAG((sys.x86.R_AH != PCIBIOS_SUCCESSFUL), F_CF);
      break;

    case 0xb10a:			/* read configuration dword */
      sys.x86.R_AH =
	pcibios_read_config_dword(sys.x86.R_BH, sys.x86.R_BL,
				  sys.x86.R_DI, &sys.x86.R_ECX);
      CONDITIONAL_SET_FLAG((sys.x86.R_AH != PCIBIOS_SUCCESSFUL), F_CF);
      break;

    case 0xb10b:			/* write configuration byte */
      sys.x86.R_AH =
	pcibios_write_config_byte(sys.x86.R_BH, sys.x86.R_BL,
				  sys.x86.R_DI, sys.x86.R_CL);
      CONDITIONAL_SET_FLAG((sys.x86.R_AH != PCIBIOS_SUCCESSFUL), F_CF);
      break;

    case 0xb10c:			/* write configuration word */
      sys.x86.R_AH =
	pcibios_write_config_word(sys.x86.R_BH, sys.x86.R_BL,
				  sys.x86.R_DI, sys.x86.R_CX);
      CONDITIONAL_SET_FLAG((sys.x86.R_AH != PCIBIOS_SUCCESSFUL), F_CF);
      break;

    case 0xb10d:			/* write configuration dword */
      sys.x86.R_AH =
	pcibios_write_config_dword(sys.x86.R_BH, sys.x86.R_BL,
				   sys.x86.R_DI, sys.x86.R_ECX);
      CONDITIONAL_SET_FLAG((sys.x86.R_AH != PCIBIOS_SUCCESSFUL), F_CF);
      break;

#ifdef ERROR_OUTPUT	
    default:
      mprintf("x86_bios.int1a: unknown function AX=%#04x\n", sys.x86.R_AX);
#endif	
  }
#ifdef ERROR_OUTPUT	
  DebugRegDump();
#endif    
}

void x86_bios_init (void)
{
  int i;

  for (i = 0; i < 256; ++i) {
    /* 0xF000F0FF = BIOS_SEG << 16 in Big Endian */    
    (*(u32*)(sys.mem_base+i*4)) = 0xF0FF00F0l;     
    bios_intr_tab[i] = undefined_intr;
  }
  /* Kompatibilit„tseinsprung 000FF065 */
  (*(u32*)(sys.mem_base+0x10*4)) = 0x65F000F0l;     

  bios_intr_tab[0x10] = int10;
  bios_intr_tab[0x1a] = int1a;
}
