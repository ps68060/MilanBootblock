;**************************************************************
; $Id: keyboard.s,v 1.3 2003/12/28 21:05:52 rincewind Exp $
; $Log: keyboard.s,v $
; Revision 1.3  2003/12/28 21:05:52  rincewind
; - export Keyboard_OK flag for TOS
;
; Revision 1.2  2000/06/19 20:52:34  rincewind
; misc cleanup
;
; Tastatur-Routinen
;**************************************************************
            INCLUDE "regdef.inc"

; Imports
            IMPORT  vgaprintf
            IMPORT  msg_kberror
            IMPORT  Keyboard_OK
; Exports
            EXPORT  GetKey
            EXPORT  InitKey, InitKey2

            MACRO   _DEBUG2 msg, par
            LOCAL   .msg
            IMPORT  vgaprintf2
            movem.l d0-d2/a0-a2,-(sp)
            lea     .msg,a0
            move.l  par,-(sp)
            bsr     vgaprintf2
            addq.l  #4,sp
            movem.l (sp)+,d0-d2/a0-a2
            DATA
.msg:       dc.b    msg
            dc.b    "$%lx"
            dc.b    13,10,0
            TEXT
            ENDM


; Keyboard Controller Register
kb_Data_reg equ     $60                     ; R/W
kb_Status_reg equ   $64                     ; Read only
kb_Command_reg equ  $64                     ; Write only

; Keyboard Controller Kommandos
kb_cc_ReadMode equ  $20                     ; Mode Bits lesen
kb_cc_WriteMode equ $60                     ; Mode Bits schreiben
kb_cc_MouseDisable equ $a7                  ; Mouse Interface disable
kb_cc_MouseEnable equ $a8                   ; Mouse Interface enable
kb_cc_MouseTest equ $a9                     ; Mouse Interface Test
kb_cc_SelfTest equ  $aa                     ; Contr. Selbsttest durchf¸hren
kb_cc_KbdTest equ   $ab                     ; Keyboard Interface Test
kb_cc_KbdDisable equ $ad                    ; Keyboard Interface disable
kb_cc_KbdEnable equ $ae                     ; Keyboard Interface enable
kb_cc_WriteMouse equ $d4                    ; Daten zu Maus schicken

; Keyboard Kommandos
kb_c_SetLeds equ    $ed                     ; Keyboard LEDs setzen
kb_c_SetRate equ    $f3                     ; Set Typematic Rate
kb_c_Enable equ     $f4                     ; Enable scanning
kb_c_Disable equ    $f5                     ; Disable scanning
kb_c_Reset  equ     $ff                     ; Keyboard zur¸cksetzen

; Keyboard Antworten
kb_r_POR    equ     $aa                     ; Power on Reset
kb_r_Ack    equ     $fa                     ; Kommando best‰tigt
kb_r_Resend equ     $fe                     ; Kommando neu senden

; Keyboard Controller Status Bits
kb_stat_obf equ     $01                     ; Keyboard Output Buffer full
kb_stat_ibf equ     $02                     ; Keyboard Input Buffer Full
kb_stat_mouse equ   $20                     ; Mause Output Buffer Full
kb_stat_gto equ     $40                     ; General transmit/receive timeout
kb_stat_perr equ    $80                     ; Parity error

; Keyboard Mode Register Bits
kb_mode_KbdInt equ  $01                     ; Keyboard Daten erzeugen IRQ1
kb_mode_MouseInt equ $02                    ; Maus Daten erzeugen IRQ12
kb_mode_Sys equ     $04                     ; ? System Flag ?
kb_mode_NoKeylock equ $08                   ;
kb_mode_DisableKbd equ $10                  ; Keyboard Interface abschalten
kb_mode_DisableMouse equ $20                ; Maus Interface abschalten
kb_mode_KCC equ     $40
kb_mode_RFU equ     $80

;**************************************************************************
InitKey:
;           _DEBUG2 'test',d0
            move.b  #0,Keyboard_OK          ; Default -> Kein Keyboard
isk_l1:
            .if     1
            moveq   #5,d7                   ; 50 ms timeout
            bsr     kb_ReceiveData          ; Alle anstehenden Zeichen lˆschen
;           _DEBUG2 'Zeichen: ',d0
            cmp.l   #-1,d0                  ; TimeOut?
            bne     isk_l1                  ; Nein, weiter Zeichen abholen

; Keyboard interface testen
;           _DEBUG2 'Selbsttest',d0
            move.b  #kb_cc_SelfTest,d0      ; Selbsttest durchfÅhren
            bsr     kb_SendCommand
            moveq   #50,d7                  ; 500 ms timeout
            bsr     kb_ReceiveData          ; Ergebnis abholen
            cmp.b   #$55,d0                 ; Test erfolgreich ?
            bne     err_end1                ; Nein, Fehler
            .endif

;  _DEBUG2 'Interface test',d0
            move.b  #kb_cc_KbdTest,d0       ; Schnittstelle testen
            bsr     kb_SendCommand
            moveq   #50,d7                  ; 500 ms timeout
            bsr     kb_ReceiveData          ; Ergebnis abholen
            cmp.b   #0,d0                   ; Test erfolgreich ?
            bne     err_end1                ; Nein, Fehler

; Nun mÅssen wir den Keyboard Controller Programieren
            move.b  #kb_cc_WriteMode,d0     ; Mode Bits schreiben
            bsr     kb_SendCommand
;           move.b  #(kb_mode_KbdInt | kb_mode_Sys | kb_mode_DisableMouse|kb_mode_KCC),d0
            move.b  #(kb_mode_Sys | kb_mode_DisableMouse|kb_mode_KCC),d0
            bsr     kb_SendData


            move.b  #kb_cc_KbdDisable,d0    ; Interface aktivieren
;  _DEBUG2 'KBC disable',d0
            bsr     kb_SendCommand

            move.b  #kb_c_Reset,d0          ; Tastatur zurÅcksetzen
            bsr     kb_dobyte
;!!         bne     err_end1                	; Nein, Fehler

err_end1:
            rts
; Ende Teil 1. Jetzt kommt erstmal anderer Code, die Tastatur
; braucht eh Zeit fÅr ihren Reset.


;**************************************************************************
; NÑchster Einsprung hier:
InitKey2:
            movem.l a0-a1,-(sp)
            move.l  #50,d7                  ; 500 ms timeout
            bsr     kb_ReceiveData          ; Ergebnis abholen
            cmp.b   #kb_r_POR,d0            ; Kommando bestÑtigt ?
;!!         bne     isk_err_end             	; Nein, Fehler

; Jetzt die Tastatur ausschalten - sonst kommen bei bereits gedrÅckter
; Taste die Codes dazwischen und stîren

            move.b  #kb_cc_KbdDisable,d0    ; Interface ausschalten
            bsr     kb_SendCommand
            bsr     kb_wait

; Nun mÅssen wir den Keyboard Controller Programieren
            move.b  #kb_c_Disable,d0        ; Tastatur deaktivieren
            bsr     kb_dobyte
;!!         bne     isk_err_end             ; Nein, Fehler
;  _DEBUG2 'KBC set mode',d0

            .if     0
            move.b  #kb_cc_WriteMode,d0     ; Mode Bits schreiben
            bsr     kb_SendCommand
;           move.b  #(kb_mode_KbdInt | kb_mode_Sys | kb_mode_DisableMouse|kb_mode_KCC),d0
            move.b  #(kb_mode_Sys | kb_mode_DisableMouse|kb_mode_KCC),d0
            bsr     kb_SendData
            .endif

; Typematic Rate setzen
            move.b  #kb_c_SetRate,d0        ; Set Typematic Rate
            bsr     kb_dobyte
;!!         bne.s   isk_norate

            moveq   #0,d0                   ; Repeat Rate
            bsr     kb_dobyte

isk_norate:
            move.b  #kb_c_Enable,d0         ; Tastatur aktivieren
            bsr     kb_dobyte
            bne     isk_err_end             ; Nein, Fehler

            move.b  #1,Keyboard_OK          ; Keyboard ist OK

;           move.b  #kb_cc_KbdEnable,d0     ; Interface einschalten
;           bsr     kb_SendCommand
            movem.l (sp)+,a0-a1
            rts

isk_err_end:
            lea     msg_kberror,a0
            bsr     vgaprintf
            movem.l (sp)+,a0-a1
            rts

GetKey:
;           tst.b   Keyboard_OK             ; Keyboard vorhanden ?
;           beq     gk_err                  ; Nein, kein Zeichen
            IORB2   kb_Status_reg,d0
            btst    #0,d0                   ;
            beq     gk_err
;           _DEBUG2 'KB Status',d0
            move.l  d7,-(sp)
            move.l  d1,-(sp)
            moveq   #0,d1                   ; Default kein Zeichen
            move.b  #kb_cc_KbdDisable,d0    ; Interface ausschalten
            bsr     kb_SendCommand
            bsr     kb_wait
            IORB2   kb_Data_reg,d0          ; Empfangenes Zeichen abholen
;           _DEBUG2 'Keyboard Char',d0
            cmp.l   #-1,d0                  ; timeout ?
            beq     gk_beenden              ; kein Zeichen
            move.b  d0,d1                   ; Zeichen sichern
            cmp.b   #$e0,d0                 ; Extended Code ?
            bne     gk_NoExt
            move.b  #kb_cc_KbdEnable,d0     ; Interface einschalten
            bsr     kb_SendCommand
            bsr     kb_wait

gk_wl1:     IORB2   kb_Status_reg,d0
            btst    #0,d0                   ; Warte bis nÑchstes Byte Da ist
            beq     gk_wl1

            move.b  #kb_cc_KbdDisable,d0    ; Interface ausschalten
            bsr     kb_SendCommand
            bsr     kb_wait
            moveq   #5,d7                   ; 50 ms timeout
            bsr     kb_ReceiveData          ; Empfangenes Zeichen abholen
;           _DEBUG2 'Keyboard ext Char',d0
            move.b  d0,d1                   ; Zeichen sichern
            or.b    #$80,d1                 ; Extend Flag setzen
gk_NoExt:
            btst    #7,d0                   ; Nur Make Codes
            beq     gk_beenden              ; Make Code, springen
            moveq   #0,d1                   ; Null zurÅckliefern
gk_beenden:
            move.b  #kb_cc_KbdEnable,d0     ; Interface einschalten
            bsr     kb_SendCommand
            move.l  d1,d0                   ; Zeichen nach d0
;           _DEBUG2 'Keyboard char',d0
            move.l  (sp)+,d1
            move.l  (sp)+,d7
            rts

gk_err:
            moveq   #0,d0
            rts

kb_wait:
kb_w_l1:
            IORB2   kb_Status_reg,d0        ; Warte, bis Input Buffer leer
            and.b   #kb_stat_ibf,d0
            bne     kb_w_l1
            rts

kb_dobyte:
            move.b  d0,last_byte
            move.b  #3,resend_cnt
kb_dobyte4:
            move.b  last_byte,d0
            bsr     kb_SendData
            move.l  #200,d7                 ; 2000 ms timeout
            bsr     kb_ReceiveData          ; Best‰tigung abholen
            cmp.b   #kb_r_Ack,d0            ; Kommando best‰tigt ?
            beq.s   kb_dobyte2
            cmp.b   #kb_r_Resend,d0
            bne.s   kb_dobyte3
            sub.b   #1,resend_cnt
            bne.s   kb_dobyte4
            moveq   #-1,d0
kb_dobyte3: ;       Z=0, D0.B = Daten
kb_dobyte2: ;       Z=1, D0.B = ACK
            rts

; Wartet, bis Controller Bereit ist und sendet das Byte in d0 als Kommando
kb_SendCommand:
            swap    d0                      ; zu sendendes Byte sichern
kb_sc_l1:
            IORB2   kb_Status_reg,d0        ; Warte, bis Input Buffer leer
            and.b   #kb_stat_ibf,d0
            bne     kb_sc_l1
            swap    d0                      ; Hole Byte zur¸ck
            IOWB2   d0,kb_Command_reg
            rts

; Wartet, bis Controller Bereit ist und sendet das Byte in d0 als Daten
kb_SendData:
            swap    d0                      ; zu sendendes Byte sichern
kb_sd_l1:
            IORB2   kb_Status_reg,d0        ; Warte, bis Input Buffer leer
            and.b   #kb_stat_ibf,d0
            bne     kb_sd_l1
            swap    d0                      ; Hole Byte zur¸ck
            IOWB2   d0,kb_Data_reg
            rts

; Wartet, bis Zeichen ansteht und liefert es in d0 zurÅck
; d7 = Timeout count in 10ms tics
kb_ReceiveData:
kb_rd_l1:
            IORB2   kb_Status_reg,d0
            btst    #0,d0                   ; Machen wir so, damit Status bleibt
            bne     kb_rd_ok
            move.w  #$0600,d0               ; 10 ms warten
            bsr     wait
            subq.l  #1,d7
            bhi.s   kb_rd_l1                ; (not timed-out yet)
            moveq   #-1,d0                  ; Fehler melden
            bra.s   kb_rd_end
kb_rd_ok:
            IORB2   kb_Data_reg,d0
kb_rd_end:
            rts


;
;           Delay mit Timer A
;
;           wait    delays for a time specified in D0.W: the high
;                   byte is the value for the divider, and the low
;                   byte is the value for the countdown.  When
;                   the time expires, ttwait returns.  No interrupts
;                   are used.
;
; This table will tell what values to use.  The "divider" column shows
; the possible values for the divider and the division it yields.
; The "units" column tells what size tick you get, which is also
; the timeout value you'll see if you use a countdown of one.  The
; "max" column is the length of a timeout if you use a countdown of zero
; (which means 256).  (All values are rounded.)
;
;            Divider  Units                 	  Max
;           -------- -------                	--------
;           1 (/4)                           1.6 us		416   us
;           2 (/10)                          4   us		  1   ms
;           3 (/16)                          6   us		  1.6 ms
;           4 (/50)                         20   us		  5   ms
;           5 (/64)                         26   us		  6.6 ms
;           6 (/100) 40   us                	 10   ms
;           7 (/200) 80   us                	 20   ms
;
; The interrupt is enabled but masked so the first time the timer
; counts down to 0 it'll set the bit in the interrupt-pending register.
; We never actually use this interrupt, just the pending bit.
;

WAITBIT     equ     5                       ; Timer A
;NOTWAITBIT equ     $df                     	; ~(1<<WAITBIT)

            .globl  wait
            .globl  delay

wait:       bsr     delay
wait1:      btst.b  #WAITBIT,MFP_IPRA.w
            beq     wait1
            clr.b   MFP_TACR.w              ; Timer wieder anhalten
            rts

delay:
            clr.b   MFP_TACR.w              ; stop timer
            bclr.b  #WAITBIT,MFP_IERA.w     ; disable int -> clear pending
;           move.b  #NOTWAITBIT,ipra+mfp.w  ; clear pending
            bclr.b  #WAITBIT,MFP_IMRA.w     ; mask int
            bset.b  #WAITBIT,MFP_IERA.w     ; enable int

            move.b  d0,MFP_TADR.w           ; set data value
            ror.w   #8,d0                   ; get mode byte into d0.b
            move.b  d0,MFP_TACR.w           ; start the clock (mode from d0)
            rol.w   #8,d0                   ; restore d0
            rts     ; and return

            .BSS
last_byte:  ds.b    1
resend_cnt: ds.b    1
