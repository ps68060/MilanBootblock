;****************************************************************************
; $Id: ll_io.s,v 1.7 2003/12/28 22:14:01 rincewind Exp $
;****************************************************************************
; $Log: ll_io.s,v $
; Revision 1.7  2003/12/28 22:14:01  rincewind
; - fix CVS headers
;
; Revision 1.6  2003/12/28 20:49:00  rincewind
; - add PLX reset to IO functions
;
; Revision 1.2  2000/06/19 20:52:34  rincewind
; - misc cleanup
;****************************************************************************


            INCLUDE "regdef.inc"

            EXPORT  puts_mfp,put_mfp,get_mfp
            EXPORT  errno
            EXPORT  ioreadb, ioreadw, ioreadl
            EXPORT  iowriteb, iowritew, iowritel
            EXPORT  pci_confread, pci_confwrite
            EXPORT  pci_read_config, pci_write_config
            EXPORT  test_readb
            EXPORT  test_readw
            EXPORT  test_readl


            TEXT

puts_mfp:
            move.b  (a0)+,d0
            beq.s   puts2
puts3:      bsr.s   put_mfp
            bra.s   puts_mfp
puts2:      rts

put_mfp:    cmp.b   #10,d0
            bne.s   put_mfp3
            move.b  #13,d0                  ; Sequenz muž CR, LF sein
put_mfp3:
            btst    #7,MFP_TSR
            beq.s   put_mfp3
            move.b  d0,MFP_UDR
            cmp.b   #13,d0
            bne.s   put_mfp2
            moveq   #10,d0
            bra.s   put_mfp3
put_mfp2:
            rts


get_mfp:    btst    #7,MFP_RSR
            beq.s   get_mfp
            move.b  MFP_UDR,d0
            rts

ioreadb:    eor.b   #3,d0
            add.l   #ISA_IOBASE,d0
            move.l  d0,a0
            move.b  (a0),d0
            move.w  #%1111100100000000,PLX_BASE+4 ; reset status
            rts

ioreadw:    eor.b   #2,d0
            add.l   #ISA_IOBASE,d0
            move.l  d0,a0
            move.w  (a0),d0
            move.w  #%1111100100000000,PLX_BASE+4 ; reset status
            rts

ioreadl:    add.l   #ISA_IOBASE,d0
            move.l  d0,a0
            move.l  (a0),d0
            move.w  #%1111100100000000,PLX_BASE+4 ; reset status
            rts

iowriteb:   eor.b   #3,d0
            add.l   #ISA_IOBASE,d0
            move.l  d0,a0
            move.b  d1,(a0)
            move.w  #%1111100100000000,PLX_BASE+4 ; reset status
            rts

iowritew:   eor.b   #2,d0
            add.l   #ISA_IOBASE,d0
            move.l  d0,a0
            move.w  d1,(a0)
            move.w  #%1111100100000000,PLX_BASE+4 ; reset status
            rts

iowritel:   add.l   #ISA_IOBASE,d0
            move.l  d0,a0
            move.l  d1,(a0)
            move.w  #%1111100100000000,PLX_BASE+4 ; reset status
            rts

pci_confread:
            bset    #31,d0
            and.l   #!3,d0
            move.l  d0,PLX_DMCFGA
            move.l  ISA_IOBASE,d0
            move.w  #%1111100100000000,PLX_BASE+4
            move.l  #0,PLX_DMCFGA
            rts

pci_confwrite:
            bset    #31,d0
            and.l   #!3,d0
            move.l  d0,PLX_DMCFGA
            move.l  d1,ISA_IOBASE
            move.w  #%1111100100000000,PLX_BASE+4
            move.l  #0,PLX_DMCFGA
            rts

            ALIGN   16
test_readb:
            movem.l d1-d2/a0-a1,-(sp)
            move.l  d0,a1
            lea     $fffe008c,a0
            moveq.l #2,d1
            moveq.l #0,d2

            move.l  d1,(a0)
            move.b  (a1),d0
            move.l  d2,(a0)

            movem.l (sp)+,d1-d2/a0-a1
            rts

            ALIGN   16
test_readw:
            movem.l d1-d2/a0-a1,-(sp)
            move.l  d0,a1
            lea     $fffe008c,a0
            moveq.l #2,d1
            moveq.l #0,d2

            move.l  d1,(a0)
            move.w  (a1),d0
            move.l  d2,(a0)

            movem.l (sp)+,d1-d2/a0-a1
            rts

            ALIGN   16
test_readl:
            movem.l d1-d2/a0-a1,-(sp)
            move.l  d0,a1
            lea     $fffe008c,a0
            moveq.l #2,d1
            moveq.l #0,d2

            move.l  d1,(a0)
            move.l  (a1),d0
            move.l  d2,(a0)

            movem.l (sp)+,d1-d2/a0-a1
            rts

;ULONG pci_read_config(int bus,   D0
;                      int dev,   D1
;                      int fct,   D2
;                      int adr);  4(sp)
pci_read_config:
            and.w   #%1111100,4(sp)
            and.l   #%111,d2
            and.l   #%11111,d1
            and.l   #%11111111,d0

            lsl.w   #8,d2                   ; Function Bit 8..10
            or.w    4(sp),d2
            lsl.l   #8,d1
            lsl.l   #3,d1                   ; device Bit 11..15
            or.l    d1,d2
            swap    d0                      ; lsl.l #16,d0
            or.l    d0,d2                   ; Bus Bit 16..23
            bset    #31,d2

            move.w  #%1111100100000000,PLX_BASE+4 ; reset status
            move.l  d2,PLX_DMCFGA
            move.l  ISA_IOBASE,d0
            move.w  PLX_BASE+4,d1           ; get status
            move.w  #%1111100100000000,PLX_BASE+4 ; reset status
            moveq   #0,d2
            move.l  d2,PLX_DMCFGA           ; back to non-config cycle
;           and.w   #%0011000000000000,d1
            btst    #13,d1                  ; Master Abort?
            beq.s   pci_read_config2
            moveq   #-1,d0                  ; error: return $FFFFFFFF
pci_read_config2:
            rts

;void pci_write_config(int bus,       D0
;                      int dev,       D1
;                      int fct,       D2
;                      int adr,       4(sp)
;                      ULONG value);  6(sp)
pci_write_config:
            and.w   #%1111100,4(sp)
            and.l   #%111,d2
            and.l   #%11111,d1
            and.l   #%11111111,d0
            lsl.w   #8,d2                   ; Function Bit 8..10
            or.w    4(sp),d2
            lsl.l   #8,d1
            lsl.l   #3,d1                   ; device Bit 11..15
            or.l    d1,d2
            swap    d0                      ; lsl.l #16,d0
            or.l    d0,d2                   ; Bus Bit 16..23
            bset    #31,d2

            move.l  d2,PLX_DMCFGA

            move.l  6(sp),ISA_IOBASE
            move.w  #%1111100100000000,PLX_BASE+4 ; reset status
            moveq   #0,d0
            move.l  d0,PLX_DMCFGA           ; back to non-config cycle
            rts

            BSS
errno:      ds.l    1
