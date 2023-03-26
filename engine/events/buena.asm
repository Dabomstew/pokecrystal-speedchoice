
BuenasPassword:
	xor a
	ld [wWhichIndexSet], a
	ld hl, .MenuHeader
	call CopyMenuHeader
	ld a, [wBuenasPassword]
	ld c, a
	farcall GetBuenasPassword
	ld a, [wMenuBorderLeftCoord]
	add c
	add $2
	ld [wMenuBorderRightCoord], a
	call PushWindow
	call DoNthMenu ; menu
	farcall Buena_ExitMenu
	ld b, $0
	ld a, [wMenuSelection]
	ld c, a
	ld a, [wBuenasPassword]
	maskbits NUM_PASSWORDS_PER_CATEGORY
	cp c
	jr nz, .wrong
	ld b, $1

.wrong
	ld a, b
	ld [wScriptVar], a
	ret

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 10, 7
	dw .MenuData
	db 1 ; default option

	db 0

.MenuData:
	db STATICMENU_CURSOR | STATICMENU_DISABLE_B ; flags
	db 0 ; items
	dw .PasswordIndices
	dw .PlacePasswordChoices

.PasswordIndices:
	db NUM_PASSWORDS_PER_CATEGORY
x = 0
rept NUM_PASSWORDS_PER_CATEGORY
	db x
x = x + 1
endr
	db -1

.PlacePasswordChoices:
	push de
	ld a, [wBuenasPassword]
	and $f0
	ld c, a
	ld a, [wMenuSelection]
	add c
	ld c, a
	farcall GetBuenasPassword
	pop hl
	call PlaceString
	ret

BuenaPrize:
	xor a
	ld [wMenuScrollPosition], a
	ld a, $1
	ld [wMenuSelection], a
	call Buena_PlacePrizeMenuBox
	call Buena_DisplayBlueCardBalance
	ld hl, .BuenaAskWhichPrizeText
	call PrintText
	jr .okay

.loop
	ld hl, .BuenaAskWhichPrizeText
	call BuenaPrintText

.okay
	call DelayFrame
	call UpdateSprites
	call PrintBlueCardBalance
	call Buena_PrizeMenu
	jr z, .done
	ld [wMenuSelectionQuantity], a
	call Buena_getprize
	ld a, [hl]
	ld [wNamedObjectIndexBuffer], a
	call GetItemName
	ld hl, .BuenaIsThatRightText
	call BuenaPrintText
	call YesNoBox
	jr c, .loop

;	ld a, [wMenuSelectionQuantity]
	call Buena_getprizepoints
	ld b, c ; store points in b
	ld a, [wNamedObjectIndexBuffer]
	ld c, a
	push bc
	;ld a, [wMenuSelectionQuantity]
	;call Buena_getprize
	;pop bc
	;inc hl
	;ld a, [hl]
	;ld a, [hli]
	;ld c, a ;store item in c
	;push bc
	;push af
	ld c, b
	ld a, [wBlueCardBalance]
	cp c
	jr c, .InsufficientBalance

	;ld a, [hli]
	;pop af
	;push hl
	pop bc
	ld a, c ; should be c
	ld [wCurItem], a
	ld a, $1
	ld [wItemQuantityChangeBuffer], a
	ld hl, wNumItems
	push bc
	call ReceiveItem
	pop bc
	jr nc, .BagFull
	;ld a, [hl]
	ld c, b
	ld a, [wBlueCardBalance]
	sub c
	ld [wBlueCardBalance], a
	call PrintBlueCardBalance
	jr .Purchase

.InsufficientBalance:
	pop bc
	ld hl, .BuenaNotEnoughPointsText
	jr .print

.BagFull:
	ld hl, .BuenaNoRoomText
	jr .print

.Purchase:
	ld de, SFX_TRANSACTION
	call PlaySFX
	call Buena_setflag
	ld hl, .BuenaHereYouGoText

.print
	call BuenaPrintText
	jr .loop

.done
	call CloseWindow
	call CloseWindow
	ld hl, .BuenaComeAgainText
	call PrintText
	call JoyWaitAorB
	call PlayClickSFX
	ret

.BuenaAskWhichPrizeText:
	text_far _BuenaAskWhichPrizeText
	text_end

.BuenaIsThatRightText:
	text_far _BuenaIsThatRightText
	text_end

.BuenaHereYouGoText:
	text_far _BuenaHereYouGoText
	text_end

.BuenaNotEnoughPointsText:
	text_far _BuenaNotEnoughPointsText
	text_end

.BuenaNoRoomText:
	text_far _BuenaNoRoomText
	text_end

.BuenaComeAgainText:
	text_far _BuenaComeAgainText
	text_end

Buena_DisplayBlueCardBalance:
	ld hl, BlueCardBalanceMenuHeader
	call LoadMenuHeader
	ret

PrintBlueCardBalance:
	ld de, wBlueCardBalance
	call .DrawBox
	ret

.DrawBox:
	push de
	xor a
	ldh [hBGMapMode], a
	ld hl, BlueCardBalanceMenuHeader
	call CopyMenuHeader
	call MenuBox
	call UpdateSprites
	call MenuBoxCoord2Tile
	ld bc, SCREEN_WIDTH + 1
	add hl, bc
	ld de, .Points_string
	call PlaceString
	ld h, b
	ld l, c
	inc hl
	ld a, " "
	ld [hli], a
	ld [hld], a
	pop de
	lb bc, 1, 2
	call PrintNum
	ret

.Points_string:
	db "Points@"

BlueCardBalanceMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 11, 11, 13

Buena_PlacePrizeMenuBox:
	ld hl, .MenuHeader
	call LoadMenuHeader
	ret

.MenuHeader
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 17, TEXTBOX_Y - 1

Buena_PrizeMenu:
	ld hl, .MenuHeader
	call CopyMenuHeader
	ld a, [wMenuSelection]
	ld [wMenuCursorBuffer], a
	xor a
	ld [wWhichIndexSet], a
	ldh [hBGMapMode], a
	call InitScrollingMenu
	call UpdateSprites
	call ScrollingMenu
	ld a, [wMenuSelection]
	ld c, a
	ld a, [wMenuCursorY]
	ld [wMenuSelection], a
	ld a, [wMenuJoypad]
	cp $2
	jr z, .cancel
	ld a, c
	and a
	ret nz

.cancel
	xor a
	ret

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 1, 1, 16, 9
	dw .MenuData
	db 1 ; default option

	db 0

.MenuData:
	db SCROLLINGMENU_DISPLAY_ARROWS ; flags
	db 4, 13 ; rows, columns
	db SCROLLINGMENU_ITEMS_NORMAL ; item format
	dba .indices
	dba .prizeitem
	dba .prizepoints

NUM_BUENA_PRIZES EQU 9 ; ((BuenaPrizeItems.End - BuenaPrizeItems) / 2)

.indices
	db NUM_BUENA_PRIZES
x = 1
rept NUM_BUENA_PRIZES
	db x
x = x + 1
endr
	db -1

.prizeitem
	ld a, [wMenuSelection]
	call Buena_getprize
	ld a, [hl]
	push de
	ld [wNamedObjectIndexBuffer], a
	call GetItemName
	pop hl
	call PlaceString
	ret

.prizepoints
	call Buena_getprizepoints
	ld a, c
	;ld a, [wMenuSelection]
	;call Buena_getprize
	;inc hl
	;ld a, [hl]
	ld c, "0"
	add c
	;push af

	;push de
	;ld de, EVENT_BUENA_ITEM_1
	;ld a, [wMenuSelection]
	;add a, d
	;adc a, e

	;ld b, CHECK_FLAG
	;farcall EventFlagAction
	;pop de
	;ld a, c
	;and a
	;jr z, .false
	;pop af
	;inc a 	; add one
	;jp .return

;.false
;	pop af
;.return
	ld [de], a
	ret

Buena_setflag:
	ld de, EVENT_BUENA_ITEM_1-1
        ld a, [wMenuSelection]
;        add a, d
;        adc a, e
	add a, d
	ld d, a
	ld a, 0
	adc a, e
	ld e, a
	

	ld b, SET_FLAG
        farcall EventFlagAction

Buena_getprizepoints:
	ld a, [wMenuSelection]
	call Buena_getprize
	inc hl
	ld a, [hl]
	push af

	push de
        ld de, EVENT_BUENA_ITEM_1-1
        ld a, [wMenuSelection]
	; not sure how to add properly here
	add a, d
	ld d, a
	ld a, 0
	adc a, e
	ld e, a

        ld b, CHECK_FLAG
        farcall EventFlagAction
        pop de
        ld a, c
        and a
        jr z, .pop
	pop af
        inc a   ; add one
        jp .return

.pop
	pop af
.return
	;ld a, [wMenuSelection]
        ld c, a
        ret

Buena_getprize:
	dec a
	ld hl, BuenaPrizeItems
	ld b, 0
	ld c, a
	add hl, bc
	add hl, bc
	add hl, bc
	ret

INCLUDE "data/items/buena_prizes.asm"
