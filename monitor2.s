;****************************************************************************
; $Id: monitor2.s,v 1.4 2003/12/28 22:14:02 rincewind Exp $
;****************************************************************************
; $Log: monitor2.s,v $
; Revision 1.4  2003/12/28 22:14:02  rincewind
; - fix CVS headers
;
; Revision 1.2  2000/06/19 20:52:34  rincewind
; - misc cleanup
;****************************************************************************

            EXPORT  monitor, montrap, regsave
            EXPORT  mon_trap_called, sr_save
            IMPORT  _monitor

            INCLUDE "regdef.inc"

            TEXT
monitor:    move.w  sr,sr_save
            movem.l d0-d7/a0-a7, regsave
            sf      mon_trap_called
            jsr     _monitor
            movem.l regsave, d0-d7/a0-a7
            rts

montrap:    move.w  sr,sr_save
            movem.l d0-d7/a0-a7, regsave
            st      mon_trap_called
;                   POSTCODE2 #$F3
            lea     $100000,a7
            jsr     _monitor
            movem.l regsave, d0-d7/a0-a7
            rts

            BSS
regsave:    DS.L    16
sr_save:    DS.W    1
mon_trap_called: ds.w 1
            END
