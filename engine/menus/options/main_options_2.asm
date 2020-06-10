MainOptionsP2String::
	db "PARKBALL EFFECT<LF>"
	db "        :@"

MainOptionsP2Pointers::
	dw Options_ParkBallEffect
	dw Options_OptionsPage
MainOptionsP2PointersEnd::

Options_ParkBallEffect:
	ld hl, PARKBALL_EFFECT_ADDRESS
	lb bc, PARKBALL_EFFECT, 3
	jp Options_OnOff
