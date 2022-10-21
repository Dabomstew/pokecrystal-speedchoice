GiveExperience:
; Give experience.
; Don't give experience if linked or in the Battle Tower.
	ld a, [wLinkMode]
	and a
	ret nz

	ld a, [wInBattleTowerBattle]
	bit 0, a
	ret nz

; kill immediately if no exp
	mboptioncheck EXP_FORMULA, NO_EXP
	ret z

	call CalculateEXPGainDivisors

	xor a
	ld [wGivingExperienceToExpShareHolders], a
; give exp to each participant exp divisors and shared exp divisors, this code requires them to be adjacent in WRAM
	ld de, wParticipantEXPDivisors
.outerLoop
	ld hl, wPartyMon1
	ld c, PARTY_LENGTH
	ld b, 0
.giveLoop
	ld a, [de]
	and a
	jp z, .nextRecipientNoPop
	ld [wCurrentDivisor], a
	ld a, b
	ld [wCurPartyMon], a
; give exp and stat exp
	push bc
	push de
	push hl
; stat exp stuff
	ld bc, MON_STAT_EXP + 1
	add hl, bc
	ld d, h
	ld e, l
	ld hl, wEnemyMonBaseStats
	ld c, NUM_EXP_STATS
.stat_exp_loop
	ld a, [hli]
	push de
	ld d, a
	ld a, [wCurrentDivisor]
	ld e, a
	call SingleByteDivide
	ld b, d
	pop de
	ld a, [de]
	add b
	ld [de], a
	jr nc, .pkrusCheck
; if there was a carry, increment the upper byte
	dec de
	ld a, [de]
	inc a
	jr z, .maxStatExp ; jump if overflow
	ld [de], a
	inc de
	jr .pkrusCheck
.pkrusCheck
	push hl
	push bc
	ld a, MON_PKRUS
	call GetPartyParamLocation
	ld a, [hl]
	and a
	pop bc
	pop hl
	jr z, .nextStat
	ld a, [de]
	add b
	ld [de], a
	jr nc, .nextStat
	dec de
	ld a, [de]
	inc a
	jr z, .maxStatExp
	ld [de], a
	inc de
	jr .nextStat
.maxStatExp
	dec a ; a = $ff
	ld [de], a
	inc de
	ld [de], a
.nextStat
	inc de
	inc de
	dec c
	jr nz, .stat_exp_loop
; calculate actual exp
	pop bc ; base of party entry, was pushed from hl earlier
	push bc ; store it back for the loop
	mboptioncheck EXP_FORMULA, BLACKWHITE
	jr z, .doBW
	farcall CalculateNonScalingExperienceGain
	jr .continue
.doBW
	farcall CalculateScalingExperienceGain
.continue
	farcall SRAMStatsRecordEXPGain
; copy exp gain to a string buffer since printnumber uses the math hram
	ldh a, [hQuotient + 1]
	ld [wStringBuffer2], a
	ldh a, [hQuotient + 2]
	ld [wStringBuffer2 + 1], a
	ldh a, [hQuotient + 3]
	ld [wStringBuffer2 + 2], a
; load mon name (must always load in case of level gain)
	ld a, [wCurPartyMon]
	ld hl, wPartyMonNicknames
	call GetNick
	ld hl, Text_MonGainedExpPoint
	ld a, [wGivingExperienceToExpShareHolders]
	and a
	jr z, .print ; print all participants individually
	mboptionload EXP_SPLITTING
	jr z, .print ; vanilla splitting = print all gains individually
	ld a, [wPrintedShareText]
	and a
	jr nz, .afterPrinting
	inc a
	ld [wPrintedShareText], a
	ld hl, GainedWithShareText
.print
	call BattleTextbox
.afterPrinting
	ld a, [wStringBuffer2 + 2]
	ldh [hQuotient + 3], a
	ld a, [wStringBuffer2 + 1]
	ldh [hQuotient + 2], a
	ld a, [wStringBuffer2]
	ldh [hQuotient + 1], a
	pop bc ; not sure this is actually used in AnimateExpBar, but just matching the current code
	call AnimateExpBar
	push bc
	call LoadTilemapToTempTilemap
	pop bc
	push bc
	ld hl, MON_EXP + 2
	add hl, bc
	ld d, [hl]
	ldh a, [hQuotient + 3]
	add d
	ld [hld], a
	ld d, [hl]
	ldh a, [hQuotient + 2]
	adc d
	ld [hld], a
	ld d, [hl]
	ldh a, [hQuotient + 1]
	adc d
	ld [hl], a
	jr nc, .no_exp_overflow
	ld a, $ff
	ld [hli], a
	ld [hli], a
	ld [hl], a
.no_exp_overflow
	ld a, [wCurPartyMon]
	ld e, a
	ld d, 0
	ld hl, wPartySpecies
	add hl, de
	ld a, [hl]
	ld [wCurSpecies], a
	call GetBaseData
	push bc
	ld d, MAX_LEVEL
	callfar CalcExpAtLevel
	pop bc
	ld hl, MON_EXP + 2
	add hl, bc
	push bc
	ldh a, [hQuotient + 1]
	ld b, a
	ldh a, [hQuotient + 2]
	ld c, a
	ldh a, [hQuotient + 3]
	ld d, a
	ld a, [hld]
	sub d
	ld a, [hld]
	sbc c
	ld a, [hl]
	sbc b
	jr c, .not_max_exp
	ld a, b
	ld [hli], a
	ld a, c
	ld [hli], a
	ld a, d
	ld [hld], a

.not_max_exp
; Check if the mon leveled up
	xor a ; PARTYMON
	ld [wMonType], a
	predef CopyMonToTempMon
	callfar CalcLevel
	pop bc
	ld hl, MON_LEVEL
	add hl, bc
	ld a, [hl]
	cp MAX_LEVEL
	jp nc, .nextRecipient
	cp d
	jp z, .nextRecipient
; <NICKNAME> grew to level ##!
	ld [wTempLevel], a
	ld a, [wCurPartyLevel]
	push af
	ld a, d
	ld [wCurPartyLevel], a
	ld [hl], a
	ld hl, MON_SPECIES
	add hl, bc
	ld a, [hl]
	ld [wCurSpecies], a
	ld [wTempSpecies], a ; unused?
	call GetBaseData
	ld hl, MON_MAXHP + 1
	add hl, bc
	ld a, [hld]
	ld e, a
	ld d, [hl]
	push de
	ld hl, MON_MAXHP
	add hl, bc
	ld d, h
	ld e, l
	ld hl, MON_STAT_EXP - 1
	add hl, bc
	push bc
	ld b, TRUE
	predef CalcMonStats
	pop bc
	pop de
	ld hl, MON_MAXHP + 1
	add hl, bc
	ld a, [hld]
	sub e
	ld e, a
	ld a, [hl]
	sbc d
	ld d, a
	dec hl
	ld a, [hl]
	add e
	ld [hld], a
	ld a, [hl]
	adc d
	ld [hl], a
	ld a, [wCurBattleMon]
	ld d, a
	ld a, [wCurPartyMon]
	cp d
	jr nz, .skip_active_mon_update
	ld de, wBattleMonHP
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld de, wBattleMonMaxHP
	push bc
	ld bc, PARTYMON_STRUCT_LENGTH - MON_MAXHP
	call CopyBytes
	pop bc
	ld hl, MON_LEVEL
	add hl, bc
	ld a, [hl]
	ld [wBattleMonLevel], a
	ld a, [wPlayerSubStatus5]
	bit SUBSTATUS_TRANSFORMED, a
	jr nz, .transformed
	ld hl, MON_ATK
	add hl, bc
	ld de, wPlayerStats
	ld bc, PARTYMON_STRUCT_LENGTH - MON_ATK
	call CopyBytes

.transformed
	xor a ; FALSE
	ld [wApplyStatLevelMultipliersToEnemy], a
	call ApplyStatLevelMultiplierOnAllStats
	callfar ApplyStatusEffectOnPlayerStats
	callfar BadgeStatBoosts
	callfar UpdatePlayerHUD
	call EmptyBattleTextbox
	call LoadTilemapToTempTilemap
	ld a, $1
	ldh [hBGMapMode], a

.skip_active_mon_update
	farcall LevelUpHappinessMod
	ld a, [wCurBattleMon]
	ld b, a
	ld a, [wCurPartyMon]
	cp b
	jr z, .skip_exp_bar_animation
	ld de, SFX_HIT_END_OF_EXP_BAR
	call PlaySFX
	call WaitSFX
	ld hl, BattleText_StringBuffer1GrewToLevel
	call StdBattleTextbox
	call LoadTilemapToTempTilemap

.skip_exp_bar_animation
	xor a ; PARTYMON
	ld [wMonType], a
	predef CopyMonToTempMon
	hlcoord 9, 0
	ld b, 10
	ld c, 9
	call Textbox
	hlcoord 11, 1
	ld bc, 4
	predef PrintTempMonStats
	ld c, 30
	call DelayFrames
	call WaitPressAorB_BlinkCursor
	call SafeLoadTempTilemapToTilemap
	xor a ; PARTYMON
	ld [wMonType], a
	ld a, [wCurSpecies]
	ld [wTempSpecies], a ; unused?
	ld a, [wCurPartyLevel]
	push af
	ld c, a
	ld a, [wTempLevel]
	ld b, a

.level_loop
	inc b
	ld a, b
	ld [wCurPartyLevel], a
	push bc
	predef LearnLevelMoves
	pop bc
	ld a, b
	cp c
	jr nz, .level_loop
	pop af
	ld [wCurPartyLevel], a
	ld hl, wEvolvableFlags
	ld a, [wCurPartyMon]
	ld c, a
	ld b, SET_FLAG
	predef SmallFarFlagAction
	pop af
	ld [wCurPartyLevel], a

.nextRecipient
	pop hl
	pop de
	pop bc
.nextRecipientNoPop
	inc de
	push bc
	ld bc, PARTYMON_STRUCT_LENGTH
	add hl, bc
	pop bc
	inc b
	dec c
	jp nz, .giveLoop
	ld a, [wGivingExperienceToExpShareHolders]
	and a
	ret nz
	inc a
	ld [wGivingExperienceToExpShareHolders], a
	jp .outerLoop

; divide d by e; quotient in d, remainder in a
SingleByteDivide:
; check for fast exit if e=1; worth it given how often the divisor will be 1 for this code
	ld a, e
	dec a
	ret z
	xor a
	ld b, 8
.loop
	sla d
	rla
	cp e
	jr c, .dontsubinc
	sub e
	inc d
.dontsubinc
	dec b
	jr nz, .loop
	ret

CalculateEXPGainDivisors:
	ld bc, wEXPCalcsEnd - wParticipantCount
	ld hl, wParticipantCount
	xor a
	call ByteFill
	ld a, [wBattleParticipantsNotFainted]
	ld b, 0
	ld c, PARTY_LENGTH
.countSetBitsLoop ; loop to count set bits in wBattleParticipantsNotFainted
	srl a
	jr nc, .next
	inc b
.next
	dec c
	jr nz, .countSetBitsLoop
	ld a, b
	ld [wParticipantCount], a
; what behavior do we actually have?
; vanilla = divide by number of participants and by a further 2 if exp share held, gen6+ = all participants get full exp
	mboptionload EXP_SPLITTING
	ld a, 1
	jr nz, .setBaseValue
	call IsAnyMonHoldingExpShare
	ld a, [wParticipantCount]
	ld b, a
	jr z, .setBaseValue
	add a
.setBaseValue
	ld b, a
	ld d, PARTY_LENGTH
	ld a, [wBattleParticipantsNotFainted]
	ld e, a
	ld a, b
	ld hl, wParticipantEXPDivisors
.participantLoop
	srl e
	jr nc, .nextParticipant
	ld [hl], a
.nextParticipant
	inc hl
	dec d
	jr nz, .participantLoop
; next up, calc exp split flags
; behavior heavily changes depending on exp splitting flag
	mboptionload EXP_SPLITTING
	jr z, .vanillaSplitting ; vanilla behavior
	cp EXP_SPLITTING_GEN8 << EXP_SPLITTING
	jr z, .splitToNonParticipants ; gen8 = always split to non-participants
	ld a, EXP_SHARE_GEN67
	ld [wCurItem], a
	ld hl, wNumItems
	call CheckItem
	ret nc ; gen6/7 = only split to non-participants if item in bag
.splitToNonParticipants
; give 50% exp to ALL alive non-participants
	ld c, 0
	ld b, c
	ld de, wParticipantEXPDivisors
	ld hl, wPartyMon1 + MON_HP
.splitLoop1
	push hl
	ld a, [de]
	and a
	jr nz, .nextSplit ; don't give to participants
	ld a, [hli]
	or [hl]
	jr z, .nextSplit ; don't give to dedmons
	ld hl, wSharedEXPDivisors
	add hl, bc
	ld [hl], 2
.nextSplit
	pop hl
	inc de
	push bc
	ld c, PARTYMON_STRUCT_LENGTH
	add hl, bc
	pop bc
	inc c
	ld a, [wPartyCount]
	cp c
	jr nz, .splitLoop1
	ret
.vanillaSplitting
; split exp/(2*numholders) to all alive exp share holders
	call IsAnyMonHoldingExpShare
	ret z
	ld a, [wPartyCount]
	ld b, a
	ld hl, wSharedEXPDivisors
.splitLoop2
	srl d
	jr nc, .nextSplit2
	ld a, e
	add a ; 2*numholders
	ld [hl], a
.nextSplit2
	inc hl
	dec b
	jr nz, .splitLoop2
	ret

; test for exp share
; returns nz if holding, z if none holding
; also d = bitfield of mons holding, e = number of mons holding
IsAnyMonHoldingExpShare:
	ld a, [wPartyCount]
	ld b, a
	ld hl, wPartyMon1
	ld c, 1
	ld d, 0
.loop
	push hl
	push bc
	ld bc, MON_HP
	add hl, bc
	ld a, [hli]
	or [hl]
	pop bc
	pop hl
	jr z, .next

	push hl
	push bc
	ld bc, MON_ITEM
	add hl, bc
	pop bc
	ld a, [hl]
	pop hl

	cp EXP_SHARE
	jr nz, .next
	ld a, d
	or c
	ld d, a

.next
	sla c
	push de
	ld de, PARTYMON_STRUCT_LENGTH
	add hl, de
	pop de
	dec b
	jr nz, .loop

	ld a, d
	ld e, 0
	ld b, PARTY_LENGTH
.loop2
	srl a
	jr nc, .okay
	inc e

.okay
	dec b
	jr nz, .loop2
	ld a, e
	and a
	ret

Text_MonGainedExpPoint:
	text_far Text_Gained
	text_asm
	ld a, [wStringBuffer2]
	and a
	jr nz, .longEXP
	ld a, [wStringBuffer2 + 1]
	cp $27
	jr nc, .longEXP

	ld hl, ExpPointsText
	ld a, [wStringBuffer2 + 3] ; IsTradedMon
	and a
	ret z

	ld hl, BoostedExpPointsText
	ret

.longEXP
	ld hl, ExpPointsLongText
	ld a, [wStringBuffer2 + 3] ; IsTradedMon
	and a
	ret z

	ld hl, BoostedExpPointsLongText
	ret

BoostedExpPointsText:
	text_far _BoostedExpPointsText
	text_end

ExpPointsText:
	text_far _ExpPointsText
	text_end

BoostedExpPointsLongText:
	text_far _BoostedExpPointsLongText
	text_end

ExpPointsLongText:
	text_far _ExpPointsLongText
	text_end

GainedWithShareText:
	text_asm
	mboptioncheck EXP_SPLITTING, GEN67
	ld hl, PartyGainedWithExpShareText
	ret z
	ld hl, PartyGainedText
	ret
	
PartyGainedWithExpShareText:
	text_far _PartyGainedWithExpShareText
	text_end
	
PartyGainedText:
	text_far _PartyGainedText
	text_end

AnimateExpBar:
	push bc

	ld hl, wCurPartyMon
	ld a, [wCurBattleMon]
	cp [hl]
	jp nz, .finish

	ld a, [wBattleMonLevel]
	cp MAX_LEVEL
	jp nc, .finish

	ldh a, [hProduct + 3]
	ld [wd004], a
	push af
	ldh a, [hProduct + 2]
	ld [wd003], a
	push af
	ldh a, [hProduct + 1]
	ld [wd002], a
	push af
	xor a ; PARTYMON
	ld [wMonType], a
	predef CopyMonToTempMon
	ld a, [wTempMonLevel]
	ld b, a
	ld e, a
	push de
	ld de, wTempMonExp + 2
	call CalcExpBar
	push bc
	ld hl, wTempMonExp + 2
	ld a, [wd004]
	add [hl]
	ld [hld], a
	ld a, [wd003]
	adc [hl]
	ld [hld], a
	ld a, [wd002]
	adc [hl]
	ld [hl], a
	jr nc, .NoOverflow
	ld a, $ff
	ld [hli], a
	ld [hli], a
	ld [hl], a

.NoOverflow:
	ld d, MAX_LEVEL
	callfar CalcExpAtLevel
	ldh a, [hProduct + 1]
	ld b, a
	ldh a, [hProduct + 2]
	ld c, a
	ldh a, [hProduct + 3]
	ld d, a
	ld hl, wTempMonExp + 2
	ld a, [hld]
	sub d
	ld a, [hld]
	sbc c
	ld a, [hl]
	sbc b
	jr c, .AlreadyAtMaxExp
	ld a, b
	ld [hli], a
	ld a, c
	ld [hli], a
	ld a, d
	ld [hld], a

.AlreadyAtMaxExp:
	callfar CalcLevel
	ld a, d
	pop bc
	pop de
	ld d, a
	cp e
	jr nc, .LoopLevels
	ld a, e
	ld d, a

.LoopLevels:
	ld a, e
	cp MAX_LEVEL
	jr nc, .FinishExpBar
	cp d
	jr z, .FinishExpBar
	inc a
	ld [wTempMonLevel], a
	ld [wCurPartyLevel], a
	ld [wBattleMonLevel], a
	push de
	call .PlayExpBarSound
	ld c, $40
	farcall _CheckBattleScene2
	call nz, .LoopBarAnimation
	call PrintPlayerHUD
	ld hl, wBattleMonNick
	ld de, wStringBuffer1
	ld bc, MON_NAME_LENGTH
	call CopyBytes
	call TerminateExpBarSound
	ld de, SFX_HIT_END_OF_EXP_BAR
	call PlaySFX
	farcall AnimateEndOfExpBar
	call WaitSFX
	ld hl, BattleText_StringBuffer1GrewToLevel
	call StdBattleTextbox
	pop de
	inc e
	ld b, $0
	jr .LoopLevels

.FinishExpBar:
	push bc
	ld b, d
	ld de, wTempMonExp + 2
	call CalcExpBar
	ld a, b
	pop bc
	ld c, a
	call .PlayExpBarSound
	farcall _CheckBattleScene2
	call nz, .LoopBarAnimation
	call TerminateExpBarSound
	pop af
	ldh [hProduct + 1], a
	pop af
	ldh [hProduct + 2], a
	pop af
	ldh [hProduct + 3], a

.finish
	pop bc
	ret

.PlayExpBarSound:
	push bc
	call WaitSFX
	ld de, SFX_EXP_BAR
	call PlaySFX
	ld c, 10
	call DelayFrames
	pop bc
	ret

.LoopBarAnimation:
	ld d, 3
	dec b
.anim_loop
	inc b
	push bc
	push de
	hlcoord 17, 11
	call PlaceExpBar
	pop de
	ld a, $1
	ldh [hBGMapMode], a
	ld c, d
	call DelayFrames
	xor a
	ldh [hBGMapMode], a
	pop bc
	ld a, c
	cp b
	jr z, .end_animation
	inc b
	push bc
	push de
	hlcoord 17, 11
	call PlaceExpBar
	pop de
	ld a, $1
	ldh [hBGMapMode], a
	ld c, d
	call DelayFrames
	xor a
	ldh [hBGMapMode], a
	dec d
	jr nz, .min_number_of_frames
	ld d, 1
.min_number_of_frames
	pop bc
	ld a, c
	cp b
	jr nz, .anim_loop
.end_animation
	ld a, $1
	ldh [hBGMapMode], a
	ret
