;****************************************************************************
; $Id: startup.s,v 1.30 2003/12/28 22:14:02 rincewind Exp $
;****************************************************************************
; $Log: startup.s,v $
; Revision 1.30  2003/12/28 22:14:02  rincewind
; - fix CVS headers
;
; Revision 1.29  2003/12/28 21:12:16  rincewind
; - change version
;****************************************************************************

            INCLUDE "regdef.inc"
            IMPORT  Init_8259,Init_SuperIO, Init_RTC ; isabus.s
            IMPORT  monitor, montrap
            IMPORT  TOS_START
            IMPORT  load_tos, run_tos, CopyRomTOS
            IMPORT  unpack_tos
            IMPORT  total_memsize, MemorySchatten
            IMPORT  R_DTTR0, R_DTTR1, R_ITTR0, R_ITTR1
            IMPORT  Init_PMMU
            IMPORT  init_vgaprintf, vgaprintf, vgaprintf2, nvram_init
            IMPORT  warmstart_magic, ram700_checksum
            IMPORT  SerialNo, CPUFrequency, bb_infostruct
            IMPORT  InitKey, InitKey2, CheckKeys
            IMPORT  detect_cpu, cpu_strtab, cpu_type, msg_cpuspeed
            IMPORT  DiskLoad
            IMPORT  wait, msg_pause, PauseFlag
            IMPORT  init_vgacard, initvga_textmode
            IMPORT  preinit_pcibus

            IMPORT  vgaemu_init
            IMPORT	display_boardrev

            IMPORT  msg_monitor, msg_serialno, msg_buserror2, msg_buserror3
            EXPORT  update700checksum, tos_buserror
            EXPORT  CompInd
            EXPORT  fill_tab
            EXPORT  error_beep

            TEXT
MAGIC       equ     $31415926               ; Magic fÅr Warmstart

romstart:
; Resetvektor
            dc.l    0                       ; Berr-Emulation
            dc.l    reset-romstart
            dc.l    reset-romstart
            dc.l    reset-romstart

            dc.l    0,0                     ; Dummy - Einsprung bei $0018
            bra.s   warmstart

; Bootblock-Infostruktur - fÅr Flash-Programm und Anzeige im TOS
bbinfo:     dc.b    "MSUS"                  ; Magic fÅr Versionsnummer des Bootblocks
CompInd:    dc.l    3                       ; Bootblock-KompatibilitÑts-Version
                                            ; bei énderungen erhîhen
            dc.l    bb_version - romstart + $400f0000

; Ende Bootblock-Infostruktur

version_text:
;           dc.b    $0F, "Bootblock V"
            dc.b    $01,$0F, "Bootblock V"
bb_version:
            dc.b    "1.04",0
            align   4

warmstart:
            move    #$2700,sr
            and.l   #!3,PLX_INTCSR.w        ; NMI aus!
            moveq   #0,d0
            dc.w    $4E7B,$0003             ; movec d0,TC: PMMU aus
            ; $80000000 - $FFFFFFFF auf NoCache, Serialized
            move.l  #$807F0000 | %1110000101000000,d0
            dc.w    $4e7b,$0006             ; movec D0,DTTR0
            ; $40000000 - $7FFFFFFF auf NoCache, Serialized
            move.l  #$403f0000 | %1110000101000000,d0
            dc.w    $4e7b,$0007             ; movec D0,DTTR1
; Neu: Reset per PIIX - Reset Control auslîsen
            lea     ISA_IOBASE,a5
            lea     $ffffc2d0.w,a0
            moveq   #-1,d0
            moveq   #-1,d1
            moveq   #-1,d2
            moveq   #-1,d3
            IOWB    #0,$CF9
            IOWB    #6,$CF9                 ; Reset auslîsen
            movem.l d0-d3,(a0)              ; '1' auf Bus fÅr fehlende Pullups
            movem.l d0-d3,(a0)              ; '1' auf Bus fÅr fehlende Pullups
            movem.l d0-d3,(a0)              ; '1' auf Bus fÅr fehlende Pullups
            movem.l d0-d3,(a0)              ; '1' auf Bus fÅr fehlende Pullups

            reset
            jmp     jmp2-romstart+$f0000+$40000000
            ALIGN   8
reset:      MOVE    #$2700,SR
            reset

; Transparent Translation fÅr Schutz des IO-Bereiches ab 2GB
; Bit 8 - U0 gesetzt -> Little endian
            move.l  #$807F0000 | %1110000101000000,d0
;           movec.l d0,pmmu_dttr0
            dc.w    $4e7b,$0006             ; movec D0,DTTR0

; PLX init
            move.l  #jmp1-romstart+$f0000,a0 ; abs. Adr fuer ROM 000F0000
            move.l  #$C0000000,PLX_DMRR.w   ; $c0000000 = 1GB Range
            jmp     (a0)                    ; Funktioniert wegen Prefetch
jmp1:
            move.l  #jmp2-romstart+$f0000+$40000000,a0 ; abs. Adr fuer ROM 400F0000
            move.l  #$40000000,PLX_DMLBAM.w ; $40000000
            jmp     (a0)
jmp2:
            MOVEQ   #0,D0
            MOVEC   D0,VBR
; Instruction Cache einschalten
            DC.W    %1111010011011000       ; CINV ALL gesammten Cache lîschen
            move.l  #$00008000,d0           ; Instruction Cache einschalten
            movec.l d0,CACR                 ; DC.W $4E7B,$0002

; Sicher ist sicher, zumindest fÅr den Warmstart
            moveq   #0,d0
            dc.w    $4E7B,$0007             ; movec d0,DTTR1
            dc.w    $4E7B,$0004             ; movec d0,ITTR0
            dc.w    $4E7B,$0005             ; movec d0,ITTR1

; PLX fÅr I/O Zugriffe initialisieren
            lea     ISA_IOBASE,A5
            move.l  #$80000000,PLX_DMLBAI.w ; $80000000
            move.l  #$00000003,PLX_DMPBAM.w ; $03
            POSTCODE #$01

            move.w  #$0500,d0               ; Tonhîhe
            CALLA6  beep_on
            POSTCODE #$02

; +++MFP initialisieren
mfp_init:
            moveq   #0,d7
            lea     MFP_BASE,a0
            moveq   #31,d0
mfp_init1:
            move.b  d7,(a0)
            addq.l  #4,a0
            dbra    d0,mfp_init1

            move.b  #$48,MFP_VR
            bset    #2,MFP_GPIP             ; CTS auf High
            move.b  d7,MFP_TCDCR            ; Timer C/D stoppen
            move.b  #1,MFP_TDDR             ; Teiler 1 fÅr 19200 bps setzen
            move.b  #$71,MFP_TCDCR          ; Vorteiler 4 fuer Timer D, 200 fÅr C
            move.b  d7,MFP_SCR
            move.b  #10,MFP_TCDR
            move.b  #$88,MFP_UCR            ; Timer/16, 8N1
            move.b  #$01,MFP_RSR            ; Enable Receiver
            move.b  #$01,MFP_TSR            ; Enable Transmitter

            POSTCODE #$03
            CALLA6  Init_SuperIO
            POSTCODE #$04

; +++ Speichergrîûe ermitteln
; Schattenregister:
; XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX
;    |    |    |    |    |    |    |    +-- Slot3 B
;    |    |    |    |    |    |    +------- Slot3 A
;    |    |    |    |    |    +------------ Slot2 B
;    |    |    |    |    +----------------- Slot2 A
;    |    |    |    +---------------------- Slot1 B
;    |    |    +--------------------------- Slot1 A
;    |    +-------------------------------- Slot0 B
;    +------------------------------------- Slot0 A
; Achtung: Slot-Nummer != Nr. des Sockels!
; XXXX:
;  0 = kein Speicher
;  1 = 4MB
;  2 = 8MB (asymmetrisch: 4MB / 4MB LÅcke / 4MB )
;  3 = 16MB
;  4 = 32MB (asymmetrisch: 16MB / 16MB LÅcke / 16MB )
;  5 = 64MB
; 11 = 16MB (asymmetrisch: 4MB / LÅcke / 4MB / LÅcke ...)
; genauere Belegung siehe MEMORY.TXT!

            move.b  #$01,MEMCTRL.w          ; Speicher einschalten
            move.b  #$01,WAITCTRL.w         ; erstmal 1 Waitstate fÅr 33 MHz
            nop
            POSTCODE #$05

            cmp.l   #MAGIC,warmstart_magic
            bne.s   MemChk
            lea     $700.w,a0
            moveq   #$80/4-1,d1
            moveq   #0,d0
MemChk3:    add.l   (a0)+,d0
            dbra    d1,MemChk3
            cmp.l   #MAGIC,d0
            bne.s   MemChk
            move.l  MemorySchatten,d5
            move.l  total_memsize,d7
            bra     MemChk2

MemChk:     clr.l   warmstart_magic
            moveq   #0,d5                   ; Hier die Memory werte merken
            moveq   #7,d3                   ; 8 Durchlaeufe
            moveq   #0,d7                   ; 0MB Hauptspeicher
            sub.l   a0,a0                   ; bei 0 MB anfangen
Mem_Loop:
            lsl.l   #4,d5                   ; Schattenregister vorbereiten
            moveq   #0,d4                   ; erst mal kein Speicher in der Bank
            move.l  a0,a1
            move.l  #$55FF00AA,(a0)
            move.l  #$87654321,4(a0)
            move.l  #$A5F05A0F,8(a0)
            move.l  #$55574505,12(a0)       ; 64 MB Pattern

            lea     ($01000000,a0),a1       ; Offset auf 16MB
            move.l  #$55FF00AA,(a1)
            move.l  #$87654321,4(a1)
            move.l  #$A5F05A0F,8(a1)
            move.l  #$55574504,12(a1)       ; Pattern fÅr 4: 32MB asym.

            lea     ($00400000,a0),a1       ; Offset auf 4MB
            move.l  #$55FF00AA,(a1)
            move.l  #$87654321,4(a1)
            move.l  #$A5F05A0F,8(a1)
            move.l  #$55574506,12(a1)       ; Pattern fÅr 6: 16MB asym.

            lea     ($02000000,a0),a1       ; Offset auf 32MB
            move.l  #$55FF00AA,(a1)
            move.l  #$87654321,4(a1)
            move.l  #$A5F05A0F,8(a1)
            move.l  #$55574503,12(a1)       ; 16 MB Pattern 3

            lea     ($02400000,a0),a1       ; Offset auf 36MB
            move.l  #$55FF00AA,(a1)
            move.l  #$87654321,4(a1)
            move.l  #$A5F05A0F,8(a1)
            move.l  #$55574502,12(a1)       ; 8MB asym. Pattern 2

            lea     ($00800000,a0),a1       ; Offset auf 8MB
            move.l  #$55FF00AA,(a1)
            move.l  #$87654321,4(a1)
            move.l  #$A5F05A0F,8(a1)
            move.l  #$55574501,12(a1)       ; 4 MB Pattern

; Mal sehen, was wir zurÅcklesen
            cmp.l   #$55FF00AA,(a0)
            bne     NoMem
            cmp.l   #$87654321,4(a0)
            bne     NoMem
            cmp.l   #$A5F05A0F,8(a0)
            bne.s   NoMem
            move.l  12(a0),d0
            move.l  d0,d1                   ; Wert sichern
            and.l   #$FFFFFFF0,d0
            cmp.l   #$55574500,d0
            bne.s   NoMem
            and.l   #$f,d1
;           tst.b   valid_tab(pc,d1.w)
;           beq.s   NoMem
;           move.l  #$00400000,d4           	; 4MB * n
;           lsl.l   d1,d4                   		; Groesse des Bereichs in D4 merken
            move.l  size_tab(pc,d1.w*4),d4
            beq.s   NoMem

MemChk4:    or.b    d1,d5                   ; Im Schattenregister merken
            add.l   d4,d7                   ; Soviel Speicher haben wir bis jetzt

NoMem:      lea     ($04000000,a0),a0       ; NÑchster Offset bei 64MB
            dbra    d3,Mem_Loop             ; NÑchstes Modul testen
            bra     MemChk2

size_tab:
            dc.l    0                       ; 0 = kein Speicher
            dc.l    $00400000               ; 1 = 4MB
            dc.l    $00800000               ; 2 = 8MB
            dc.l    $01000000               ; 3 = 16MB
            dc.l    $02000000               ; 4 = 32MB
            dc.l    $04000000               ; 5 = 64MB
            dc.l    $01000000               ; 6 = 16MB
            dc.l    0                       ; 7
            dc.l    0                       ; 8
            dc.l    0                       ; 9
            dc.l    0                       ; 10
            dc.l    0                       ; 11
            dc.l    0                       ; 12
            dc.l    0                       ; 13
            dc.l    0                       ; 14
            dc.l    0                       ; 15

; Tabelle, welche 4MB-Blîcke wirklich existieren. Adresse 0 ist
; rechts (Bit 0)
fill_tab:
            dc.w    %0000000000000000       ;  0 = kein Speicher
            dc.w    %0000000000000001       ;  1 = 4MB
            dc.w    %0000000000000101       ;  2 = 8MB
            dc.w    %0000000000001111       ;  3 = 16MB
            dc.w    %0000111100001111       ;  4 = 32MB
            dc.w    %1111111111111111       ;  5 = 64MB
            dc.w    %0000010100000101       ;  6 = 16MB
            dc.w    %0000000000000000       ;  7
            dc.w    %0000000000000000       ;  8
            dc.w    %0000000000000000       ;  9
            dc.w    %0000000000000000       ; 10
            dc.w    %0000000000000000       ; 11
            dc.w    %0000000000000000       ; 12
            dc.w    %0000000000000000       ; 13
            dc.w    %0000000000000000       ; 14
            dc.w    %0000000000000000       ; 15

; Folgende Register sind nun belegt:
; d7 - Gesamtmenge Speicher
; d6 - frei
; d5 - Memory Schattenregister

MemChk2:
            POSTCODE #$06

; Bei 0MB: kein Speichertest, sondern Fehlermeldung

            move.l  d5,d0
            swap    d0
            and.w   #$f000,d0               ; Bits fÅr Slot 0A
            cmp.w   #$3000,d0
            beq.s   memtst0
            cmp.w   #$4000,d0
            beq.s   memtst0
            cmp.w   #$5000,d0
            beq.s   memtst0
            cmp.w   #$0000,d0
            beq.s   memtst9a	; no SIMM detected

            moveq   #2,d0	; wrong type of SIMM
            bra     error_beep

memtst0:    tst.l   d7
            bne.s   memtst0b
memtst9a:   moveq   #1,d0
            bra     error_beep

memtst9:    moveq   #3,d0	; error during test
            bra     error_beep

bb_buserror:
            move.w  #%1111100100000000,PLX_BASE+4 ; reset status
            POSTCODE #$F0
            moveq   #4,d0
            bra     error_beep

memtst0b:
            POSTCODE #$07
            cmp.l   #MAGIC,warmstart_magic
            bne     memtst0c

            move.w  #($00100000-$800)/16/4-1,d4
            move.w  #$800,a0                ; nur ab $800 lîschen
            bra     memtst8a

; kompletten Speicher mit Adreûpattern fÅllen
memtst0c:
            POSTCODE #$08
            clr.l   a2                      ; Startadresse
            moveq   #7,d3                   ; 8 Durchlaeufe
memtst1b:
            move.l  a2,a4                   ; Anfang merken
            rol.l   #4,d5
            move.w  d5,d1
            and.w   #$0f,d1
            lea     fill_tab(pc),a0
            move.w  (a0,d1.w*2),d4          ; Tabelle der exist. Blocks
memtst1d:
            tst.w   d4
            beq.s   memtst1a                ; kein Speicher Åbrig
            move.l  a2,a0
            add.l   #$00400000,a0           ; Endwert = +4MB
            lsr.w   #1,d4                   ; Block vorhanden?
            bcs.s   memtst1                 ; Ja
            move.l  a0,a2
            bra.s   memtst1d
memtst1:    REPT    16
            move.l  a2,(a2)+
            ENDM
            cmp.l   a2,a0
            bne.s   memtst1
            CALLA6  beep_off
            bra.s   memtst1d

memtst1a:
            lea     ($04000000,a4),a2       ; NÑchster Offset bei 64MB
            dbra    d3,memtst1b


; 1MB Speicher testen (auf SIMM0A)
            POSTCODE #$09
            moveq   #0,d0
            move.l  d0,a0
            move.l  #$00100000,d4           ; Endadresse
memtst2:    cmp.l   (a0)+,d0
            bne     memtst9                 ; Fehler
            addq.l  #4,d0
            cmp.l   a0,d4
            bne.s   memtst2

            sub.l   a0,a0
            move.l  #$55aa55aa,d0
            move.l  #$aa55aa55,d1
memtst4:    REPT    4
            move.l  d0,(a0)+
            move.l  d1,(a0)+
            ENDM
            cmp.l   a0,d4
            bne.s   memtst4

            sub.l   a0,a0
memtst5:    REPT    2
            cmp.l   (a0)+,d0
            bne     memtst9
            cmp.l   (a0)+,d1
            bne     memtst9
            ENDM
            cmp.l   a0,d4
            bne.s   memtst5


memtst8:
; 1MB Speicher lîschen
            move.w  #$00100000/16/4-1,d4
            sub.l   a0,a0
memtst8a:   ;       Einsprung fÅr Warmstart
            CALLA6  beep_off
            moveq   #0,d0
            move.l  d0,d1
            move.l  d0,d2
            move.l  d0,d3
            POSTCODE #$0A
memclr:     movem.l d0-d3,(a0)
            movem.l d0-d3,16(a0)
            movem.l d0-d3,32(a0)
            movem.l d0-d3,48(a0)
            lea     64(a0),a0
            dbra    d4,memclr

; +++Stack einrichten etc.
            POSTCODE #$0B
            move.l  #bb_buserror,8.w

            move.l  d5,MemorySchatten       ; Schattenregister schreiben
            move.l  d7,total_memsize
            move.l  #memmagic,memvalid
            move.l  #memmagic2,memval2
            move.l  #memmagic3,memval3
            clr.l   remtop                  ; kein Fastram
            move.l  #remmagic,remvalid
            move.l  #n_stack,sp

            .if     0
            lea     montrap(pc),a0          ; Bus/Address-Error auf Monitor setzen
            clr.l   a1
            move.l  a0,(a1)+
            move.l  a0,(a1)+
            move.l  a0,(a1)+
            move.l  a0,(a1)+
            .endif

; +++Error Vektoren und Routinen einrichten
            POSTCODE #$0C

; +++ Tastatur initialisieren, Teil 1
            bsr     InitKey

; +++Bootblock ins RAM kopieren
            POSTCODE #$0D

            ; ISA-Bridge fÅr 512K ROM freischalten
            move.l  #$80000000 | (1 << 11) | ($13<<2) ,PLX_DMCFGA.w
            move.l  ISA_IOBASE,d0
            and.l   #$FF00FFFF,d0
            or.l    #$00C40000,d0
            move.l  d0,ISA_IOBASE

            moveq   #0,d0
            move.l  d0,PLX_DMCFGA.w

            ; Bootblock ins RAM kopieren
            lea     romstart(pc),a0
            move.w  #($1000-1),d0           ; FFFF0000 bis FFFFFFFF kopieren
            move.l  #BootBlockTarget,a1     ; an feste Adresse kopieren
.loop_1:    move.l  (a0)+,(a1)+
            move.l  (a0)+,(a1)+
            move.l  (a0)+,(a1)+
            move.l  (a0)+,(a1)+
            dbra    d0,.loop_1
            DC.W    %1111010010011000       ; CINVA IC gesammten I-Cache lîschen
            jmp     RomCopyEnd

; der Code steht jetzt im RAM - ab jetzt kînnen C-Routinen ausgefÅhrt werden!
RomCopyEnd:
            POSTCODE #$0E

; ISA-Bridge fÅr 14MB DMA freischalten
; TOM - Top of Memory Register schreiben
            move.l  #$80000000 | (1 << 11) | ($68) ,PLX_DMCFGA.w
            move.l  ISA_IOBASE,d0
            and.l   #$FFFF00FF,d0
            or.l    #$0000D200,d0           ; 14MB + 640KB fÅr DMA
            move.l  d0,ISA_IOBASE
            moveq   #0,d0
            move.l  d0,PLX_DMCFGA.w

            POSTCODE #$0F
;           bsr     dcache_on
            bsr     preinit_pcibus          ; VGA base regs initialisieren
            bsr     init_vgacard
;           bsr     dcache_off
            bsr     initvga_textmode
            POSTCODE #$10

            IORB    $410,d0                 ; Jumper abfragen
            btst    #5,d0                   ; 0 = gesetzt -> kein Logo
            beq.s   .no_logo

            lea     $400B8000,a3
            lea     MILAN_TXT1(pc),a0
            move.l  a3,a1
            bsr     textout
            lea     MILAN_TXT2(pc),a0
            lea     160*1(a3),a1
            bsr     textout
            lea     MILAN_TXT3(pc),a0
            lea     160*2(a3),a1
            bsr     textout
            move.b  #$0D,$0B(a3)            ; Farbe i-Punkt (BigEndian)
.no_logo:
            bsr     init_vgaprintf
            move.l  #bb_buserror2,8.w

            pea     bb_version(pc)
            lea     bb_versiontxt(pc),a0
            bsr     vgaprintf2
            addq    #4,sp

; CPU-Frequenz messen.
            bsr     detect_cpu
            move.w  d0, CPUFrequency
            cmp.w   #280,d0
            bcc.s   .wait1
            move.b  #$00,WAITCTRL.w         ; 0 Waitstate bei <28MHz
            bra     .wait2
; TODO: Bei >28MHz Waitstates auf ISA einschalten
.wait1:
          .if     0
            move.l  #$80000000 | (1 << 11) | ($4c) ,PLX_DMCFGA.w
            move.l  ISA_IOBASE,d0
            move.b  #%01000100,d0           ; Default: %01001101
            move.l  d0,ISA_IOBASE
            moveq   #0,d0
            move.l  d0,PLX_DMCFGA.w
          .endif
.wait2:     move.w  cpu_type,d0
            and.w   #3,d0
            lea     cpu_strtab(pc),a0
            move.l  (a0,d0.w*4),-(sp)
            moveq   #0,d0
            move.w  CPUFrequency,d0
            divu.w  #10,d0
            btst    #1,cpu_type+1
            beq.s   .is040
            asl.w   #1,d0
.is040:
            move.l  total_memsize,d1        ; Speichergrîûe nach d0
            swap    d1
            lsr.w   #4,d1

            move.w  d0,-(sp)                ; CPU-Takt
            move.w  d1,-(sp)                ; Speichergrîûe in MB
            lea     msg_cpuspeed,a0
            bsr     vgaprintf
            addq.l  #8,sp
            
            bsr     display_boardrev        ; display board revision
            bsr     nvram_init

            lea     MEMCTRL.w,a1            ; Parameter fÅr Init_PMMU
            lea     ISA_IOBASE,a5

; +++ Interrupt-Controller initialisieren
            POSTCODE #$16
            bsr     Init_8259               ; Achtung: A0 erhalten!

            lea     SerialNo-20,a0          ; Parameter fÅr Init_PMMU

; +++ Super-IO initialisieren
            POSTCODE #$17
            bsr     Init_RTC                ; Achtung: A0/A1 erhalten!

            move.l  #bbinfo-romstart+$400f0000,bb_infostruct

; +++ Tastatur initialisieren, Teil 2
            bsr     InitKey2                ; Achtung: A0/A1 erhalten!

; +++PMMU, PCI initialisieren
; Code steht jetzt im RAM
; Stack ist vorhanden
; Die C-Routine erstellt abhaengig von der Speichergroesse die
; PMMU-Tabellen.
; Die Initialisierung der Transparent Translation Register muss
; jedoch noch in Assembler geschehen.
; Folgende Variablen werden benoetigt
;           total_memsize - Speicherobergrenze
;           MemorySchatten
; Folgende Variablen werden gesetzt:
;           phys_RootTbl - Physikalische Adresse der Root-table
;           log_IOpage - Logische Adresse der I/O page
;           log_phystop                     - Obergrenze fÅr ST-RAM
;           log_ramtop                      - Obergrenze fÅr TT-RAM
            POSTCODE #$18

            jsr     Init_PMMU               ; C-Routine aufrufen
            bsr     update700checksum

            IORB    $410,d0                 ; Jumper abfragen
            btst    #7,d0
            bne.s   no_mon                  ; 1 = kein Jumper = direkt ins TOS

            lea     msg_monitor,a0
            bsr     vgaprintf
            jsr     monitor
no_mon:
            IORB    $410,d0                 ; Jumper abfragen
            btst    #6,d0
            beq.s   disktos
            move.w  #50,d7                  ; 1/2 s
no_mon2:
            bsr     CheckKeys               ; C-Routine
            move.w  #$0600,d0               ; ergibt 10ms
            bsr     wait
            dbra    d7,no_mon2

            tst.w   PauseFlag
            beq.s   no_pause
            lea     msg_pause,a0
            bsr     vgaprintf
pause:
            bsr     CheckKeys
            tst.w   PauseFlag
            bne.s   pause

no_pause:
            tst.w   DiskLoad                ; Diskload ?
            beq.s   no_disktos

disktos:
            bsr     load_tos
            bne.s   no_mon                  ; Lesefehler
            moveq   #0,d0                   ; CompInd Flag
            bsr     dcache_on
            bsr     unpack_tos
            bsr     dcache_off
            tst.w   d0
            beq.s   no_mon                  ; Error unpacking TOS
            bsr     run_tos
            bra.s   no_mon
no_disktos:
            bsr     CopyRomTOS
            moveq   #1,d0                   ; CompInd Flag
            bsr     dcache_on
            bsr     unpack_tos
            bsr     dcache_off
            tst.w   d0
            beq.s   disktos                 ; Error unpacking TOS
            bsr     run_tos
            st.b    DiskLoad
            bra     no_mon                  ; ROM-TOS failed

textout:    move.b  (a0)+,d2                ; Attribut
textout3:   move.b  (a0)+,d0
            beq.s   textout2
            move.b  d0,(a1)+
            move.b  d2,(a1)+
            bra.s   textout3
textout2:
            rts

bb_buserror2:
;            POSTCODE #$F6
            lea     msg_buserror2,a0
            bsr     vgaprintf
.loop:      bra.s   .loop

tos_buserror:
            POSTCODE #$F7
            lea     msg_buserror3,a0
            move.l  sp,a1
            move.l  2(a1),-(sp)
            move.l  $14(a1),-(sp)
            bsr     vgaprintf
.loop:      bra.s   .loop

; Dezimalzahl in D0.W ausgeben - Maximal 999
dezout:     ext.l   d0
            divu.w  #100,d0

            move.w  d0,d1
            and.w   #$0F,d1
            or.b    #$30,d1
            move.b  d1,(a1)+
            move.b  d2,(a1)+

            swap    d0
            ext.l   d0
            divu.w  #10,d0

            move.w  d0,d1
            and.w   #$0F,d1
            or.b    #$30,d1
            move.b  d1,(a1)+
            move.b  d2,(a1)+

            swap    d0

            move.w  d0,d1
            and.w   #$0F,d1
            or.b    #$30,d1
            move.b  d1,(a1)+
            move.b  d2,(a1)+

            jmp     (a6)

beep_on:    IOWB    #$B6,$43
;           IOWB    #$00,$42
;           IOWB    #$05,$42
            IOWB    d0,$42                  ; Lowbyte Timerwert
            ror.w   #8,d0
            IOWB    d0,$42                  ; Highbyte Timerwert
            IOWB    #3,$61
            jmp     (a6)

beep_off:
            IOWB    #0,$61
            jmp     (a6)

error_beep:
            move.w  d0,d2
            CALLA6  beep_off
            clr.l   warmstart_magic

beep_loop:
            move.w  d2,d3
            move.w  #$0500,d0               ; Tonhîhe
            CALLA6  beep_on
            move.w  #$100,d0
            CALLA6  delay
            CALLA6  beep_off

            move.w  #$100,d0
            CALLA6  delay

beep_loop2:
            move.w  #$0500,d0               ; Tonhîhe
            CALLA6  beep_on
            move.w  #$60,d0
            CALLA6  delay
            CALLA6  beep_off
            move.w  #$60,d0
            CALLA6  delay
            sub.w   #1,d3
            bne.s   beep_loop2
            move.w  #$120,d0
            CALLA6  delay
            bra     beep_loop

delay:      moveq   #-1,d1
delay2:     dbf     d1,delay2
            dbf     d0,delay
            jmp     (a6)

update700checksum:
            move.l  #MAGIC,warmstart_magic
            clr.l   ram700_checksum
            lea     $700.w,a0
            moveq   #$080/4-1,d1
            moveq   #0,d0
upd700:     add.l   (a0)+,d0
            dbra    d1,upd700
            move.l  #MAGIC,d1
            sub.l   d0,d1
            move.l  d1,ram700_checksum
            rts

dcache_on:
            dc.w    $4e7a,$0002             ; movec cacr,d0
            bset    #31,d0
            bne.s   dcache_on2              ; was already on
            dc.w    $f458                   ; CINVA DC
            dc.w    $4e7b,$0002             ; movec d0,cacr
dcache_on2:
            rts
dcache_off:
            dc.w    $4e7a,$0002             ; movec cacr,d0
            bclr    #31,d0
            beq.s   dcache_off2             ; was already off
            dc.w    $f478                   ; CPUSHA DC
            dc.w    $4e7b,$0002             ; movec d0,cacr
dcache_off2:
            rts

;simm0nomem:
;           dc.b    $81,"no memory or <16MB in one block in slot 0!",0
;simm0error:
;           dc.b    $81,"slot 0 memory fail!",0
;nomemerror:
;           dc.b    $81,"no memory found!",0
;buserror_msg:
;           dc.b    $81,"buserror in bootblock (this should not happen)!",0

memfoundtxt: dc.b   $01," MB,",0

bb_versiontxt:
            dc.b    $01,$0F, "Bootblock V%s",13,10,$01,$01,0

MILAN_TXT1:
            dc.b    $0E, $C0,$C3,$C6,$C9,$B5,$B8,$CC,$20,$20,$20,$20,$20,0
MILAN_TXT2:
            dc.b    $0E, $C1,$C4,$C7,$CA,$B6,$B9,$CD,$CF,$D1,$BB,$D3,$BE,0
MILAN_TXT3:
            dc.b    $0E, $C2,$C5,$C8,$CB,$B7,$BA,$CE,$D0,$D2,$BC,$BD,$BF,0

            BSS
            ds.l    $2000
n_stack:    ds.l    1
            END
