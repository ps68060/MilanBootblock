;****************************************************************************
; $Id: regdef.inc,v 1.12 2003/12/28 22:14:02 rincewind Exp $
;****************************************************************************
; $Log: regdef.inc,v $
; Revision 1.12  2003/12/28 22:14:02  rincewind
; - fix CVS headers
;
; Revision 1.2  2000/06/19 20:52:34  rincewind
; - misc cleanup
;****************************************************************************

; Speicherbelegung:
; $   700 Bootblock-Variablen, BSS des Bootblocks
; $0A0000-      Kopie des Bootblocks im RAM (64k)
; $E00000 TOS

;RomCopyTarget EQU $030000
BootBlockTarget   EQU     $0A0000
TosTarget         EQU     $E00000         ; Endgltige Lage des TOS im RAM
TosLoadBuffer     EQU     $F00000         ; Puffer fr komprimiertes TOS
MallocBuffer      EQU     $F80000         ; Puffer fr Malloc w„hrend unzip

BIG_ENDIAN        EQU     0

; Die alten Basisadressen
;PLX_BASE         EQU     $FFFE0000
;MEMCTRL          EQU     $FFFEC003
;MFP_BASE         EQU     $FFFE8003
; Die neuen Basisadressen
PLX_BASE          EQU     $FFFFC200
MEMCTRL           EQU     $FFFFC003
WAITCTRL          EQU     $FFFFC007
MFP_BASE          EQU     $FFFFC103

ISA_IOBASE        EQU     $80000000
PCI_MEMBASE       EQU     $40000000
ISA_ROMBASE       EQU     $00080000
TosLen            EQU     $00080000

; Transparent Translation Register fr den normalen Betrieb
; PCI I/O Bereich ab 2GB mit 1GB, Range NoCache, serialized
; Bit 8 - U0 gesetzt -> Little endian
R_DTTR0           EQU     $803FE140
; PCI Memory Bereich ab 1GB mit 1GB Range, Writethrough
R_DTTR1           EQU     $403FE000
; Die ITTR werden zur Sicherheit wie die DTTR gesetzt
R_ITTR0           EQU     $803FE040
R_ITTR1           EQU     $403FE000

;POSTCODE         EQU     ISA_IOBASE + $83

PLX_PCIIDR        EQU     PLX_BASE + $00
PLX_PCICR         EQU     PLX_BASE + $04
PLX_PCIBAR0       EQU     PLX_BASE + $10
PLX_PCIBAR1       EQU     PLX_BASE + $14
PLX_PCIBAR2       EQU     PLX_BASE + $18
PLX_PCIBAR3       EQU     PLX_BASE + $1C
PLX_PCIBAR4       EQU     PLX_BASE + $20
PLX_PCIBAR5       EQU     PLX_BASE + $24
PLX_PCIERBAR      EQU     PLX_BASE + $30
PLX_PCIINTLAT     EQU     PLX_BASE + $3C
PLX_LAS0RR        EQU     PLX_BASE + $80
PLX_LAS0BA        EQU     PLX_BASE + $84
PLX_LARBR         EQU     PLX_BASE + $88
PLX_BIGEND        EQU     PLX_BASE + $8C
PLX_EROMRR        EQU     PLX_BASE + $90
PLX_EROMBA        EQU     PLX_BASE + $94
PLX_LBRD0         EQU     PLX_BASE + $98
PLX_DMRR          EQU     PLX_BASE + $9C
PLX_DMLBAM        EQU     PLX_BASE + $A0
PLX_DMLBAI        EQU     PLX_BASE + $A4
PLX_DMPBAM        EQU     PLX_BASE + $A8
PLX_DMCFGA        EQU     PLX_BASE + $AC
PLX_LAS1RR        EQU     PLX_BASE + $170
PLX_LAS1BA        EQU     PLX_BASE + $174
PLX_LBRD1         EQU     PLX_BASE + $178
PLX_INTCSR        EQU     PLX_BASE + $E8
PLX_CNTRL         EQU     PLX_BASE + $EC

MFP_GPIP          EQU     MFP_BASE +$00 ; ST: FFFFFA01
MFP_AER           EQU     MFP_BASE +$04 ; ST: FFFFFA03
MFP_DDR           EQU     MFP_BASE +$08 ; ST: FFFFFA05
MFP_IERA          EQU     MFP_BASE +$0C ; ST: FFFFFA07
MFP_IERB          EQU     MFP_BASE +$10 ; ST: FFFFFA09
MFP_IPRA          EQU     MFP_BASE +$14 ; ST: FFFFFA0B
MFP_IPRB          EQU     MFP_BASE +$18 ; ST: FFFFFA0D
MFP_ISRA          EQU     MFP_BASE +$1C ; ST: FFFFFA0F
MFP_ISRB          EQU     MFP_BASE +$20 ; ST: FFFFFA11
MFP_IMRA          EQU     MFP_BASE +$24 ; ST: FFFFFA13
MFP_IMRB          EQU     MFP_BASE +$28 ; ST: FFFFFA15
MFP_VR            EQU     MFP_BASE +$2C ; ST: FFFFFA17
MFP_TACR          EQU     MFP_BASE +$30 ; ST: FFFFFA19
MFP_TBCR          EQU     MFP_BASE +$34 ; ST: FFFFFA1B
MFP_TCDCR         EQU     MFP_BASE +$38 ; ST: FFFFFA1D
MFP_TADR          EQU     MFP_BASE +$3C ; ST: FFFFFA1F
MFP_TBDR          EQU     MFP_BASE +$40 ; ST: FFFFFA21
MFP_TCDR          EQU     MFP_BASE +$44 ; ST: FFFFFA23
MFP_TDDR          EQU     MFP_BASE +$48 ; ST: FFFFFA25
MFP_SCR           EQU     MFP_BASE +$4C ; ST: FFFFFA27
MFP_UCR           EQU     MFP_BASE +$50 ; ST: FFFFFA29
MFP_RSR           EQU     MFP_BASE +$54 ; ST: FFFFFA2B
MFP_TSR           EQU     MFP_BASE +$58 ; ST: FFFFFA2D
MFP_UDR           EQU     MFP_BASE +$5C ; ST: FFFFFA2F

; MEMCTRLxA:
; 0 EQU 0MB
; 1 EQU 4MB
; 2 EQU 16MB
; 3 EQU 64MB
; MEMCTRLxB:
; 0 EQU eine Bank
; 1 EQU 2 B„nke (Kapazit„t*2)

;MEMCTRL0A EQU MEMCTRL
;MEMCTRL0B EQU MEMCTRL+4
;MEMCTRL1A EQU MEMCTRL+8
;MEMCTRL1B EQU MEMCTRL+12
;MEMCTRL2A EQU MEMCTRL+16
;MEMCTRL2B EQU MEMCTRL+20
;MEMCTRL3A EQU MEMCTRL+24
;MEMCTRL3B EQU MEMCTRL+28

                  IF      BIG_ENDIAN
BYTE_ADR_MASK     EQU     0
WORD_ADR_MASK     EQU     0
                  ELSE
BYTE_ADR_MASK     EQU     3
WORD_ADR_MASK     EQU     2
                  ENDIF

RTC_REGSEL        EQU     (ISA_IOBASE + ($70^BYTE_ADR_MASK))
RTC_DATA          EQU     (ISA_IOBASE + ($71^BYTE_ADR_MASK))

                  .MACRO  IOWB data,adr
                  move.b  data,adr^(BYTE_ADR_MASK)(A5)
                  .ENDM

                  .MACRO  IOWB2 data,adr
                  move.b  data,(adr^(BYTE_ADR_MASK)) + ISA_IOBASE
                  .ENDM

                  .MACRO  IOWW data,adr
                  move.w  data,adr^(WORD_ADR_MASK)(A5)
                  .ENDM

                  .MACRO  IORB adr,dest
                  move.b  adr^(BYTE_ADR_MASK)(A5),dest
                  .ENDM

                  .MACRO  IORB2 adr,dest
                  move.b  (adr^(BYTE_ADR_MASK)) + ISA_IOBASE,dest
                  .ENDM

                  .MACRO  IORW adr,dest
                  move.w  adr^(WORD_ADR_MASK)(A5),dest
                  .ENDM

                  .MACRO  POSTCODE val
                  move.b  val,$80^BYTE_ADR_MASK(A5)
                  nop     ; wait for bus operation to complete
                  .ENDM

                  .MACRO  POSTCODE2 val
                  move.b  val,($80^BYTE_ADR_MASK) + ISA_IOBASE
                  nop     ; wait for bus operation to complete
                  .ENDM

                  .MACRO  CALLA6 adr
                  .LOCAL  ret
                  lea     ret(pc),a6
                  bra     adr
ret:
                  .ENDM

;FalconStatus     EQU -$7FFA
;ROM_Port         EQU $FA0000

;ACIA_KEYCTL      EQU -$400
;ACIA_KEYBD       EQU -$3FE
;ACIA_MIDICTL     EQU -$3FC
;ACIA_MIDID       EQU -$3FA

vec_berr          EQU     $08
vec_adrerr        EQU     $0C
vec_illeg         EQU     $10
vec_divzero       EQU     $14
vec_priv          EQU     $20
vec_linea         EQU     $28
vec_linef         EQU     $2C
vec_int1          EQU     $64
vec_hbl           EQU     $68
vec_int3          EQU     $6c
vec_vbl           EQU     $70
vec_int5          EQU     $74
vec_isaint        EQU     $74
vec_int6          EQU     $78
vec_nmi           EQU     $7c
vec_trap0         EQU     $80
vec_trap1         EQU     $84
vec_trap2         EQU     $88
vec_trap3         EQU     $8c
vec_trap4         EQU     $90
vec_trap5         EQU     $94
vec_trap6         EQU     $98
vec_trap7         EQU     $9c
vec_trap8         EQU     $a0
vec_trap9         EQU     $a4
vec_trap10        EQU     $a8
vec_trap11        EQU     $ac
vec_trap12        EQU     $b0
vec_trap13        EQU     $b4
vec_trap14        EQU     $b8
vec_trap15        EQU     $bc

etv_timer         EQU     $400
etv_critic        EQU     $404
etv_term          EQU     $408
memvalid          EQU     $420
memcntrl          EQU     $424
resvalid          EQU     $426
resvector         EQU     $42A
phystop           EQU     $42E
_membot           EQU     $432
memval2           EQU     $43A
_memtop           EQU     $436
seekrate          EQU     $440
_timr_ms          EQU     $442
_fverify          EQU     $444
_bootdev          EQU     $446
sshiftmd          EQU     $44c
_v_bas_ad         EQU     $44E
vblsem            EQU     $452
nvbls             EQU     $454
_vblqueue         EQU     $456
colorptr          EQU     $45A
screenpt          EQU     $45E
_vbclock          EQU     $462
_frclock          EQU     $466
swv_vec           EQU     $46E
hdv_bpb           EQU     $472
hdv_init          EQU     $46A
hdv_rw            EQU     $476
hdv_boot          EQU     $47A
hdv_mediach       EQU     $47E
_cmdload          EQU     $482
conterm           EQU     $484
savptr            EQU     $4A2
_hz_200           EQU     $4BA
_drvbits          EQU     $4C2
_dskbufp          EQU     $4C6
_vbl_list         EQU     $4CE
prt_cnt           EQU     $4EE
_sysbase          EQU     $4F2
end_os            EQU     $4FA
exec_os           EQU     $4FE
scr_dump          EQU     $502
prv_lsto          EQU     $506
prv_lst           EQU     $50A
prv_auxo          EQU     $50E
prv_aux           EQU     $512
memval3           EQU     $51A
xconstat          EQU     $51E
xconin            EQU     $53E
xcostat           EQU     $55E
xconout           EQU     $57E
_longframe        EQU     $59E
remtop            EQU     $5A4            ; l
remvalid          EQU     $5A8
bell_hook         EQU     $5AC
_p_cookies        EQU     $5A0
kcl_hook          EQU     $5B0
saveptr_vec       EQU     $93A
cookie_vec        EQU     $980
aux_iorec         EQU     $F72
key_iorec         EQU     $F96
midi_iorec        EQU     $10A4
KeyErrorVec       EQU     $113A
MidiErrorVec      EQU     $113E
IKBDstatusVec     EQU     $1142
MouseVec          EQU     $1146
JdostimeVec       EQU     $114A
JoyVec            EQU     $114E
kbshift_val       EQU     $1187
keytab_normal     EQU     $1188
keytab_shift      EQU     $118C
keytab_capslock   EQU     $1190
keytab_alt        EQU     $1194
keytab_shiftalt   EQU     $1198
keytab_capsalt    EQU     $119C
KeyboardDelay1    EQU     $11B4
KeyboardDelay2    EQU     $11B5
PrinterTimeout    EQU     $11B6
SoundPointer      EQU     $11BC
DelayTimer        EQU     $11C0
TempValue         EQU     $11C1
bconmap_current_port EQU  $11CC
bconmap_ptr       EQU     $11C6           ; Zeiger auf BCONMAP-Struct
bconmap_size      EQU     $11CA           ; Anzahl Eintr„ge in BCONMAP->maptab
cur_aux_rsconf    EQU     $11CE
cur_aux_iorec     EQU     $11D2
bconmap_struct    EQU     $11D6           ; BCONMAP->maptab
scc1_iorec        EQU     $1436
scc0_iorec        EQU     $165A

current_videomode EQU     $184C
; Konstanten
                  memmagic  = $752019F3
                  memmagic2 = $237698AA
                  memmagic3 = $5555AAAA
                  remmagic  = $1357BD13

;BiosStack  EQU $8870

