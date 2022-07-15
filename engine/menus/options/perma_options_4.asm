PermaOptionsP4String::
	db "EARLY KANTO DEX<LF>"
	db "        :<LF>"
	db "START WITH BIKE<LF>"
	db "        :<LF>"
	db "METRONOME ONLY<LF>"
	db "        :<LF>"
	db "HAPPINESS EVO<LF>"
	db "        :@"

PermaOptionsP4Pointers::
	dw Options_EarlyKantoDex
	dw Options_StartWithBike
	dw Options_MetronomeOnly
	dw Options_HappinessEvo
	dw Options_PermaOptionsPage
PermaOptionsP4PointersEnd::

Options_EarlyKantoDex:
	ld hl, EARLY_KANTO_DEX_ADDRESS
	lb bc, EARLY_KANTO_DEX, 3
	jp Options_OnOff

Options_StartWithBike:
	ld hl, START_WITH_BIKE_ADDRESS
	lb bc, START_WITH_BIKE, 5
	jp Options_OnOff

Options_MetronomeOnly:
	ld hl, METRONOME_ONLY_ADDRESS
	lb bc, METRONOME_ONLY, 7
	jp Options_OnOff

Options_HappinessEvo:
	ld hl, HAPPINESS_EVO_ADDRESS
	lb bc, HAPPINESS_EVO, 9
	ld de, .ChangeKeep
	jp Options_TrueFalse
.ChangeKeep
	dw .Change
	dw .Keep

.Change
	db "CHANGE@"
.Keep
	db "KEEP  @"