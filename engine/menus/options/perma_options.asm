PermaOptionsP1String::
	db "PRESET (A: SET)<LF>"
	db "        :<LF>"
	db "PLAYER NAME<LF>"
	db "        :<LF>"
	db "GENDER<LF>"
	db "        :<LF>"
	db "RIVAL NAME<LF>"
	db "        :<LF>"
	db "RACE GOAL<LF>"
	db "        :@"

PermaOptionsP1Pointers::
	dw Options_Preset
	dw Options_PlayerName
	dw Options_PlayerGender
	dw Options_RivalName
	dw Options_RaceGoal
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
	permaoptionspreset Preset_VanillaName, 0, RACEGOAL_RED << RACEGOAL, 0, 0
	; Bingo
	permaoptionspreset Preset_BingoName, ROCKETLESS_VAL | (SPINNERS_NONE << SPINNERS) | BETTER_ENC_SLOTS_VAL | (EXP_FORMULA_BLACKWHITE << EXP_FORMULA), BETTER_MARTS_VAL | EASY_TIN_TOWER_VAL, EASY_CLAIR_BADGE_VAL, 0
	; 251
	permaoptionspreset Preset_CEAName, ROCKETLESS_VAL | (SPINNERS_NONE << SPINNERS) | BETTER_ENC_SLOTS_VAL | (EXP_FORMULA_BLACKWHITE << EXP_FORMULA), BETTER_MARTS_VAL | EASY_TIN_TOWER_VAL | (RACEGOAL_RED << RACEGOAL), EASY_CLAIR_BADGE_VAL, 0
	; KIR
	permaoptionspreset Preset_KIRName, (SPINNERS_NONE << SPINNERS) | BETTER_ENC_SLOTS_VAL | (EXP_FORMULA_BLACKWHITE << EXP_FORMULA), BETTER_MARTS_VAL | EVOLVED_EARLY_WILDS_VAL | (RACEGOAL_RED << RACEGOAL), EASY_CLAIR_BADGE_VAL, EARLY_KANTO_DEX_VAL
PermaOptionsPresetsEnd:

Preset_VanillaName:
	db "VANILLA @"
Preset_BingoName:
	db "BINGO   @"
Preset_CEAName:
	db "251 RACE@"
Preset_KIRName:
	db "ITEMRAND@"

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

Options_PlayerName:
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

Options_RivalName:
	and A_BUTTON
	jr z, .GetText
	ld a, [wJumptableIndex]
	push af
	ld b, 2
	ld de, wRivalName
	callba NamingScreen
	call DrawOptionsMenu
	pop af
	ld [wJumptableIndex], a
.GetText
	ld de, wRivalName
	ld a, [de]
	cp "@"
	jr nz, .Display
	ld de, .NotSetString
.Display
	hlcoord 11, 9
	call PlaceString
	and a
	ret
.NotSetString
	db "NOT SET@"

Options_RaceGoal:
	ld hl, .Data
	jp Options_Multichoice

.Data:
	multichoiceoptiondata RACEGOAL_ADDRESS, RACEGOAL, RACEGOAL_SIZE, 11, NUM_OPTIONS, .Strings
.Strings:
	dw .Manual
	dw .E4
	dw .Red
.Strings_End:

.Manual
	db "MANUAL@"
.E4
	db "E4    @"
.Red
	db "RED   @"