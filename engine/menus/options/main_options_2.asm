MainOptionsP2String::
	db "PARKBALL EFFECT<LF>"
	db "        :@"

MainOptionsP2Pointers::
	dw Options_ParkBallEffect
	dw Options_OptionsPage
MainOptionsP2PointersEnd::

Options_ParkBallEffect:
	ld hl, PARKBALL_EFFECT_ADDRESS
	ld b, PARKBALL_EFFECT
	ld c, 3
	jp Options_OnOff
