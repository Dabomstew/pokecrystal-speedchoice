PermaOptionsP3String::
	db "KANTO ACCESS<LF>"
	db "        :<LF>"
	db "EASY TIN TOWER<LF>"
	db "        :<LF>"
	db "EASY CLAIR BADGE<LF>"
	db "        :<LF>"
	db "DEX AREA BEEP<LF>"
	db "        :<LF>"
	db "RODS ALWAYS WORK<LF>"
	db "        :<LF>"
	db "FAST EGG MAKING<LF>"
	db "        :<LF>"
	db "FAST EGG HATCHING<LF>"
	db "        :@"

PermaOptionsP3Pointers::
	dw Options_KantoAccess
	dw Options_EasyTinTower
	dw Options_EasyClairBadge
	dw Options_DexAreaBeep
	dw Options_RodsAlwaysWork
	dw Options_FastEggMaking
	dw Options_FastEggHatching
	dw Options_PermaOptionsPage
PermaOptionsP3PointersEnd::

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

Options_EasyTinTower:
	ld hl, EASY_TIN_TOWER_ADDRESS
	lb bc, EASY_TIN_TOWER, 5
	jp Options_OnOff_IRLocked

Options_EasyClairBadge:
	ld hl, EASY_CLAIR_BADGE_ADDRESS
	lb bc, EASY_CLAIR_BADGE, 7
	jp Options_OnOff_IRLocked

Options_DexAreaBeep:
	ld hl, DEX_AREA_BEEP_ADDRESS
	lb bc, DEX_AREA_BEEP, 9
	jp Options_OnOff

Options_RodsAlwaysWork:
	ld hl, ROD_ALWAYS_SUCCEEDS_ADDRESS
	lb bc, ROD_ALWAYS_SUCCEEDS, 11
	jp Options_OnOff

Options_FastEggMaking:
	ld hl, FAST_EGG_GENERATION_ADDRESS
	lb bc, FAST_EGG_GENERATION, 13
	jp Options_OnOff

Options_FastEggHatching:
	ld hl, FAST_EGG_HATCHING_ADDRESS
	lb bc, FAST_EGG_HATCHING, 15
	jp Options_OnOff
