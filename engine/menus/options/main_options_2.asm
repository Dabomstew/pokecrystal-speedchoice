MainOptionsP2String::
	db "PARKBALL EFFECT<LF>"
	db "        :<LF>"
	db "BIKE MUSIC<LF>"
	db "        :@"

MainOptionsP2Pointers::
	dw Options_ParkBallEffect
	dw Options_BikeMusic
	dw Options_OptionsPage
MainOptionsP2PointersEnd::

Options_ParkBallEffect:
	ld hl, PARKBALL_EFFECT_ADDRESS
	lb bc, PARKBALL_EFFECT, 3
	jp Options_OnOff

Options_BikeMusic:
	ld hl, DISABLE_BIKE_MUSIC_ADDRESS
	lb bc, DISABLE_BIKE_MUSIC, 5
	jp Options_InvertedOnOff
