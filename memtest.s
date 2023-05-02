;****************************************************************************
; Gruendlicher Speichertest mit Bildschirmausgabe
;****************************************************************************
; $Id: memtest.s,v 1.4 2003/12/28 22:14:01 rincewind Exp $
;****************************************************************************
; $Log: memtest.s,v $
; Revision 1.4  2003/12/28 22:14:01  rincewind
; - fix CVS headers
;
; Revision 1.2  2000/06/19 20:52:34  rincewind
; - misc cleanup
;****************************************************************************

            export  do_memtest;
            import  vgaprintf2
            import  fast_memtest, CheckKeys

            include "regdef.inc"

; Aufruf:
; Startadresse in A0
; Endadresse in A1
; return: letzte einwandfreie Adresse in A0
do_memtest: movem.l d0-d7/a2-a6,-(sp)
            POSTCODE2 #$20

            tst.w   count
            bne.s   memtst1
            add.w   #1,count                ; bei 1MB anfangen

memtst1:    moveq   #0,d4                   ; viele Nullen fÅr Lîschroutine
            move.l  d4,d5
            move.l  d4,d6
            move.l  d4,d7

; Speicher in 1MB-Blîcken testen
memtst2:    move.l  a0,d2
            add.l   #$00100000,d2           ; +1MB = Endadresse Durchlauf

            tst.w   fast_memtest
            beq.s   memtst2a
; Schneller Ramtest: nur Adreûpattern am Anfang jedes 1MB-Blocks testen
            move.l  a0,d0                   ; Vergleichswert
            REPT    4
            cmp.l   (a0)+,d0
            bne     memtst9                 ; Fehler
            addq.l  #4,d0
            ENDM
            bra     NextBlock

; Adreûpattern vergleichen
memtst2a:   move.l  a0,a2
            move.l  a0,d0                   ; Vergleichswert
memtst3:    REPT    4
            cmp.l   (a2)+,d0
            bne     memtst9                 ; Fehler
            addq.l  #4,d0
            ENDM
            cmp.l   a2,d2
            bne.s   memtst3

            POSTCODE2 #$21

; Testmuster schreiben
            move.l  a0,a2
            move.l  #$55aa55aa,d0
            move.l  #$aa55aa55,d1
memtst4:    REPT    4
            move.l  d0,(a2)+
            move.l  d1,(a2)+
            ENDM
            cmp.l   a2,d2
            bne.s   memtst4

            POSTCODE2 #$22

; Testmuster vergleichen
            move.l  a0,a2
memtst5:    REPT    4
            cmp.l   (a2)+,d0
            bne     memtst9
            cmp.l   (a2)+,d1
            bne     memtst9                 ; Fehler
            ENDM
            cmp.l   a2,d2
            bne.s   memtst5

            if      0
; Lîschen
            move.l  a0,a2
memtst6:    movem.l d4-d7,(a2)
            movem.l d4-d7,16(a2)
            movem.l d4-d7,32(a2)
            movem.l d4-d7,48(a2)
            lea     64(a2),a2
            cmp.l   a2,d2
            bne.s   memtst6
            endif

;--- Ende des Blocks - Textausgabe
NextBlock:  POSTCODE2 #$23
            move.l  d2,a0                   ; nÑchster Block

            add.w   #1,count

            movem.l a0-a2/d0-d2,-(sp)
            lea     memtxt(pc),a0
            move.w  count,-(sp)
            bsr     vgaprintf2
            addq.l  #2,sp
            bsr     CheckKeys
            movem.l (sp)+,a0-a2/d0-d2

            cmp.l   a0,a1                   ; Ende?
            bne     memtst2

memtst9:    POSTCODE2 #$24
            movem.l (sp)+,d0-d7/a2-a6
            rts     ; Ende in A0

memtxt:     dc.b    3,"%d MB",0

            BSS
count:      ds.w    1
            END

