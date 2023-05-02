/****************************************************************************
 * $Id: convert.c,v 1.10 2003/12/28 22:13:35 rincewind Exp $
 ****************************************************************************
 * $Log: convert.c,v $
 * Revision 1.10  2003/12/28 22:13:35  rincewind
 * - fix CVS headers
 *
 * Revision 1.4  2000/07/15 22:46:02  rincewind
 * - Add magic and CRC-32 checksum to end of bootblock image
 * - removed endian conversion code
 * - conversion takes place in memory now
 ****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "crc32.c"

/*typedef unsigned char BYTE;*/

#define SOURCE "rom.prg"
#define TARGET "c:\\flash\\bootblk.img"

FILE *efopen(char *filename, const char *mode )
{
  FILE *fp = fopen(filename, mode);
  if (!fp)
  {
    perror(filename);
    exit(1);
  }
  return fp;
}

int efclose(FILE *fp)
{
  int stat = fclose(fp);
  if (stat)
    perror("fclose");
  return stat;
}

int efseek(FILE *stream, long offset, int mode)
{
  int stat = fseek(stream, offset, mode);
  if(stat)
    perror("fseek");
  return stat;
}

size_t efread( void *ptr, size_t elem_Size, size_t count, FILE *fp)
{
  size_t result = fread(ptr, elem_Size, count, fp);
	
  if (result != count)
    fprintf(stderr,"fread: wanted %ld, got %ld\n",count,result);
	
  return result;
}

size_t efwrite(void *ptr, size_t elem_Size, size_t count, FILE *fp)
{
  size_t result = fwrite(ptr, elem_Size, count, fp);
	
  if (result != count)
    perror("fwrite");
	
  return result;
}

void *emalloc(size_t size)
{
  void *p = malloc(size);
  if(!p)
  {
    perror("malloc");
    exit(1);
  }
  return p;
}

int main(void)
{
  FILE *fin, *fout;
  int convert_endian = 0;
  unsigned long length;
  unsigned char *buffer;
  ULONG crc;
  ULONG magic;
	
  fin = efopen(SOURCE,"rb");
  fout = efopen(TARGET,"wb");

  efseek(fin, 0x00, SEEK_END);
  length = ftell(fin) - 0x26;
	
  printf("image length: $%lX\n",length);
	
  buffer = emalloc(length + 0x10);
	
  efseek(fin, 0x26, SEEK_SET);
  efread(buffer,1,length,fin);
	
  if (convert_endian)
  {
    printf("endian conversion not implemente!\n");
    exit(1);
  }
	
  length = (length + 3) & ~3;
  crc = crc32buf(buffer, length);
  printf("CRC is $%lX\n",crc);
	
  efwrite(buffer,1,length,fout);

  memcpy(&magic, "bCRC", 4);
  efwrite(&magic, 1, 4, fout);
  efwrite(&crc, 1, 4, fout);

  efclose(fin);
  efclose(fout);
  printf("convert: wrote $%lX bytes to " TARGET ".\n",length+8);
  return 0;	
}
