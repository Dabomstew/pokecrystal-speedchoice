PermaOptionsP4String::
	db "EARLY KANTO DEX<LF>"
	db "        :<LF>"
	db "START WITH BIKE<LF>"
	db "        :<LF>"
	db "METRONOME ONLY<LF>"
	db "        :<LF>"
	db "EVO EVERY LEVEL<LF>"
  db "        :<LF>"
	db "CHANGE HAPPY EVO<LF>"
	db "        :@"

PermaOptionsP4Pointers::
	dw Options_EarlyKantoDex
	dw Options_StartWithBike
	dw Options_MetronomeOnly
	dw Options_EvolveEveryLevel
	dw Options_NoHappyEvo
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

Options_EvolveEveryLevel:
	ld hl, EVOLVE_EVERY_LEVEL_ADDRESS
	lb bc, EVOLVE_EVERY_LEVEL, 9
  jp Options_OnOff

Options_NoHappyEvo:
	ld hl, NO_HAPPY_EVO_ADDRESS
	lb bc, NO_HAPPY_EVO, 11
	jp Options_OnOff