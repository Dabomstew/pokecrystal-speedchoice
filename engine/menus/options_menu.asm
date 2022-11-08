FIRST_OPTIONS_PAGEID EQU 0
NUM_OPTIONS_PAGES EQUS "((PermaOptionsMenuScreens - OptionsMenuScreens)/6)"

FIRST_PERMAOPTIONS_PAGEID EQUS "((PermaOptionsMenuScreens - OptionsMenuScreens)/6)"
NUM_PERMAOPTIONS_PAGES EQUS "((PermaOptionsMenuScreensEnd - PermaOptionsMenuScreens)/6)"

PermaOptionsMenu:
	call EnforceItemRandoOptions
	ld a, FIRST_PERMAOPTIONS_PAGEID
	jr OptionsMenuCommon

OptionsMenu:
	xor a
	; fallthrough

OptionsMenuCommon::
	ld [wOptionsMenuID], a
	xor a
	ld [wStoredJumptableIndex], a
	ld [wOptionsMenuPreset], a
	ld hl, hInMenu
	ld a, [hl]
	push af
	ld [hl], $1
	call ClearBGPalettes
.pageLoad
	call DrawOptionsMenu
.joypad_loop
	call JoyTextDelay
	ldh a, [hJoyPressed]
	ld b, a
	ld a, [wOptionsExitButtons]
	and b
	jr nz, .ExitOptions
	call OptionsControl
	jr c, .dpad
	call GetOptionPointer
	jr c, .ExitOptions

.dpad
	call Options_UpdateCursorPosition
	ld c, 3
	call DelayFrames
	jr .joypad_loop

.ExitOptions
	ld a, [wOptionsNextMenuID]
	cp $FF
	jr z, .doExit
	ld [wOptionsMenuID], a
	jr .pageLoad
.doExit
	ld a, [wOptionsMenuID]
	cp FIRST_PERMAOPTIONS_PAGEID
	jr c, .exit
	ld a, [wPlayerName]
	cp "@"
	jr nz, .exit
	ld a, [HOLD_TO_MASH_ADDRESS]
	push af
	and $ff ^ HOLD_TO_MASH_VAL
	ld [HOLD_TO_MASH_ADDRESS], a
	ld hl, NameNotSetText
	call PrintText
	pop af
	ld [HOLD_TO_MASH_ADDRESS], a
	jr .pageLoad
.exit
	pop af
	ld [hInMenu], a
	ld de, SFX_TRANSACTION
	call PlaySFX
	jp WaitSFX

DrawOptionsMenu:
	call DrawOptionsMenuLagless
	call LoadFontsExtra
	ld a, [wStoredJumptableIndex]
	ld [wJumptableIndex], a
	xor a
	ld [wStoredJumptableIndex], a
	inc a
	ldh [hBGMapMode], a
	call WaitBGMap
	ld b, SCGB_DIPLOMA
	call GetSGBLayout
	call SetPalettes
	ret

DrawOptionsMenuLagless_::
	ld a, [wJumptableIndex]
	push af
	call DrawOptionsMenuLagless
	pop af
	ld [wJumptableIndex], a
	ret

DrawOptionsMenuLagless::
	call RetrieveOptionsMenuConfig
	hlcoord 0, 0
	lb bc, SCREEN_HEIGHT - 2, SCREEN_WIDTH - 2
	call Textbox
	ld hl, wOptionsStringPtr
	ld a, [hli]
	ld e, a
	ld d, [hl]
	hlcoord 2, 2
	call PlaceString
	xor a
	ld [wJumptableIndex], a
	dec a
	ld [wOptionsNextMenuID], a
	ld a, [wOptionsMenuCount]
	inc a
	ld c, a ; number of items on the menu

.print_text_loop ; this next will display the settings of each option when the menu is opened
	push bc
	xor a
	ldh [hJoyPressed], a
	call GetOptionPointer
	pop bc
	ld hl, wJumptableIndex
	inc [hl]
	dec c
	jr nz, .print_text_loop
	ret

RetrieveOptionsMenuConfig::
	ld a, [wOptionsMenuID]
	ld hl, OptionsMenuScreens
	ld bc, wOptionsNextMenuID - wOptionsMenuCount
	call AddNTimes
	ld de, wOptionsMenuCount
	jp CopyBytes

GetOptionPointer:
	ld a, [wOptionsMenuCount]
	ld b, a
	ld a, [wJumptableIndex] ; load the cursor position to a
	cp b
	jr c, .doJump
	ld a, b ; if on the bottom option, use the last item in the jumptable
.doJump
	add a
	ld e, a ; copy it to de
	ld d, 0
	ld hl, wOptionsJumptablePtr
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ldh a, [hJoyPressed] ; almost all options use this, so it's easier to just do it here
	jp hl ; jump to the code of the current highlighted item

Options_Cancel:
	and A_BUTTON
	jr nz, Options_Exit
Options_NoFunc:
	and a
	ret

Options_Exit:
	scf
	ret

Options_OptionsPage:
	lb bc, FIRST_OPTIONS_PAGEID, FIRST_OPTIONS_PAGEID + NUM_OPTIONS_PAGES - 1
	jr Options_Page

Options_PermaOptionsPage:
	lb bc, FIRST_PERMAOPTIONS_PAGEID, FIRST_PERMAOPTIONS_PAGEID + NUM_PERMAOPTIONS_PAGES - 1
Options_Page:
; assumes b = MenuID of first page, c = MenuID of last page
; also assumes all pages use sequential MenuIDs
	bit D_LEFT_F, a
	jr nz, .Decrease
	bit D_RIGHT_F, a
	jr nz, .Increase
	coord hl, 2, 16
	ld de, .PageString
	push bc
	call PlaceString
	pop bc
	ld a, [wOptionsMenuID]
	sub b
	add "1"
	coord hl, 8, 16
	ld [hl], a
	and a
	ret
.Decrease
	ld a, [wOptionsMenuID]
	cp b
	jr nz, .actuallyDecrease
	ld a, c
	jr .SaveAndChangePage
.actuallyDecrease
	dec a
	jr .SaveAndChangePage
.Increase
	ld a, [wOptionsMenuID]
	cp c
	jr nz, .actuallyIncrease
	ld a, b
	jr .SaveAndChangePage
.actuallyIncrease
	inc a
.SaveAndChangePage
	ld [wOptionsNextMenuID], a
	ld a, 7
	ld [wStoredJumptableIndex], a
	scf
	ret
.PageString
	db "PAGE:@"

OptionsControl:
	ld hl, wJumptableIndex
	ld a, [hJoyLast]
	cp D_DOWN
	jr z, .DownPressed
	cp D_UP
	jr z, .UpPressed
	and a
	ret

.DownPressed
	ld a, [hl] ; load the cursor position to a
	cp 7
	jr nz, .clampToMenuTest
	ld [hl], $0
	scf
	ret
.clampToMenuTest
	ld c, a
	ld a, [wOptionsMenuCount]
	dec a
	cp c ; maximum index of item in real options menu
	jr nz, .Increase
	ld [hl], $6 ; bottom option minus 1

.Increase
	inc [hl]
	scf
	ret

.UpPressed
	ld a, [hl]
	cp 7
	jr z, .HandleBottomOption
	and a
	jr nz, .Decrease
	ld a, 8
	ld [hl], a ; move to bottom option

.Decrease
	dec [hl]
	scf
	ret

.HandleBottomOption
; move to bottommost regular option
	ld a, [wOptionsMenuCount]
	dec a
	ld [hl], a
	scf
	ret

Options_UpdateCursorPosition:
	hlcoord 1, 1
	ld de, SCREEN_WIDTH
	ld c, $10
.loop
	ld [hl], " "
	add hl, de
	dec c
	jr nz, .loop
	hlcoord 1, 2
	ld bc, 2 * SCREEN_WIDTH
	ld a, [wJumptableIndex]
	call AddNTimes
	ld [hl], "▶"
	ret

; b = x-coordinate (0~19)
; c = y-coordinate (0~17)
; clobbers a, b, c; result in hl
CoordHL:
	ld a, c
	add c ; *2 (0~34)
	add a ; *4 (0~68)
	add c ; *5 (0~85)
	add a ; *10 (0~170)
	add a ; *20 (0~340)
	ld c, a
	ld a, b
	ld b, 0
	jr nc, .noOverflow
	inc b
.noOverflow
	hlcoord 0, 0
	add hl, bc
	ld c, a
	ld b, 0
	add hl, bc
	ret

; hl = ram address
; b = bit number in ram address
; c = y-coordinate to draw at
; de = table of strings to show for false/true (false first)
Options_InvertedOnOff:
	ld de, OffOnStrings
	jr Options_TrueFalse

Options_OnOff:
	ld de, OnOffStrings
Options_TrueFalse:
	push de
	ld d, a
	ld a, 1
	and a ; clear carry
	inc b
.shiftloop
	dec b
	jr z, .doneshift
	rla
	jr .shiftloop
.doneshift
	ld b, a
	ld a, d
	and D_LEFT | D_RIGHT
	ld a, [hl]
	jr z, .GetText
	xor b
	ld [hl], a
.GetText
	pop de
	and b
	jr z, .Display
	ld a, 2
	add e
	ld e, a
	jr nc, .Display
	inc d
.Display
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld d, a
	ld e, l
	ld b, 11 ; x-coord, y-coord is already in c
	call CoordHL
	call PlaceString
	and a
	ret

Options_OnOff_IRLocked:
	ld de, OnOffStrings
Options_TrueFalse_IRLocked:
	push hl
	call IsItemRandoActive
	pop hl
	and a
	ld a, 0
	jr nz, Options_TrueFalse
	ldh a, [hJoyPressed]
	jr Options_TrueFalse

OnOffStrings::
	dw OffOptionText
	dw OnOptionText
OffOnStrings::
	dw OnOptionText
	dw OffOptionText
OffOptionText:
	db "OFF@"
OnOptionText:
	db "ON @"

; arguments = ram address, start bit, size in bits, y-coord, number of choices, pointer to choices
multichoiceoptiondata: macro
	dw \1 ; ram address
	db \2 ; bit number that data STARTS at
	db (1 << (\2 + \3)) - (1 << \2) ; bitmask for data
	db \4 ; y-coordinate
	db \5 ; number of choices
	dw \6 ; pointer to choices
endm

; hl = pointer to options multichoice struct
Options_Multichoice:
	; load multichoice data to ram
	ld bc, 8
	ld de, wBuffer1
	call CopyBytes
	ldh a, [hJoyPressed]
	bit D_LEFT_F, a
	jr nz, .LeftPressed
	bit D_RIGHT_F, a
	jr nz, .RightPressed
	jr .UpdateDisplay
.RightPressed
	call .GetVal
	inc a
	jr .Save

.LeftPressed
	call .GetVal
	dec a

.Save
	cp $ff
	jr nz, .nextCheck
	ld a, [wBuffer1 + 5] ; max value
	dec a
	jr .store
.nextCheck
	ld b, a
	ld a, [wBuffer1 + 5] ; max value
	cp b
	jr nz, .storeskipmove
	xor a
.store
	ld b, a
.storeskipmove
	ld a, [wBuffer1 + 2] ; bitshift required
	inc a
.shiftloop
	dec a
	jr z, .calcAndStore
	sla b
	jr .shiftloop
.calcAndStore
	ld hl, wBuffer1
	rst UnHL
	ld a, [hl]
	ld c, a
	ld a, [wBuffer1 + 3] ; bitmask for the option in question
	cpl ; invert it so we clear the option
	and c ; bitmask AND current value
	or b ; set new value
	ld [hl], a

.UpdateDisplay:
	call .GetVal
	ld c, a
	ld b, 0
	ld hl, wBuffer1 + 6 ; pointer to strings
	rst UnHL
rept 2
	add hl, bc
endr
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, [wBuffer1 + 4] ; y-coordinate
; calculate ram address to put string at from y-coordinate
	ld c, a
	ld b, 11 ; x-coordinate
	call CoordHL
	call PlaceString
	and a
	ret

.GetVal:
	ld hl, wBuffer1
	rst UnHL
	ld b, [hl]
	ld a, [wBuffer1 + 3] ; bitmask
	and b
	ld b, a
; bitshift as needed
	ld a, [wBuffer1 + 2] ; bitshift
	inc a
.shiftloop2
	dec a
	jr z, .done
	srl b
	jr .shiftloop2
.done
	ld a, b
	ret

NUM_OPTIONS EQUS "((.Strings_End - .Strings)/2)"

options_menu: MACRO
	db ((\2End - \2)/2 - 1) ; number of options except bottom option
	dw (\1) ; template string
	dw (\2) ; jumptable for options
	db (\3) ; buttons that can be pressed to exit
ENDM

OptionsMenuScreens:
	options_menu MainOptionsP1String, MainOptionsP1Pointers, (START | B_BUTTON)
	options_menu MainOptionsP2String, MainOptionsP2Pointers, (START | B_BUTTON)
PermaOptionsMenuScreens:
	options_menu PermaOptionsP1String, PermaOptionsP1Pointers, START
	options_menu PermaOptionsP2String, PermaOptionsP2Pointers, START
	options_menu PermaOptionsP3String, PermaOptionsP3Pointers, START
	options_menu PermaOptionsP4String, PermaOptionsP4Pointers, START
	options_menu PermaOptionsP5String, PermaOptionsP5Pointers, START
PermaOptionsMenuScreensEnd:

INCLUDE "engine/menus/options/main_options.asm"
INCLUDE "engine/menus/options/main_options_2.asm"
INCLUDE "engine/menus/options/perma_options.asm"
INCLUDE "engine/menus/options/perma_options_2.asm"
INCLUDE "engine/menus/options/perma_options_3.asm"
INCLUDE "engine/menus/options/perma_options_4.asm"
INCLUDE "engine/menus/options/perma_options_5.asm"

NameNotSetText::
	text "Please set your"
	line "name on page 1!@"
	start_asm
	ld de, SFX_WRONG
	call PlaySFX
	call WaitSFX
	ld hl, .done
	ret
.done
	text ""
	prompt
	
IsItemRandoActive::
	ld a, BANK(ItemRandoData)
	ld hl, ItemRandoActive
	call GetFarByte
	and a
	ret

EnforceItemRandoOptions::
	call IsItemRandoActive
	ret z
	ld de, ItemRandoLockedOptionsTable
.loop
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	or l
	ret z
	ld a, BANK(ItemRandoData)
	call GetFarByte
	ld c, a
	inc de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	ld a, [de]
	inc de
	ld b, a
	cpl
	and [hl]
	ld [hl], a
	ld a, c
	and a
	jr z, .loop
	ld a, [hl]
	or b
	ld [hl], a
	jr .loop

ItemRandoLockedOptionsTable:
lockedoption: MACRO
	dw \2
	dw \1_ADDRESS
	db \1_VAL
ENDM
	lockedoption ROCKETLESS, ItemRandoRocketless
	lockedoption EASY_CLAIR_BADGE, ItemRandoEasyClairBadge
	lockedoption EARLY_KANTO, ItemRandoEarlyKanto
	lockedoption EASY_TIN_TOWER, ItemRandoEasyTinTower
	lockedoption START_WITH_BIKE, ItemRandoStartWithBike
	lockedoption BETTER_MARTS, ItemRandoBetterMarts
	dw 0 ; terminator
