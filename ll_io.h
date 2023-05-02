/****************************************************************************
 * $Id: ll_io.h,v 1.6 2003/12/28 22:14:01 rincewind Exp $
 ****************************************************************************
 * $Log: ll_io.h,v $
 * Revision 1.6  2003/12/28 22:14:01  rincewind
 * - fix CVS headers
 *
 ****************************************************************************/

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
