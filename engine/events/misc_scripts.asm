Script_AbortBugContest:
	checkflag ENGINE_BUG_CONTEST_TIMER
	iffalse .finish
	setflag ENGINE_DAILY_BUG_CONTEST
	special ContestReturnMons
.finish
	end

FindItemInBallScript::
	callasm .TryReceiveItem
	iffalse .no_room
	increment2bytestat sStatsItemsPickedUp
	disappear LAST_TALKED
	opentext
	writetext .FoundItemText
	callasm .DecideSound
	waitsfx
	itemnotify
	closetext
	end

.no_room
	opentext
	writetext .FoundItemText
	waitbutton
	writetext .CantCarryItemText
	waitbutton
	closetext
	end

.DecideSound
	farcall CheckItemPocket
        ld a, [wItemAttributeParamBuffer]
        cp TM_HM
        ld de, SFX_GET_TM
        jr z, .play
	cp KEY_ITEM
	ld de, SFX_KEY_ITEM
	jr z, .play
        ld de, SFX_RB_GET_ITEM
.play
        call PlaySFX
	ret

.FoundItemText:
	text_far _FoundItemText
	text_end

.CantCarryItemText:
	text_far _CantCarryItemText
	text_end

.TryReceiveItem:
	xor a
	ld [wScriptVar], a
	ld a, [wItemBallItemID]
	ld [wNamedObjectIndexBuffer], a
	call GetItemName
	ld hl, wStringBuffer3
	call CopyName2
	ld de, wStringBuffer3 + STRLEN("TM##")
	farcall AppendTMHMMoveName
	ld a, [wItemBallItemID]
	ld [wCurItem], a
	ld a, [wItemBallQuantity]
	ld [wItemQuantityChangeBuffer], a
	ld hl, wNumItems
	call ReceiveItem
	ret nc
	ld a, $1
	ld [wScriptVar], a
	ret

FindProgressiveRodInBallScript::
	loadmem wItemBallQuantity, 1
	checkitem OLD_ROD
	loadmem wItemBallItemID, OLD_ROD
	iffalse FindItemInBallScript
	checkitem GOOD_ROD
	loadmem wItemBallItemID, GOOD_ROD
	iffalse FindItemInBallScript
	loadmem wItemBallItemID, SUPER_ROD
	sjump FindItemInBallScript
