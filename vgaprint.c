/****************************************************************************
 ****************************************************************************
 * $Id: vgaprint.c,v 1.9 2003/12/28 22:14:02 rincewind Exp $
 ****************************************************************************
 * $Log: vgaprint.c,v $
 * Revision 1.9  2003/12/28 22:14:02  rincewind
 * - fix CVS headers
 *
 ****************************************************************************/

/*
  printf auf VGA-Textbildschirm
  Steuerzeichen:
  10 = \n   Return/Linefeed
  13 = \r   an Zeilenanfang
  1,xx      Attribut auf xx setzen
  2         akt. Position sichern
  3         zur gesicherten Position zurÅck
*/

#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include "proto.h"


#define SCREENBASE ((UBYTE *) 0x400B8000L)

static int line, column;
static int saved_line, saved_column;
static UBYTE *current;
static UBYTE color;
static UBYTE state;
static UBYTE did_init;
int language;

static void set_current(void)
{
  current = SCREENBASE + 160*line + 2*column;
}

static void scroll_up(void)
{
  memcpy(SCREENBASE, SCREENBASE+160, 24*160);
  memset(SCREENBASE+24*160, 0, 160);
}

void init_vgaprintf(void)
{
  saved_line = line = 3;
  saved_column = column = 0;
  color = 1;
  state=0;
  language=0;
  set_current();
  iowriteb(0x3d4,0x0a); iowriteb(0x3d5,0x20); /* turn off cursor */
  did_init = 1;
}

void vgaputc(UBYTE c)
{
  if (!did_init)
    return;
  if (state > 0)
  {
    color = c;
    state = 0;
    return;
  }
  if (c == 1)
  {
    state=1;
    return;
  }
  if (c == '\n')
    column = 80;
  else if (c == 8) {			/* Backspace */
    if (column > 0)
      column--;
    set_current();
    return;
  } else if (c == 13) {			/* Return */
    column = 0;
    set_current();
    return;
  } else if (c == 2) {			/* save position */
    saved_column = column;
    saved_line = line;
    return;
  } else if (c == 3) {			/* restore position */
    line = saved_line;
    column = saved_column;
    set_current();
    return;
  }
  else
  {
    *current++ = c;
    *current++ = color;
  }
  if (++column >= 80)
  {
    column = 0;
    if(++line >= 25)
    {
      scroll_up();
      line=24;
    }
    set_current();
  }
}

/* Ausgabe eines Strings. Bekommt einen Zeiger auf eine Liste 
   der Formatstrings und sucht sich den in der richtigen 
   Sprache heraus */

int vgaprintf(char *format[], ...)
{
  static char buffer[300], *p;
  va_list arglist;
  int stat;

  va_start(arglist,format);
  stat = vsprintf(buffer,format[language],arglist);
  va_end(arglist);

  p = buffer;
  while(*p)
    vgaputc(*p++);

  return stat;
}

/* direkte Ausgabe eines Strings */
int vgaprintf2(char *format, ...)
{
  static char buffer[300], *p;
  va_list arglist;
  int stat;

  va_start(arglist,format);
  stat = vsprintf(buffer,format,arglist);
  va_end(arglist);

  p = buffer;
  while(*p)
    vgaputc(*p++);

  return stat;
}
