MainOptionsP2String::
	db "PARKBALL EFFECT<LF>"
	db "        :<LF>"
	db "BIKE MUSIC<LF>"
	db "        :<LF>"
	db "GIVE NICKNAMES<LF>"
	db "        :<LF>"
	db "SHINY ANIMATION<LF>"
	db "        :@"

MainOptionsP2Pointers::
	dw Options_ParkBallEffect
	dw Options_BikeMusic
	dw Options_Nicknames
	dw Options_Shiny_Animation
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

Options_Nicknames:
	ld hl, SKIP_NICKNAMING_ADDRESS
	lb bc, SKIP_NICKNAMING, 7
	ld de, .Options
	jp Options_TrueFalse

.Options
	dw .Yes
	dw .No

.Yes
	db "YES@"
.No
	db "NO @"

Options_Shiny_Animation:
	ld hl, DISABLE_SHINY_ANIMATION_ADDRESS
	lb bc, DISABLE_SHINY_ANIMATION, 9
	jp Options_OnOff