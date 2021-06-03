PermaOptionsP4String::
	db "KANTO ACCESS<LF>"
	db "        :<LF>"
	db "EARLY KANTO DEX<LF>"
	db "        :<LF>"
	db "DEX AREA BEEP<LF>"
	db "        :<LF>"
	db "GOOD EARLY WILDS<LF>"
	db "        :<LF>"
	db "NERF HMs<LF>"
	db "        :<LF>"
	db "METRONOME ONLY<LF>"
	db "        :@"

PermaOptionsP4Pointers::
	dw Options_KantoAccess
	dw Options_EarlyKantoDex
	dw Options_DexAreaBeep
	dw Options_GoodEarlyWilds
	dw Options_NerfHMs
	dw Options_MetronomeOnly
	dw Options_PermaOptionsPage
PermaOptionsP4PointersEnd::

Options_KantoAccess:
	ld hl, EARLY_KANTO_ADDRESS
	lb bc, EARLY_KANTO, 3
	ld de, .NormalEarly
	jp Options_TrueFalse_IRLocked
.NormalEarly
	dw .Normal
	dw .Early

.Normal
	db "NORMAL@"
.Early
	db "EARLY @"

Options_EarlyKantoDex:
	ld hl, EARLY_KANTO_DEX_ADDRESS
	lb bc, EARLY_KANTO_DEX, 5
	jp Options_OnOff

Options_DexAreaBeep:
	ld hl, DEX_AREA_BEEP_ADDRESS
	lb bc, DEX_AREA_BEEP, 7
	jp Options_OnOff

Options_GoodEarlyWilds:
	ld hl, EVOLVED_EARLY_WILDS_ADDRESS
	lb bc, EVOLVED_EARLY_WILDS, 9
	jp Options_OnOff

Options_NerfHMs:
	ld hl, NERF_HMS_ADDRESS
	ld a, [wRandomizedMovesStatus]
	dec a
	jr z, .normalCase
	dec a
	jr z, .randomizedMoves
; check whether move data is randomized
	ld hl, MovesHMNerfs
	ld a, BANK(MovesHMNerfs)
	ld bc, MOVE_LENGTH
	ld de, wStringBuffer5
	call FarCopyBytes
	ld hl, .PoundUnchanged
	ld de, wStringBuffer5
	ld c, MOVE_LENGTH
	call CompareBytes
	ld a, 1
	jr z, .write
	inc a
.write
	ld [wRandomizedMovesStatus], a
	jr Options_NerfHMs
.normalCase
	ldh a, [hJoyPressed]
	lb bc, NERF_HMS, 11
	ld de, .NoYes
	jp Options_TrueFalse
.randomizedMoves
	set NERF_HMS, [hl]
	ld de, .Randomized
	hlcoord 2, 15
	call PlaceString
	and a
	ret
.NoYes
	dw .No
	dw .Yes

.No
	db "NO @"
.Yes
	db "YES@"
.Randomized
	db "RANDOMIZED MOVES!@"
.PoundUnchanged
	move POUND,        EFFECT_NORMAL_HIT,         40, NORMAL,   100, 35,   0

Options_MetronomeOnly:
	ld hl, METRONOME_ONLY_ADDRESS
	lb bc, METRONOME_ONLY, 13
	jp Options_OnOff
