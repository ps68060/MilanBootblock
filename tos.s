;****************************************************************************
; $Id: tos.s,v 1.11 2003/12/28 22:14:02 rincewind Exp $
;****************************************************************************
; $Log: tos.s,v $
; Revision 1.11  2003/12/28 22:14:02  rincewind
; - fix CVS headers
;
; Revision 1.2  2000/06/19 20:52:34  rincewind
; - misc cleanup
;****************************************************************************
            INCLUDE "regdef.inc"

; Exports
            .GLOBL  load_tos, run_tos, CopyRomTOS
; Imports
            .GLOBL  Flopinit, getbpb, Motor_on, Motor_off
            .GLOBL  Fsfirst, readfile
            .GLOBL  curr_err

            IMPORT  vgaprintf, phys_RootTbl, Lock_TOS
            IMPORT  msg_tosload, msg_tosstart, msg_ok
            IMPORT  msg_bpberror, msg_direrror, msg_fileerror
            IMPORT  msg_tosinvalid
            IMPORT  tos_buserror

load_tos:   movem.l a0-a6/d0-d7,-(sp)
load_retry: lea     msg_tosload,a0
            bsr     vgaprintf
            bsr     Flopinit
            bsr     Motor_on
            bsr     getbpb
            bsr     getbpb
            cmp.w   #0,curr_err             ; Fehler ?
            bne     lt_error1
            bsr     Fsfirst
            cmp.w   #0,curr_err             ; Fehler ?
            bne     lt_error2
            bsr     readfile
            cmp.w   #0,curr_err             ; Fehler ?
            bne     lt_error3
            lea     msg_ok(PC),a0
            bsr     vgaprintf
lt_end:     bsr     Motor_off
            move.w  curr_err,d0
            movem.l (sp)+,a0-a6/d0-d7
            rts

lt_error1:  lea     msg_bpberror(pc),a0
            bsr     vgaprintf
            bra.s   lt_end

lt_error2:  lea     msg_direrror(pc),a0
            bsr     vgaprintf
            bra.s   lt_end

lt_error3:  lea     msg_fileerror(pc),a0
            bsr     vgaprintf
            bra.s   lt_end

run_tos:    move.l  #TosTarget,a0
            cmp.w   #$602e,(a0)
            bne.s   run_tos2
            lea     msg_tosstart(pc),a0
            bsr     vgaprintf
            bsr     LockTOS
            move.l  #tos_buserror,8.w
            jmp     TosTarget+$36

run_tos2:   lea     msg_tosinvalid(pc),a0
            bra     vgaprintf               ; return

CopyRomTOS:
            lea     $7FF80000,a0
            move.l  #TosLoadBuffer,a1
            move.l  #$C0000003,PLX_DMPBAM.w ; 3GB PCI Base
            nop
;           move.l  #$2,PLX_BIGEND.w        ; auf Big endian umschalten
            move.w  #($7000-1),d0           ; FFF80000 bis FFFEFFFF kopieren
.loop_0:    move.l  (a0)+,(a1)+
            move.l  (a0)+,(a1)+
            move.l  (a0)+,(a1)+
            move.l  (a0)+,(a1)+
            dbra    d0,.loop_0
;           move.l  #$0,PLX_BIGEND.w        ; und wieder zurÅck
            move.l  #$00000003,PLX_DMPBAM.w ; 0GB PCI Base
            nop
            DC.W    %1111010010011000       ; CINVA IC gesammten I-Cache lîschen
            rts

; !!! Die nachfolgende Routine funktioniert nur, wenn sie im dem Teil
; vom RAM steht, in dem physikalische und logische Adressen gleich sind
LockTOS:
            jsr     Lock_TOS                ; C-Routine aufrufen
; Die Root-Zeiger der Tabelle setzen
            move.l  phys_RootTbl,d0
            dc.w    $4E7B,$0807             ; movec d0,SRP
            dc.w    $4E7B,$0806             ; movec d0,URP
            move.l  #R_DTTR0,d0
            dc.w    $4E7B,$0006             ; movec d0,DTTR0
            move.l  #R_DTTR1,d0
            dc.w    $4E7B,$0007             ; movec d0,DTTR1
            move.l  #R_ITTR0,d0
            dc.w    $4E7B,$0004             ; movec d0,ITTR0
            move.l  #R_ITTR1,d0
            dc.w    $4E7B,$0005             ; movec d0,ITTR1

            moveq   #1,d0
            movec   d0,DFC                  ; Flush User ATC
            dc.w    %1111010100011000       ; PFLUSHA
            moveq   #5,d0
            movec   d0,DFC                  ; Flush Super ATC
            dc.w    %1111010100011000       ; PFLUSHA

            move.w  #$C000,d0               ; Die oberen Bits sind evtl. nicht Null
            dc.w    $4E7B,$0003             ; movec d0,TC: PMMU ein
            rts

            END
