/****************************************************************************
 * PMMU-Initialisierung
 ****************************************************************************
 * $Id: pmmu.c,v 1.17 2003/12/28 22:14:02 rincewind Exp $
 ****************************************************************************
 * $Log: pmmu.c,v $
 * Revision 1.17  2003/12/28 22:14:02  rincewind
 * - fix CVS headers
 *
 * Revision 1.16  2003/12/28 20:56:28  rincewind
 * - add flag to NVRAM to force fast memtest
 ****************************************************************************/

#include "proto.h"
#include <string.h>
#include <stdio.h>

#define PageSize 8192        /* Seitengroesse sollte nicht geaendert werden */
#define ever ;;

#define ULONG unsigned long
#define BOOL  unsigned int
#define WORD  unsigned int
#define BYTE  unsigned char
#define TRUE  1
#define FALSE 0

#define M1  0x00100000L /* 1MB */
#define M4  0x00400000L /* 4MB */
#define M16 0x01000000L /* 16MB */
#define M64 0x04000000L /* 64MB */

ULONG TosLen;				/* Groesse des TOS */

/* aus monitor.c */
extern int mprintf(char *format, ...);

/* Die Variablen sind im Assembler Teil deklariert */
extern ULONG phys_RootTbl;		/* Zeiger auf die root table */
extern ULONG log_IOpage;		/* Zeiger auf die I/O page */
extern ULONG log_IO_PageDescript;	/* Zeiger auf die I/O Descriptoren */
extern ULONG log_phystop;		/* Logische Obergrenze des ST-RAMs */
extern ULONG log_ramtop;		/* Logische Obergrenze des Fast RAMs */
extern ULONG MemorySchatten;
extern ULONG warmstart_magic;		/* Magic: bei Warmstart $31415926 */
extern ULONG SerialNo;
extern UWORD fill_tab[16];		/* Tabelle von 4MB-Blîcken */

ULONG stram_end;
int romport_emu;

#define Jumper   (*(BYTE*)  0x80000413L)

/* Transparent Translation Register definieren */
/* 1GB PCI I/O */
#define R_DTTR0 (0x803FE000L | PAGE_NOCACHE_SER | PAGE_LIT_END)
#define R_ITTR0 (0x803FE000L | PAGE_NOCACHE_SER | PAGE_LIT_END)
/* 1GB PCI Memory */
#define R_DTTR1 (0x403FE000L | PAGE_WRITE_THR)
#define R_ITTR1 (0x403FE000L | PAGE_WRITE_THR)

/* Attribute fuer die Seiten */
                                       /* - -GUU SCCM UWPP */
#define PAGE_NOACCESS    0x0008L       /* - ---- ---- 1-00 */
#define PAGE_READWRITE   0x000BL       /* - ---- ---- 1011 */
#define PAGE_READONLY    0x000FL       /* - ---- ---- 1111 */

#define PAGE_SUPER_ONLY  0x0080L       /* - ---- 1--- ---- */
#define PAGE_GLOBAL      0x0400L       /* - -1-- ---- ---- */

#define PAGE_WRITE_THR   0x0000L       /* - ---- -00- ---- */
#define PAGE_COPY_BACK   0x0020L       /* - ---- -01- ---- */
#define PAGE_NOCACHE_SER 0x0040L       /* - ---- -10- ---- */
#define PAGE_NOCACHE     0x0060L       /* - ---- -11- ---- */

#define PAGE_LIT_END     0x0100L       /* - ---1 ---- ---- */
#define PAGE_BIG_END     0x0000L       /* - ---0 ---- ---- */

#define PAGE_MASK        0xFFFFE000L

int fast_memtest = 0;                  /* Abbruch Flag fÅr Speicher test */
int DiskLoad = 0;                      /* TOS von Diskette laden */
int PauseFlag = 0;

extern int GetKey(void);

/* Alle mîglichen Tasten testen */
void CheckKeys(void)
{
  char Key;

  do
  {
    Key = GetKey();
#if 0	  
    if(Key)
      vgaprintf2("Taste: $%02X\r\n",Key);
#endif  		
    switch (Key)
    {
      case 0x43:   /* F9 */
	DiskLoad = 1;
	/* fallthrough */
      case 0x01:   /* ESC */
	fast_memtest = 1;
	break;
      case 0x44:   /* F10 */
	DiskLoad = 0;
	break;
      case 0x45:   /* PAUSE */
	PauseFlag = 1;
	break;
      case 0x39:   /* Space */
	PauseFlag = 0;
	break;
    }
  }while(Key);
}

/* Liefert den angeforderten Speicher Longaligned zurueck
 */

void *kmalloc(ULONG Amount)
{
  log_phystop -= Amount;
  log_phystop &= ~3;
  return (void *)log_phystop;
}

/* Liefert den angeforderten Speicher 9Bit-aligned zurueck.
 * Die Root-Tabelle und die Pointer-Tabellen brauchen das 9-Bit alignment.
 */
ULONG kmalloc9(ULONG Amount)
{
  log_phystop -= Amount;
  log_phystop &= ~511;
  return log_phystop;
}

ULONG kmallocPage(ULONG Amount)
{
  log_phystop -= Amount;
  log_phystop &= ~8191;
  return log_phystop;
}

/* Liefert den angeforderten Speicher 7Bit-aligned zurueck.
 * Die Page-Tabellen brauchen das 7-Bit alignment.
 */
ULONG kmalloc7(ULONG Amount)
{
  log_phystop -= Amount;
  log_phystop &= ~127;
  return log_phystop;
}

/* Liefert den Root Table Pointer.
 * IN:  Create  - Flag gesetzt: falls Tabelle nicht vorhanden, wird sie angelegt.
 * OUT: Zeiger auf die Root Table.
 */

ULONG GetRootTablePointer(BOOL Create)
{
  if ((phys_RootTbl == 0) && Create)
  {
    phys_RootTbl = kmalloc9(128*4);  /* 128 Eintraege a 4 Byte anlegen */
    memset((void*)phys_RootTbl, 0, 512);
  }
  return phys_RootTbl;
}

/* Liefert den Pointer Table Pointer
 * Eine Pointer Table hat eine Granularitaet von 7-Bit d.h. 02000000H bzw. 32MB
 * Die Aufrufende Routine hat dafuer Sorge zu tragen, dass bei Ueberschreitung
 * des Bereichs ein neuer Zeiger angefordert wird.
 * IN:  Address - Startadresse des gewuenschten Bereichs
 *      Create  - Flag gesetzt:  falls Tabelle nicht vorhanden, wird sie angelegt.
 * OUT: Zeiger auf die Pointer Table
 */
ULONG GetPointerTablePointer(ULONG Address, BOOL Create)
{
  ULONG *PTP;                    /* Zeiger auf den Root Tabellen Eintrag   */
  
/* RRRR RRRP PPPP PPII III- ---- ---- ---- */
  PTP = (ULONG*)(GetRootTablePointer(TRUE) + ((Address >> 23) & 0x000001FCL));
/* mprintf("PointerTable: PTP=%lx\n",PTP);*/
  if ((*PTP == 0) && Create) {
    *PTP = kmalloc9(128*4);              /* 128 Eintraege a 4 Byte anlegen   */
    memset((void*)(*PTP), 0, 512);
    *PTP |= PAGE_READWRITE;                 /* Write Protect nur auf Page Ebene */
  }
  return (ULONG)*PTP & ~511;
}

/* Liefert den Page Table Pointer
 * Eine Page Table fuer 8-K Pages hat eine Granularitaet von 7-Bit d.h. 00040000H bzw. 256KB
 * Die Aufrufende Routine hat dafuer Sorge zu tragen, dass bei Ueberschreitung
 * des Bereichs ein neuer Zeiger angefordert wird.
 * IN:  Address - Startadresse des gewuenschten Bereichs
 *      Create  - Flag gesetzt:  falls Tabelle nicht vorhanden, wird sie angelegt.
 * OUT: Zeiger auf die Page Table
 */
ULONG GetPageTablePointer(ULONG Address, BOOL Create)
{
  ULONG *PgTP;                              /* Zeiger auf den Pointer Tabellen Eintrag   */
  
/* RRRR RRRP PPPP PPII III- ---- ---- ---- */
  PgTP = (ULONG*)(GetPointerTablePointer(Address,TRUE) + ((Address >> 16) & 0x000001FC));
  if ((*PgTP == 0) && Create) {
    *PgTP = kmalloc7(32*4);              /* 32 Eintraege a 4 Byte anlegen   */
    memset((void*)(*PgTP), 0, 128);
    *PgTP |= PAGE_READWRITE;                /* Write Protect nur auf Page Ebene */
  }
  return (ULONG)*PgTP & ~127;
}

/* Diese Routine alloziert den Speicher fuer die benoetigten Deskriptoren
 * und setzt die Parameter wie gewuenscht.
 */

extern void *do_memtest(void *start, void *end);

static void SetPMMUTables(void) 
{
  ULONG PhysAdr;                            /* Physikalische Adresse */
  ULONG LogAdr;                             /* Logische Adresse */
  ULONG *temp, *temp2;                      /* Zeiger auf die Page Tabelle */
  ULONG CacheMode;                          /* Cache Modi */
  WORD i, slot;
  ULONG schatten, mask;
  ULONG total_mem_ok = 0L;
  /* FÅr Fehlermeldung: */
  static char cslots[8] = "01230123";	/* Echte Slotnummer */
  static char csides[8] = "00001111";	/* Seite im Slot */

  /* Der gesammte Hauptspeicher muss auf entsprechende logische Adressen
   * verteilt werden.
   */
  LogAdr = 0;

  log_IOpage = kmallocPage(8192);

  /* Cache Mode fuer den Hauptspeicher nach den Jumpern einstellen */ 
  switch (Jumper & 3)
  {
    case 0: CacheMode = PAGE_READWRITE | PAGE_NOCACHE_SER; break;
    case 1: CacheMode = PAGE_READWRITE | PAGE_NOCACHE; break;
    case 2: CacheMode = PAGE_READWRITE | PAGE_WRITE_THR; break;
    case 3: CacheMode = PAGE_READWRITE | PAGE_COPY_BACK; break;
  }

  /* die 8 Speicherblîcke - wenn vorhanden - testen und mappen */
  vgaprintf(msg_testing_mem);
  schatten = MemorySchatten;
  mask = 0xf0000000L;
  /*mprintf("MemoryConfig: $%08lX\n",MemorySchatten);*/
  for(slot=0;slot<8; slot++)
  {
    int block;
    UWORD mask_4m;
    
    mask_4m = fill_tab[(int)((schatten & 0xf0000000L) >> 28)];
    /*mprintf("Slot %d: config=%d, mask=$%04X\n",slot,(int)((schatten & 0xf0000000L) >> 28),mask_4m);*/
    for(block=0; block < 16; block++, mask_4m>>=1)
    {
      if (mask_4m & 1)
      {
	ULONG end_ok, end;
	PhysAdr = slot * M64 + block * M4;
	end = PhysAdr + M4;
	if (warmstart_magic != 0x31415926L)
	{
          end_ok = (ULONG)do_memtest((PhysAdr == 0L) ? (void*) M1 : (void*)PhysAdr,
                                     (void*)end);
	  if (end_ok == end)
	    total_mem_ok += M4;
	  else
	  {
	    vgaprintf(msg_mem_error,cslots[slot], csides[slot]);
	    MemorySchatten &= ~mask; /* Block ausblenden */
	    if (slot == 0)
	    {
	      vgaprintf(msg_need_16m);
	      warmstart_magic = 0l;
	      for(ever);
	    }
	  }
	}
	else
	  total_mem_ok += M4;             /* bei Warmstart */
      } /* if (mask...) */
    } /* for(block) */

    mask_4m = fill_tab[(int)((schatten & 0xf0000000L) >> 28)];
    for(block=0; block < 16; block++, mask_4m>>=1)
    {
      if (mask_4m & 1)
      {
	ULONG end;
	PhysAdr = slot * M64 + block * M4;
	end = PhysAdr + M4;

	while (PhysAdr < end)            /* Durch alle phys. Adressen laufen */
	{
	  temp = (ULONG*)GetPageTablePointer(LogAdr,TRUE);
	  for (i = 0; i < 32; i++)		   /* jeweils 256KB Bloecke schreiben */
	  {
	    if (PhysAdr == 0x00FA0000L && romport_emu)
	      PhysAdr += 256L*1024L;     /* Romport-Bereich Åberspringen */
	    *temp = PhysAdr | CacheMode;
	    LogAdr += PageSize;
	    PhysAdr += PageSize;
	    temp++; 
	  }
	  if (LogAdr == stram_end)
	    LogAdr = 0x01000000L;        /* im Alt-RAM weitermachen */
	  if (PhysAdr == 0x00E00000L)
	    PhysAdr += TosLen;           /* TOS-Bereich Åberspringen */
	} 
      }
    } /* for(block) */
    schatten <<= 4;
    mask >>= 4;
  }
#if 0 /* wird oben schon abgefangen */
  if (LogAdr < M16)
  {
    vgaprintf(msg_need_16m);
    warmstart_magic = 0l;
    for(ever);
  }
#endif
  log_ramtop = LogAdr;
  vgaprintf(msg_mb_ok,(int)(total_mem_ok >> 20));

#if 0 /* Page 0 auf nocache setzen, fÅr 68060/Hardwareemulation */
  temp = (ULONG*)GetPageTablePointer(0,FALSE);
  temp[0] &= PAGE_MASK;
  temp[0] |= PAGE_READWRITE | PAGE_NOCACHE;
#endif

  
  /* Tabellen fuer TOS getrennt einrichten */
  for(PhysAdr=0x00e00000L, i=0; PhysAdr < 0x00e00000L + TosLen; PhysAdr += PageSize)
  {
    if (i==0)
      temp = (ULONG*)(GetPageTablePointer(PhysAdr,TRUE));
    temp[i++] = PhysAdr |(PAGE_READONLY | PAGE_COPY_BACK); /* Beschreiber */
    i &= 31;
  }

#if 0
  /*mprintf("Milan IO\n");*/
  /* Milan I/O Bereich */
  temp  = (ULONG*)GetPageTablePointer(0xFFFE0000L,TRUE); /* Zeiger auf I/O Bereich holen */
  temp += 16;                                    /* Nur die letzen 16 Eintraege */
  PhysAdr = 0xFFFE0000L;
  /* Zuerst der Milan I/O Bereich an FFFE0000 */  
  for (i = 0; i < 8; i++) {                      /* 64KB Block schreiben */
    *temp++ = PhysAdr + (PAGE_READWRITE | PAGE_NOCACHE_SER | PAGE_LIT_END);
    PhysAdr += PageSize;
  }
#endif

  /*mprintf("ROMPORT:\n");*/
  /* ROM-Port auf ROPOCOP:
     Port A bei $40020000 128K hinten (Slotblech)
     Port B bei $40040000 128K oben
     Port C bei $40060000 128K innen
  */
  if (romport_emu)
    PhysAdr = 0x00FA0000L;
  else
    PhysAdr = 0x40020000L;
  temp  = (ULONG*)GetPageTablePointer(0x00FA0000L,TRUE) + 16;
  temp2 = temp;                                  /* merken fÅr Alias bei $FFFA0000 */
  for (i = 0; i < 16; i++)                       /* 128KB Block schreiben */
  {
    *temp++ = PhysAdr + (PAGE_READONLY | PAGE_NOCACHE_SER | PAGE_BIG_END);
    PhysAdr += PageSize;
  }

  /* Romport - alias bei $FFFA0000 */
  temp = (ULONG*)GetPageTablePointer(0xFFFA0000L,TRUE) + 16;
  for (i = 0; i < 16; i++)                       /* 128KB Block schreiben */
    *temp++ = (ULONG)temp2++ | 0x02;             /* indirekte Beschreiber */

  if (romport_emu) /* Das Gleiche nochmal ab $00FE0000, aber schreibbar */
  {
    PhysAdr = 0x00FA0000L;
    temp  = (ULONG*)GetPageTablePointer(0x00FD0000L,TRUE)+8;
    for (i = 0; i < 16; i++)                     /* 128KB Block schreiben */
    {
      *temp++ = PhysAdr + (PAGE_READWRITE | PAGE_NOCACHE_SER | PAGE_BIG_END | PAGE_SUPER_ONLY);
      PhysAdr += PageSize;
    }
  }

  /*mprintf("Atari IO:\n");*/
  /* Atari I/O Bereich */
  temp  = (ULONG*)GetPageTablePointer(0xFFFE0000L,TRUE); /* Zeiger auf I/O Bereich holen */
  temp += 24;
  PhysAdr = (ULONG)temp;                         /* Adresse merken */
  log_IO_PageDescript = PhysAdr;		 /* FÅr spÑter merken */
  for (i = 0; i < 8; i++)                        /* 64KB Block schreiben */
  {
    if (i == 6) {				 /* Neuer Milan I/O Bereich */
      *temp = 0xFFFFC000L + (PAGE_READWRITE | PAGE_NOCACHE_SER | PAGE_LIT_END);
    } else {
      *temp = 0xFFFF0000L + (PAGE_READWRITE | PAGE_NOCACHE_SER | PAGE_LIT_END);
    }
    temp++; 
  }

  /* Atari I/O Bereich - alias bei $00FF0000 */
  temp = (ULONG*)GetPageTablePointer(0x00FF0000L,TRUE);  /* Zeiger auf I/O Bereich holen */
  temp += 24;                                    /* Nur die letzen 8 Eintraege */
  for (i = 0; i < 8; i++)                      /* 64KB Block schreiben */
  {
    *temp = PhysAdr + 0x02;                      /* indirekte Beschreiber */
    PhysAdr += 4;
    temp++; 
  }

  /* I/O Bereich noch einmal als Big Endian einblenden.
   * Der Bereich wird mit 128K ab $C0000000 eingeblendet.
   */
  temp = (ULONG*)GetPageTablePointer(0xC0000000L,TRUE);  /* Zeiger auf neuen I/O Bereich holen */
  PhysAdr = 0x80000000L;                         /* Der normale PCI (ISA) I/O Bereich */
  for (i = 0; i < 16; i++)                       /* 128KB Block schreiben */
  {
    *temp = PhysAdr + (PAGE_READWRITE | PAGE_NOCACHE_SER | PAGE_BIG_END);
    PhysAdr += PageSize;
    temp++; 
  }
  /* $C1000000 als Alias fÅr PCI Memory ab $40000000 fÅr
     Interrupt-Acknowledge-Cycle */
  temp = (ULONG*)GetPageTablePointer(0xC1000000L,TRUE);  /* Zeiger auf neuen I/O Bereich holen */
  PhysAdr = 0x40000000L;                         /* Der normale PCI (ISA) I/O Bereich */
  *temp = PhysAdr + (PAGE_READWRITE | PAGE_NOCACHE_SER | PAGE_LIT_END);
}

/* PMMU initialisieren */
void Init_PMMU(UBYTE *serial, UBYTE *memctrl)
{
  ULONG PhysAdr;                        /* Physikalische Adresse */
  ULONG *temp;                          /* Zeiger auf die Page Tabelle */
  UBYTE nv_tmp = nvram_read(0x30);

  /* mprintf("Init_PMMU start\n"); */
  
  stram_end = 0x00e00000L;

  switch(nv_tmp & 3)
  {
    case 1:
      stram_end = 0x00800000L; break;
    case 2:
      stram_end = 0x00400000L; break;
  }
  romport_emu = (nv_tmp & 4);
  if (nv_tmp & 8)
    fast_memtest = 1;

  log_phystop = stram_end;		/* 14MB - TOS ab $E0, wir haben mindestens 16MB RAM */
  TosLen = 512*1024l;
  log_ramtop = 0L;

  serial += 10;
  phys_RootTbl = 0;			/* Tabelle haben wir noch keine */
  SetPMMUTables();			/* Tabellen anlegen */
  memctrl += 0xc4 - 3;
  /* mprintf("nach SetPMMUTables\n"); */

/* Jetzt sind alle Tabellen angelegt. */

/* Jetzt PCI-Ressourcen initialisieren (braucht kmalloc!) */
  init_pcibus(serial, memctrl);
#if 0
  SerialNo = 1L;
#endif

/*
 * Nun muessen wir nur noch den Speicher auf die naechste Seitengrenze abrunden
 * Und die Attribute fuer die Seiten auf NoCache gesetzt werden.
 */  
  log_phystop &= PAGE_MASK;
  PhysAdr = log_phystop;
  while (PhysAdr < stram_end)
  {
    temp = (ULONG*)(GetPageTablePointer(PhysAdr,FALSE) |
		    ((PhysAdr >> 11) & 0x0000007CL));
    *temp &= PAGE_MASK;		/* Adresse beibehalten */
    *temp |= (PAGE_READWRITE | PAGE_SUPER_ONLY | PAGE_NOCACHE);
    PhysAdr += PageSize;
  }
  /* Seriennummer:
     Jahr:6 / Monat:4 / Charge:6 / Nr:16
     -> RCCMMNNNNNJJ
  */
  if(1)
  {
    unsigned int jahr  = (unsigned int) (SerialNo >>26) & 63;
    unsigned int monat = (unsigned int) (SerialNo >>22) & 15;
    unsigned int charge = (unsigned int) (SerialNo >>16) & 63;
    unsigned int nr = (unsigned int) SerialNo;
    jahr = (jahr+98) % 100;
     
    vgaprintf(msg_st_tt_serial,log_phystop>>10, (log_ramtop-M16) >>10, charge, monat,nr,jahr);
    sprintf((char*)(0x00e80000L-16),"R%02d%02d%05d%02d",charge, monat,nr,jahr);
  }
}

/* TOS Bereich schreibschuetzen */
void Lock_TOS(void)
{
  ULONG PhysAdr;                        /* Physikalische Adresse */
  ULONG *temp;                          /* Zeiger auf die Page Tabelle */

  PhysAdr = 0xe00000L;
  while (PhysAdr < 0xe00000L + TosLen) {
    temp = (ULONG*)(GetPageTablePointer(PhysAdr,FALSE) | ((PhysAdr >> 11) & 0x0000007CL));
/* mprintf("Lock TOS: phys=%lx, temp=%lx\n",PhysAdr, temp); */
    *temp &= PAGE_MASK;		/* Adresse beibehalten */
    *temp |= (PAGE_READONLY | PAGE_COPY_BACK);
    PhysAdr += PageSize;
  }
}

/* 
   PMMU fÅr VME-Karte initialisieren. Die Karte liegt physikalisch bei
   membase und soll logisch bei $FE000000 eingeblendet werden.
*/
void init_vme_pmmu(ULONG membase)
{
  ULONG PhysAdr;                            /* Physikalische Adresse */
  ULONG *temp;                              /* Zeiger auf die Page Tabelle */
  ULONG adr;
  WORD i;

  for(adr=0L, i=0; adr<M16; adr += PageSize)
  {
    if (i==0)
      temp = (ULONG*)(GetPageTablePointer(0xFE000000L + adr,TRUE));
    temp[i++] = membase + adr +(PAGE_READWRITE | PAGE_NOCACHE_SER); /* Beschreiber */
    i &= 31;
  }

  /* Das TOS greift auf $FD00FFFx zu, um einen Interrupt-Acknowledge-Cycle auszufÅhren. 
     Diesen Bereich (eine Page wÅrde ausreichen) mappen wir auf die VME-Karte bei $01FF0000, 
     damit landet der Zugriff bei Offset $01FFFFFx. */
#if 0
  PhysAdr = membase + 0x00010000L;
#else
  PhysAdr = membase + 0x01FF0000L;
#endif  
  temp = (ULONG*)GetPageTablePointer(0xFD000000L,TRUE);
  for (i = 0; i < 8; i++) {                 /* 64KB Block schreiben */
    *temp = PhysAdr + (PAGE_READWRITE | PAGE_NOCACHE_SER); /* Beschreiber */
    PhysAdr += PageSize;
    temp++; 
  }
  /* Bei Offset $01000000 kann bei neuen VME-Karten die Interruptnummer gelesen werden 
     temp zeigt auf Beschreiber fÅr $FD01xxxx */
  PhysAdr = membase + 0x01000000L;
  *temp++ = PhysAdr + (PAGE_READWRITE | PAGE_NOCACHE_SER); /* Beschreiber */

  vgaprintf(msg_vme_card_init, membase);

#if 1
  /* Atari I/O Bereich $FFA000 auf StarTrack mappen (Falcon-DSP-KompatibilitÑt) */
  temp  = (ULONG*)GetPageTablePointer(0xFFFC0000L,TRUE);
  temp += 29;
  *temp = membase + 0x00ff2000L + (PAGE_READWRITE | PAGE_NOCACHE_SER);
#endif  
}
