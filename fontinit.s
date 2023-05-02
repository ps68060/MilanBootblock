;****************************************************************************
; $Id: fontinit.s,v 1.9 2003/12/28 22:14:01 rincewind Exp $
;****************************************************************************
; $Log: fontinit.s,v $
; Revision 1.9  2003/12/28 22:14:01  rincewind
; - fix CVS headers
;
; Revision 1.2  2000/06/19 20:52:34  rincewind
; misc cleanup
;****************************************************************************

            INCLUDE "regdef.inc"
            EXPORT  init_vga_font

            TEXT

init_vga_font:
; Font laden
; Grafikkarte in den linearen Modus schalten
            IOWW    #$0402,$3C4             ; Enable plane 2
            IOWW    #$0604,$3C4             ; Seq. Modus
            IOWW    #$2004,$3CE             ; Read Plane 2
            IOWW    #$0005,$3CE             ; Standard Adressierung
            IOWW    #$0406,$3CE             ; A0 unchanged, 64KByte ab A0000

            lea     font8x16(pc),a0         ; Font Startadresse laden
            lea     $400A0000,a1            ; Plane 2
            move.w  #255,d2                 ; 128 Zeichen
FONT_LOOP:
            moveq   #15,d3
FONT_LOOP1:
            move.b  (a0)+,(a1)+             ; 16 Rasterzeilen
            dbra    d3,FONT_LOOP1
            lea     16(a1),a1               ; Offset korrigieren
            dbra    d2,FONT_LOOP
; Spezielle Zeichen fÅr den Milan Schriftzug einfÅgen
            lea     MilanFont(pc),a0        ; Adresse des Fonts
            lea     $400A0000+($B5*$20),a1  ; Plane 2
            move.w  #30,d2                  ; 31 Zeichen
FONT_LOOP2:
            moveq   #3,d3
FONT_LOOP3:
            move.l  (a0)+,(a1)+
            dbra    d3,FONT_LOOP3
            lea     16(a1),a1
            dbra    d2,FONT_LOOP2

; Grafikkarte zurÅckschalten

            IOWW    #$0302,$3C4             ; Enable plane 0,1
            IOWW    #$0204,$3C4             ; Odd/Even Modus
            IOWW    #$0004,$3CE             ; Read Plane 0
            IOWW    #$1005,$3CE             ; Odd/Even Adressierung
            IOWW    #$0E06,$3CE             ; A0 Odd/Even, 32KByte ab B8000

            rts

            DATA
            INCLUDE "fontlogo.s"
            INCLUDE "font8x16.s"
            END
