/****************************************************************************
 * $Id: initvga.c,v 1.3 2003/12/28 22:14:01 rincewind Exp $
 ****************************************************************************
 * $Log: initvga.c,v $
 * Revision 1.3  2003/12/28 22:14:01  rincewind
 * - fix CVS headers
 *
 * Revision 1.2  2003/12/28 20:48:22  rincewind
 * - use hardcoded init for S3 Trio instead of VGA emulator
 *
 * Revision 1.2  2000/07/15 22:56:53  rincewind
 * - re-indent code
 * - change CRTC initialization to use UWORD constants
 *
 * Revision 1.1  2000/07/15 22:49:46  rincewind
 * - rewrote VGA init code in C
 ****************************************************************************/

#include <string.h>
#include "proto.h"
#include "ll_io.h"
#include "pci.h"

extern void init_vga_font(void);

#define NUMOF(array) (sizeof(array)/sizeof(array[0]))

extern UBYTE VGA_bus;
extern UBYTE VGA_dev;
extern UBYTE VGA_fct;
extern UBYTE VGA_devfn;

extern void vgaemu_init(void);
static void init_s3_vga(void);

#define POSTCODE(a) if(1) { *(UBYTE*)0x80000083L = a; }

void init_vgacard(void)
{
  ULONG x;

#if 1 /* use hard-coded init for S3 Trio */
  x = pci_read_config(VGA_bus, VGA_dev, VGA_fct, PCI_VENDOR_ID);
  if (x == 0x88115333L || /* Trio32/64 */
      x == 0x89015333L || /* Trio 64V2 */
#if 1
      x == 0x88125333L || /* Aurora 64VP */
      x == 0x88145333L || /* Trio 64UVP */
      x == 0x89025333L || /* Plato PXG */
#endif	    
      0)
  {
    init_s3_vga();
  }
  else
#endif  
    vgaemu_init();
  memset((void*) 0x400b8000L, 0, 4000);    /* clear screen */
}

static void write_vga_table(ULONG ioaddr, UWORD *table, int count)
{
  for(; count; count--)
    iowritew(ioaddr, *table++);
}


/* Attribute Controller p. 14-32 */
static UBYTE textmode_attrib_tab[] = {
  0x00,0x00,	/* AR00 Palette 0 */
  0x01,0x01,
  0x02,0x02,
  0x03,0x03,
  0x04,0x04,
  0x05,0x05,
  0x06,0x06,
  0x07,0x07,
  0x08,0x08,
  0x09,0x09,
  0x0A,0x0A,
  0x0B,0x0B,
  0x0C,0x0C,
  0x0D,0x0D,
  0x0E,0x0E,
  0x0F,0x0F,  /* AR0F Palette 15 */
  0x10,0x0C,  /* AR10 Mode: Text,Color,LineGrf */
  0x11,0x00,  /* AR11 Border Color */
  0x12,0x0F,  /* AR12 Enable Plane 0-3 */
  0x13,0x08,  /* AR13 H-Panning */
  0x14,0x00   /* AR14 Pixel Padding */
};

/* RAMDAC p. 14-40 */
static UBYTE textmode_palette[] = {
  0x00,0x00,0x00,             /* schwarz */
  0x3F,0x3F,0x3F,             /* weiû */
  0x3F,0x00,0x00,             /* rot */
  0x00,0x3F,0x00,             /* grÅn */
  0x3F,0x3F,0x00,             /* gelb */
  0x00,0x00,0x3F,             /* blau */
  0x2A,0x00,0x2A,
  0x2A,0x2A,0x00,
  0x2A,0x2A,0x2A,
  0x00,0x00,0x15,
  0x00,0x00,0x3F,
  0x00,0x2A,0x15,
  0x00,0x2A,0x3F,
  0x3F,0x28,0x28,             /* Orange fÅr i-Punkt */
  0x00,0x20,0x30,             /* BlaugrÅn fÅr Milan */
  0x30,0x30,0x30,             /* hellgrau fÅr Bootmeldung */
};

void initvga_textmode(void)
{
  int i;
  UBYTE *p;
	
  /* Attribute Controller p. 14-32 */
  ioreadb(0x3DA);
  for(p=textmode_attrib_tab, i=0; i<sizeof(textmode_attrib_tab); i++)
    iowriteb(0x3C0, *p++);
  iowriteb(0x3C0, 0x20);	/* Bild einschalten */

  /* RAMDAC p. 14-40 */
  iowriteb(0x3C8, 0);
  for(p=textmode_palette, i=0; i<16*3; i++)
    iowriteb(0x3C9, *p++);

  init_vga_font();
}



/* Sequencer p. 14-4 */
/* lowbyte is register number, highbyte is register contents */
static UWORD s3_seq_tab[] = {
  0x0300,  /* Reset inaktiv */
  0x0001,  /* CLK_MODE: 9 dots wide */
  0x0302,  /* ENWT_PL: Write Enable Plane 0+1 */
  0x0003,  /* CH_FONT_SL: Font is first 8K of page 2 */
  0x0204,  /* MEM_MODE: full 256K, odd/even mode */
  0x0608,  /* Unlock extendes Regs */
  0x0009,
  0x800A,  /* 2 MClk writes */
  0x000B,  /* S3 Trio ext. Init */
  0x000D,  /* S3 Trio ext. Init - neu */
  0x0014,  /* S3 Trio ext. Init */
  0x0215,  /* Enable DClk Load (fÅr 25/28 MHz Umschaltung ) */
  0x0018   /* S3 Trio ext. Init */
};

/* CRTC p. 14-10 */
/* lowbyte is register number, highbyte is register contents */
static UWORD s3_crtc_tab[] = {
  0x0E11,  /* CR11 unlock */
  0x5F00,  /* CR0 H TOTAL */
  0x4F01,  /* CR1 H Display End */
  0x5002,  /* CR2 H Blank Start */
  0x8203,  /* CR3 H Blank End */
  0x5504,  /* CR4 H Sync Start */
  0x8105,  /* CR5 H Sync End */
  0xBF06,  /* CR6 V Total (Scanlines) LSB */
  0x1F07,  /* CR7 Overflow Register */
  0x0008,  /* CR8 Preset Row Scan */
  0x4F09,  /* CR9 Max Scanline (Char) = 16, misc bits */
  0x0D0A,  /* CRA Cursor Start Scanline */
  0x0E0B,  /* CRB Cursor End Scanline */
  0x000C,  /* CRC Start Address High */
  0x000D,  /* CRD Start Address Low */
  0x050E,  /* CRE Cursor Location Address High */
  0x000F,  /* CRF Cursor Location Address Low */
  0x9C10,  /* CR10 VSYNC Start Low */
  0x8E11,  /* CR11 VSYNC End */
  0x8F12,  /* CR12 Vertical Display End Low, LOCK CR0-7 */
  0x2813,  /* CR13 Logical Screen Width */
  0x1F14,  /* CR14 Underline Location */
  0x9615,  /* CR15 Start Vertical Blank Low */
  0xB916,  /* CR16 End Vertical Blank Low */
  0xA317,  /* CR17 Mode Control: Sync Enabled, Word Mode */
  0xFF18,  /* CR18 Line Compare Register */
  0x4838,  /* unlock 1 */
  0xA539,  /* unlock 2 */
  0x0531,
  0x4032,
  0x0033,
  0x0034,
  0x0035,
  0x8236,
  0x0A37,
  0x013A,
  0x5A3B,  /* Start Display FIFO, typical CR00 - 5, Bit 9 is in CR5D */
  0x103C,
  0x2040,
  0xD142,
  0x4043,
  0x4045,
  0x0050,
  0x0051,
  0x0053,
  0x3854,
  0x0055,
  0x0056,
  0x0057,
  0x0358,
  0x035C,
  0x005d,
  0x005e,
  0x005F,
  0x0F60,
  0x0F61,
  0x0F62,
  0x0063,
  0x0064,
  0x0465,
  0x8866,
  0x0067,
  0xFF68,
  0xE069,
  0xC06A,
  0x5D6D
};

/* Graphics Controller p. 14-25 */
/* lowbyte is register number, highbyte is register contents */
static UWORD s3_gc_tab[] = {
  0x0400,
  0x0001,
  0x0002,
  0x0003,
  0x0004,
  0x1005,
  0x0E06,
  0x0007,
  0xFF08
};



/*
	Init S3 Trio64 without using the BIOS
*/
void init_s3_vga(void)
{
#if 0	
  /* Wakeup for S3 864 */
  iowriteb(0x3c3,1);
  if(ioreadb(0x3CC) == 0xFF)
  {
    iowriteb(0x46e8,0x10);
    iowriteb(0x102,0x01);
    iowriteb(0x46e8,0x08);
  }
#endif

	/* enable legacy-IO mode in case only memory-mapped IO is active */
  iowritew(0x3c4, 0x0608);
  iowritew(0x3c4, 0x0009);

  /* Wakeup fÅr S3 Trio64V+ */
  iowriteb(0x3c3, 0x01);

  iowritew(0x3b4, 0x4838); /* CRT register unlock */
  iowritew(0x3b4, 0xa539); /* CRT register unlock */
  iowritew(0x3c4, 0x0608); /* SEQ register unlock */

	/* Workaround for broken S3 Trio cards where the PLL does not 
	   start up properly. Taken from Phoenix S3 TrioV+ BIOS. */
  for(;;)
  {
    UBYTE a,b;
    int i;
    
	  iowritew(0x03C4, 0x314);  /* Power down PLLs */
	  for(i=0; i<16; i++)
		  wait(0x600);            /* wait total 160ms */
	  iowritew(0x03C4, 0x14);   /* Power up PLLs */
	  for(i=0; i<16; i++)
		  wait(0x600);            /* wait total 160ms */
	  iowritew(0x03C4, 0x1C14); /* Test MCLK - reset counter */
	  iowritew(0x03C4, 0xC14);  /* test MCLK */
	  iowriteb(0x03C4, 0x17);
	  a = ioreadb(0x3c5);       /* read MCLK counter */
	  iowriteb(0x03C4, 0x17);
	  b = ioreadb(0x3c5);       /* read MCLK counter */
	  if ( a == b)
	    continue;               /* repeat until MCLK is running */
	  
	  iowritew(0x03C4, 0x1414); /* Test DCLK - reset counter */
	  iowritew(0x03C4, 0x414);  /* Test DCLK */
	
	  iowriteb(0x03C4, 0x17);
	  a = ioreadb(0x3c5);       /* read DCLK counter */
	  iowriteb(0x03C4, 0x17);
	  b = ioreadb(0x3c5);       /* read DCLK counter */
	  if (a != b)
	    break;                  /* repeat until both are running */
  }

  iowriteb(0x3c6, 0xFF);
  iowriteb(0x3cc, 0x00);
  iowriteb(0x3ca, 0x01);
  /* iowritew(0x3d4, 0x4011); */

  iowriteb(0x3c2, 0x67);
  /*iowriteb(0x3c6, 0xff);*/

  write_vga_table(0x3C4, s3_seq_tab, (int) NUMOF(s3_seq_tab));
  write_vga_table(0x3D4, s3_crtc_tab, (int) NUMOF(s3_crtc_tab));
  /* S3 Trio PCI Init */
  /* Graphics Controller p. 14-25 */
  write_vga_table(0x3CE, s3_gc_tab, (int) NUMOF(s3_gc_tab));
}
