; input bc = base of party mon entry
CalculateScalingExperienceGain:
; calculate z = floor(yield*level*trainer/7/divisor)
	push bc
	ld a, [wEnemyMonSpecies]
	ld c, a
	ld b, 0
	ld hl, ExpYieldTable
	add hl, bc
	add hl, bc
	xor a
	ldh [hMultiplicand], a
	ld a, [hli]
	ldh [hMultiplicand + 1], a
	ld a, [hl]
	ldh [hMultiplicand + 2], a
	ld a, [wEnemyMonLevel]
	cp MAX_LEVEL
	jr c, .notMaxLevel1
	ld a, MAX_LEVEL
.notMaxLevel1
	ldh [hMultiplier], a
	call Multiply
; trainer boost
	ld a, [wBattleMode]
	dec a
	call nz, BoostExpBW
; divide by 7
	ld a, 7
	ldh [hDivisor], a
	ld b, 4
	call Divide
; divide by divisor if >1
	ld a, [wCurrentDivisor]
	dec a
	jr z, .noDivisor
	inc a
	ldh [hDivisor], a
	ld b, 4
	call Divide
.noDivisor
	ldh a, [hQuotient + 2]
	ld d, a
	ldh a, [hQuotient + 3]
	ld e, a
; calculate 2*enemymonlevel + 10
	ld a, [wEnemyMonLevel]
	cp MAX_LEVEL
	jr c, .notMaxLevel2
	ld a, MAX_LEVEL
.notMaxLevel2
	add a
	add 10
	ld c, a
	ld b, 0
	ld hl, LevelFactorLookupTable
rept 4
	add hl, bc
endr
	push de
	ld de, hBigMultiplicand + 2
	ld bc, 4
	call CopyBytes
; multiply what we got by Z
	pop de
	call BigMult
	
; now get the level factor for the bottom: enemy level + our level + 10
; but if our level <= their level, do 2L+10 instead
	ld a, [wEnemyMonLevel]
	cp MAX_LEVEL
	jr c, .notMaxLevel3
	ld a, MAX_LEVEL
.notMaxLevel3
	ld d, a
	pop bc
	ld hl, MON_LEVEL
	add hl, bc
	ld a, [hl]
	cp d
	jr nc, .ourLevelNotLower
	cp MAX_LEVEL
	jr c, .loadLevel
	ld a, MAX_LEVEL
	jr .loadLevel
.ourLevelNotLower
	ld a, d
.loadLevel
	add d
	add 10
	push bc
	ld c, a
	ld b, 0
	ld hl, LevelFactorLookupTable
rept 4
	add hl, bc
endr
; move the result over to hBigDivisor
	ld de, hBigDivisor + 2
	ld bc, 4
	call CopyBytes
; do the big division
	xor a
	ldh [hBigDivisor], a
	ldh [hBigDivisor + 1], a
	call BigDivide
; move the result + 1 to hQuotient (should always fit in 24 bits)
	ldh a, [hBigDivisionResult + 5]
	add 1
	ldh [hQuotient + 3], a
	ldh a, [hBigDivisionResult + 4]
	adc 0
	ldh [hQuotient + 2], a
	ldh a, [hBigDivisionResult + 3]
	adc 0
	ldh [hQuotient + 1], a
; 1.5x exp + boosted flag if traded
	pop bc
	ld hl, MON_ID
	add hl, bc
	ld a, [wPlayerID]
	cp [hl]
	jr nz, .boosted
	inc hl
	ld a, [wPlayerID + 1]
	cp [hl]
	ld a, 0
	jr z, .no_boost

.boosted
	call BoostExpBW
	ld a, 1

.no_boost
; save boost flag value for the message
	ld [wStringBuffer2 + 3], a
; Boost experience for Lucky Egg
	ld a, MON_ITEM
	call GetPartyParamLocation
	ld a, [hl]
	cp LUCKY_EGG
	ret nz
	jp BoostExpBW
	
BigMult:
; 32bit * 16bit, 48bit result
; inputs: 32bit in hBigMultiplicand + 2 .. 5, 16bit in de
	ld b, 16
	xor a
	ldh [hBigMultiplicand], a
	ldh [hBigMultiplicand + 1], a
	ldh [hBigMultResultStore], a
	ldh [hBigMultResultStore + 1], a
	ldh [hBigMultResultStore + 2], a
	ldh [hBigMultResultStore + 3], a
	ldh [hBigMultResultStore + 4], a
	ldh [hBigMultResultStore + 5], a
.loop
	srl d
	rr e
	jr nc, .next
	ld hl, hBigMultiplicand + 5
	ldh a, [hBigMultResultStore + 5]
	add [hl]
	ldh [hBigMultResultStore + 5], a
offs = 4
REPT 5
	dec hl
	ldh a, [hBigMultResultStore + offs]
	adc [hl]
	ldh [hBigMultResultStore + offs], a
offs = offs - 1
ENDR

.next
	dec b
	jr z, .done
	ld hl, hBigMultiplicand + 5
	sla [hl]
    dec hl
REPT 5
    rl [hl]
    dec hl
ENDR
	jr .loop
	
.done
offs = 5
REPT 6
	ldh a, [hBigMultResultStore + offs]
	ldh [hBigProduct + offs], a
offs = offs - 1
ENDR
	ret
	
BigDivide:
; 48bit / 48bit, 48bit result but it'll definitely be 24bits or less for its use here
; can use for bigger/smaller values by adjusting num_bytes
num_bytes = 6
; check for div/0 and don't divide at all if it happens
	xor a
	ld hl, hBigDivisor + num_bytes - 1
rept num_bytes
	or [hl]
	jr nz, .dontquit
	dec hl
endr
	ret
.dontquit
; clear result and shifter
	xor a
	ld hl, hBigDivisionResult
rept num_bytes
	ld [hli], a
endr
	ld b, 1 ; shifter
; setup for the division
.setup
	ld hl, hBigDivisor
	ld de, hBigDividend
	call BigDivide_Compare
	jr nc, .zeroCheck
; to be foolproof, we would check the MSB of hBigDivisor here and jump directly to .loop if it's set
; for this use, this will never be the case, so it is skipped to save time
	ld hl, hBigDivisor + num_bytes - 1
	call BigDivide_LeftShift
	inc b
	jr .setup
.zeroCheck
; if b=1 (without MSB of hBigDivisor set) then divisor > dividend so the answer is 0, no need to do anything more
	dec b
	ret z
	inc b
.loop
	ld hl, hBigDivisor
	ld de, hBigDividend
	call BigDivide_Compare
	jr nc, .aftersubtract
	ld de, hBigDividend + num_bytes - 1
	ld hl, hBigDivisor + num_bytes - 1
	call BigDivide_Subtract
	call BigDivide_AccumulateAnswer
.aftersubtract
	dec b
	ret z ; done if b=0
	ld hl, hBigDivisor
	call BigDivide_RightShift
	jr .loop

BigDivide_Subtract:
; subtract value ending at [hl] from value ending at [de]
	ld a, [de]
	sub [hl]
	ld [de], a

rept num_bytes - 1
	dec de
	dec hl
	ld a, [de]
	sbc [hl]
	ld [de], a
endr

	ret

BigDivide_AccumulateAnswer:
	ld a, b
	dec a
	ld hl, hBigDivisionResult + num_bytes - 1
.byteCheck
	sub 8
	jr c, .setBit
	dec hl
	jr .byteCheck
.setBit
	add 8
	ld d, a
	add a
	add d
	ld de, BigDivide_SetBit0
	add e
	ld e, a
	jr nc, .doSet
	inc d
.doSet
	push de
	ret

BigDivide_SetBit0:
	set 0, [hl]
	ret

BigDivide_SetBit1:
	set 1, [hl]
	ret

BigDivide_SetBit2:
	set 2, [hl]
	ret

BigDivide_SetBit3:
	set 3, [hl]
	ret

BigDivide_SetBit4:
	set 4, [hl]
	ret

BigDivide_SetBit5:
	set 5, [hl]
	ret

BigDivide_SetBit6:
	set 6, [hl]
	ret

BigDivide_SetBit7:
	set 7, [hl]
	ret
	
BigDivide_Compare:
; sets carryflag if value starting at [hl] <= value starting at [de]
rept num_bytes - 1
	ld a, [de]
	cp [hl]
	jr c, .returnFalse
	jr nz, .returnTrue
	inc de
	inc hl
endr

	ld a, [de]
	cp [hl]
	jr c, .returnFalse
.returnTrue
	scf
	ret
.returnFalse
	and a
	ret

BigDivide_LeftShift:
; take hl = last address in memory
; shift it and the preceding bytes left
	sla [hl]

rept num_bytes - 1
	dec hl
	rl [hl]
endr

	ret

BigDivide_RightShift:
; take hl = first address in memory
; shift it and the following bytes right
	srl [hl]

rept num_bytes - 1
	inc hl
	rr [hl]
endr

	ret

BoostExpBW:
; Multiply experience by 1.5x (24bit)
; load experience value
	ldh a, [hProduct + 1]
	ld b, a
	ldh a, [hProduct + 2]
	ld c, a
	ldh a, [hProduct + 3]
	ld d, a
; halve it
	srl b
	rr c
	rr d
; add it back to the whole exp value
	add d
	ldh [hProduct + 3], a
	ldh a, [hProduct + 2]
	adc c
	ldh [hProduct + 2], a
	ldh a, [hProduct + 1]
	adc b
	ldh [hProduct + 1], a
	ret

INCLUDE "data/bwxp/experience_yields.asm"
INCLUDE "data/bwxp/level_factors.asm"
