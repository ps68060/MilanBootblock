/****************************************************************************
 * NVRAM-Routinen fr Bootblock
 ****************************************************************************
 * $Id: nvram.c,v 1.4 2003/12/28 22:14:02 rincewind Exp $
 ****************************************************************************
 * $Log: nvram.c,v $
 * Revision 1.4  2003/12/28 22:14:02  rincewind
 * - fix CVS headers
 *
 * Revision 1.3  2003/12/28 20:57:05  rincewind
 * - document new flags
 *
 * Revision 1.2  2000/06/19 20:52:34  rincewind
 * - misc cleanup
 ****************************************************************************/

#include "proto.h"

/* Default NVRAM contents - used to initialize NVRAM if the checksum is invalid
 */
UBYTE nv_defs[] = {
  0, 0,		/* 0  UNIX/TOS boot preference */
  0,0,0,0,	/* 2  factory code, etc. */
  0,		/* 6  _AKP language */
  0,		/* 7  _AKP keyboard */
  0x11,		/* 8  _IDT time/date pref.: 
		      7-4        3-0     	          	
		      st_time    st_date  	          	
		      0 12 hour  0  MM-DD-YY
		      1 24 hour  1  DD-MM-YY
		                 2  YY-MM-DD
				 3  YY-DD-MM */
  '.',		/* 9  _IDT seperator */
  32,		/* 10 spinup delay */
  0xFF,		/* 11 IDE scan mask */
  0xFF,		/* 12 SCSI scan mask */
  0xFF,		/* 13 ACSI scan mask */
  0x00,0x00,	/* 14 (Falcon Video) _modecode */
  0x87,		/* 16 SCSI-ID, Bit 7 = Busarbitrierung enabled */
  0x00

  /* 0x30-0xE0 Milan NVRAM:
     0x30  Bit 1,0:  00 = ST-RAM 14MB
                     01 = ST-RAM 8MB
		     10 = ST-RAM 4MB
		     11 = illegal
           Bit 2:    1 = Romport Emulation (memory)
           Bit 3:    1 = skip memory test
     0x31  ISA interrupts assigned for use by PCI:
           Bit 7..4: PCI-INT[0]
           Bit 3..0: PCI-INT[1]
     0x32  ISA interrupts assigned for use by PCI:
           Bit 7..4: PCI-INT[2]
           Bit 3..0: PCI-INT[3]
           
  */
};

#define NVM_MAX 0xFF
#define RTC_BASE 0x70
#define RTC_OFFSET 1

#define NVM_BYTES (NVM_MAX+1-0x0E)
#define FIRST_ADR 0x0e

#define SEC	0
#define MIN	2
#define HOUR	4
#define WKDAY	6
#define DAY	7
#define MONTH	8
#define YEAR	9
#define REGA	0x0a
#define REGB	0x0b
#define REGC	0x0c
#define REGD	0x0d

#define NVMREAD 0
#define NVMWRITE 1
#define NVMINIT 2

static UBYTE nvram_ok = 0;

static UBYTE rtc_read(UBYTE ofs)
{
  iowriteb(RTC_BASE, ofs);
  return ioreadb(RTC_BASE+RTC_OFFSET);
}

void rtc_write(UBYTE ofs, UBYTE data)
{
  iowriteb(RTC_BASE, ofs);
  iowriteb(RTC_BASE+RTC_OFFSET, data);
}

#define SETBANK0 rtc_write(REGA, 0x20)
#define SETBANK1 rtc_write(REGA, 0x30)
#define SETBANK2 rtc_write(REGA, 0x40)

/*
  NVRAM Byte $0E .. $7F sind direkt in Bank 0 anzusprechen
  NVRAM Byte $80..$FF sind indirekt über Bank 1, Reg. $50/$53
  */
UBYTE nvram_read(UBYTE adr)
{
  if (!nvram_ok)
    return adr > sizeof(nv_defs)-1 ? 0 : nv_defs[adr];

  adr += FIRST_ADR;
  if (adr & 0x80)
  {
    SETBANK1;
    rtc_write(0x50, adr & 0x7F);
    return rtc_read(0x53);
  }
  else
  {
    SETBANK0;
    return rtc_read(adr);
  }
}

#if 0 /* not used in bootblock */
void nvram_write(UBYTE adr, UBYTE data)
{
  adr += FIRST_ADR;
  if (adr & 0x80)
  {
    SETBANK1;
    rtc_write(0x50, adr & 0x7F);
    rtc_write(0x53, data);
  }
  else
  {
    SETBANK0;
    rtc_write(adr, data);
  }
}
#endif


extern int language;    /* in vgaprintf.c */
void nvram_init(void)
{
  UBYTE sum;
  unsigned i;

  nvram_ok = 1;
  /* check checksum */
  for(sum=0, i=0; i<=NVM_MAX-2-FIRST_ADR; i++)
    sum += nvram_read(i);

  if (sum == nvram_read(NVM_MAX-FIRST_ADR) && 
      sum == (UBYTE)~nvram_read(NVM_MAX-FIRST_ADR-1))
  {
    language = nvram_read(6); /* 0 = USA, 1 = German */
    if (language != 1)
      language = 0;
  }
  else
  {
    nvram_ok = 0;
    vgaprintf(msg_nvram);
  }
}

