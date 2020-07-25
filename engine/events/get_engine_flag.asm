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
	cp ENGINE_EARTHBADGE + 1
	ld de, .UnknownString
	jr nc, .setName
	ld hl, .FlagNames
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
	ret

.FlagNames:
	dw .RadioCardString
	dw .MapCardString
	dw .PhoneCardString
	dw .ExpnCardString
	dw .PokegearString
rept ENGINE_POKEDEX - ENGINE_POKEGEAR - 1
	dw .UnknownString
endr
	dw .PokedexString
rept ENGINE_ZEPHYRBADGE - ENGINE_POKEDEX - 1
	dw .UnknownString
endr
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
.PokedexString:
	db "#DEX@"
.UnknownString:
	db "???@"
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
