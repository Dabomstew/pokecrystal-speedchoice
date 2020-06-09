MainOptionsString::
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

MainOptionsPointers::
	dw Options_TextSpeed
	dw Options_HoldToMash
	dw Options_BattleScene
	dw Options_BattleStyle
	dw Options_Sound
	dw Options_MenuAccount
	dw Options_Frame
	dw Options_OptionsPage
MainOptionsPointersEnd::

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
	ld b, BATTLE_SHOW_ANIMATIONS
	ld c, 7
	jp Options_OnOff

Options_BattleStyle:
	ld hl, BATTLE_SHIFT_ADDRESS
	ld b, BATTLE_SHIFT
	ld c, 9
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
	ld b, HOLD_TO_MASH
	ld c, 5
	jp Options_OnOff

Options_Sound:
	ld hl, STEREO_ADDRESS
	ld b, STEREO
	ld c, 11
	ld de, .MonoStereo
	jp Options_TrueFalse
.MonoStereo
	dw .Mono
	dw .Stereo

.Mono
	db "MONO  @"
.Stereo
	db "STEREO@"

Options_MenuAccount:
	ld hl, MENU_ACCOUNT_ADDRESS
	ld b, MENU_ACCOUNT
	ld c, 13
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
