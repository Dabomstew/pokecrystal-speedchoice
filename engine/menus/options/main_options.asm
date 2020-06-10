MainOptionsP1String::
	db "TEXT SPEED<LF>"
	db "        :<LF>"
	db "HOLD TO MASH<LF>"
	db "        :<LF>"
	db "BATTLE SCENE<LF>"
	db "        :<LF>"
	db "BATTLE STYLE<LF>"
	db "        :<LF>"
	db "SOUND<LF>"
	db "        :<LF>"
	db "MENU ACCOUNT<LF>"
	db "        :<LF>"
	db "FRAME<LF>"
	db "        :TYPE@"

MainOptionsP1Pointers::
	dw Options_TextSpeed
	dw Options_HoldToMash
	dw Options_BattleScene
	dw Options_BattleStyle
	dw Options_Sound
	dw Options_MenuAccount
	dw Options_Frame
	dw Options_OptionsPage
MainOptionsP1PointersEnd::

Options_TextSpeed:
	ld hl, .Data
	jp Options_Multichoice

.Data:
	multichoiceoptiondata TEXT_SPEED_ADDRESS, TEXT_SPEED, TEXT_SPEED_SIZE, 3, NUM_OPTIONS, .Strings

.Strings
	dw .Inst
	dw .Fast
	dw .Mid
	dw .Slow
.Strings_End:

.Inst
	db "INST@"
.Fast
	db "FAST@"
.Mid
	db "MID @"
.Slow
	db "SLOW@"

Options_BattleScene:
	ld hl, BATTLE_SHOW_ANIMATIONS_ADDRESS
	lb bc, BATTLE_SHOW_ANIMATIONS, 7
	jp Options_OnOff

Options_BattleStyle:
	ld hl, BATTLE_SHIFT_ADDRESS
	lb bc, BATTLE_SHIFT, 9
	ld de, .ShiftSet
	jp Options_TrueFalse
.ShiftSet
	dw .Set
	dw .Shift

.Shift
	db "SHIFT@"
.Set
	db "SET  @"

Options_HoldToMash:
	ld hl, HOLD_TO_MASH_ADDRESS
	lb bc, HOLD_TO_MASH, 5
	jp Options_OnOff

; this could be a truefalse but we want to apply it immediately
Options_Sound:
	ld hl, STEREO_ADDRESS
	ldh a, [hJoyPressed]
	and D_LEFT | D_RIGHT
	jr z, .NonePressed
	bit STEREO, [hl]
	jr nz, .SetMono
	jr .SetStereo

.NonePressed:
	bit STEREO, [hl]
	jr nz, .ToggleStereo
	jr .ToggleMono

.SetMono:
	res STEREO, [hl]
	call RestartMapMusic

.ToggleMono:
	ld de, .Mono
	jr .Display

.SetStereo:
	set STEREO, [hl]
	call RestartMapMusic

.ToggleStereo:
	ld de, .Stereo

.Display:
	hlcoord 11, 11
	call PlaceString
	and a
	ret

.Mono
	db "MONO  @"
.Stereo
	db "STEREO@"

Options_MenuAccount:
	ld hl, MENU_ACCOUNT_ADDRESS
	lb bc, MENU_ACCOUNT, 13
	jp Options_OnOff

Options_Frame:
	ld a, [TEXT_FRAME_ADDRESS]
	and TEXT_FRAME_MASK
	ld c, a
	ldh a, [hJoyPressed]
	bit D_LEFT_F, a
	jr nz, .LeftPressed
	bit D_RIGHT_F, a
	jr z, .NonePressed
	ld a, c ; right pressed
	cp NUM_TEXTBOX_FRAMES - 1
	jr c, .Increase
	ld c, $ff

.Increase
	inc c
	jr .Save

.LeftPressed
	ld a, c
	and a
	jr nz, .Decrease
	ld c, NUM_TEXTBOX_FRAMES

.Decrease
	dec c

.Save
	ld a, [TEXT_FRAME_ADDRESS]
	and $ff ^ TEXT_FRAME_MASK
	or c
	ld [TEXT_FRAME_ADDRESS], a
	push bc
	call LoadFontsExtra
	pop bc
.NonePressed
	inc c
	ld a, c
	ld [wBuffer1], a
	ld de, wBuffer1
	coord hl, 16, 15
; empty the space for the new number
	ld a, " "
	ld [hli], a
	ld [hld], a
	lb bc, PRINTNUM_LEFTALIGN | 1, 2
	call PrintNum
	and a
	ret
