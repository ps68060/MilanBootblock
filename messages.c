/****************************************************************************
 * $Id: messages.c,v 1.13 2003/12/28 22:14:01 rincewind Exp $
 ****************************************************************************
 * $Log: messages.c,v $
 * Revision 1.13  2003/12/28 22:14:01  rincewind
 * - fix CVS headers
 *
 ****************************************************************************/

#include "proto.h"

char *msg_monitor[] = {
  "starting serial monitor.\n",
  "Starte seriellen Monitor.\n" };

char *msg_battery[] = {
  "NVRAM battery low - check date/time and setup!\n",
  "NVRAM-Batterie leer - Datum/Uhrzeit und Setup pruefen!\n"};

char *msg_tosload[] = {
  "Loading TOS.IMG  ",
  "Lade TOS.IMG  " };

char *msg_tosstart[] = {
  "\nstarting TOS",
  "\nstarte TOS" };

char *msg_ok[] = {
  "OK  ",
  "OK  " };

char *msg_bpberror[] = {
  "error reading BPB\n",
  "BPB Lesefehler\n" };

char *msg_direrror[] = {
  "error reading root directory\n",
  "Lesefehler im Inhaltsverzeichnis\n" };

char *msg_fileerror[] = {
  "error reading TOS.IMG\n",
  "Lesefehler in TOS.IMG\n" };

char *msg_tosinvalid[] = {
  "\x01\x81Invalid TOS header - can't start!\x01\x01\n",
  "\x01\x81Ungueltiger TOS-Header - kann TOS nicht starten!\x01\x01\n"};

char *msg_pci_interrupt[] = {
  "\x01\x81\nERROR: \x01\x01no free interrupt for PCI devices!\n",
  "\x01\x81\nFehler:\x01\x01 kein Interrupt fuer PCI-Karten frei!\n"};

char *msg_pci_devs[] = {
  "\nPCI devices:\n" "slot/fct  Vendor  Device  Int\n",
  "\nPCI Geraete:\n" "slot/fct  Vendor  Device  Int\n" };

char *msg_testing_mem[] = {
  "Testing Memory: \0021 MB",
  "Speichertest: \0021 MB" };

char *msg_mem_error[] = {
  "\nRAM error in slot %c, side %c\n",
  "\nRAM-Fehler in Slot %c, Seite %c\n"};

char *msg_need_16m[] = {
  "\x01\x81\nneed error-free, contiguous 16MB in slot 0!\n",
  "\x01\x81\nbenoetige fehlerfreie 16MB am Stueck in Slot 0!\n" };

char *msg_mb_ok[] = {
  "\003%d MB OK.\n",
  "\003%d MB OK.\n" };

char *msg_st_tt_serial[] = {
  "\n%ld kB ST-RAM, %ld kB TT-RAM, serial no. R%02d%02d%05d%02d\n",
  "\n%ld kB ST-RAM, %ld kB TT-RAM, Seriennummer R%02d%02d%05d%02d\n" };
  
char *msg_vme_card_init[] = {
  "VME-Karte @$%lX initialized.\n",
  "VME-Karte @$%lX initialisiert.\n" };  

char *msg_buserror2[] = {
  "\n\x01\x81Internal error 2 in Bootblock\n",
  "\n\x01\x81Interner Fehler 2 im Bootblock\n" };

char *msg_buserror3[] = {
  "\x01\x81\nBuserror during OS startup, PC=$%p, FA=$%p\n",
  "\x01\x81\nBusfehler beim Starten des BS, PC=$%p, FA=$%p\n" };

char *msg_compind[] = {
  "\x01\x81\nThis TOS requires a newer bootblock!\n\x01\x01",
  "\x01\x81\nDieses TOS benoetigt einen neueren Bootblock!\n\x01\x01"};

char *msg_uncompress[] = {
  "uncompressing TOS ...",
  "entpacke TOS ..."};

char *msg_uc_error[] = {
  "error %d uncompressing TOS!\n",
  "Fehler %d beim Entpacken des TOS!\n"};

char *msg_pkg_error[] = {
  "TOS PKG error %d\n",
  "TOS PKG fehlerhaft, Fehler %d\n"};

char *msg_done[] = {
  "done.\n",
  "fertig.\n" };

char *msg_nvram[] = {
  "NVRAM checksum invalid - run MSETUP!\n",
  "NVRAM-Pruefsumme ungueltig - MSETUP starten!\n" };

char *msg_cpuspeed[] = {
  "%d MB, %dMHz %s CPU, ",
  "%d MB, %dMHz %s CPU, " };

char *msg_boardrev[] = {
  "Board rev. %s\n",
  "Board rev. %s\n" };

char *msg_kberror[] = {
  "Keyboard not found.\n",
  "Tastatur nicht gefunden.\n"};

char *msg_pause[] = {
  "Press <SPACE> to continue!\n",
  "<SPACE> druecken!\n"};
