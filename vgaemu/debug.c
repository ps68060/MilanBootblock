/****************************************************************************
 * $Id: debug.c,v 1.3 2003/12/28 22:14:15 rincewind Exp $
 ****************************************************************************
 * $Log: debug.c,v $
 * Revision 1.3  2003/12/28 22:14:15  rincewind
 * - fix CVS headers
 *
 ****************************************************************************/

#include <stdio.h>
#include <ctype.h>
#include <string.h>

#include "debug.h"

/* debug-port printf routine for standalone version */

int mprintf(char *format, ...)
{
#ifdef ERROR_OUTPUT
  char buffer[300];
  va_list arglist;
  int stat;

  va_start(arglist,format);
  stat = vsprintf(buffer,format,arglist);
  va_end(arglist);
  puts_mfp(buffer);
  return stat;
#endif	
}
