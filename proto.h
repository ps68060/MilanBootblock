/****************************************************************************
 * $Id: proto.h,v 1.9 2003/12/28 22:14:02 rincewind Exp $
 ****************************************************************************
 * $Log: proto.h,v $
 * Revision 1.9  2003/12/28 22:14:02  rincewind
 * - fix CVS headers
 *
 ****************************************************************************/

typedef unsigned long ULONG;
typedef unsigned short UWORD;
typedef          short WORD;
typedef unsigned char UBYTE;

extern int mprintf(char*, ...);
extern void *kmalloc(ULONG size);
extern void init_pcibus(UBYTE *, UBYTE *);

extern void pci_write_config(int bus, int dev, int fct, int adr, ULONG value);
extern ULONG pci_read_config(int bus, int dev, int fct, int adr);


extern char get_mfp(void);
extern void unget_mfp(char c);
extern void put_mfp(char c);
extern void puts_mfp(char *);
extern unsigned char ioreadb(unsigned long adr);
extern unsigned int  ioreadw(unsigned long adr);
extern unsigned long ioreadl(unsigned long adr);
extern void iowriteb(unsigned long adr, unsigned char data);
extern void iowritew(unsigned long adr, unsigned int data);
extern void iowritel(unsigned long adr, unsigned long data);
extern unsigned long pci_confread(unsigned long dev);
extern void pci_confwrite(unsigned long dev, unsigned long val);

extern unsigned char test_readb(unsigned long adr);
extern unsigned int  test_readw(unsigned long adr);
extern unsigned long test_readl(unsigned long adr);

extern void load_tos(void);
extern void run_tos(void);

extern ULONG PhysToLog(ULONG PhysAdr);

extern void vgaputc(UBYTE c);
extern int vgaprintf2(char *format, ...);
extern int vgaprintf(char *format[], ...);

extern void init_vme_pmmu(ULONG membase);

/* keyboard.s */
extern void wait(UWORD amount);

/* messages.c */
extern char *msg_pci_interrupt[];
extern char *msg_pci_devs[];
extern char *msg_testing_mem[];
extern char *msg_mem_error[];
extern char *msg_need_16m[];
extern char *msg_memory_config[];
extern char *msg_mb_ok[];
extern char *msg_st_tt_serial[];
extern char *msg_vme_card_init[];
extern char *msg_nvram[];
extern char *msg_boardrev[];

/* package.c */
extern ULONG rompkg_get_len(WORD type, WORD id);
extern int rompkg_get_package(void *buffer);
extern void *zipmalloc(unsigned long amount);
extern void zipfree(void *block);
extern void zipmalloc_save(void);
extern void zipmalloc_restore(void);

/* crc32.c */
extern ULONG crc32buf(UBYTE *buf, ULONG len);

/* nvram.c */
UBYTE nvram_read(UBYTE adr);

