PermaOptionsP1String::
	db "PRESET (A: SET)<LF>"
	db "        :<LF>"
	db "NAME<LF>"
	db "        :<LF>"
	db "GENDER<LF>"
	db "        :<LF>"
	db "ROCKET SECTIONS<LF>"
	db "        :<LF>"
	db "SPINNERS<LF>"
	db "        :<LF>"
	db "TRAINER VISION<LF>"
	db "        :<LF>"
	db "NERF HMs<LF>"
	db "        :@"

PermaOptionsP1Pointers::
	dw Options_Preset
	dw Options_Name
	dw Options_PlayerGender
	dw Options_Rocketless
	dw Options_Spinners
	dw Options_TrainerVision
	dw Options_NerfHMs
	dw Options_PermaOptionsPage
PermaOptionsP1PointersEnd::

permaoptionspreset: MACRO
	dw \1
rept NUM_PERMAOPTIONS_BYTES
	db \2
	shift
endr
ENDM

PermaOptionsPresets:
	; Vanilla
	permaoptionspreset Preset_VanillaName, 0, RACEGOAL_RED << RACEGOAL, 0, REMOVE_ANIMATIONS_VAL
	; Bingo
	permaoptionspreset Preset_BingoName, ROCKETLESS_VAL | (SPINNERS_NONE << SPINNERS) | BETTER_ENC_SLOTS_VAL | (EXP_FORMULA_BLACKWHITE << EXP_FORMULA), BETTER_MARTS_VAL | EASY_TIN_TOWER_VAL, DEX_AREA_BEEP_VAL | ROD_ALWAYS_SUCCEEDS_VAL | FAST_EGG_GENERATION_VAL | FAST_EGG_HATCHING_VAL | EASY_CLAIR_BADGE_VAL , START_WITH_BIKE_VAL , BIKE_INDOORS_VAL
	; KIR
	permaoptionspreset Preset_KIRName, (SPINNERS_NONE << SPINNERS) | BETTER_ENC_SLOTS_VAL | (EXP_FORMULA_BLACKWHITE << EXP_FORMULA), BETTER_MARTS_VAL | EVOLVED_EARLY_WILDS_VAL | (RACEGOAL_RED << RACEGOAL), DEX_AREA_BEEP_VAL | ROD_ALWAYS_SUCCEEDS_VAL | FAST_EGG_GENERATION_VAL | FAST_EGG_HATCHING_VAL | EASY_CLAIR_BADGE_VAL, EARLY_KANTO_DEX_VAL | NO_HAPPY_EVO_VAL | BIKE_INDOORS_VAL | FAST_REPEL_VAL
	; Warp
	permaoptionspreset Preset_WarpName, (SPINNERS_NONE << SPINNERS) | BETTER_ENC_SLOTS_VAL | (EXP_FORMULA_BLACKWHITE << EXP_FORMULA), BETTER_MARTS_VAL | (RACEGOAL_RED << RACEGOAL), DEX_AREA_BEEP_VAL | ROD_ALWAYS_SUCCEEDS_VAL | FAST_EGG_GENERATION_VAL | START_WITH_BIKE_VAL | FAST_EGG_HATCHING_VAL | EASY_CLAIR_BADGE_VAL, EARLY_KANTO_DEX_VAL | NO_HAPPY_EVO_VAL | GUARANTEED_CATCH_VAL | BIKE_INDOORS_VAL | FAST_REPEL_VAL
PermaOptionsPresetsEnd:

Preset_VanillaName:
	db "VANILLA @"
Preset_BingoName:
	db "BINGO   @"
Preset_KIRName:
	db "ITEMRAND@"
Preset_WarpName:
	db "WARP    @"

Options_Preset::
	ld hl, wOptionsMenuPreset
	ld c, [hl]
	bit D_LEFT_F, a
	jr nz, .decr
	bit D_RIGHT_F, a
	jr nz, .incr
	bit A_BUTTON_F, a
	jr z, .print
	call .get_pointer
	inc hl
	inc hl
	ld b, NUM_PERMAOPTIONS_BYTES
	ld de, wPermanentOptions
.setloop
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .setloop
	call EnforceItemRandoOptions
	ld de, SFX_TRANSACTION
	call PlaySFX
	call WaitSFX
	call DrawOptionsMenuLagless_
	and a
	ret

.incr
	inc c
	ld a, c
	cp (PermaOptionsPresetsEnd - PermaOptionsPresets) / (NUM_PERMAOPTIONS_BYTES + 2)
	jr c, .okay
	ld c, 0
	jr .okay

.decr
	ld a, c
	dec c
	and a
	jr nz, .okay
	ld c, (PermaOptionsPresetsEnd - PermaOptionsPresets) / (NUM_PERMAOPTIONS_BYTES + 2) - 1
.okay
	ld [hl], c
.print
	call .get_pointer
	ld a, [hli]
	ld d, [hl]
	ld e, a
	hlcoord 11, 3
	call PlaceString
	and a
	ret

.get_pointer
	ld b, 0
	ld hl, PermaOptionsPresets
rept (NUM_PERMAOPTIONS_BYTES + 2)
	add hl, bc
endr
	ret

Options_Name:
	and A_BUTTON
	jr z, .GetText
	ld a, [wJumptableIndex]
	push af
	ld b, 1
	ld de, wPlayerName
	callba NamingScreen
	call DrawOptionsMenu
	pop af
	ld [wJumptableIndex], a
.GetText
	ld de, wPlayerName
	ld a, [de]
	cp "@"
	jr nz, .Display
	ld de, .NotSetString
.Display
	hlcoord 11, 5
	call PlaceString
	and a
	ret

.NotSetString
	db "NOT SET@"

Options_PlayerGender:
	ld hl, wPlayerGender
	lb bc, 0, 7 ; bit hardcoded as 0
	ld de, .MaleFemale
	jp Options_TrueFalse
.MaleFemale
	dw .Male
	dw .Female

.Male
	db "MALE  @"
.Female
	db "FEMALE@"

Options_Rocketless:
	ld hl, ROCKETLESS_ADDRESS
	lb bc, ROCKETLESS, 9
	ld de, .NormalPurge
	jp Options_TrueFalse_IRLocked
.NormalPurge
	dw .Normal
	dw .Purge

.Normal
	db "NORMAL@"
.Purge
	db "PURGE @"

Options_Spinners:
	ld hl, .Data
	jp Options_Multichoice

.Data:
	multichoiceoptiondata SPINNERS_ADDRESS, SPINNERS, SPINNERS_SIZE, 11, NUM_OPTIONS, .Strings

.Strings
	dw .Normal
	dw .Purge
	dw .Hell
	dw .Why
.Strings_End:

.Normal
	db "NORMAL@"
.Purge
	db "PURGE @"
.Hell
	db "HELL  @"
.Why
	db "WHY   @"

Options_TrainerVision:
	ld hl, MAX_RANGE_ADDRESS
	lb bc, MAX_RANGE, 13
	ld de, .NormalMax
	jp Options_TrueFalse
.NormalMax
	dw .Normal
	dw .Max

.Normal
	db "NORMAL@"
.Max
	db "MAX   @"

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
	lb bc, NERF_HMS, 15
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
