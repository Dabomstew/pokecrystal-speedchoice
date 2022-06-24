PermaOptionsP2String::
	db "BETTER ENC. SLOTS<LF>"
	db "        :<LF>"
	db "EXPERIENCE<LF>"
	db "        :<LF>"
	db "EXP SPLITTING<LF>"
	db "        :<LF>"
	db "CATCH EXP<LF>"
	db "        :<LF>"
	db "BETTER MARTS<LF>"
	db "        :<LF>"
	db "GOOD EARLY WILDS<LF>"
	db "        :<LF>"
	db "RACE GOAL<LF>"
	db "        :@"

PermaOptionsP2Pointers::
	dw Options_BetterEncSlots
	dw Options_EXP
	dw Options_EXPSplitting
	dw Options_CatchEXP
	dw Options_BetterMarts
	dw Options_GoodEarlyWilds
	dw Options_RaceGoal
	dw Options_PermaOptionsPage
PermaOptionsP2PointersEnd::

Options_BetterEncSlots:
	ld hl, BETTER_ENC_SLOTS_ADDRESS
	lb bc, BETTER_ENC_SLOTS, 3
	jp Options_OnOff

Options_EXP:
	ld hl, .Data
	jp Options_Multichoice

.Data:
	multichoiceoptiondata EXP_FORMULA_ADDRESS, EXP_FORMULA, EXP_FORMULA_SIZE, 5, NUM_OPTIONS, .Strings
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
	multichoiceoptiondata EXP_SPLITTING_ADDRESS, EXP_SPLITTING, EXP_SPLITTING_SIZE, 7, NUM_OPTIONS, .Strings
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
	lb bc, CATCH_EXP, 9
	jp Options_OnOff

Options_BetterMarts:
	ld hl, BETTER_MARTS_ADDRESS
	lb bc, BETTER_MARTS, 11
	jp Options_OnOff_IRLocked

Options_GoodEarlyWilds:
	ld hl, EVOLVED_EARLY_WILDS_ADDRESS
	lb bc, EVOLVED_EARLY_WILDS, 13
	jp Options_OnOff

Options_RaceGoal:
	ld hl, .Data
	jp Options_Multichoice

.Data:
	multichoiceoptiondata RACEGOAL_ADDRESS, RACEGOAL, RACEGOAL_SIZE, 15, NUM_OPTIONS, .Strings
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
