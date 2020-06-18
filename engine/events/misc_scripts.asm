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
	playsound SFX_RB_GET_ITEM
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

HiddenEngineFlagScript::
	callasm .SetMemEvent
	sjump PickupEngineFlagCommon

.SetMemEvent:
	ld hl, wEngineFlagPickupEvent
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld b, SET_FLAG
	call EventFlagAction
	ret

FindEngineFlagInBallScript::
	disappear LAST_TALKED

PickupEngineFlagCommon::
	callasm .ReceiveFlag
	increment2bytestat sStatsItemsPickedUp
	opentext
	writetext .FoundFlagText
	playsound SFX_RB_GET_ITEM
	waitsfx
	closetext
	end

.FoundFlagText:
	text_far _FoundItemText
	text_end

.ReceiveFlag:
	ld a, [wEngineFlagPickupFlagID]
	ld e, a
	ld d, 0
	ld b, SET_FLAG
	farcall EngineFlagAction
GetEngineFlagName::
	ld a, [wEngineFlagPickupFlagID]
	cp ENGINE_POKEDEX
	ld de, .PokedexString
	jr z, .setName
	cp ENGINE_POKEGEAR + 1
	ld de, .UnknownString
	jr nc, .setName
	ld hl, .FirstFlagNamesLookupTable
	add a
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hli]
	ld d, [hl]
	ld e, a
.setName
	ld hl, wStringBuffer3
	call CopyName2
	ld a, TRUE
	ld [wScriptVar], a
	ret
	
.PokedexString:
	db "#DEX@"
.UnknownString:
	db "???@"
.FirstFlagNamesLookupTable:
	dw .RadioCardString
	dw .MapCardString
	dw .PhoneCardString
	dw .ExpnCardString
	dw .PokegearString
.RadioCardString:
	db "RADIO CARD@"
.MapCardString:
	db "MAP CARD@"
.PhoneCardString:
	db "PHONE CARD@"
.ExpnCardString:
	db "EXPN CARD@"
.PokegearString:
	db "#GEAR@"
