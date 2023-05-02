/****************************************************************************
 * $Id: misc.c,v 1.3 2003/12/28 22:14:01 rincewind Exp $
 ****************************************************************************
 * $Log: misc.c,v $
 * Revision 1.3  2003/12/28 22:14:01  rincewind
 * - fix CVS headers
 *
 ****************************************************************************/

#include "proto.h"
#include <string.h>
#include <stdio.h>

extern ULONG bb_boardrev; /* in ram700.s */

void display_boardrev(void)
{
	register ULONG rev = *(ULONG*) 0xFFFFC0C0L;
	char *s;
	bb_boardrev = rev;
	switch((int) rev)
	{
		case 0: s="1"; break;
		case 1: s="2.0"; break;
		case 2: s="2.1"; break;
		case 3: s="2.2"; break;
		default: s="unknown"; break;
	}
	vgaprintf(msg_boardrev, s);
}
