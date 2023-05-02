;****************************************************************************
; Startup code for program that is launched from the Milan bootblock
; as a TOS.IMG
;****************************************************************************
; $Id: bb_start.s,v 1.2 2003/12/28 22:14:15 rincewind Exp $
;****************************************************************************
; $Log: bb_start.s,v $
; Revision 1.2  2003/12/28 22:14:15  rincewind
; - fix CVS headers
;
;****************************************************************************

; Export references
            .EXPORT __text, __data, __bss
            .EXPORT errno

; Import references
            .IMPORT main

; Data segment
            .BSS
__bss:
StackSave:  ds.l    1

; Code segment
            .CODE
__text:

Start:      dc.w    $602e                   ; Wegen dem unpack TOS
            dc.l    $0
            dc.l    $0
            dc.l    $0
            dc.l    $0
            dc.l    $0
            dc.l    $0
            dc.l    $0
            dc.l    $0
            dc.l    $0
            dc.l    $0
            dc.l    $0
            dc.l    $0
            dc.l    $0
            move.l  A7,StackSave
            LEA     $00200000,A7
            BSR     main
            move.l  StackSave,A7
            rts
            .END
