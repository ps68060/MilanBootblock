;****************************************************************************
; $Id: x86_regs.inc,v 1.3 2003/12/28 22:14:16 rincewind Exp $
;****************************************************************************
; $Log: x86_regs.inc,v $
; Revision 1.3  2003/12/28 22:14:16  rincewind
; - fix CVS headers
;
; Revision 1.2  2000/06/19 20:52:35  rincewind
; - misc cleanup
;****************************************************************************

; x86 Struktur mit offset 0x10 auf sys
.OFFSET     $10
X86Regs:
genregs:    ds.l    8
segregs:    ds.l    6
spcregs1:   ds.l    1
spcregs2:   ds.l    1
OverSeg:    ds.l    1
;mode:      ds.w    1
REP:        ds.w    1
intno:      ds.b    2
intr:       ds.w    1
shortcut:   ds.l    8                       ; Adressen fÅr 8 Bit Register

.OFFSET     genregs
EAX:        ds.b    2
AX:
AH:         ds.b    1
AL:         ds.b    1
ECX:        ds.b    2
CX:
CH:         ds.b    1
CL:         ds.b    1
EDX:        ds.b    2
DX:
DH:         ds.b    1
DL:         ds.b    1
EBX:        ds.b    2
BX:
BH:         ds.b    1
BL:         ds.b    1
ESP:        ds.b    2
SP:         ds.b    2
EBP:        ds.b    2
BP:         ds.b    2
ESI:        ds.b    2
SI:         ds.b    2
EDI:        ds.b    2
DI:         ds.b    2

.OFFSET     segregs
ES:         ds.l    1
CS:         ds.l    1
SS:         ds.l    1
DS:         ds.l    1
FS:         ds.l    1
GS:         ds.l    1

.OFFSET     spcregs1
EIP:        ds.b    2
IP:         ds.b    2

.OFFSET     spcregs2
EFlags:     ds.b    2
Flags:
HiFlags:    ds.b    1
LoFlags:    ds.b    1

