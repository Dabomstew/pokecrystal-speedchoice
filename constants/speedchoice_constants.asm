; macros for options
optionbyte = 0
optiontype = 0
optionbytestart: MACRO
optionbyte = optionbyte + 1
optionbit = 0
ENDM

nextoptiontype: MACRO
optiontype = optiontype + 1
optionbyte = 0
optionbit = 0
ENDM

sboption: MACRO
\1 EQU optionbit
\1_SCRIPT EQU (optionbyte - 1)*8 + optionbit
\1_VAL EQU (1 << optionbit)
IF optiontype == 0
\1_ADDRESS EQUS "wOptions + {optionbyte} - 1"
ELSE
\1_ADDRESS EQUS "wPermanentOptions + {optionbyte} - 1"
ENDC
optionbit = optionbit + 1
ENDM

mboption: MACRO
\1 EQU optionbit
\1_SCRIPT EQU (optionbyte - 1)*8 + optionbit
\1_SIZE EQU \2
\1_MASK EQU (1 << (optionbit + \2)) - (1 << optionbit)
IF optiontype == 0
\1_ADDRESS EQUS "wOptions + {optionbyte} - 1"
ELSE
\1_ADDRESS EQUS "wPermanentOptions + {optionbyte} - 1"
ENDC
optionbit = optionbit + \2
ENDM

; z if option off, nz if option on
sboptioncheck: MACRO
	ld a, [\1_ADDRESS]
	bit \1, a
ENDM

; nz if selection does not match, z if selection matches (careful of difference vs above!)
mboptioncheck: MACRO
	ld a, [\1_ADDRESS]
	and \1_MASK
	cp \1_\2 << \1
ENDM

; load a multi bit option but don't check for a specific value yet
mboptionload: MACRO
	ld a, [\1_ADDRESS]
	and \1_MASK
ENDM

pushalloptions: MACRO
obtemp = 0
	rept NUM_OPTIONS_BYTES
	ld a, [wOptions + obtemp]
	push af
obtemp = obtemp + 1
	endr
ENDM

popalloptions: MACRO
obtemp = NUM_OPTIONS_BYTES - 1
	rept NUM_OPTIONS_BYTES
	pop af
	ld [wOptions + obtemp], a
obtemp = obtemp - 1
	endr
ENDM

; wOptions:
	optionbytestart
	mboption TEXT_SPEED, 2
	sboption NO_TEXT_SCROLL ; 2
	sboption BATTLE_SHIFT ; 3
	sboption BATTLE_SHOW_ANIMATIONS ; 4
	sboption HOLD_TO_MASH ; 5
	sboption STEREO ; 6
	sboption MENU_ACCOUNT ; 7

TEXT_SPEED_INSTANT EQU %00
TEXT_SPEED_FAST    EQU %01
TEXT_SPEED_MEDIUM  EQU %10
TEXT_SPEED_SLOW    EQU %11

	optionbytestart
	mboption TEXT_FRAME, 4
	sboption PARKBALL_EFFECT ; 4
	sboption DISABLE_BIKE_MUSIC ; 5
	sboption DISABLE_SURF_MUSIC ; 6
	sboption SKIP_NICKNAMING ; 7

NUM_TEXTBOX_FRAMES EQU 10

NUM_OPTIONS_BYTES EQU optionbyte

; permaoptions
	nextoptiontype
	optionbytestart
	sboption ROCKETLESS
	mboption SPINNERS, 2 ; 1
	sboption MAX_RANGE ; 3
	sboption NERF_HMS ; 4
	sboption BETTER_ENC_SLOTS ; 5
	mboption EXP_FORMULA, 2 ; 6

EXP_FORMULA_NORMAL     EQU %00
EXP_FORMULA_BLACKWHITE EQU %01
EXP_FORMULA_NO_EXP     EQU %10

SPINNERS_NORMAL EQU %00
SPINNERS_NONE   EQU %01
SPINNERS_HELL   EQU %10
SPINNERS_WHY    EQU %11

SPINNERHELL EQU SPINNERS + 1
SPINNERHELL_VAL EQU (1 << SPINNERHELL)

SPINNERHELL_NORMAL_SPEED EQU %1111
SPINNERHELL_WHY_SPEED EQU %11

MAX_RANGE_VALUE EQU 5

	optionbytestart
	sboption BETTER_MARTS
	sboption EVOLVED_EARLY_WILDS ; 1
	mboption RACEGOAL, 2 ; 2
	sboption EARLY_KANTO ; 4
	sboption EASY_TIN_TOWER ; 5
	mboption EXP_SPLITTING, 2 ; 6

EVOLVED_EARLY_WILDS_MAX_LEVEL EQU 9

RACEGOAL_NONE      EQU %00
RACEGOAL_ELITEFOUR EQU %01
RACEGOAL_RED       EQU %10

EXP_SPLITTING_VANILLA EQU %00
EXP_SPLITTING_GEN67   EQU %01
EXP_SPLITTING_GEN8    EQU %10

	optionbytestart
	sboption CATCH_EXP
	sboption METRONOME_ONLY ; 1
	sboption DEX_AREA_BEEP ; 2
	sboption ROD_ALWAYS_SUCCEEDS ; 3
	sboption FAST_EGG_GENERATION ; 4
	sboption FAST_EGG_HATCHING ; 5
	sboption START_WITH_BIKE ; 6
	sboption EASY_CLAIR_BADGE ; 7
	
	optionbytestart
	sboption EARLY_KANTO_DEX ; 0
	sboption EVOLVE_EVERY_LEVEL ; 1
	sboption NO_HAPPY_EVO ; 2
	sboption GUARANTEED_CATCH ; 3
	sboption REMOVE_ANIMATIONS ; 4
	sboption BIKE_INDOORS ;5
	sboption FAST_REPEL ; 6

NUM_PERMAOPTIONS_BYTES EQU optionbyte

; hTimerType:
TIMER_OVERWORLD EQU 0
TIMER_BATTLE EQU 1
TIMER_MENUS EQU 2
TIMER_INTROS EQU 3
