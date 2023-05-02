/****************************************************************************
 * $Id: convert.c,v 1.2 2003/12/28 22:14:15 rincewind Exp $
 ****************************************************************************
 * $Log: convert.c,v $
 * Revision 1.2  2003/12/28 22:14:15  rincewind
 * - fix CVS headers
 *
 ****************************************************************************/

#include <stdio.h>
#include <stdlib.h>

typedef unsigned char BYTE;

#define SOURCE "rom.prg"
#define TARGET "a:\\tos.img"

FILE *efopen(const char *filename, const char *mode )
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

int main(void)
{
  FILE *fin, *fout;
  int convert_endian = 0;
  unsigned long length=0;
	
  fin = efopen(SOURCE,"rb");
  fout = efopen(TARGET,"wb");

  efseek(fin, 0x26, SEEK_SET);
	
  while (!feof(fin))
  {
    BYTE a[4];
    efread(a,1,4,fin);
    if (convert_endian)
    {
      BYTE b[4];
      b[0] = a[3];
      b[1] = a[2];
      b[2] = a[1];
      b[3] = a[0];
      efwrite(b,1,4,fout);
    }
    else
      efwrite(a,1,4,fout);
    length += 4;
  }

  efclose(fin);
  efclose(fout);
  printf("convert: wrote $%lX bytes to " TARGET ".\n",length);
  return 0;	
}
