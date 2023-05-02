;****************************************************************************
; $Id: ram700.s,v 1.12 2003/12/28 22:14:02 rincewind Exp $
;****************************************************************************
; $Log: ram700.s,v $
; Revision 1.12  2003/12/28 22:14:02  rincewind
; - fix CVS headers
;
; Revision 1.11  2003/12/28 21:12:05  rincewind
; - export bb_boardrev variable (for TOS)
;
; Revision 1.3  2000/07/15 22:47:16  rincewind
; - removed variable VGA_Slot which is no longer used
;
; Revision 1.2  2000/06/19 20:52:34  rincewind
; - misc cleanup
;****************************************************************************

                  EXPORT  total_memsize, phys_RootTbl, log_IOpage, MemorySchatten
                  EXPORT  log_IO_PageDescript, log_phystop, log_ramtop
                  EXPORT  PCIBIOS_DevTable, PCIBIOS_DevNum, PCI_Interrupts
                  EXPORT  warmstart_magic, ram700_checksum
                  EXPORT  SerialNo, CPUFrequency, bb_infostruct
                  EXPORT  Keyboard_OK, bb_boardrev
                  BSS

; Speicher ab $700: neue Systemvariablen

; $700 Speicherausbau in Bytes
total_memsize:    ds.l    1

; $704 Logische Obergrenze des ST-Rams
log_phystop:      ds.l    1

; $708 Logische Obergranze des FastRams
log_ramtop:       ds.l    1

; $70C Physikalische Adresse der Root-Tabelle
phys_RootTbl:     ds.l    1

; $710 Zeiger auf die 8K I/O Page
log_IOpage:       ds.l    1

; $714 Schattenregister fÅr den Memory Controller
; --XX ---X --XX ---X --XX ---X --XX ---X
;    |    |    |    |    |    |    |    X-- MEMCTRL3B
;    |    |    |    |    |    |   XX------- MEMCTRL3A
;    |    |    |    |    |    X------------ MEMCTRL2B
;    |    |    |    |   XX----------------- MEMCTRL2A
;    |    |    |    X---------------------- MEMCTRL1B
;    |    |   XX--------------------------- MEMCTRL1A
;    |    X-------------------------------- MEMCTRL0B
;   XX------------------------------------- MEMCTRL0A
MemorySchatten:   ds.l    1

; $718 PCI-Slot in dem die VGA-Karte steckt (2-5)
unused_VGA_Slot:         ds.l    1

; $71C Zeiger auf 1. von 8 Beschreibern fÅr Atari I/O Bereich
log_IO_PageDescript: ds.l 1

; $720 PCI-Bios Tabellen
PCIBIOS_DevTable: ds.l    1
PCIBIOS_DevNum:   ds.w    1               ; $724
PCI_Interrupts:   ds.l    1               ; $726
PCI_Dummy1:       ds.w    1               ; $72A unbenutzt
PCI_Dummy:        ds.l    1               ; $72C unbenutzt

; $730
SerialNo:         ds.l    1
CPUFrequency:     ds.w    1               ; $734 CPU-Frequenz, 25MHz = 250

warmstart_magic:  ds.l    1               ; $738
Keyboard_OK:      ds.b    1               ; $73A
unused1:          ds.b    1               ; $73B
                  align   4
ram700_checksum:  ds.l    1               ; $73C
bb_infostruct:    ds.l    1               ; $740 Zeiger auf Infostruct
bb_boardrev:      ds.l    1               ; $744 Board-Revision
                  end
