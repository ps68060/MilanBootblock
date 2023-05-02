/****************************************************************************
 * $Id: monitor.c,v 1.7 2003/12/28 22:14:01 rincewind Exp $
 ****************************************************************************
 * $Log: monitor.c,v $
 * Revision 1.7  2003/12/28 22:14:01  rincewind
 * - fix CVS headers
 *
 ****************************************************************************/

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "proto.h"

#if MON_TEST
# include <tos.h>
# define get_mfp() ((char)Bconin(2))
# define put_mfp(c) putchar(c)
# define puts_mfp(s) fputs(s,stdout)
# define ioreadb(x) 0
# define ioreadw(x) 0
# define ioreadl(x) 0
#define iowriteb(a,b)
#define iowritew(a,b)
#define iowritel(a,b)
#else
/*# include "ll_io.h"*/
#endif

#define NUMOF(a) (sizeof(a)/sizeof(a[0]))
static char buf[100];
extern unsigned long regsave[16];
extern unsigned int sr_save;

int mprintf(char *format, ...)
{
  char buffer[300];
  va_list arglist;
  int stat;

  va_start(arglist,format);
  stat = vsprintf(buffer,format,arglist);
  va_end(arglist);
  puts_mfp(buffer);
  return stat;
}

static int getline(void)
{
  int len=0;
  char c;

  for(;;)
  {
    c = toupper(get_mfp());
    put_mfp(c);
    if (c==13 || c ==10)
      break;
    if (c == 8 && len>0) /* Backspace */
    {
      len--;
      continue;
    }
    buf[len++] = c;
    if (len == 99)
      break;
  }
  buf[len] = 0;
  return len;
}

typedef enum {
  NOP, ERROR,
  IN_B, OUT_B, IN_W, OUT_W, IN_L, OUT_L,
  READ_B, READ_W, READ_L, WRITE_B, WRITE_W, WRITE_L,
  DUMP, TEST_D, TEST_W, TEST_L,
  CONFREAD, CONFWRITE,
  LOAD_TOS, RUN_TOS,
  HELP, QUIT
} CMD;

static struct
{
  char *cmdstr;
  int nargs_min;
  int nargs_max;
  CMD cmd;
  char *help;
} cmd_tab[] = {
  {"H",0,0,HELP,       "H / ?          this help\n"},
  {"?",0,0,HELP,       ""},
  {"IB",1,1,IN_B,      "IB adr         read byte at adr from IO\n"},
  {"IW",1,1,IN_W,      "IW adr         read word at adr from IO\n"},
  {"IL",1,1,IN_L,      "IL adr         read long at adr from IO\n"},
  {"OB",2,2,OUT_B,     "OB adr,val     write byte to IO at adr\n"},
  {"OW",2,2,OUT_W,     "OW adr,val     write word to IO at adr\n"},
  {"OL",2,2,OUT_L,     "OL adr,val     write long to IO at adr\n"},
  {"RB",1,1,READ_B,    "RB adr         read byte at adr from memory\n"},
  {"RW",1,1,READ_W,    "RW adr         read word at adr from memory\n"},
  {"RL",1,1,READ_L,    "RL adr         read long at adr from memory\n"},
  {"WB",2,2,WRITE_B,   "WB adr,val     write byte at adr to memory\n"},
  {"WW",2,2,WRITE_W,   "WW adr,val     write word at adr to memory\n"},
  {"WL",2,2,WRITE_L,   "WL adr,val     write long at adr to memory\n"},
  {"CR",3,3,CONFREAD,  "CR dev,fctn,reg     read PCI config (long)\n"},
  {"CW",4,4,CONFWRITE, "CW dev,fctn,reg,val write PCI config (long)\n"},
  {"D", 1,2,DUMP,      "D  adr<,lines> dump memory\n"},
  {"TD", 1,2,TEST_D,      "T              test function\n"},
  {"TW",1,1,TEST_W,    "TW adr         Test-read word at adr from memory\n"},
  {"TL",1,1,TEST_L,    "TL adr         Test-read long at adr from memory\n"},
  {"LT",0,0,LOAD_TOS,  "LT             Load TOS\n"},
  {"RT",0,0,RUN_TOS,   "RT             Run TOS\n"},
  {"Q", 0,0,QUIT,       "Q              Quit monitor\n"}
};

void _monitor(void)
{
  CMD cmd;
  int i, cmd_nr;
  unsigned long args[5];
  int nargs;
  char *p;
	
  mprintf("\nMILAN debug-mon V0.1 ready\n");
  mprintf("D0: %08LX D1: %08LX D2: %08LX D3: %08LX\n",
	  regsave[0], regsave[1], regsave[2], regsave[3]);
  mprintf("D4: %08LX D5: %08LX D6: %08LX D7: %08LX\n",
	  regsave[4], regsave[5], regsave[6], regsave[7]);
  mprintf("A0: %08LX A1: %08LX A2: %08LX A3: %08LX\n",
	  regsave[8], regsave[9], regsave[10], regsave[11]);
  mprintf("A4: %08LX A5: %08LX A6: %08LX A7: %08LX\n",
	  regsave[12], regsave[13], regsave[14], regsave[15]);
  mprintf("SR: %04X\n",sr_save);
  while(1)
  {
    mprintf("\n>");
    if(!getline())
      continue;
    p = buf;

    for(cmd=ERROR,i=0;i<NUMOF(cmd_tab); i++)
    {
      if(buf[0] == cmd_tab[i].cmdstr[0] &&
	 (!cmd_tab[i].cmdstr[1] || buf[1] == cmd_tab[i].cmdstr[1]))
      {
	cmd_nr = i;
	p ++;
	if(cmd_tab[i].cmdstr[1])
	  p++;
	break;
      }
    }

/*		while(*p >= 'A' && *p <= 'Z')
		p++;*/
    for(nargs=0;*p && nargs < 5; )
    {
      char *p2;
      while (isspace(*p) || *p == ',')
	p++;
      args[nargs] = strtoul(p, &p2 ,16);
      if (p2 != p)
      {
	nargs++;
	p = p2;
      }
      else
	break;
    }

    if (nargs < cmd_tab[cmd_nr].nargs_min || nargs > cmd_tab[cmd_nr].nargs_max)
    {
      mprintf("\n?parameter error!\n");
      cmd = NOP;
    }
    else
      cmd = cmd_tab[cmd_nr].cmd;

    switch(cmd)
    {
      case ERROR:
	mprintf("\n?unknown command!");
	break;
      case IN_B:
	mprintf("\n ->%02X",ioreadb(args[0]));
	break;
      case IN_W:
	mprintf("\n ->%04X",ioreadw(args[0]));
	break;
      case IN_L:
	mprintf("\n ->%08lX",ioreadl(args[0]));
	break;
      case OUT_B:
	iowriteb(args[0],(unsigned char) args[1]);
	break;
      case OUT_W:
	iowritew(args[0],(unsigned int) args[1]);
	break;
      case OUT_L:
	iowritel(args[0],(unsigned long) args[1]);
	break;
      case READ_B:
	mprintf("\n ->%02X",*((unsigned char *)args[0]) );
	break;
      case READ_W:
	mprintf("\n ->%04X",*((unsigned int *)args[0]) );
	break;
      case READ_L:
	mprintf("\n ->%08lX",*((unsigned long *)args[0]) );
	break;
      case WRITE_B:
	*((unsigned char *)args[0]) = (unsigned char) args[1];
	break;
      case WRITE_W:
	*((unsigned int *)args[0]) = (unsigned int) args[1];
	break;
      case WRITE_L:
	*((unsigned long *)args[0]) = (unsigned long) args[1];
	break;
      case TEST_W:
	mprintf("\n ->%04X",test_readw(args[0]));
	break;
      case TEST_L:
	mprintf("\n ->%08lX",test_readl(args[0]));
	break;
      case TEST_D:
	if(1)
	{
	  long lines = (nargs == 2) ? args[1] : 1;
	  unsigned long adr;
	  int i;
					
	  while(lines--)
	  {
	    adr = args[0];
	    mprintf("\n:%08lX ",args[0]);
	    for(i=0;i<16;i++)
	      mprintf("%02X ",test_readb(adr+i));
	    args[0] += 16;
	  }
	}	
	break;
      case CONFREAD:
	if (1)
	{
	  unsigned long dev;
	  dev = ((args[0] & 0x1f) << 11) |
	    ((args[1] & 0x07) << 8)  |
	    ((args[2] & 0x3f) << 2);
	  mprintf("\n ->%08lX",pci_confread(dev));
	}
	break;
      case CONFWRITE:	
	if (1)
	{
	  unsigned long dev;
	  dev = ((args[0] & 0x1f) << 11) |
	    ((args[1] & 0x07) << 8)  |
	    ((args[2] & 0x3f) << 2);
	  pci_confwrite(dev, args[3]);
	}
	break;
      case DUMP:
	if(1)
	{
	  long lines = (nargs == 2) ? args[1] : 1;
	  unsigned char *p;
	  int i;
					
	  while(lines--)
	  {
	    p = (unsigned char *) args[0];
	    mprintf("\n:%08lX ",args[0]);
	    for(i=0;i<16;i++)
	      mprintf("%02X ",p[i]);
	    put_mfp('"');
	    for(i=0;i<16;i++)
	      mprintf("%c",(p[i] >= 0x20 && p[i] < 0x80) ? p[i] : ' ');
	    put_mfp('"');
	    args[0] += 16;
	  }
	}	
	break;
      case LOAD_TOS:
	load_tos();
	break;
      case RUN_TOS:
	run_tos();
	break;
      case NOP:
      default:
	break;
      case QUIT:
	mprintf(" bye!\n");
	return;
      case HELP:
	mprintf("\ncommand summary:\n");
	for(i=0;i<NUMOF(cmd_tab); i++)
	  mprintf(cmd_tab[i].help);
	break;				
    }			
  }
}

#if MON_TEST
int main(void)
{
  _monitor();
  return 0;
}
#endif
