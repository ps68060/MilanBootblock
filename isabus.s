;****************************************************************************
; $Id: isabus.s,v 1.12 2004/01/18 16:46:22 rincewind Exp $
;****************************************************************************
; $Log: isabus.s,v $
; Revision 1.12  2004/01/18 16:46:22  rincewind
; - set KBD and MOUSE to interrupt 12
;
; Revision 1.11  2003/12/28 22:14:01  rincewind
; - fix CVS headers
;
; Revision 1.10  2003/12/28 21:11:22  rincewind
; - fix CS addresses for UARTs on REAC060 board
;
; Revision 1.2  2000/06/19 20:52:34  rincewind
; - misc cleanup
;****************************************************************************

            INCLUDE "regdef.inc"
            EXPORT  Init_8259,Init_SuperIO, Init_RTC
            IMPORT  vgaprintf, msg_battery

;*** Diverse Initialisierungsroutinen
            CoProzRegister EQU              $00F0
            Int1_Base EQU                   $0020
            Int2_Base EQU                   $00A0

Init_8259:  IOWB    #$0,CoProzRegister      ; INT13 CoProzFehler rÅcksetzen
; Controller 1 initialisieren
            IOWB    #$11,Int1_Base          ; ICW1 - Edge, Master ICW4
            IOWB    #$00,Int1_Base+1        ; ICW2 - Interrupt Vektor Base (00-07)
            IOWB    #$04,Int1_Base+1        ; ICW3 - Master Level 2
            IOWB    #$01,Int1_Base+1        ; ICW4 - Master, 8086 Mode
            IOWB    #$FF,Int1_Base+1        ; Mask all Ints off
; Controller 2 initialisieren
            IOWB    #$11,Int2_Base          ; ICW1 - Edge, Slave ICW4
            IOWB    #$08,Int2_Base+1        ; ICW2 - Interrupt Vektor Base 08 (08-0F)
            IOWB    #$02,Int2_Base+1        ; ICW3 - Slave Level 2
            IOWB    #$01,Int2_Base+1        ; ICW4 - Slave, 8086 Mode
            IOWB    #$FF,Int2_Base+1        ; Mask all Ints off
            rts

Init_SuperIO:
            lea     SuperIoTab(pc),a0
.loop:      move.w  (a0)+,d0
            cmp.w   #-1,d0
            beq.s   .quit
            IOWW    d0,$15C
            bra.s   .loop
.quit:
            IOWB    #3,$400                 ; PMC2: Clock
            IOWB    #$07,$401               ; internal clock multiplier
            IOWB    #4,$400                 ; PMC3: Enable Bits
            IOWB    #$7D,$401               ; Enable all
            IOWB    #$00,$414               ; GPIO2 Data: disable RS232/485 drivers
            IOWB    #$F0,$415               ; GPIO2: set direction
            IOWB    #$FF,$416               ; GPIO2: output push/pull
            IOWB    #$FE,$417               ; Disable GPIO20 pull-up (disable watchdog)
            jmp     (a6)

; A0 erhalten!
Init_RTC:   IOWB    #$0D,$70                ; RTC CRD
            IORB    $71,d0                  ; CRD lesen
            btst    #7,d0
            bne.s   .quit2
            movem.l a0-a1,-(sp)
            lea     msg_battery(pc),a0
            bsr     vgaprintf               ; Warnung ausgeben: Battery low
            movem.l (sp)+,a0-a1
.quit2:     rts

SuperIoTab: even    ; Registerinhalt, Registernummer
            dc.b    $07,$21                 ; general config
            dc.b    $12,$22                 ; general config
            dc.b    $08,$07                 ; APM
            dc.b    $04,$60                 ; Adresse $0400
            dc.b    $00,$61
            dc.b    $01,$30                 ; enable

            dc.b    $00,$07                 ; KBD
            dc.b    $40,$f0                 ; KBD clock
            dc.b     12,$70                 ; interrupt line
            dc.b    $01,$30                 ; enable
            
            dc.b    $01,$07                 ; Maus
            dc.b     12,$70                 ; interrupt line
            dc.b    $01,$30                 ; enable
            
            dc.b    $02,$07                 ; RTC
            dc.b    $01,$30                 ; enable

            dc.b    $03,$07                 ; FDC
            dc.b    $01,$30                 ; enable

            dc.b    $04,$07                 ; Parallel port
            dc.b    $01,$30                 ; enable

            dc.b    $05,$07                 ; UART2
            dc.b    $01,$30                 ; enable

            dc.b    $06,$07                 ; UART1
            dc.b    $01,$30                 ; enable
            
            dc.b    $07,$07                 ; GPIO
            dc.b    $04,$60                 ; Base=$410
            dc.b    $10,$61                 ;     -$417

            dc.b    $00,$23                 ; CS0 Base High
            dc.b    $04,$24
            dc.b    $01,$23                 ; CS0 base Low
            dc.b    $18,$24
            dc.b    $02,$23                 ; CS0 Config
            dc.b    $20,$24

            dc.b    $04,$23                 ; CS1 Base High
            dc.b    $04,$24
            dc.b    $05,$23                 ; CS1 base Low
            dc.b    $28,$24
            dc.b    $06,$23                 ; CS1 Config
            dc.b    $47,$24

            dc.b    $08,$23                 ; CS2 Base High
            dc.b    $04,$24
            dc.b    $09,$23                 ; CS2 base Low
            dc.b    $20,$24
            dc.b    $0A,$23                 ; CS2 Config
            dc.b    $47,$24

            dc.b    $01,$30                 ; enable
            dc.b    $ff,$ff
