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
; do the big mama calculation
	xor a
	ldh [hBigDivisor], a
	ldh [hBigDivisor + 1], a
	call BigDivide
; move the result
	ldh a, [hBigDivisionResult + 3]
	ldh [hQuotient + 1], a
	ldh a, [hBigDivisionResult + 4]
	ldh [hQuotient + 2], a
	ldh a, [hBigDivisionResult + 5]
	ldh [hQuotient + 3], a
; todo lucky egg and traded
	pop bc
	ret
	
BigMult:
; 32bit * 16bit, 48bit result
; inputs: 16bit in de, 32bit in hBigMultiplicand + 2 .. 5
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
; 48bit / 48bit, 48bit result but it'll definitely be 24bits or less
num_bytes = 6
; check for div/0 and don't divide at all if it happens
bnum = num_bytes
rept num_bytes
bnum = bnum - 1
	ldh a, [hBigDivisor + bnum]
	and a
	jr nz, .dontquit
endr
	ret
.dontquit
; clear result and shifter
	xor a
bnum = 0
rept num_bytes - 1
	ldh [hBigDivisionResult + bnum], a
	ldh [hBigDivisionShift + bnum], a
bnum = bnum + 1
endr
	ldh [hBigDivisionResult + bnum], a
	inc a ; a = 1 for final byte of the shifter
	ldh [hBigDivisionShift + bnum], a
; setup for the division
.setup
	ld hl, hBigDivisor
	ld de, hBigDividend
	call BigDivide_Compare
	jr nc, .loop
	ld hl, hBigDivisor + num_bytes - 1
	call BigDivide_LeftShift
	ld hl, hBigDivisionShift + num_bytes - 1
	call BigDivide_LeftShift
	jr .setup
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
	ld hl, hBigDivisionShift
	call BigDivide_RightShift
	ret c ; if carry is set, the accumulator finished so we're done.
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
; set the appropriate answer bit when we do a division step
accblock: MACRO
	ldh a, [hBigDivisionShift + \1]
	and a
IF \1 == num_bytes - 1
	ret z
ELSE
	jr z, .not\1
ENDC
	ld d, a
	ldh a, [hBigDivisionResult + \1]
	or d
	ldh [hBigDivisionResult + \1], a
	ret
IF \1 < num_bytes - 1
.not\1
ENDC
ENDM
	accblock 0
	accblock 1
	accblock 2
	accblock 3
	accblock 4
	accblock 5
	
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
; Multiply experience by 1.5x (24bit instead of 16bit)
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

LevelFactorLookupTable:
	db $00, $00, $00, $00
	db $00, $00, $10, $00
	db $00, $00, $5A, $84
	db $00, $00, $F9, $66
	db $00, $02, $00, $00
	db $00, $03, $7E, $6F
	db $00, $05, $82, $E4
	db $00, $08, $1A, $45
	db $00, $0B, $50, $40
	db $00, $0F, $30, $00
	db $00, $13, $C3, $C4
	db $00, $19, $15, $09
	db $00, $1F, $2D, $50
	db $00, $26, $15, $30
	db $00, $2D, $D5, $F8
	db $00, $36, $76, $F8
	db $00, $40, $00, $00
	db $00, $4A, $78, $F8
	db $00, $55, $EA, $08
	db $00, $62, $58, $EE
	db $00, $6F, $CD, $E0
	db $00, $7E, $4E, $42
	db $00, $8D, $E2, $B0
	db $00, $9E, $90, $7C
	db $00, $B0, $5C, $80
	db $00, $C3, $50, $00
	db $00, $D7, $70, $18
	db $00, $EC, $BE, $AB
	db $01, $03, $48, $A0
	db $01, $1B, $0F, $FA
	db $01, $34, $19, $0C
	db $01, $4E, $6B, $96
	db $01, $6A, $08, $00
	db $01, $86, $FE, $6A
	db $01, $A5, $4B, $30
	db $01, $C4, $F1, $E8
	db $01, $E6, $00, $00
	db $02, $08, $74, $DB
	db $02, $2C, $54, $24
	db $02, $51, $AD, $2C
	db $02, $78, $72, $40
	db $02, $A0, $B9, $23
	db $02, $CA, $7F, $A4
	db $02, $F5, $C9, $53
	db $03, $22, $A1, $20
	db $03, $51, $03, $5D
	db $03, $80, $F3, $10
	db $03, $B2, $84, $51
	db $03, $E5, $AA, $00
	db $04, $1A, $70, $00
	db $04, $50, $D9, $CC
	db $04, $88, $EA, $BB
	db $04, $C2, $B0, $90
	db $04, $FE, $19, $A3
	db $05, $3B, $3E, $6C
	db $05, $7A, $22, $F9
	db $05, $BA, $BF, $00
	db $05, $FD, $15, $0C
	db $06, $41, $34, $A8
	db $06, $87, $21, $76
	db $06, $CE, $D0, $F0
	db $07, $18, $62, $2F
	db $07, $63, $BB, $F0
	db $07, $B0, $EF, $7F
	db $08, $00, $00, $00
	db $08, $50, $F0, $7F
	db $08, $A3, $C3, $F0
	db $08, $F8, $7D, $2F
	db $09, $4F, $1F, $00
	db $09, $A7, $BE, $A8
	db $0A, $02, $4D, $38
	db $0A, $5E, $CD, $32
	db $0A, $BD, $41, $00
	db $0B, $1D, $AA, $F4
	db $0B, $80, $22, $AC
	db $0B, $E4, $96, $10
	db $0C, $4B, $1D, $C0
	db $0C, $B3, $A6, $56
	db $0D, $1E, $49, $7C
	db $0D, $8A, $F2, $76
	db $0D, $F9, $BC, $00
	db $0E, $6A, $90, $00
	db $0E, $DD, $8A, $4C
	db $0F, $52, $93, $64
	db $0F, $C9, $C8, $40
	db $10, $43, $2C, $2B
	db $10, $BE, $C2, $64
	db $11, $3C, $70, $8D
	db $11, $BC, $56, $00
	db $12, $3E, $75, $D2
	db $12, $C2, $B3, $68
	db $13, $49, $2F, $F9
	db $13, $D1, $EE, $70
	db $14, $5C, $F1, $AC
	db $14, $EA, $3C, $80
	db $15, $79, $D1, $B3
	db $16, $0B, $90, $00
	db $16, $9F, $C1, $55
	db $17, $36, $1F, $90
	db $17, $CE, $F7, $8B
	db $18, $6A, $00, $00
	db $19, $07, $60, $EC
	db $19, $A7, $45, $60
	db $1A, $49, $5F, $42
	db $1A, $ED, $D8, $C0
	db $1B, $94, $DF, $34
	db $1C, $3E, $1F, $8C
	db $1C, $E9, $C6, $39
	db $1D, $98, $02, $F0
	db $1E, $48, $7D, $83
	db $1E, $FB, $93, $FC
	db $1F, $B1, $1A, $D2
	db $20, $69, $14, $00
	db $21, $23, $81, $75
	db $21, $E0, $65, $14
	db $22, $9F, $F4, $5D
	db $23, $61, $CA, $B0
	db $24, $26, $52, $09
	db $24, $ED, $58, $78
	db $25, $B6, $DF, $AA
	db $26, $82, $E9, $40
	db $27, $51, $B0, $00
	db $28, $22, $FE, $28
	db $28, $F6, $D5, $3B
	db $29, $CD, $36, $B0
	db $2A, $A6, $60, $FB
	db $2B, $81, $DC, $64
	db $2C, $60, $64, $50
	db $2D, $41, $40, $00
	db $2E, $24, $EF, $BA
	db $2F, $0B, $35, $B8
	db $2F, $F4, $13, $29
	db $30, $DF, $89, $30
	db $31, $CD, $DD, $FD
	db $32, $BF, $15, $BC
	db $33, $B2, $A6, $37
	db $34, $A9, $1D, $C0
	db $35, $A2, $37, $26
	db $36, $9E, $3D, $B4
	db $37, $9C, $EA, $0B
	db $38, $9E, $89, $90
	db $39, $A2, $85, $05
	db $3A, $A9, $77, $64
	db $3B, $B3, $64, $B5
	db $3C, $C0, $00, $00
	db $3D, $CF, $49, $EA
	db $3E, $E1, $96, $50
	db $3F, $F6, $94, $C5
	db $41, $0E, $9B, $60
	db $42, $29, $57, $5E
	db $43, $47, $21, $18
	db $44, $67, $4A, $5C
	db $45, $8A, $DE, $C0
	db $46, $B1, $2E, $D9
	db $47, $DA, $3A, $F8
	db $49, $06, $61, $3B
	db $4A, $35, $46, $70
	db $4B, $67, $4B, $13
	db $4C, $9C, $11, $78
	db $4D, $D3, $FC, $81
	db $4F, $0E, $AC, $00
	db $50, $4C, $20, $04
	db $51, $8D, $25, $98
	db $52, $D0, $8C, $F6
	db $54, $17, $24, $60
	db $55, $60, $EF, $96
	db $56, $AD, $86, $B4
	db $57, $FD, $56, $84
	db $59, $4F, $F4, $80
	db $5A, $A5, $D0, $00
	db $5B, $FE, $7B, $D4
	db $5D, $5A, $69, $EA
	db $5E, $B9, $9D, $F0
	db $60, $1B, $31, $C2
	db $61, $80, $83, $B8
	db $62, $E8, $AC, $49
	db $64, $54, $24, $00
	db $65, $C2, $74, $1E
	db $67, $33, $9C, $1C
	db $68, $A8, $95, $B9
	db $6A, $20, $6B, $A0
	db $6B, $9B, $1D, $32
	db $6D, $19, $2B, $28
	db $6E, $9A, $99, $12
	db $70, $1E, $E6, $40
	db $71, $A6, $97, $A0
	db $73, $31, $29, $98
	db $74, $BF, $23, $EC
	db $76, $50, $8A, $20
	db $77, $E4, $D4, $2F
	db $79, $7C, $01, $2C
	db $7B, $17, $2D, $20
	db $7C, $B5, $40, $00
	db $7E, $56, $38, $C7
	db $7F, $FB, $3C, $6C
	db $81, $A3, $29, $DE
	db $83, $4E, $00, $00
	db $84, $FC, $55, $42
	db $86, $AE, $2D, $10
	db $88, $62, $F0, $25
	db $8A, $1B, $39, $80
	db $8B, $D7, $0C, $87
	db $8D, $95, $CD, $3C
	db $8F, $58, $1B, $3F
	db $91, $1D, $F9, $F0
	db $92, $E6, $C8, $86
	db $94, $B3, $2B, $54
	db $96, $82, $7E, $53
	db $98, $55, $69, $00
	db $9A, $2B, $EE, $AF
	db $9C, $06, $12, $B4

ExpYieldTable:
	bigdw 0
	bigdw 64
	bigdw 142
	bigdw 236
	bigdw 62
	bigdw 142
	bigdw 240
	bigdw 63
	bigdw 142
	bigdw 239
	bigdw 39
	bigdw 72
	bigdw 173
	bigdw 39
	bigdw 72
	bigdw 173
	bigdw 50
	bigdw 113
	bigdw 172
	bigdw 57
	bigdw 116
	bigdw 58
	bigdw 162
	bigdw 62
	bigdw 147
	bigdw 82
	bigdw 122
	bigdw 93
	bigdw 163
	bigdw 59
	bigdw 117
	bigdw 194
	bigdw 60
	bigdw 118
	bigdw 195
	bigdw 68
	bigdw 129
	bigdw 63
	bigdw 178
	bigdw 76
	bigdw 109
	bigdw 54
	bigdw 171
	bigdw 78
	bigdw 132
	bigdw 184
	bigdw 70
	bigdw 128
	bigdw 75
	bigdw 138
	bigdw 81
	bigdw 153
	bigdw 69
	bigdw 154
	bigdw 64
	bigdw 175
	bigdw 61
	bigdw 159
	bigdw 70
	bigdw 194
	bigdw 60
	bigdw 135
	bigdw 225
	bigdw 62
	bigdw 140
	bigdw 221
	bigdw 61
	bigdw 142
	bigdw 227
	bigdw 60
	bigdw 137
	bigdw 216
	bigdw 67
	bigdw 180
	bigdw 73
	bigdw 134
	bigdw 218
	bigdw 82
	bigdw 175
	bigdw 63
	bigdw 172
	bigdw 65
	bigdw 163
	bigdw 123
	bigdw 62
	bigdw 161
	bigdw 65
	bigdw 166
	bigdw 65
	bigdw 175
	bigdw 61
	bigdw 184
	bigdw 62
	bigdw 142
	bigdw 225
	bigdw 108
	bigdw 66
	bigdw 169
	bigdw 65
	bigdw 166
	bigdw 66
	bigdw 168
	bigdw 65
	bigdw 182
	bigdw 64
	bigdw 149
	bigdw 159
	bigdw 159
	bigdw 77
	bigdw 68
	bigdw 172
	bigdw 69
	bigdw 170
	bigdw 395
	bigdw 87
	bigdw 172
	bigdw 59
	bigdw 154
	bigdw 64
	bigdw 158
	bigdw 68
	bigdw 182
	bigdw 161
	bigdw 100
	bigdw 159
	bigdw 172
	bigdw 173
	bigdw 175
	bigdw 211
	bigdw 40
	bigdw 189
	bigdw 187
	bigdw 101
	bigdw 65
	bigdw 184
	bigdw 184
	bigdw 184
	bigdw 79
	bigdw 71
	bigdw 173
	bigdw 71
	bigdw 173
	bigdw 180
	bigdw 189
	bigdw 261
	bigdw 261
	bigdw 261
	bigdw 60
	bigdw 147
	bigdw 270
	bigdw 306
	bigdw 270
	bigdw 64
	bigdw 142
	bigdw 236
	bigdw 62
	bigdw 142
	bigdw 240
	bigdw 63
	bigdw 142
	bigdw 239
	bigdw 43
	bigdw 145
	bigdw 52
	bigdw 155
	bigdw 53
	bigdw 137
	bigdw 50
	bigdw 137
	bigdw 241
	bigdw 66
	bigdw 161
	bigdw 41
	bigdw 44
	bigdw 42
	bigdw 49
	bigdw 142
	bigdw 64
	bigdw 165
	bigdw 56
	bigdw 128
	bigdw 225
	bigdw 216
	bigdw 88
	bigdw 185
	bigdw 144
	bigdw 225
	bigdw 50
	bigdw 119
	bigdw 203
	bigdw 72
	bigdw 36
	bigdw 149
	bigdw 78
	bigdw 42
	bigdw 151
	bigdw 184
	bigdw 184
	bigdw 81
	bigdw 172
	bigdw 87
	bigdw 118
	bigdw 142
	bigdw 159
	bigdw 58
	bigdw 163
	bigdw 145
	bigdw 86
	bigdw 179
	bigdw 60
	bigdw 158
	bigdw 86
	bigdw 175
	bigdw 177
	bigdw 175
	bigdw 86
	bigdw 66
	bigdw 175
	bigdw 50
	bigdw 144
	bigdw 50
	bigdw 158
	bigdw 133
	bigdw 60
	bigdw 168
	bigdw 116
	bigdw 163
	bigdw 163
	bigdw 66
	bigdw 175
	bigdw 243
	bigdw 66
	bigdw 175
	bigdw 180
	bigdw 163
	bigdw 88
	bigdw 42
	bigdw 159
	bigdw 61
	bigdw 72
	bigdw 73
	bigdw 172
	bigdw 608
	bigdw 261
	bigdw 261
	bigdw 261
	bigdw 60
	bigdw 144
	bigdw 270
	bigdw 306
	bigdw 306
	bigdw 270
	bigdw 0
	bigdw 0
	bigdw 0
	bigdw 0
