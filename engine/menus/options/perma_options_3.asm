PermaOptionsP3String::
	db "KANTO ACCESS<LF>"
	db "        :<LF>"
	db "EASY TIN TOWER<LF>"
	db "        :@"

PermaOptionsP3Pointers::
	dw Options_KantoAccess
	dw Options_EasyTinTower
	dw Options_PermaOptionsPage
PermaOptionsP3PointersEnd::

Options_KantoAccess:
	ld hl, EARLY_KANTO_ADDRESS
	lb bc, EARLY_KANTO, 3
	ld de, .NormalEarly
	jp Options_TrueFalse
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
	jp Options_OnOff
