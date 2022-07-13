EvolvePokemon:
	ld hl, wEvolvableFlags
	xor a
	ld [hl], a
	ld a, [wCurPartyMon]
	ld c, a
	ld b, SET_FLAG
	call EvoFlagAction
EvolveAfterBattle:
	xor a
	ld [wMonTriedToEvolve], a
	dec a
	ld [wCurPartyMon], a
	push hl
	push bc
	push de
	ld hl, wPartyCount

	push hl

EvolveAfterBattle_MasterLoop:
	ld hl, wCurPartyMon
	inc [hl]

	pop hl

	inc hl
	ld a, [hl]
	cp $ff
	jp z, .ReturnToMap

	ld [wEvolutionOldSpecies], a

	push hl
	ld a, [wCurPartyMon]
	ld c, a
	ld hl, wEvolvableFlags
	ld b, CHECK_FLAG
	call EvoFlagAction
	ld a, c
	and a
	jp z, EvolveAfterBattle_MasterLoop

	ld a, [wEvolutionOldSpecies]
	dec a
	ld b, 0
	ld c, a
	ld hl, EvosAttacksPointers
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a

	push hl
	xor a
	ld [wMonType], a
	predef CopyMonToTempMon
	pop hl

.loop
	ld a, [hli]
	and a
	jr z, EvolveAfterBattle_MasterLoop

	ld b, a

	cp EVOLVE_TRADE
	jp z, .trade

	ld a, [wLinkMode]
	and a
	jp nz, .dont_evolve_2

	ld a, b
	cp EVOLVE_ITEM
	jp z, .item

	ld a, [wForceEvolution]
	and a
	jp nz, .dont_evolve_2
	
	ld a, b
	cp EVOLVE_E_LEVEL
	jp z, .every_level
	
	cp EVOLVE_LEVEL
	jp z, .level

	cp EVOLVE_HAPPINESS
	jr z, .happiness
	
	cp EVOLVE_STAT
	jr z, .stat

	jp .dont_evolve_1

.stat
	ld a, [wTempMonLevel]
	cp [hl]
	jp c, .dont_evolve_1

	call IsMonHoldingEverstone
	jp z, .dont_evolve_1

	push hl
	ld de, wTempMonAttack
	ld hl, wTempMonDefense
	ld c, 2
	call CompareBytes
	ld a, ATK_EQ_DEF
	jr z, .got_tyrogue_evo
	ld a, ATK_LT_DEF
	jr c, .got_tyrogue_evo
	ld a, ATK_GT_DEF
.got_tyrogue_evo
	pop hl

	inc hl
	cp [hl]
	jp nz, .dont_evolve_2

	inc hl
	jp .proceed

.happiness
	ld a, [wTempMonHappiness]
	cp HAPPINESS_TO_EVOLVE
	jp c, .dont_evolve_2

	call IsMonHoldingEverstone
	jp z, .dont_evolve_2

	ld a, [hli]
	cp TR_ANYTIME
	jp z, .proceed
	cp TR_MORNDAY
	jr z, .happiness_daylight

; TR_NITE
	ld a, [wTimeOfDay]
	cp NITE_F
	jp nz, .dont_evolve_3
	jp .proceed

.happiness_daylight
	ld a, [wTimeOfDay]
	cp NITE_F
	jp z, .dont_evolve_3
	jp .proceed

.trade
	ld a, [wLinkMode]
	and a
	jp z, .dont_evolve_2

	call IsMonHoldingEverstone
	jp z, .dont_evolve_2

	ld a, [hli]
	ld b, a
	inc a
	jp z, .proceed

	ld a, [wLinkMode]
	cp LINK_TIMECAPSULE
	jp z, .dont_evolve_3

	ld a, [wTempMonItem]
	cp b
	jp nz, .dont_evolve_3

	xor a
	ld [wTempMonItem], a
	jp .proceed

.item
	ld a, [hli]
	ld b, a
	ld a, [wCurItem]
	cp b
	jp nz, .dont_evolve_3

	ld a, [wForceEvolution]
	and a
	jp z, .dont_evolve_3
	ld a, [wLinkMode]
	and a
	jp nz, .dont_evolve_3
	jp .proceed

.level
	push af
	push bc
	push de
	push hl
	
	sboptioncheck EVOLVE_EVERY_LEVEL
	jr z, .level2
	
	pop hl
	pop de
	pop bc
	pop af
	
	jp .dont_evolve_2
	
.level2
	pop hl
	pop de
	pop bc
	pop af

	ld a, [hli]
	ld b, a
	ld a, [wTempMonLevel]
	cp b
	jp c, .dont_evolve_3
	call IsMonHoldingEverstone
	jp z, .dont_evolve_3
	
	jp .proceed

.every_level
	push af
	push bc
	push de
	push hl
	
	sboptioncheck EVOLVE_EVERY_LEVEL
	jr nz, .every_level2
	
	pop hl
	pop de
	pop bc
	pop af
	
	jp .dont_evolve_4
	
.every_level2
	pop hl
	pop de
	pop bc
	pop af
	
	jp .proceed_every_level

.proceed
	ld a, [wTempMonLevel]
	ld [wCurPartyLevel], a
	ld a, $1
	ld [wMonTriedToEvolve], a

	push hl

	ld a, [hl]
	ld [wEvolutionNewSpecies], a
	ld a, [wCurPartyMon]
	ld hl, wPartyMonNicknames
	call GetNick
	call CopyName1
	ld hl, EvolvingText
	call PrintText

	ld c, 50
	call DelayFrames

	xor a
	ldh [hBGMapMode], a
	hlcoord 0, 0
	lb bc, 12, 20
	call ClearBox

	ld a, $1
	ldh [hBGMapMode], a
	call ClearSprites

	farcall EvolutionAnimation

	push af
	call ClearSprites
	pop af
	jp c, CancelEvolution

	ld hl, CongratulationsYourPokemonText
	call PrintText

	pop hl

	ld a, [hl]
	ld [wCurSpecies], a
	ld [wTempMonSpecies], a
	ld [wEvolutionNewSpecies], a
	ld [wNamedObjectIndexBuffer], a
	call GetPokemonName

	push hl
	ld hl, EvolvedIntoText
	call PrintTextboxText

	ld de, MUSIC_NONE
	call PlayMusic
	ld de, SFX_CAUGHT_MON
	call PlaySFX
	call WaitSFX

	ld c, 40
	call DelayFrames

	call ClearTilemap
	call UpdateSpeciesNameIfNotNicknamed
	call GetBaseData

	ld hl, wTempMonExp + 2
	ld de, wTempMonMaxHP
	ld b, TRUE
	predef CalcMonStats

	ld a, [wCurPartyMon]
	ld hl, wPartyMons
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	ld e, l
	ld d, h
	ld bc, MON_MAXHP
	add hl, bc
	ld a, [hli]
	ld b, a
	ld c, [hl]
	ld hl, wTempMonMaxHP + 1
	ld a, [hld]
	sub c
	ld c, a
	ld a, [hl]
	sbc b
	ld b, a
	ld hl, wTempMonHP + 1
	ld a, [hl]
	add c
	ld [hld], a
	ld a, [hl]
	adc b
	ld [hl], a

	ld hl, wTempMonSpecies
	ld bc, PARTYMON_STRUCT_LENGTH
	call CopyBytes

	ld a, [wCurSpecies]
	ld [wTempSpecies], a
	xor a
	ld [wMonType], a
	call LearnLevelMoves
	ld a, [wTempSpecies]
	dec a
	call SetSeenAndCaughtMon

	ld a, [wTempSpecies]
	cp UNOWN
	jr nz, .skip_unown

	ld hl, wTempMonDVs
	predef GetUnownLetter
	callfar UpdateUnownDex

.skip_unown
	pop de
	pop hl
	ld a, [wTempMonSpecies]
	ld [hl], a
	push hl
	ld l, e
	ld h, d
	jp EvolveAfterBattle_MasterLoop
	
.proceed_every_level:
	ld a, [wTempMonLevel]
	ld [wCurPartyLevel], a
	ld a, $1
	ld [wMonTriedToEvolve], a

	push hl

	; generates pseudo-random evolution
	push de

	ld a, [wTempMonLevel]	; current level
	
	ld d, a					; save current value
	ld a, [wTempMonSpecies]	; current species ID
	add d					; add saved value
	
	ld d, a					; save current value
	ld a, [wPlayerID]		; Trainer ID high byte?
	add d					; add saved value
	ld d, a					; save current value
	ld a, [wPlayerID + 1]	; Trainer ID low byte?
	add d					; add saved value
	
	ld d, a					; save current value
	ld a, [wTempMonDVs]		; ATK/DEF DVs
	add d					; add saved value
	ld d, a					; save current value
	ld a, [wTempMonDVs + 1]	; SPD/SPC DVs
	add d					; add saved value
	
	ld d, a					; storing current result in d
	
	; check for invalid new species IDs (0 and 252-255 are invalid)
	; subtract 1 first, so 251-255 are invalid (fixing if necessary), then add 1 at the end
	sub 1
	ld d, a					; save current value
	cp 252					; c flag will be set if a < 252 (valid number)
	jp c, .valid_id
	
	ld a, d
	add 6					; fixes 251-255 so they wrap around to 1-5 (includes previous offset)
	jp .done_fixing_id
	
.valid_id:
	ld a, d
	add 1					; undo previous offset

.done_fixing_id:
	
	; a should now have a pseudo-random value 1-251 for selecting a new species for the evo.
	
	ld [wBuffer8], a	; saves new species to wram
	ld [wEvolutionNewSpecies], a
	
	pop de
	
	ld a, [wCurPartyMon]
	ld hl, wPartyMonNicknames
	call GetNick
	call CopyName1
	ld hl, EvolvingTextEL
	call PrintText

	ld c, 50
	call DelayFrames

	xor a
	ldh [hBGMapMode], a
	hlcoord 0, 0
	lb bc, 12, 20
	call ClearBox

	ld a, $1
	ldh [hBGMapMode], a
	call ClearSprites

	farcall EvolutionAnimation

	push af
	call ClearSprites
	pop af
	jp c, CancelEvolution

	ld hl, CongratulationsYourPokemonText
	call PrintText

	pop hl

	ld a, [wBuffer8] ; load the previously calculated new pokemon species
	;ld a, [hl]
	ld [wCurSpecies], a
	ld [wTempMonSpecies], a
	ld [wEvolutionNewSpecies], a
	ld [wNamedObjectIndexBuffer], a
	call GetPokemonName

	push hl
	ld hl, EvolvedIntoText
	call PrintTextboxText

	ld de, MUSIC_NONE
	call PlayMusic
	ld de, SFX_CAUGHT_MON
	call PlaySFX
	call WaitSFX

	ld c, 40
	call DelayFrames

	call ClearTilemap
	call UpdateSpeciesNameIfNotNicknamed
	call GetBaseData

	ld hl, wTempMonExp + 2
	ld de, wTempMonMaxHP
	ld b, TRUE
	predef CalcMonStats

	ld a, [wCurPartyMon]
	ld hl, wPartyMons
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	ld e, l
	ld d, h
	ld bc, MON_MAXHP
	add hl, bc
	ld a, [hli]
	ld b, a
	ld c, [hl]
	ld hl, wTempMonMaxHP + 1
	ld a, [hld]
	sub c
	ld c, a
	ld a, [hl]
	sbc b
	ld b, a
	ld hl, wTempMonHP + 1
	ld a, [hl]
	add c
	ld [hld], a
	ld a, [hl]
	adc b
	ld [hl], a

	ld hl, wTempMonSpecies
	ld bc, PARTYMON_STRUCT_LENGTH
	call CopyBytes

	ld a, [wCurSpecies]
	ld [wTempSpecies], a
	xor a
	ld [wMonType], a
	call LearnLevelMoves
	ld a, [wTempSpecies]
	dec a
	call SetSeenAndCaughtMon

	ld a, [wTempSpecies]
	cp UNOWN
	jr nz, .skip_unown_every_level

	ld hl, wTempMonDVs
	predef GetUnownLetter
	callfar UpdateUnownDex

.skip_unown_every_level:
	pop de
	pop hl
	ld a, [wTempMonSpecies]
	ld [hl], a
	push hl
	ld l, e
	ld h, d
	jp EvolveAfterBattle_MasterLoop

.dont_evolve_1
	inc hl
.dont_evolve_2
	inc hl
.dont_evolve_3
	inc hl
.dont_evolve_4	
	jp .loop

; unused
	pop hl
.ReturnToMap:
	pop de
	pop bc
	pop hl
	ld a, [wLinkMode]
	and a
	ret nz
	ld a, [wBattleMode]
	and a
	ret nz
	ld a, [wMonTriedToEvolve]
	and a
	call nz, RestartMapMusic
	ret

UpdateSpeciesNameIfNotNicknamed:
	ld a, [wCurSpecies]
	push af
	ld a, [wBaseDexNo]
	ld [wNamedObjectIndexBuffer], a
	call GetPokemonName
	pop af
	ld [wCurSpecies], a
	ld hl, wStringBuffer1
	ld de, wStringBuffer2
.loop
	ld a, [de]
	inc de
	cp [hl]
	inc hl
	ret nz
	cp "@"
	jr nz, .loop

	ld a, [wCurPartyMon]
	ld bc, MON_NAME_LENGTH
	ld hl, wPartyMonNicknames
	call AddNTimes
	push hl
	ld a, [wCurSpecies]
	ld [wNamedObjectIndexBuffer], a
	call GetPokemonName
	ld hl, wStringBuffer1
	pop de
	ld bc, MON_NAME_LENGTH
	jp CopyBytes

CancelEvolution:
	ld hl, StoppedEvolvingText
	call PrintText
	call ClearTilemap
	pop hl
	jp EvolveAfterBattle_MasterLoop

IsMonHoldingEverstone:
	push hl
	ld a, [wCurPartyMon]
	ld hl, wPartyMon1Item
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	ld a, [hl]
	cp EVERSTONE
	pop hl
	ret

CongratulationsYourPokemonText:
	text_far _CongratulationsYourPokemonText
	text_end

EvolvedIntoText:
	text_far _EvolvedIntoText
	text_end

StoppedEvolvingText:
	text_far _StoppedEvolvingText
	text_end

EvolvingText:
	text_far _EvolvingText
	text_end
	
EvolvingTextEL:
	text_far _EvolvingTextEL
	text_end

LearnLevelMoves:
	ld a, [wTempSpecies]
	ld [wCurPartySpecies], a
	dec a
	ld b, 0
	ld c, a
	ld hl, EvosAttacksPointers
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a

.skip_evos
	ld a, [hli]
	and a
	jr nz, .skip_evos

.find_move
	ld a, [hli]
	and a
	jr z, .done

	ld b, a
	ld a, [wCurPartyLevel]
	cp b
	ld a, [hli]
	jr nz, .find_move

	push hl
	ld d, a
	ld hl, wPartyMon1Moves
	ld a, [wCurPartyMon]
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes

	ld b, NUM_MOVES
.check_move
	ld a, [hli]
	cp d
	jr z, .has_move
	dec b
	jr nz, .check_move
	jr .learn
.has_move

	pop hl
	jr .find_move

.learn
	ld a, d
	ld [wPutativeTMHMMove], a
	ld [wNamedObjectIndexBuffer], a
	call GetMoveName
	call CopyName1
	predef LearnMove
	pop hl
	jr .find_move

.done
	ld a, [wCurPartySpecies]
	ld [wTempSpecies], a
	ret

FillMoves:
; Fill in moves at de for wCurPartySpecies at wCurPartyLevel

	push hl
	push de
	push bc
	ld hl, EvosAttacksPointers
	ld b, 0
	ld a, [wCurPartySpecies]
	dec a
	add a
	rl b
	ld c, a
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
.GoToAttacks:
	ld a, [hli]
	and a
	jr nz, .GoToAttacks
	jr .GetLevel

.NextMove:
	pop de
.GetMove:
	inc hl
.GetLevel:
	ld a, [hli]
	and a
	jp z, .done
	ld b, a
	ld a, [wCurPartyLevel]
	cp b
	jp c, .done
	ld a, [wEvolutionOldSpecies]
	and a
	jr z, .CheckMove
	ld a, [wd002]
	cp b
	jr nc, .GetMove

.CheckMove:
	push de
	ld c, NUM_MOVES
.CheckRepeat:
	ld a, [de]
	inc de
	cp [hl]
	jr z, .NextMove
	dec c
	jr nz, .CheckRepeat
	pop de
	push de
	ld c, NUM_MOVES
.CheckSlot:
	ld a, [de]
	and a
	jr z, .LearnMove
	inc de
	dec c
	jr nz, .CheckSlot
	pop de
	push de
	push hl
	ld h, d
	ld l, e
	call ShiftMoves
	ld a, [wEvolutionOldSpecies]
	and a
	jr z, .ShiftedMove
	push de
	ld bc, wPartyMon1PP - (wPartyMon1Moves + NUM_MOVES - 1)
	add hl, bc
	ld d, h
	ld e, l
	call ShiftMoves
	pop de

.ShiftedMove:
	pop hl

.LearnMove:
	ld a, [hl]
	ld [de], a
	ld a, [wEvolutionOldSpecies]
	and a
	jr z, .NextMove
	push hl
	ld a, [hl]
	ld hl, MON_PP - MON_MOVES
	add hl, de
	push hl
	dec a
	call LoadHLMovesPlusPP
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte
	pop hl
	ld [hl], a
	pop hl
	jr .NextMove

.done
	pop bc
	pop de
	pop hl
	ret

ShiftMoves:
	ld c, NUM_MOVES - 1
.loop
	inc de
	ld a, [de]
	ld [hli], a
	dec c
	jr nz, .loop
	ret

EvoFlagAction:
	push de
	ld d, $0
	predef SmallFarFlagAction
	pop de
	ret

GetPreEvolution:
; Find the first mon to evolve into wCurPartySpecies.

; Return carry and the new species in wCurPartySpecies
; if a pre-evolution is found.

	ld c, 0
.loop ; For each Pokemon...
	ld hl, EvosAttacksPointers
	ld b, 0
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
.loop2 ; For each evolution...
	ld a, [hli]
	and a
	jr z, .no_evolve ; If we jump, this Pokemon does not evolve into wCurPartySpecies.
	cp EVOLVE_STAT ; This evolution type has the extra parameter of stat comparison.
	jr nz, .not_tyrogue
	inc hl

.not_tyrogue
	inc hl
	ld a, [wCurPartySpecies]
	cp [hl]
	jr z, .found_preevo
	inc hl
	ld a, [hl]
	and a
	jr nz, .loop2

.no_evolve
	inc c
	ld a, c
	cp NUM_POKEMON
	jr c, .loop
	and a
	ret

.found_preevo
	inc c
	ld a, c
	ld [wCurPartySpecies], a
	scf
	ret
