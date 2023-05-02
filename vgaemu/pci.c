/****************************************************************************
 * PCI Support Funktionen
 ****************************************************************************
 * $Id: pci.c,v 1.4 2003/12/28 22:14:15 rincewind Exp $
 ****************************************************************************
 * $Log: pci.c,v $
 * Revision 1.4  2003/12/28 22:14:15  rincewind
 * - fix CVS headers
 *
 * Revision 1.3  2003/12/28 20:52:21  rincewind
 * - add debug output
 *
 * Revision 1.3  2000/07/15 22:41:46  rincewind
 * - Removed FindVgaCard code from common area since bootblock does this during
 *   PCI init
 ****************************************************************************/

#include "pci.h"
#include "debug.h"


ULONG
EnableVgaRom(void)
{
  ULONG Value;

  /* Karte fÅr Memory und I/O freischalten */
  pcibios_write_config_byte(VGA_bus,VGA_devfn,0x04,0x03);
  /* An der Default BIOS Adresse einschalten */
  pcibios_write_config_dword(VGA_bus,VGA_devfn,0x30,0x000C0001l);
  /* Und sicherheitshalber die Adresse zurÅcklesen */
  pcibios_read_config_dword(VGA_bus,VGA_devfn,0x30,&Value); 
  /* Das unterste Bis interessiert nicht */
  Value &= 0xFFFFFFFEl; 
  /* Plus dem Offset fÅr den Bus */  
  Value += 0x40000000l; 
  return Value;
}

void
DisableVgaRom(void)
{
  ULONG Value;
  pcibios_read_config_dword(VGA_bus,VGA_devfn,0x30,&Value); 
  Value &= 0xFFFFFFFEl;   
  pcibios_write_config_dword(VGA_bus,VGA_devfn,0x30,Value);
}

int pcibios_find_device (UWORD vendor, 
                         UWORD device_id,
		         UWORD index,
		         UBYTE *bus,
		         UBYTE *devfn)
{
  int slot;
  ULONG dev_id = (((ULONG)device_id)<<16) | vendor;
	
#ifdef ERROR_OUTPUT	    
  mprintf("PCI find device: vendor %04X, device_id %04X, index %04X\n",vendor, device_id,index);
#endif  

  for(slot=2; slot<=5; slot++)
  {
    ULONG x;
    x = pci_read_config(0, slot, 0, 0);       /* 89015333 */
    
    if (x == dev_id && index-- == 0)
    {
      *bus = 0;
      *devfn = slot<<3;
      return PCIBIOS_SUCCESSFUL;
    }
  }
  return PCIBIOS_DEVICE_NOT_FOUND;
}


int
pcibios_find_class (ULONG class_code,
                    UWORD index,
                    UBYTE *bus,
                    UBYTE *devfn)
{
  int slot;
	
  for(slot=2; slot<=5; slot++)
  {
    ULONG class;
    class = pci_read_config(0, slot, 0, 8)>>8; /* 00030000 */
    
    if (class == class_code && index-- == 0)
    {
      *bus = 0;
      *devfn = slot<<3;
      return 1;
    }
  }
  return 0;
}

int
pcibios_write_config_byte (UBYTE bus,
                          UBYTE device_fn,
                          UBYTE where,
		          UBYTE value)
{
  ULONG v_value;
  UBYTE v_Offset = where & 0x03;
  UBYTE device = (device_fn >> 3);

#ifdef ERROR_OUTPUT	    
  mprintf("PCI write config byte: bus %X, dev %X, addr %X, val %X\n",
          bus, device_fn, where, value);
#endif  

  where &= 0xFC;
  v_value = pci_read_config(bus, device, (device_fn & 0x07), where);
  switch (v_Offset)
  {
    case 3:
      v_value &= 0x00FFFFFFl; 
      v_value |= ((ULONG)value) << 24;
      break;
    case 2:
      v_value &= 0xFF00FFFFl; 
      v_value |= ((ULONG)value) << 16;
      break;
    case 1:
      v_value &= 0xFFFF00FFl; 
      v_value |= ((ULONG)value) << 8;
      break;
    case 0:
      v_value &= 0xFFFFFF00l; 
      v_value |= value;
      break;
  }
  pci_write_config(bus, device, (device_fn & 0x07), where, v_value);
  return PCIBIOS_SUCCESSFUL;
}

int
pcibios_write_config_word(UBYTE bus,
                          UBYTE device_fn,
                          UBYTE where,
		          UWORD value)
{
  ULONG v_value;
  UBYTE v_Offset = where & 0x02;
  UBYTE device = (device_fn >> 3);
#ifdef ERROR_OUTPUT	    
  mprintf("PCI write config word: bus %X, dev %X, addr %X, val %X\n",
          bus, device_fn, where, value);
#endif  
  where &= 0xFC;
  v_value = pci_read_config(bus, device, (device_fn & 0x07), where);
  switch (v_Offset)
  {
    case 2:
      v_value &= 0x0000FFFFl; 
      v_value |= ((ULONG)value) << 16;
      break;
    case 0:
      v_value &= 0xFFFF0000l; 
      v_value |= value;
      break;
  }
  pci_write_config(bus, device, (device_fn & 0x07), where, v_value);
  return PCIBIOS_SUCCESSFUL;
}

int
pcibios_read_config_byte (UBYTE bus,
                          UBYTE device_fn,
                          UBYTE where,
		          UBYTE *value)
{
  ULONG v_value;
  UBYTE v_Offset = where & 0x03;
  UBYTE device = (device_fn >> 3);
  where &= 0xFC;
  v_value = pci_read_config(bus, device, (device_fn & 0x07), where);
  switch (v_Offset)
  {
    case 3: v_value >>= 8;
    case 2: v_value >>= 8;
    case 1: v_value >>= 8;
    case 0: break;
  }
  *value = (UBYTE)v_value;
  return PCIBIOS_SUCCESSFUL;
}

int
pcibios_read_config_word (UBYTE bus,
                           UBYTE device_fn,
                           UBYTE where,
		           unsigned short *value)
{
  ULONG v_value;
  UBYTE v_Offset = where & 0x02;
  UBYTE device = (device_fn >> 3);
  where &= 0xFC;
  v_value = pci_read_config(bus, device, (device_fn & 0x07), where);
  if (v_Offset == 2) v_value >>= 16;
  *value = (unsigned short)v_value;
#ifdef ERROR_OUTPUT	    
  mprintf("PCI read config word: bus %X, dev %X, addr %X, val %X\n",
          bus, device_fn, where, *value);
#endif  
  return PCIBIOS_SUCCESSFUL;
}

int
pcibios_read_config_dword (UBYTE bus,
                           UBYTE device_fn,
                           UBYTE where,
		           ULONG int *value)
{
  UBYTE device = (device_fn >> 3);
  *value = pci_read_config(bus, device, (device_fn & 0x07), where);
#ifdef ERROR_OUTPUT	    
  mprintf("PCI read config dword: bus %X, dev %X, addr %X, val %lX\n",
          bus, device_fn, where, *value);
#endif  
  return PCIBIOS_SUCCESSFUL;
}

int
pcibios_write_config_dword (UBYTE bus,
                            UBYTE device_fn,
		            UBYTE where,
		            ULONG int value)
{
  UBYTE device = (device_fn >> 3);
#ifdef ERROR_OUTPUT	    
  mprintf("PCI write config dword: bus %X, dev %X, addr %X, val %lX\n",
          bus, device_fn, where, value);
#endif  
  pci_write_config(bus, device, (device_fn & 0x07), where, value);
  return PCIBIOS_SUCCESSFUL;
}
