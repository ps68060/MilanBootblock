/****************************************************************************
 * $Id: pci.h,v 1.3 2003/12/28 22:14:15 rincewind Exp $
 ****************************************************************************
 * $Log: pci.h,v $
 * Revision 1.3  2003/12/28 22:14:15  rincewind
 * - fix CVS headers
 *
 ****************************************************************************/

#ifndef __PCI_H__
#define __PCI_H__

#define ULONG unsigned long
#define UWORD unsigned short
#define UBYTE unsigned char

extern UBYTE VGA_bus;
extern UBYTE VGA_devfn;


#define PCIBIOS_SUCCESSFUL          0x00
#define PCIBIOS_FUNC_NOT_SUPPORTED  0x81
#define PCIBIOS_BAD_VENDOR_ID       0x83
#define PCIBIOS_DEVICE_NOT_FOUND    0x86
#define PCIBIOS_BAD_REGISTER_NUMBER 0x87
#define PCIBIOS_SET_FAILED          0x88
#define PCIBIOS_BUFFER_TOO_SMALL    0x89

/* Prototypen fuer LL_IO.S */
extern void pci_write_config(int bus, int dev, int fct, int adr, ULONG value);
extern ULONG pci_read_config(int bus, int dev, int fct, int adr);

extern unsigned long pci_confread(unsigned long dev);
extern void pci_confwrite(unsigned long dev, unsigned long val);

/* Funktionen in PCI.C */
ULONG EnableVgaRom(void);
void  DisableVgaRom(void);

int pcibios_read_config_byte (unsigned char bus, unsigned char device_fn,
			      unsigned char where, unsigned char *value);

int pcibios_read_config_word (unsigned char bus, unsigned char device_fn,
			      unsigned char where, unsigned short *value);

int pcibios_read_config_dword (unsigned char bus, unsigned char device_fn,
			       unsigned char where, unsigned long int *value);

int pcibios_write_config_byte (unsigned char bus, unsigned char device_fn,
			       unsigned char where, unsigned char value);

int pcibios_write_config_word (unsigned char bus, unsigned char device_fn,
			       unsigned char where, unsigned short value);

int pcibios_write_config_dword (unsigned char bus, unsigned char device_fn,
				unsigned char where, unsigned long int value);

int pcibios_find_class (unsigned long class_code, unsigned short index,
			unsigned char *bus,
			unsigned char *devfn);

int pcibios_find_device (unsigned short vendor, unsigned short device_id,
			 unsigned short index, unsigned char *bus,
			 unsigned char *devfn);
#endif
