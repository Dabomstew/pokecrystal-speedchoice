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
	readmem wEngineFlagPickupFlagID
	engineflagsound
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
	cp ENGINE_ZEPHYRBADGE
	jr c, .notBadges
	cp ENGINE_UNLOCKED_UNOWNS_A_TO_K
	jr nc, .notBadges
	ld hl, .BadgeNamesLookupTable
	sub ENGINE_ZEPHYRBADGE
	jr .lookupcommon
.notBadges
	cp ENGINE_POKEDEX
	ld de, .PokedexString
	jr z, .setName
	cp ENGINE_POKEGEAR + 1
	ld de, .UnknownString
	jr nc, .setName
	ld hl, .FirstFlagNamesLookupTable
.lookupcommon
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
.BadgeNamesLookupTable:
	dw .ZephyrBadgeString
	dw .HiveBadgeString
	dw .PlainBadgeString
	dw .FogBadgeString
	dw .MineralBadgeString
	dw .StormBadgeString
	dw .GlacierBadgeString
	dw .RisingBadgeString
	dw .BoulderBadgeString
	dw .CascadeBadgeString
	dw .ThunderBadgeString
	dw .RainbowBadgeString
	dw .SoulBadgeString
	dw .MarshBadgeString
	dw .VolcanoBadgeString
	dw .EarthBadgeString
.ZephyrBadgeString:
	db "ZEPHYRBADGE@"
.HiveBadgeString:
	db "HIVEBADGE@"
.PlainBadgeString:
	db "PLAINBADGE@"
.FogBadgeString:
	db "FOGBADGE@"
.MineralBadgeString:
	db "MINERALBADGE@"
.StormBadgeString:
	db "STORMBADGE@"
.GlacierBadgeString:
	db "GLACIERBADGE@"
.RisingBadgeString:
	db "RISINGBADGE@"
.BoulderBadgeString:
	db "BOULDERBADGE@"
.CascadeBadgeString:
	db "CASCADEBADGE@"
.ThunderBadgeString:
	db "THUNDERBADGE@"
.RainbowBadgeString:
	db "RAINBOWBADGE@"
.SoulBadgeString:
	db "SOULBADGE@"
.MarshBadgeString:
	db "MARSHBADGE@"
.VolcanoBadgeString:
	db "VOLCANOBADGE@"
.EarthBadgeString:
	db "EARTHBADGE@"
