/****************************************************************************
 * $Id: package.c,v 1.4 2003/12/28 22:14:02 rincewind Exp $
 ****************************************************************************
 * $Log: package.c,v $
 * Revision 1.4  2003/12/28 22:14:02  rincewind
 * - fix CVS headers
 *
 ****************************************************************************/

#include "proto.h"
#include "package.h"
#include <string.h>

extern int uncompress_data(PKG_HEADER *from, void *to);

static char *zipmalloc_ptr;
static char *saved_zipmalloc_ptr;

void *zipmalloc(unsigned long amount)
{
  void *adr = zipmalloc_ptr;
  amount = (amount+3) & ~3;
  zipmalloc_ptr += amount;
  if (zipmalloc_ptr > (char*) 0x01000000L)
  {
    vgaprintf2("Not enough memory to uncompress TOS!\n");
    return 0;
  }
  return adr;
}

void zipfree(void *block)
{
  (void) block;
}

void zipmalloc_save(void)
{
  saved_zipmalloc_ptr = zipmalloc_ptr;
}

void zipmalloc_restore(void)
{
  zipmalloc_ptr = saved_zipmalloc_ptr;
}

extern char *msg_compind[];
extern char *msg_uncompress[];
extern char *msg_done[];
extern char *msg_uc_error[];
extern char *msg_pkg_error[];
/* CompInd_Flag:
   1 = TOS stammt aus ROM - bei falschem CmpInd nicht starten
   0 = TOS stammt von DISK - Warnung, aber Start versuchen.
*/
extern unsigned long CompInd; /* Bootblock Compatiblity Index */   
int unpack_tos(int CompInd_Flag)
{
  char *tos_buffer = (char *) 0x00F00000L;
  if (*(UWORD*) tos_buffer == 0x602e) /* old TOS without header */
  {
    vgaprintf2("Old TOS without header: copying.\n");
    memcpy((void*) 0x00e00000L, tos_buffer, 0x00070000L);
  } else
  {
    int stat;
    PKG_HEADER *pkg = (PKG_HEADER *) tos_buffer;
    
    if (pkg->magic != PKG_MAGIC || 
        pkg->header_version != 1 ||
        pkg->pkg_type != PKGTYPE_TOS ||
        pkg->compr_type > 2)
    {
      vgaprintf(msg_pkg_error,1);
      return 0;
    }
    
    if (pkg->orig_len + sizeof(PKG_HEADER) > 0x080000L)
    {
      vgaprintf(msg_pkg_error,2);
      return 0;
    }
    if (pkg->orig_len > 0x00100000L)
    {
      vgaprintf(msg_pkg_error,3);
      return 0;
    }
    if (pkg->pkg_id > CompInd)
    {
      vgaprintf(msg_compind);
      if (CompInd_Flag)
      	return 0;
    }
    vgaprintf(msg_uncompress);
    if (pkg->compr_type == COMPR_NONE)
      memcpy((void*) 0x00e00000L, tos_buffer + sizeof(PKG_HEADER), pkg->orig_len);
    else
    {
      ULONG dest = 0x00e00000L;
      zipmalloc_ptr = (char*) 0xf80000L;
      stat = uncompress_data(pkg, (void *) dest);
      if (stat)
      {
        vgaprintf(msg_uc_error,stat);
        return 0;
      }
      /* now copy remaining PKGs unmodified to the end of the ROM */
      dest += pkg->orig_len;
      while(1)
      {
	dest = (dest + 15) & ~15;
	pkg = (PKG_HEADER *)(((ULONG)pkg + pkg->compressed_len + sizeof(PKG_HEADER) + 15) & ~15);
	if(pkg->magic != PKG_MAGIC || dest + pkg->orig_len > 0x00e80000L)
	  break;
				/*mprintf("copying %ld bytes PKG at %p\r\n",pkg->compressed_len, pkg);*/
	memcpy((void*) dest, pkg, pkg->compressed_len + sizeof(PKG_HEADER) + 15);
	dest += pkg->compressed_len + sizeof(PKG_HEADER);
      } 
    }
    vgaprintf(msg_done);
  }
  return 1;
}
