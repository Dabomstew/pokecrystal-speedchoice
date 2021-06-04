PermaOptionsP3String::
	db "BETTER MARTS<LF>"
	db "        :<LF>"
	db "EASY TIN TOWER<LF>"
	db "        :<LF>"
	db "EASY CLAIR BADGE<LF>"
	db "        :<LF>"
	db "RODS ALWAYS WORK<LF>"
	db "        :<LF>"
	db "FAST EGG MAKING<LF>"
	db "        :<LF>"
	db "FAST EGG HATCHING<LF>"
	db "        :<LF>"
	db "START WITH BIKE<LF>"
	db "        :@"
	
PermaOptionsP3Pointers::
	dw Options_BetterMarts
	dw Options_EasyTinTower
	dw Options_EasyClairBadge
	dw Options_RodsAlwaysWork
	dw Options_FastEggMaking
	dw Options_FastEggHatching
	dw Options_StartWithBike
	dw Options_PermaOptionsPage
PermaOptionsP3PointersEnd::

Options_BetterMarts:
	ld hl, BETTER_MARTS_ADDRESS
	lb bc, BETTER_MARTS, 3
	jp Options_OnOff

Options_EasyTinTower:
	ld hl, EASY_TIN_TOWER_ADDRESS
	lb bc, EASY_TIN_TOWER, 5
	jp Options_OnOff_IRLocked

Options_EasyClairBadge:
	ld hl, EASY_CLAIR_BADGE_ADDRESS
	lb bc, EASY_CLAIR_BADGE, 7
	jp Options_OnOff_IRLocked

Options_RodsAlwaysWork:
	ld hl, ROD_ALWAYS_SUCCEEDS_ADDRESS
	lb bc, ROD_ALWAYS_SUCCEEDS, 9
	jp Options_OnOff


Options_FastEggMaking:
	ld hl, FAST_EGG_GENERATION_ADDRESS
	lb bc, FAST_EGG_GENERATION, 11
	jp Options_OnOff

Options_FastEggHatching:
	ld hl, FAST_EGG_HATCHING_ADDRESS
	lb bc, FAST_EGG_HATCHING, 13
	jp Options_OnOff

Options_StartWithBike:
	ld hl, START_WITH_BIKE_ADDRESS
	lb bc, START_WITH_BIKE, 15
	jp Options_OnOff