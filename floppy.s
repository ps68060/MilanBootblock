;****************************************************************************
; Low-Level Routinen zur Floppy Initialisierung
; $Id: floppy.s,v 1.7 2003/12/28 22:14:01 rincewind Exp $
;****************************************************************************
; $Log: floppy.s,v $
; Revision 1.7  2003/12/28 22:14:01  rincewind
; - fix CVS headers
;
; Revision 1.2  2000/06/19 20:52:34  rincewind
; misc cleanup
;****************************************************************************
            INCLUDE "regdef.inc"

; Exports
            .globl  Flopinit, getbpb, Motor_on, Motor_off
            .globl  Fsfirst, readfile, filesize
            .GLOBL  curr_err


; Register Definitionen
F_SRA       EQU     0                       ; R   Status Register A
F_SRB       EQU     1                       ; R   Status Register B
F_DOR       EQU     2                       ; R/W Digital Output Register
F_TDR       EQU     3                       ; R/W Tape Drive Register
F_MSR       EQU     4                       ; R   Main Status Register
F_DSR       EQU     4                       ; W   Data Rate Select Register
F_FIFO      EQU     5                       ; R/W Data Register
F_DIR       EQU     7                       ; R   Digital Input Register
F_CCR       EQU     7                       ; W   Configuration Control Register

FloppyBase  EQU     ISA_IOBASE + $3F0

; Kommando Definitionen
CONFIGURE     EQU   $43
DUMPREG       EQU   $0E
FORMAT_TRACK  EQU   $0D
LOCK          EQU   $14
MODE          EQU   $01
NSC           EQU   $18
PERPENDICULAR EQU   $12
READ_DATA     EQU   $06
READF_DELETED EQU   $0C
READ_ID       EQU   $09
READ_A_TRACK  EQU   $02
RECALIBRATE   EQU   $07
RELATIVE_SEEK EQU   $8F
SCAN_EQUAL    EQU   $11
SCAN_HIGH_OE  EQU   $19
SEEK          EQU   $0F
SENSE_STATUS  EQU   $04
SENSE_INT     EQU   $08
SET_TRACK     EQU   $41
SPECIFY       EQU   $03
VERIFY        EQU   $16
VERSION       EQU   $10
WRITE_DATA    EQU   $05
WRITE_DELETED EQU   $09

; Modifiers
MFM           EQU   $40

; Boot Sektor Offsets
IBM_BPS     EQU     $0B                     ; .W #bytes/sector
IBM_SPC     EQU     $0D                     ; .B #sectors/cluster
IBM_RES     EQU     $0E                     ; .W #reserved sectors
IBM_NFATS   EQU     $10                     ; .B #FATs
IBM_NDIRS   EQU     $11                     ; .W #root dir entries
IBM_NSECTS  EQU     $13                     ; .W #sectors on media
IBM_MEDIA   EQU     $15                     ; .B media descriptor byte
IBM_SPF     EQU     $16                     ; .W #sectors/FAT
IBM_SPT     EQU     $18                     ; .W #sectors/track
IBM_NSIDES  EQU     $1A                     ; .W #sides on device
IBM_NHID    EQU     $1C                     ; .W #hidden sectors

; bpb Offsets
recsize     EQU     0                       ; physical sector size in bytes
clsize      EQU     2                       ; cluster size in sectors
clsizeb     EQU     4                       ; cluster size in bytes
rdlen       EQU     6                       ; root dir len in sectors
fsiz        EQU     8                       ; FAT size in sectors
fatrec      EQU     10                      ; sector # of 1. sector od 2nd FAT
datrec      EQU     12                      ; sector # of 1. data sector
numcl       EQU     14                      ; # of data clusters on disk
bflags      EQU     16                      ; diverse Flags

; dsb Offsets
dntracks    EQU     0                       ; #tracks (cylinders) on device
dnsides     EQU     2                       ; #sides per cylinder
dspc        EQU     4                       ; #sectors/cylinder
dspt        EQU     6                       ; #sectors/track
dhidden     EQU     8                       ; #hidden tracks

*------     Error   returns
e_error     equ     -1                      ; general catchall
e_nready    equ     -2                      ; drive-not-ready
e_crc       equ     -4                      ; CRC error
e_seek      equ     -6                      ; seek error
e_rnf       equ     -8                      ; record (sector) not found
e_write     equ     -10                     ; generic write error
e_read      equ     -11                     ; generic read error
e_wp        equ     -13                     ; write on write-protected media
e_undev     equ     -15                     ; unknown device
e_badsects  equ     -16                     ; bad sectors on format-track
e_insert    equ     -17                     ; insert_a_disk

            .MACRO  F_CMP.size src,adr
            CMP.size src,(adr+FloppyBase)^3
            .ENDM

            .MACRO  F_IOW.size src,adr
            MOVE.size src,(adr+FloppyBase)^3
            .ENDM

            .MACRO  F_IOR.size adr,dst
            MOVE.size (adr+FloppyBase)^3,dst
            .ENDM


.TEXT
; Floppy Kommand ausfÅhren
; On Input:
;  D0 - Kommando Byte
;  A0 - Zeiger auf Kommando Daten
;  A1 - Zeiger auf Speicher fÅr die Daten
;  A2 - Zeiger auf Speicher fÅr Result-Phase
; On Output
;  D0, D1 ,A0 zerstîrt
;  A1 zeigt auf 1. Byte nach dem letzten geschriebenen Byte
;  A2 unverÑndert

Do_Command: move.l  a2,-(sp)
;                   F_CMP.B                 #$80,F_MSR		; Kann ein Kommkando ausgefÅhrt werden?
DCL5:       F_IOR.b F_MSR,d1
            btst.b  #7,d1                   ; Warte bis Kontroller bereit
; Time Out fehlt noch
            beq.s   DCL5
            and.b   #$f0,d1
            cmp.b   #$80,d1                 ; Muû 80 sein, sonst Fehler
            bne     DCL_END
            F_IOW.b d0,F_FIFO               ; 1. Kommando Byte ausgeben
DCL1:       F_IOR.b F_MSR,d0
            btst.b  #7,d0                   ; Warte bis Kontroller bereit
            beq.s   DCL1
            btst.b  #4,d0                   ; Kommando beendet ?
            beq     DCL_END
            btst.b  #5,d0                   ; Execution Phase ?
            bne.s   DCL_EXEC
            btst.b  #6,d0                   ; Result Phase ?
            bne.s   DCL_RESULT
            F_IOW.b (a0)+,F_FIFO            ; NÑchstes Byte des Kommandos ausgeben
            bra.s   DCL1                    ; Und weiter
DCL_EXEC:   btst.b  #6,d0                   ; Lesen oder Schreiben ?
            bne.s   DCL_READ
DCL_WRITE:  F_IOW.b (a1)+,F_FIFO            ; Daten ausgeben
DCL2:       F_IOR.b F_MSR,d0
            btst.b  #7,d0                   ; Warte bis Kontroller bereit
            beq.s   DCL2
            btst.b  #5,d0                   ; Noch Execution Phase ?
            bne.s   DCL_WRITE
            btst.b  #4,d0                   ; Kommando beendet ?
            beq.s   DCL_END
            bra.s   DCL_RESULT              ; Ist Result Phase

DCL_READ:   F_IOR.b F_FIFO,(a1)+            ; Daten holen
DCL3:       F_IOR.b F_MSR,d0
            btst.b  #7,d0                   ; Warte bis Kontroller bereit
            beq.s   DCL3
            btst.b  #5,d0                   ; Noch Execution Phase ?
            bne.s   DCL_READ
            btst.b  #4,d0                   ; Kommando beendet ?
            beq.s   DCL_END
DCL_RESULT: F_IOR.b F_FIFO,(a2)+            ; Ergebnis holen
DCL4:       F_IOR.b F_MSR,d0
            btst.b  #7,d0                   ; Warte bis Kontroller bereit
            beq.s   DCL4
            btst.b  #4,d0                   ; Kommando beendet ?
            bne.s   DCL_RESULT
DCL_END:    move.l  (sp)+,a2
            rts

; Floppy Controller initialisieren
Flopinit:   movem.l a0-a2/d0-d1,-(sp)
            lea     ResultBuffer,a2         ; FÅr alle FÑlle initialisieren
            lea     SektorPuffer,a1
            F_IOW.b #$14,F_DOR              ; No Reset, Motor On
            move.b  #RECALIBRATE,d0
            lea     RecalData,a0
            bsr     Do_Command
            F_IOR.b F_MSR,d0
            and.b   #$0F,d0                 ; Ist ein Int abzufangen ?
            beq.s   fi1
            move.b  #SENSE_INT,d0           ; Nach steppen durchfÅhren !
            lea     ResultBuffer,a2
            bsr     Do_Command
fi1:
            F_IOW.b #$04,F_DOR              ; No Reset, Motor Off
            F_IOW.b #$00,F_DSR              ; 1.44MB, Default Precomp
            F_IOW.b #$00,F_CCR
            move.b  #CONFIGURE,d0
            lea     ConfData,a0
            bsr     Do_Command
            move.b  #SPECIFY,d0
            lea     SpecifyData,a0
            bsr     Do_Command
            move.b  #MODE,d0
            lea     ModeData,a0
            bsr     Do_Command
            movem.l (sp)+,d0-d1/a0-a2
            rts

.DATA
ConfData:   dc.b    $00,$60,$00             ; EIS, Kein FIFO, Polling enabled
SpecifyData: dc.b   $AF,$03                 ; DSR = 6msec,
ModeData:   dc.b    $22,$00,$C8,00          ; IPS auch hier erlauben
RecalData:  dc.b    $00

.TEXT
Motor_on:   F_IOW.b #$14,F_DOR
            rts

Motor_off:  F_IOW.b #$04,F_DOR
            rts

; floprd - read sector from floppy
; Passed (on the stack):
;           $14(sp) count
;           $12(sp) sideno
;           $10(sp) trackno
;            $e(sp) sectno
;            $c(sp) devno
;            $8(sp) ->DSB
;            $4(sp) ->buffer
;            $0(sp) return address
;
; Returns:  EQ, the read won (on all sectors),
;                   NE, the read failed (on some sector).
; a0, a1, a2, d0, d1 zerstîrt

Floprd:     move.w  #e_read,def_error
            lea     CommandBuffer,a0
            move.b  $0D(sp),d0
            and.b   #3,d0                   ; Laufwerke ausmaskieren
            or.b    #$80,d0                 ; IPS setzen
            move.b  d0,(a0)
            move.b  $11(sp),1(a0)           ; Track Nummer
            move.b  $13(sp),d0
            move.b  d0,2(a0)                ; Head Nummer
            and.b   #1,d0
            lsl.b   #2,d0
            or.b    d0,(a0)                 ; Bit fÅr Head im 2. Kommando Byte setzen
;           move.b  $0F(sp),3(a0)           ; Sektor Nummer
            move.b  $0F(sp),d0              ; Sektor Nummer Holen
            move.b  d0,3(a0)                ; und wegschreiben
            move.b  #2,4(a0)                ; 512 Bytes per Sektor
            add.b   $15(sp),d0              ; Endsektor = Start + Count - 1
            subq.b  #1,d0
            move.b  d0,5(a0)                ; und EOT Setzen
;           move.b  $0F(sp),5(a0)           ; EOT auf Sektor Nummer setzen (Count = 1)
            move.b  #$1B,6(a0)              ; Intersector GAP fÅr 1.44MB
            move.b  #$FF,7(a0)              ; dummy
            move.b  #(READ_DATA | MFM),d0   ; Read Data
            move.l  $4(sp),a1               ; Data Buffer
            lea     ResultBuffer,a2
            bsr     Do_Command
            move.b  (a2),d0
            moveq   #0,d1                   ; Kein Fehler
            and.b   #$c0,d0                 ; Ist ein Fehler aufgetreten ?
            beq     eb1                     ; nein, springe

            btst.b  #7,1(a2)                ; EOT ?
            bne     eb1                     ; Ist fÅr uns kein Fehler

;           moveq   #e_wp,d1                ; write protect?
;           btst.b  #1,1(a2)
;           bne     eb1

            moveq   #e_rnf,d1               ; record-not-found?
            btst.b  #2,1(a2)
            bne     eb1

            moveq   #e_crc,d1               ; CRC error?
            btst.b  #5,2(a2)
            bne     eb1

            move.w  def_error,d1            ; use default error#
eb1:        move.w  d1,curr_err             ; set current error number & return
Floprd_end: rts

u2i:        ror.w   #8,d0
            rts

getbpb:     movem.l d0-d2/a0-a2,-(sp)
            move.w  #$1,-(sp)               ; 1 Sektor laden
            move.w  #$0,-(sp)               ; Side 0
            move.w  #$0,-(sp)               ; Track 0
            move.w  #$1,-(sp)               ; Sektor 1
            move.w  #$0,-(sp)               ; Lw 0
            move.l  #$0,-(sp)               ; -> DSB
            pea.l   SektorPuffer
            bsr     Floprd
            add.l   #18,sp
            cmp.w   #0,curr_err             ; Fehler ?
            bne     getbpb_eend             ; ja, springe
; bpb Parameter setzen
            lea     SektorPuffer,a0
            move.w  IBM_BPS(a0),d1
            ror.w   #8,d1                   ; Big Endian
            cmp.w   #0,d1                   ; darf nicht <= 0 sein
            ble     getbpb_eend
            move.w  d1,bpb+recsize          ; recsize in d1 halten
            move.b  IBM_SPC(a0),d0
            and.w   #$00FF,d0               ; Byte darf nicht null sein
            beq     getbpb_eend
            move.w  d0,d2                   ; clsize in d2 sichern
            move.w  d0,bpb+clsize
            mulu    d1,d0
            move.w  d0,bpb+clsizeb
            move.w  IBM_SPF(a0),d0
            ror.w   #8,d0                   ; Big Endian
            move.w  d0,bpb+fsiz
            addq.w  #1,d0
            move.w  d0,bpb+fatrec
            move.w  IBM_NDIRS(a0),d0
            ror.w   #8,d0                   ; Big Endian
            and.l   #$0000FFFF,d0
            lsl.l   #5,d0
            divu    d1,d0
            move.w  d0,bpb+rdlen
            add.w   bpb+fatrec,d0
            add.w   bpb+fsiz,d0
            move.w  d0,bpb+datrec
            move.w  IBM_NSECTS(a0),d1
            ror.w   #8,d1                   ; Big Endian
            sub.w   d0,d1
            and.l   #$0000FFFF,d1
            divu    d2,d1
            move.w  d1,bpb+numcl
            move.w  #0,bpb+bflags
; dsb Parameter setzen
            move.w  IBM_NSIDES(a0),d0
            ror.w   #8,d0                   ; Big Endian
            move.w  d0,dsb+dnsides
            move.w  IBM_SPT(a0),d1
            ror.w   #8,d1                   ; Big Endian
            move.w  d1,dsb+dspt
            mulu    d0,d1
            move.w  d1,dsb+dspc
            move.w  IBM_NHID(a0),d0
            ror.w   #8,d0                   ; Big Endian
            move.w  d0,dsb+dhidden
            move.w  IBM_NSECTS(a0),d0
            ror.w   #8,d0                   ; Big Endian
            and.l   #$0000FFFF,d0
            divu    d1,d0
            move.w  d0,dsb+dntracks
            move.w  #0,curr_err
            bra.s   getbpb_end
getbpb_eend: move.w #e_error,curr_err
getbpb_end: movem.l (sp)+,d0-d2/a0-a2
            rts

; readabs - read absolute sector from floppy
; Passed (on the stack):
;            $E(sp) count
;            $A(sp) sectno
;            $8(sp) devno
;            $4(sp) ->buffer
;            $0(sp) return address
; d0-d2 und a0 verÑndert
readabs:    cmp.w   #0,$e(sp)               ; sind Sektoren zu lesen ?
            beq     rdabs_end
rdabs_2:    move.l  $a(sp),d0               ; Sektornummer holen
            move.l  4(sp),a0                ; Puffer Adresse
            divu    dsb+dspc,d0
            moveq   #0,d1
            swap    d0
            cmp.w   dsb+dspt,d0
            blt.s   rdabs_1
            sub.w   dsb+dspt,d0             ; ist zweite Seite
            moveq   #1,d1
rdabs_1:    move.w  dsb+dspt,d2             ; Sektoren pro Spur
            sub.w   d0,d2                   ; minus Startsektor = Max. Count
            cmp.w   $0e(sp),d2              ; Mit Count vergleichen
            bls.s   rdabs_3
            move.w  $0e(sp),d2
rdabs_3:    move.w  d2,Cur_Read             ; Wert sichern
            move.w  8(sp),d2                ; Device holen
            move.w  Cur_Read,-(sp)          ; n Sektoren laden
            move.w  d1,-(sp)                ; Side 0
            swap    d0
            move.w  d0,-(sp)                ; Track 0
            swap    d0
            addq.w  #1,d0                   ; Sec. sind 1-Based
            move.w  d0,-(sp)                ; Sektor 1
            move.w  d2,-(sp)                ; Lw 0
            move.l  #$0,-(sp)               ; -> DSB
            move.l  a0,-(sp)
            bsr     Floprd
            add.l   #18,sp
            cmp.w   #0,curr_err
            bne.s   rdabs_end
            move.w  Cur_Read,d2
            and.l   #$0000FFFF,d2
            add.l   d2,$a(sp)               ; Sektornummer erhîhen
            move.w  bpb+recsize,d0
            mulu    d2,d0
;           and.l   #$0000FFFF,d0
            add.l   d0,4(sp)                ; Offset korrigieren
            sub.w   d2,$e(sp)               ; Count erniedrigen
            bne     rdabs_2
rdabs_end:
            rts

Fsfirst:    movem.l d0-d2/a0-a2,-(sp)
            move.w  bpb+fatrec,d0
            add.w   bpb+fsiz,d0             ; d0 = 1. root dir sec.
;           addq.l  #1,d0                   ; Korrektur fÅr readabs
            move.w  #1,-(sp)                ; 1 sektor lesen
            and.l   #$0000FFFF,d0
            move.l  d0,-(sp)                ; Sektornummer
            move.w  #0,-(sp)                ; device
            pea.l   SektorPuffer
            bsr     readabs
            add.l   #12,a7
            cmp.w   #0,curr_err             ; Fehler ?
            bne     fsfirst_eend            ; ja, springe
            move.l  #15,d0                  ; 16 EintrÑge im Sektor
            lea     SektorPuffer,a0
            lea     DateiName,a1
ffl1:       moveq   #0,d1
ffl3:       move.b  (a0,d1.w),d2
            cmp.b   #$60,d2
            bls.s   ffl4
            and.b   #$DF,d2                 ; ToUpper
ffl4:       cmp.b   (a1,d1.w),d2
            bne.s   ffl2
            addq.l  #1,d1
            cmp.l   #11,d1
            bne     ffl3
            bra.s   ff_found
ffl2:       add.l   #32,a0
            dbra    d0,ffl1                 ; NÑchster Eintrag
            bra.s   fsfirst_eend
ff_found:   move.l  28(a0),d0
            ror.w   #8,d0
            swap    d0
            ror.w   #8,d0
            move.l  d0,filesize
            move.w  26(a0),d0
            ror.w   #8,d0
            subq.w  #2,d0                   ; immer zwei abziehen
            move.w  bpb+clsize,d1
            mulu    d1,d0
            move.w  bpb+datrec,d1
            and.l   #$0000FFFF,d1
            add.l   d1,d0
            move.l  d0,filestart
            move.w  #0,curr_err             ; Kein Fehler
            bra.s   fsfirst_end
fsfirst_eend: move.w #e_error,curr_err
fsfirst_end: movem.l (sp)+,d0-d2/a0-a2
            rts

readfile:   movem.l d0-d2/a0-a2,-(sp)
            move.l  filesize,d0
            move.w  bpb+recsize,d1
            and.l   #$0000FFFF,d1
            add.l   d1,d0
            subq.l  #1,d0
            divu    d1,d0                   ; Anzahl der zu lesenden Sektoren
;           move.w  #10,d0
            move.w  d0,-(sp)                ; n Sektoren lesen
            move.l  filestart,d0
            move.l  d0,-(sp)                ; Sektornummer
            move.w  #0,-(sp)                ; device

            move.l  #TosLoadBuffer,-(sp)
            bsr     readabs
            add.l   #12,a7
            movem.l (sp)+,d0-d2/a0-a2
            rts
            .DATA
DateiName:  dc.b    'TOS     IMG'
            .BSS
def_error:  ds.w    1                       ; default error number
curr_err:   ds.w    1                       ; current error number
ResultBuffer: ds.b  7
CommandBuffer: ds.b 8
            ALIGN
bpb:        ds.w    9                       ; bpb
dsb:        ds.w    5                       ; dsb
Cur_Read:   ds.w    1                       ; Momentan zu lesende Sektoren
filestart:  ds.l    1                       ; Startsektor fÅr TOS.IMG
filesize:   ds.l    1                       ; Dateigrîûe in Bytes
SektorPuffer: ds.b  512

            END
