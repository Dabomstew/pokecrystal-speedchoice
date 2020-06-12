sramstatmethod: MACRO
\1::
	ld hl, \1_
	jp SRAMStatsStart
	ENDM

	sramstatmethod SRAMStatsFrameCount

SRAMStatsFrameCount_::
	ld hl, sStatsFrameCount
	call FourByteIncrement
	ld hl, sStatsOWFrameCount
	ldh a, [hTimerType]
	sla a
	sla a
	add l
	ld l, a
	jr nc, .noOverflow
	inc h
.noOverflow
	call FourByteIncrement
	jp SRAMStatsEnd

	sramstatmethod SRAMStatsIncrement2Byte

SRAMStatsIncrement2Byte_::
	ld h, d
	ld l, e
	call TwoByteIncrement
	jp SRAMStatsEnd

	sramstatmethod SRAMStatsIncrement4Byte

SRAMStatsIncrement4Byte_::
	ld h, d
	ld l, e
	call FourByteIncrement
	jp SRAMStatsEnd

	sramstatmethod SRAMStatsTotalDamageTaken

SRAMStatsTotalDamageTaken_::
; curdamage is big endian
	ld hl, sStatsTotalDamageTaken
	ld a, [wCurDamage+1]
	add [hl]
	ld [hli], a
	ld a, [wCurDamage]
	adc [hl]
	ld [hli], a
	jp nc, SRAMStatsEnd
	call TwoByteIncrement
	jp SRAMStatsEnd

	sramstatmethod SRAMStatsActualDamageTaken

SRAMStatsActualDamageTaken_::
; lower of CurDamage and BattleMonHP
	ld hl, wCurDamage
	ld a, [wBattleMonHP]
	cp [hl]
	jr c, .useMonHP
	jr nz, .useDamage
	inc hl
	ld a, [wBattleMonHP+1]
	cp [hl]
	jr nc, .useDamagePostIncrement
.useMonHP
	ld hl, wBattleMonHP
.useDamage
	inc hl
.useDamagePostIncrement
	ld a, [sStatsActualDamageTaken]
	add [hl]
	ld [sStatsActualDamageTaken], a
	dec hl
	ld a, [sStatsActualDamageTaken+1]
	adc [hl]
	ld [sStatsActualDamageTaken+1], a
	jp nc, SRAMStatsEnd
	ld hl, sStatsActualDamageTaken+2
	call TwoByteIncrement
	jp SRAMStatsEnd

	sramstatmethod SRAMStatsTotalDamageDealt

SRAMStatsTotalDamageDealt_::
; curdamage is big endian
	ld hl, sStatsTotalDamageDealt
	ld a, [wCurDamage+1]
	add [hl]
	ld [hli], a
	ld a, [wCurDamage]
	adc [hl]
	ld [hli], a
	jp nc, SRAMStatsEnd
	call TwoByteIncrement
	jp SRAMStatsEnd

	sramstatmethod SRAMStatsActualDamageDealt

SRAMStatsActualDamageDealt_::
; lower of CurDamage and EnemyMonHP
	ld hl, wCurDamage
	ld a, [wEnemyMonHP]
	cp [hl]
	jr c, .useMonHP
	jr nz, .useDamage
	inc hl
	ld a, [wEnemyMonHP+1]
	cp [hl]
	jr nc, .useDamagePostIncrement
.useMonHP
	ld hl, wEnemyMonHP
.useDamage
	inc hl
.useDamagePostIncrement
	ld a, [sStatsActualDamageDealt]
	add [hl]
	ld [sStatsActualDamageDealt], a
	dec hl
	ld a, [sStatsActualDamageDealt+1]
	adc [hl]
	ld [sStatsActualDamageDealt+1], a
	jp nc, SRAMStatsEnd
	ld hl, sStatsActualDamageDealt+2
	call TwoByteIncrement
	jp SRAMStatsEnd

	sramstatmethod SRAMStatsStepCount

SRAMStatsStepCount_::
	ld hl, sStatsStepCount
	call FourByteIncrement
	ld a, [wPlayerState]
	ld hl, sStatsStepCountSurf
	cp PLAYER_SURF
	jr z, .increment
	cp PLAYER_SURF_PIKA
	jr z, .increment
	ld hl, sStatsStepCountBike
	cp PLAYER_BIKE
	jr z, .increment
	ld hl, sStatsStepCountWalk
.increment
	call FourByteIncrement
	jp SRAMStatsEnd

	sramstatmethod SRAMStatsBlackoutMoneyLoss

SRAMStatsBlackoutMoneyLoss_::
; add Buffer1-Buffer3 (big endian) to little endian money loss
	ld hl, sStatsMoneyLost
	ld a, [wBuffer3]
	add [hl]
	ld [hli], a
	ld a, [wBuffer2]
	adc [hl]
	ld [hli], a
	ld a, [wBuffer1]
	adc [hl]
	ld [hli], a
	jp nc, SRAMStatsEnd
	inc [hl]
	jp SRAMStatsEnd

	sramstatmethod SRAMStatsAddMoneyGain

SRAMStatsAddMoneyGain_::
; add [de] through [de-2] to little endian money gain
	ld hl, sStatsMoneyMade
	ld a, [de]
	add [hl]
	ld [hli], a
	dec de
	ld a, [de]
	adc [hl]
	ld [hli], a
	dec de
	ld a, [de]
	adc [hl]
	ld [hli], a
	jp nc, SRAMStatsEnd
	inc [hl]
	jp SRAMStatsEnd

	sramstatmethod SRAMStatsAddMoneySpent

SRAMStatsAddMoneySpent_::
; add [de] through [de-2] to little endian money spent
	ld hl, sStatsMoneySpent
	ld a, [de]
	add [hl]
	ld [hli], a
	dec de
	ld a, [de]
	adc [hl]
	ld [hli], a
	dec de
	ld a, [de]
	adc [hl]
	ld [hli], a
	jp nc, SRAMStatsEnd
	inc [hl]
	jp SRAMStatsEnd

	sramstatmethod SRAMStatsIncreaseItemsBought

SRAMStatsIncreaseItemsBought_::
; add [wItemQuantityChangeBuffer] to items bought
	ld hl, sStatsItemsBought
	ld a, [wItemQuantityChangeBuffer]
	add [hl]
	ld [hli], a
	jp nc, SRAMStatsEnd
	inc [hl]
	jp SRAMStatsEnd

	sramstatmethod SRAMStatsIncreaseItemsSold

SRAMStatsIncreaseItemsSold_::
; add [wItemQuantityChangeBuffer] to items sold
	ld hl, sStatsItemsSold
	ld a, [wItemQuantityChangeBuffer]
	add [hl]
	ld [hli], a
	jp nc, SRAMStatsEnd
	inc [hl]
	jp SRAMStatsEnd

	sramstatmethod SRAMStatsRecordCriticalHit

SRAMStatsRecordCriticalHit_::
	ld a, [wCriticalHit]
	and a
	jp z, SRAMStatsEnd
	dec a
	ld c, a
	ldh a, [hBattleTurn]
	sla a
	or c
	sla a
; add sStatsCriticalsDealt to (battleturn << 1 | hittype)*2 to get the correct field
	ld c, a
	ld b, 0
	ld hl, sStatsCriticalsDealt
	add hl, bc
	call TwoByteIncrement
	jp SRAMStatsEnd

	sramstatmethod SRAMStatsRecordMoveHitOrMiss

SRAMStatsRecordMoveHitOrMiss_::
	ld a, [wAttackMissed]
	and a
	jr z, .sideCheck
	ld a, 1
.sideCheck
	ld c, a
	ldh a, [hBattleTurn]
	sla a
	or c
	sla a
	ld c, a
	ld b, 0
	ld hl, sStatsOwnMovesHit
	add hl, bc
	call TwoByteIncrement
	jp SRAMStatsEnd

	sramstatmethod SRAMStatsRecordMoveEffectiveness

SRAMStatsRecordMoveEffectiveness_::
	ld a, [wTypeModifier]
	and $7f
	cp 10 ; 1.0
	jp z, SRAMStatsEnd
	ld a, 1 ; not very effective
	jr c, .sideCheck
	xor a ; super effective
.sideCheck
	ld c, a
	ldh a, [hBattleTurn]
	sla a
	or c
	sla a
	ld c, a
	ld b, 0
	ld hl, sStatsOwnMovesSE
	add hl, bc
	call TwoByteIncrement
	jp SRAMStatsEnd

	sramstatmethod SRAMStatsRecordEXPGain

SRAMStatsRecordEXPGain_::
; big endian EXP at hQuotient + 1, 3 bytes
	ld hl, sStatsExperienceGained
	ldh a, [hQuotient + 3]
	add [hl]
	ld [hli], a
	ldh a, [hQuotient + 2]
	adc [hl]
	ld [hli], a
	ldh a, [hQuotient + 1]
	adc [hl]
	ld [hli], a
	jp nc, SRAMStatsEnd
	inc [hl]
	jp SRAMStatsEnd

SRAMStatsStart::
; takes return address in hl
; check enable
	ldh a, [hStatsDisabled]
	and a
	ret nz
; enable sram for stat tracking
	ld a, SRAM_ENABLE
	ld [MBC3SRamEnable], a
; backup old sram bank
	ldh a, [hSRAMBank]
	push af
; switch to correct bank
	ld a, BANK(sStatsStart)
	ldh [hSRAMBank], a
	ld [MBC3SRamBank], a
; done, move to actual code
	jp hl

SRAMStatsEnd::
; restore old sram bank
	pop af
	ldh [hSRAMBank], a
	ld [MBC3SRamBank], a
	ret

FourByteIncrement::
; address in hl
	inc [hl]
	ret nz
	inc hl
	inc [hl]
	ret nz
	inc hl
TwoByteIncrement::
	inc [hl]
	ret nz
	inc hl
	inc [hl]
	ret
