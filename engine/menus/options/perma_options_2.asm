PermaOptionsP2String::
	db "ROCKET SECTIONS<LF>"
	db "        :<LF>"
	db "SPINNERS<LF>"
	db "        :<LF>"
	db "TRAINER VISION<LF>"
	db "        :<LF>"
	db "BETTER ENC. SLOTS<LF>"
	db "        :<LF>"
	db "EXPERIENCE<LF>"
	db "        :<LF>"
	db "EXP SPLITTING<LF>"
	db "        :<LF>"
	db "CATCH EXP<LF>"
	db "        :@"

PermaOptionsP2Pointers::
	dw Options_Rocketless
	dw Options_Spinners
	dw Options_TrainerVision
	dw Options_BetterEncSlots
	dw Options_EXP
	dw Options_EXPSplitting
	dw Options_CatchEXP
	dw Options_PermaOptionsPage
PermaOptionsP2PointersEnd::

Options_Rocketless:
	ld hl, ROCKETLESS_ADDRESS
	lb bc, ROCKETLESS, 3
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
	multichoiceoptiondata SPINNERS_ADDRESS, SPINNERS, SPINNERS_SIZE, 5, NUM_OPTIONS, .Strings

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
	lb bc, MAX_RANGE, 7
	ld de, .NormalMax
	jp Options_TrueFalse
.NormalMax
	dw .Normal
	dw .Max

.Normal
	db "NORMAL@"
.Max
	db "MAX   @"

Options_BetterEncSlots:
	ld hl, BETTER_ENC_SLOTS_ADDRESS
	lb bc, BETTER_ENC_SLOTS, 9
	jp Options_OnOff

Options_EXP:
	ld hl, .Data
	jp Options_Multichoice

.Data:
	multichoiceoptiondata EXP_FORMULA_ADDRESS, EXP_FORMULA, EXP_FORMULA_SIZE, 11, NUM_OPTIONS, .Strings
.Strings:
	dw .Normal
	dw .BW
	dw .None
.Strings_End:

.Normal
	db "NORMAL@"
.BW
	db "B/W   @"
.None
	db "NONE  @"

Options_EXPSplitting:
	ld hl, .Data
	jp Options_Multichoice

.Data:
	multichoiceoptiondata EXP_SPLITTING_ADDRESS, EXP_SPLITTING, EXP_SPLITTING_SIZE, 13, NUM_OPTIONS, .Strings
.Strings:
	dw .Normal
	dw .Gen67
	dw .Gen8
.Strings_End:

.Normal
	db "NORMAL @"
.Gen67
	db "GEN 6/7@"
.Gen8
	db "GEN 8  @"

Options_CatchEXP:
	ld hl, CATCH_EXP_ADDRESS
	lb bc, CATCH_EXP, 15
	jp Options_OnOff