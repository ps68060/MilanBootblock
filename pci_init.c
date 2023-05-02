/****************************************************************************
 * PCI-Initialisierung fÅr Milan-Bootblock
 ****************************************************************************
 * $Id: pci_init.c,v 1.13 2003/12/28 22:14:02 rincewind Exp $
 ****************************************************************************
 * $Log: pci_init.c,v $
 * Revision 1.13  2003/12/28 22:14:02  rincewind
 * - fix CVS headers
 *
 * Revision 1.12  2003/12/28 21:13:09  rincewind
 * - fix MB-IRQ for UART and 2nd IDE port interrupt
 *
 * Revision 1.3  2000/07/15 23:03:15  rincewind
 * - moved base addreee register initialization to function init_BARs, so that we
 *   can initialize the VGA card's registers before the rest.
 *
 * Revision 1.2  2000/06/19 20:52:34  rincewind
 * - misc cleanup
 ****************************************************************************/

#include <string.h>
#include "proto.h"
#include "pci.h"

typedef void (*scan_fct)(int bus,int dev, int fct, ULONG id);

/*
 * Align VAL to ALIGN, which must be a power of two.
 */
#define ALIGN(val,align)        (((val) + ((align) - 1)) & ~((align) - 1))

extern char *msg_pci_interrupt[];

/* Resource Deskriptor */
#define FLG_LAST       0x8000
#define FLG_IO         0x4000
#define FLG_ROM        0x2000
#define FLG_MEM        0x0000
#define FLG_8BIT       0x0100
#define FLG_16BIT      0x0200
#define FLG_32BIT      0x0400
#define FLG_MOTOROLA   0x0000
#define FLG_INTEL_ADR  0x0001
#define FLG_INTEL_LANE 0x0002

typedef struct
{
  UWORD struct_len;     /* LÑnge der Struktur */
  UWORD flags;
  ULONG base;           /* Basisadresse (PCI) */
  ULONG length;
  ULONG offset;
  ULONG dmaoffset;
} pci_rsc;

typedef struct
{
  ULONG magic;          /* 0x5f4d535f - fÅr GÅltigkeitsprÅfung */
  ULONG plx_config;     /* PLX DMCFGA fÅr Config-Cycle */
  ULONG id;             /* Device/Vendor-ID */
  ULONG classcode;      /* Class code (24 Bit) */
  void  *callback;      /* Callback, um Treiber zu entfernen */
  pci_rsc *resources;   /* Resource descriptoren */
  UBYTE bus, slot, fct;
  UBYTE pci_interrupt;  /* 0 = unused, 1 = INTA, 2 = INTB, ... */
  UBYTE isa_interrupt;
  UBYTE dev_used;       /* Flag, ob Karte von Treiber belegt ist */
  UWORD struct_size;    /* Grîûe der Struktur */
  void *int_handler;    /* Interrupt handler */
  void *next_int;       /* nÑchster Handler auf gleichem INT */
  ULONG int_param;      /* Parameter fÅr Int-Handler */
} pci_device;

static pci_device *vme_card_dev;

static UBYTE interrupt_table[6][4] =
{
  {0,0,0,0},    /* Slot 0 - PLX */
  {0,0,0,0},    /* Slot 1 - PCI->Isa Bridge */
  {1,2,3,4},    /* Slot 2 */
  {4,1,2,3},    /* Slot 3 */
  {3,4,1,2},    /* Slot 4 */
  {2,3,4,1},    /* Slot 5 */
};


static void enum_devs(int bus, scan_fct do_it)
{
  int dev;
  int fct;
  ULONG id, tmp;
        
  for(dev=1; dev<=5; dev++)
    for(fct=0;fct<8; fct++)
    {
      id = pci_read_config(bus, dev, fct, PCI_VENDOR_ID);
      if ((id & 0xffffl) != 0xffffl)
      {
        /*mprintf("enum: dev %d, fct %d, ID $%lX\r\n",dev,fct, id);*/
        tmp = pci_read_config(bus, dev, fct, 0x0c);
        if ((tmp & 0x007f0000L) == 0) /* config layout type 0 */
          do_it(bus, dev, fct, id);
        if (fct == 0 && (tmp & 0x00800000L) == 0) /* not multi-function */
          break; /* skip function 1-7 */
      }
    }
}

static int num_devices;
static pci_device *cur_device;
static ULONG cur_io_base;
static ULONG cur_mem_base;
static int vga_found;
UBYTE VGA_bus;
UBYTE VGA_dev;
UBYTE VGA_fct;
UBYTE VGA_devfn;
pci_rsc VGA_resources[7];

/* 
   Step 1: count all devices so that we know how much memory we need
   for the tables. At the same time, search for a VGA card.
*/

static void do_preinit(int bus, int dev, int fct, ULONG id)
{
  ULONG class;
  (void) id;

  class = pci_read_config(bus,dev,fct,PCI_CLASS_REVISION)>>8; /* 00030000 */
  if (!vga_found && (((class & 0xFF0000L) == 0x030000L) || (class == 0x000100L) ))
  {
    VGA_bus = bus;
    VGA_dev = dev;
    VGA_fct = fct;
    VGA_devfn = (VGA_dev<<3) | VGA_fct;
    vga_found = 1;
  }
  num_devices++;
}

/* Init base address registers for one device */
static pci_rsc *init_BARs(int bus, int dev, int fct, pci_rsc *rsc)
{
  ULONG cmd;
  int cnt, reg;
  ULONG bases[7], *cur_base;
  pci_rsc *retval = 0;
        
  cmd = pci_read_config(bus, dev, fct, PCI_COMMAND);

  /*
    Alle Baseregister abklappern, ZÑhlen, wieviele benutzt sind
    und belegte Bits merken
  */
  cur_base = bases;
  cnt=0;
  for (reg = PCI_BASE_ADDRESS_0; reg <= PCI_BASE_ADDRESS_5; reg += 4)
  {
    pci_write_config(bus, dev, fct, reg, 0xffffffffL);
    if ((*cur_base++ = pci_read_config(bus, dev, fct, reg)) != 0)
      cnt++;
  }
  reg = PCI_BASE_ADDRESS_ROM;
  pci_write_config(bus, dev, fct, reg, 0xffffffffL);
  if ((*cur_base++ = pci_read_config(bus, dev, fct, reg)) != 0)
    cnt++;

  /* mprintf("device %LX, %d resourcen\r\n",id, cnt);*/
  if (!cnt)
    return 0;

  /* Platz fÅr Resource Deskriptoren anfordern */
  if (!rsc)
    rsc = kmalloc(cnt * sizeof(pci_rsc));
  retval = rsc;

  for (cur_base=bases, reg = PCI_BASE_ADDRESS_0; 
       reg <= PCI_BASE_ADDRESS_ROM; 
       reg = (reg == PCI_BASE_ADDRESS_5) ? PCI_BASE_ADDRESS_ROM : reg+4, cur_base++)
  {
    ULONG base = *cur_base, mask;

    /* mprintf("\r\ndo_config: reg %d: ",reg);*/
    /* mprintf("->base $%lx ",*cur_base);*/

    if (!base)
      continue; /* Register ist unbenutzt */

    rsc->struct_len = sizeof(pci_rsc);
    rsc->dmaoffset = 0L;

    if ((base & PCI_BASE_ADDRESS_SPACE_IO) && reg != PCI_BASE_ADDRESS_ROM)
    {
      ULONG size;
      
      cmd |= PCI_COMMAND_IO;

      base &= PCI_BASE_ADDRESS_IO_MASK;
      mask = (~base << 1) | 0x1;
      size = (mask & base) & 0xffffffffL;
      /*alignto = MAX(0x400, size);*/
      base = ALIGN(cur_io_base, size);

      /* align to multiple of $400 due to ISA address aliasing! */
      cur_io_base = ALIGN(base+size, 0x400);

      pci_write_config(bus, dev, fct, reg, base | 0x1);
      rsc->base = base;
      rsc->length = size;
#if 0
      rsc->offset = 0x80000000L;
      rsc->flags = FLG_IO | FLG_8BIT | FLG_16BIT | FLG_32BIT |FLG_INTEL_ADR;
#else
      rsc->offset = 0xC0000000L;
      rsc->flags = FLG_IO | FLG_8BIT | FLG_16BIT | FLG_32BIT |FLG_INTEL_LANE;
#endif      
      /*mprintf("do_config: device %d, fct %d, reg %d -> IO address: $%lX, size $%lX\r\n", dev, fct, reg, base, size);*/
    }
    else /* memory space */
    {
      UWORD type;
      ULONG size;

      cmd |= PCI_COMMAND_MEMORY;
      type = (UWORD)(base & PCI_BASE_ADDRESS_MEM_TYPE_MASK);
      base &= PCI_BASE_ADDRESS_MEM_MASK;
      mask = (~base << 1) | 0x1;
      size = (mask & base) & 0xffffffffL;
      switch (type)
      {
	case PCI_BASE_ADDRESS_MEM_TYPE_32:
	  break;

	case PCI_BASE_ADDRESS_MEM_TYPE_64:
	  vgaprintf2("pci_init: ignoring 64-bit device in "
		     "slot %d, function %d: \r\n", dev, fct);
	  reg += 4;     /* skip extra 4 bytes */
	  continue;

	case PCI_BASE_ADDRESS_MEM_TYPE_1M:
	  vgaprintf2("pci_init: slot %d, function %d requests memory below 1MB\r\n",
		     dev, fct);
	  continue;
      }

      /*alignto = MAX(0x1000, size) ;*/
      base = ALIGN(cur_mem_base, size);
      cur_mem_base = base + size;
      pci_write_config(bus, dev, fct, reg, base); /* in case of ROM: decode disabled */
      rsc->base = base;
      rsc->length = size;
      rsc->offset = 0x40000000L;
      if (reg == PCI_BASE_ADDRESS_ROM)
	rsc->flags = FLG_ROM | FLG_MEM | FLG_8BIT | FLG_16BIT | FLG_32BIT |FLG_INTEL_LANE;
      else
	rsc->flags =           FLG_MEM | FLG_8BIT | FLG_16BIT | FLG_32BIT |FLG_INTEL_LANE;
      /*mprintf("do_config: device %d, fct %d, reg %d -> MEM address: $%lX, size $%lX\r\n", dev, fct, reg, base, size);*/
    }
    rsc++;
  }
  (--rsc)->flags |= FLG_LAST;

  pci_write_config(bus, dev, fct, PCI_COMMAND, cmd | PCI_COMMAND_MASTER);

  /* das nÑchste Device muû auf einer Page-Grenze liegen */
  cur_mem_base = ALIGN(cur_mem_base, 8192);
  
  return retval;
}

/*
   Step 2: configure one device, fill in tables
*/
/* TODO: Fast back-to-back Transfers einschalten wenn mîglich */
static void do_config(int bus, int dev, int fct, ULONG id)
{
  cur_device->magic = 0x5f4d535fL;
  cur_device->plx_config = 0x80000000L | 
    (((ULONG) bus)<<16) |
    (((ULONG) dev)<<11) |
    (((ULONG) fct)<<8);

  cur_device->id = id;
  cur_device->classcode = (pci_read_config(bus,dev,fct,8) >> 8) & 0xffffffl;
  cur_device->bus = bus;
  cur_device->slot = dev;
  cur_device->fct = fct;
  cur_device->dev_used = 0;
  cur_device->callback = 0;
  cur_device->resources = 0;
  cur_device->int_handler = 0;
  cur_device->next_int = 0;
  cur_device->int_param = 0;
  cur_device->struct_size = sizeof(pci_device);

  if (id == 0x12345678l) /* VME card */
  {
    ULONG *plx_io = (ULONG *) 0x81000000L;
    vme_card_dev = cur_device;
/* HACK: solange das EEPROM auf der VME-Karte nicht korrekt ist, 
   PLX IO auf feste Adresse einblenden und per Zugriff auf die 
   Local-Register passend konfigurieren. 
*/
    pci_write_config(bus, dev, fct, PCI_BASE_ADDRESS_0, 0x01000001L);
    pci_write_config(bus, dev, fct, PCI_BASE_ADDRESS_1, 0x01000001L);
    pci_write_config(bus, dev, fct, PCI_COMMAND, 3L);
    pci_write_config(bus, dev, fct, PCI_ROM_ADDRESS, 0L);

/* VME-PLX liegt jetzt auf $81000000 (IO) und auf $41000000 (MEM) */
    plx_io[0x00/4] = 0xFE000000L; /* Adr. space 0 Range */
    plx_io[0x04/4] = 0x00000001L; /* Adr. space 0 local base */
    plx_io[0x0C/4] = 0x0000000fL; /* Adr. space 0 BIGEND */
    plx_io[0x14/4] = 0x00020000L; /* ROM local base */
    plx_io[0x18/4] = 0xF8410341L; /* Adr. space 0 region descriptor */
    plx_io[0x28/4] = 0x00000000L; /* DM disable */
    plx_io[0xF4/4] = 0x00010000L; /* Adr. Space 1 disable */
    plx_io[0xF8/4] = 0x00000341L; /* Adr. space 1 region descriptor */
    plx_io[0x68/4] = 0x00000900L; /* Int Enable */

    /* Karte erstmal wieder ausschalten fÅr PCI Init */
    pci_write_config(bus, dev, fct, PCI_BASE_ADDRESS_0, 0L);
    pci_write_config(bus, dev, fct, PCI_BASE_ADDRESS_1, 0L);
    pci_write_config(bus, dev, fct, PCI_COMMAND, 0L);
  }

  if (bus != VGA_bus || dev != VGA_dev || fct != VGA_fct)
    cur_device->resources = init_BARs(bus,dev,fct,0);
  else
    memcpy(cur_device->resources = kmalloc(7 * sizeof(pci_rsc)), VGA_resources, 7 * sizeof(pci_rsc));

  /* Interrupts einstellen */
  if(1)
  {
    ULONG tmp;
    int x;

    tmp = pci_read_config(bus, dev, fct, PCI_INTERRUPT_LINE);
    x = (int)((tmp>>8) & 0xff);
    if (x)
      cur_device->pci_interrupt = interrupt_table[dev][x-1];
    else
      cur_device->pci_interrupt = 0;
    cur_device->isa_interrupt = 0;
    /*
      erstmal im Interrupt Line Register den echten PCI Interrupt eintragen.
      Sobald das PCI->ISA-Mapping bekannt ist, durch den ISA-Interrupt ersetzen
    */
    tmp &= 0xffffff00L;
    tmp |= cur_device->pci_interrupt;
    pci_write_config(bus, dev, fct, PCI_INTERRUPT_LINE, tmp);
  }
  
  cur_device++;
}

/* diese Variablen sollten per NVRAM initialisiert bzw. vom ISA-PnP-Code
   aktualisiert werden
*/
UBYTE free_isa_ints[4];
int num_free_isa_ints;
UBYTE valid_int[16] = { 1,0,0,0, 1,1,0,1, 0,1,1,1, 1,0,1,1 };



/* pre-init PCI bus: setup variables, look for VGA card and setup
   VGA base address registers. Called before the VGA BIOS emulator runs.
*/
void preinit_pcibus(void)
{
  ULONG cmd;
        
  num_devices = 0;
  vme_card_dev = 0;
  vga_found=0;
  
  cur_io_base = 0x8000L;        /* Start unter 64K - wegen PIIX */
  cur_mem_base = 0x20000000L;   /* 512MB - auûerhalb Memory! */
        
  /*mprintf("preinit_pcibus start\r\n");*/
  enum_devs(0, do_preinit);
  /*mprintf("preinit_pcibus: found %d devices\r\n",num_devices);*/
  
  /*mprintf("VGA card in slot %d\n", VGA_dev);*/
  
  init_BARs(VGA_bus,VGA_dev,VGA_fct,VGA_resources);

  /* PCI Memory/IO fÅr VGA-Karte generell freischalten, auch wenn 
     die Karte keinen PCI-IO-Space anfordert - nîtig fÅr S3 Trio */
  cmd = pci_read_config(VGA_bus, VGA_dev, VGA_fct, PCI_COMMAND);
  cmd |= PCI_COMMAND_MEMORY | PCI_COMMAND_IO | PCI_COMMAND_MASTER;
  pci_write_config(VGA_bus, VGA_dev, VGA_fct, PCI_COMMAND, cmd);
}

/*
  Do the real PCI initialization for all devices expect the VGA card, which
  was initialized in preinit_pcibus.
  Also decode the board serial number.
*/
void init_pcibus(UBYTE *serial, UBYTE *memctrl)
{
  pci_device *devptr;
  extern pci_device *PCIBIOS_DevTable;
  extern UWORD PCIBIOS_DevNum;
  extern UBYTE PCI_Interrupts[4];
  
  int i,j;

  devptr = kmalloc((num_devices+1) * sizeof(pci_device));
        
  serial += 10;

  cur_device = devptr;
  enum_devs(0, do_config);
  *serial++ = *memctrl++ ^0x03;
  
  /*mprintf("init_pcibus done\r\n");*/

  /* PCI-Int-Zuordnung aus NVRAM lesen */
  if(1)
  {
    UBYTE tmp;
                
    tmp = nvram_read(0x31);
    free_isa_ints[0] = tmp & 15;
    free_isa_ints[1] = (tmp>>4) & 15;
    tmp = nvram_read(0x32);
    free_isa_ints[2] = tmp & 15;
    free_isa_ints[3] = (tmp>>4) & 15;
                
    if(!valid_int[free_isa_ints[0]] ||
       !valid_int[free_isa_ints[1]] ||
       !valid_int[free_isa_ints[2]] ||
       !valid_int[free_isa_ints[3]] ||
       free_isa_ints[0] == 0)
    {
      free_isa_ints[0] = 9;
      free_isa_ints[1] = 11;
      num_free_isa_ints = 2;
    }
    else
    {
      num_free_isa_ints = 4;
      if(free_isa_ints[3] == 0)
        num_free_isa_ints = 3;
      if(free_isa_ints[2] == 0)
        num_free_isa_ints = 2;
      if(free_isa_ints[1] == 0)
        num_free_isa_ints = 1;
    }
  }
  /* Liste der belegten PCI-Interrupts aufstellen */
  PCI_Interrupts[0] = PCI_Interrupts[1] = 
    PCI_Interrupts[2] = PCI_Interrupts[3] = 0;
  for(i=0;i<num_devices; i++)
  {
    if(devptr[i].pci_interrupt)
      PCI_Interrupts[devptr[i].pci_interrupt - 1] = 1;
  }

  *serial++ = *memctrl++ ^0x08;
  if (( PCI_Interrupts[0] || PCI_Interrupts[1] || 
        PCI_Interrupts[2] || PCI_Interrupts[3] ) 
      && num_free_isa_ints == 0)
  {
    vgaprintf(msg_pci_interrupt);
    PCI_Interrupts[0] = PCI_Interrupts[1] = 
      PCI_Interrupts[2] = PCI_Interrupts[3] = 0;
  }
  else
  {
    ULONG tmp;
    /* die freien ISA-Ints zyklisch auf INTA - INTD verteilen */
    for(i=j=0;i<4;i++)
    {
      if(PCI_Interrupts[i])
        PCI_Interrupts[i] = free_isa_ints[j++];
      if (j >= num_free_isa_ints)
        j=0;
    }
    /* Routing in PIIX einstellen */
    tmp = 0l;
    for(i=3 ; i>=0; i--)
    {
      tmp <<= 8;
      tmp |= PCI_Interrupts[i];
    }
    pci_write_config(0, 1, 0, 0x60, tmp); /* PIIX Fct. 0 PIRQx route control */

    tmp = pci_read_config(0,1,0, 0x70);
    tmp &= 0xffff0000L;
    tmp |= 0x00000f4eL; /* MBIRQ0 -> INT14, enable sharing. MBIRQ1 off */
    pci_write_config(0,1,0, 0x70, tmp);
  }
  *serial++ = *memctrl++ ^0x19;

  for(i=0;i<num_devices; i++)
  {
    ULONG tmp;
    int bus = devptr[i].bus;
    int dev = devptr[i].slot;
    int fct = devptr[i].fct;
    
    if(devptr[i].pci_interrupt)
      devptr[i].isa_interrupt = 
        PCI_Interrupts[devptr[i].pci_interrupt - 1];

    tmp = pci_read_config(bus, dev, fct, PCI_INTERRUPT_LINE);
    tmp &= 0xffffff00L;
    tmp |= devptr[i].isa_interrupt;
    pci_write_config(bus, dev, fct, PCI_INTERRUPT_LINE, tmp);
  }
  
  vgaprintf(msg_pci_devs);
  *serial++ = *memctrl++ ^0x68;
  for(i=0;i<num_devices; i++)
  {
    vgaprintf2(" %d/%d      %04X    %04X    ",
               devptr[i].slot,
               devptr[i].fct,
               (UWORD) devptr[i].id,
               (UWORD)(devptr[i].id>>16) );

    if(devptr[i].pci_interrupt)
      vgaprintf2("%c -> IRQ %d\n",devptr[i].pci_interrupt-1+'A', devptr[i].isa_interrupt);
    else
      vgaprintf2("-\n");
  }
  if (vme_card_dev)
  {
    init_vme_pmmu(vme_card_dev->resources[2].base + 
                  vme_card_dev->resources[2].offset);
  }
  /* Variablen ab $700 fÅrs TOS setzen */
  PCIBIOS_DevTable = devptr;
  PCIBIOS_DevNum = num_devices;
}
