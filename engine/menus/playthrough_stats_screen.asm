STATTYPE_2BYTE EQU $1
STATTYPE_4BYTE EQU $2
STATTYPE_MONEY EQU $3
STATTYPE_TIMER EQU $4
STATTYPE_2BYTE_COMPARE EQU $5
STATTYPE_4BYTE_COMPARE EQU $6
NUM_STAT_SCREENS EQUS "(PlaythroughStatsScreensEnd - PlaythroughStatsScreens)/4"

PlaythroughStatsScreen::
	ld de, MUSIC_MOBILE_CENTER
	call PlayMusic
	xor a
	ld [wOptionsMenuID], a
; stop stats (mainly frame counter) actually being counted
	inc a
	ldh [hStatsDisabled], a
; Open SRAM for stats
	ld a, BANK(sStatsStart)
	call OpenSRAM
	ld hl, hInMenu
	ld a, [hl]
	push af
	ld [hl], $1
	call ClearBGPalettes
.pageLoad
	call RetrievePlaythroughStatsConfig
	hlcoord 0, 0
	ld b, 16
	ld c, 18
	call Textbox
; render title
	ld hl, wPlayStatsStringPtr
	ld a, [hli]
	ld e, a
	ld d, [hl]
	hlcoord 1, 2
	call PlaceString
	hlcoord 1, 1
	ld de, PlayerStatsString
	call PlaceString
	call RenderStats
; render page display
	hlcoord 1, 16
	ld [hl], "←"
	hlcoord 18, 16
	ld [hl], "→"
	hlcoord 4, 16
	ld de, PSPageStartString
	call PlaceString
	ld a, [wOptionsMenuID]
	add a, "1"
	hlcoord 9, 16
	ld [hli], a
	inc hl
	ld de, PSPageOfString
	call PlaceString
	hlcoord 14, 16
	ld a, NUM_STAT_SCREENS + "0"
	ld [hl], a
	call LoadFontsExtra
	ld a, 1
	ld [hBGMapMode], a
	call WaitBGMap
	ld b, SCGB_GS_INTRO
	call GetSGBLayout
	call SetPalettes
.joypad_loop
	ld c, 3
	call DelayFrames
	call JoyTextDelay
	ldh a, [hJoyPressed]
	ld b, a
	and D_LEFT
	jr nz, .scrollLeft
	ld a, b
	and D_RIGHT
	jr nz, .scrollRight
	ld a, b
	and START
	jr z, .joypad_loop
	pop af
	ldh [hInMenu], a
	xor a
	ldh [hStatsDisabled], a
	ld de, SFX_TRANSACTION
	call PlaySFX
	call WaitSFX
	call CloseSRAM
	ret
.scrollLeft
	ld a, [wOptionsMenuID]
	and a
	jr nz, .decreasePage
	ld a, NUM_STAT_SCREENS
.decreasePage
	dec a
.scrollDone
	ld [wOptionsMenuID], a
	jp .pageLoad
.scrollRight
	ld a, [wOptionsMenuID]
	inc a
	cp NUM_STAT_SCREENS
	jr nz, .scrollDone
	xor a
	jr .scrollDone

RenderStats::
; render stats themselves
	ld hl, wPlayStatsConfigPtr
	ld a, [hli]
	ld h, [hl]
	ld l, a
	xor a
	ld [wPlayStatsStatNum], a
.loop
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	or e
	ret z
	push hl
	hlcoord 1, 4
	ld a, [wPlayStatsStatNum]
	sla a
	ld bc, SCREEN_WIDTH
	call AddNTimes
	push hl
	push bc
	call PlaceString
	pop bc
	pop hl
	add hl, bc
	ld d, h
	ld e, l
	pop hl
	ld a, [hli]
	ld [wStoredJumptableIndex], a

	push hl
	cp STATTYPE_2BYTE
	jr nz, .test2bcompare
	call Copy2ByteValueIntoPrintScratch
	jr .donecopying
.test2bcompare
	cp STATTYPE_2BYTE_COMPARE
	jr nz, .test4bcompare
	call Copy2ByteComparesIntoPrintScratch
	jr .donecopying
.test4bcompare
	cp STATTYPE_4BYTE_COMPARE
	jr nz, .do4bcopy
	call Copy4ByteComparesIntoPrintScratch
	jr .donecopying
.do4bcopy
	call Copy4ByteValueIntoPrintScratch
.donecopying
	ld h, d
	ld l, e
	ld a, [wStoredJumptableIndex]
	cp STATTYPE_2BYTE
	jr nz, .check_4byte
; print 2byte
	ld bc, (SCREEN_WIDTH - 1 - 5 - 1)
	add hl, bc
	lb bc, 2, 5
	ld de, wBuffer3
	call PrintNum
	jr .next_loop
.check_4byte
	cp STATTYPE_4BYTE
	jr nz, .check_money
; print 4byte
	ld bc, (SCREEN_WIDTH - 1 - 7 - 1)
	add hl, bc
	lb bc, 3, 7
	ld de, wBuffer2
	call PrintNum
	jr .next_loop
.check_money
	cp STATTYPE_MONEY
	jr nz, .check_2bytecompare
; print money (if only)
	ld bc, (SCREEN_WIDTH - 1 - 8 - 1)
	add hl, bc
	lb bc, (PRINTNUM_MONEY | 3), 7
	ld de, wBuffer2
	call PrintNum
	jr .next_loop
.check_2bytecompare
	cp STATTYPE_2BYTE_COMPARE
	jr nz, .check_4bytecompare
	call Print2ByteCompare
	jr .advance_extra_then_next_loop
.check_4bytecompare
	cp STATTYPE_4BYTE_COMPARE
	jr nz, .print_timer
	call Print4ByteCompare
	jr .advance_extra_then_next_loop
.print_timer
; print timer
	call PrintTimer
.next_loop
	pop hl
.next_loop_nopop
	inc hl
	inc hl
	ld a, [wPlayStatsStatNum]
	inc a
	ld [wPlayStatsStatNum], a
	jp .loop
.advance_extra_then_next_loop
	pop hl
	inc hl
	inc hl
	jr .next_loop_nopop

Print2ByteCompare:
	ld bc, SCREEN_WIDTH - 3
	add hl, bc
	ld [hl], ")"
	ld bc, -5
	add hl, bc
	lb bc, 2, 5
	ld de, wBuffer3
	call PrintNum
.find_blank
	ld a, [hld]
	cp " "
	jr nz, .find_blank
	inc hl
	ld [hl], "("
	ld bc, -6
	add hl, bc
	lb bc, 2, 5
	ld de, wBuffer1
	call PrintNum
	ret

Print4ByteCompare:
	ld bc, SCREEN_WIDTH - 3
	add hl, bc
	ld [hl], ")"
	ld bc, -7
	add hl, bc
	lb bc, 3, 7
	ld de, wBuffer6
	call PrintNum
.find_blank
	ld a, [hld]
	cp " "
	jr nz, .find_blank
	inc hl
	ld [hl], "("
	ld bc, -8
	add hl, bc
	lb bc, 3, 7
	ld de, wBuffer2
	call PrintNum
	ret

PrintTimer:
; frames/milliseconds part
; use 4/239 as a better approximation for gbc framerate than 1/60
rept 2
	ld a, [wBuffer4]
	sla a
	ld [wBuffer4], a
	ld a, [wBuffer3]
	rl a
	ld [wBuffer3], a
	ld a, [wBuffer2]
	rl a
	ld [wBuffer2], a
	ld a, [wBuffer1]
	rl a
	ld [wBuffer1], a
endr
; copy wBuffer1-4 into dividend
	ld a, [wBuffer1]
	ldh [hDividend], a
	ld a, [wBuffer2]
	ldh [hDividend+1], a
	ld a, [wBuffer3]
	ldh [hDividend+2], a
	ld a, [wBuffer4]
	ldh [hDividend+3], a
; divide by 239
	ld a, 239
	ldh [hDivisor], a
	ld b, 4
	call Divide
; backup the result (seconds) for now
	ldh a, [hQuotient]
	push af
	ldh a, [hQuotient+1]
	push af
	ldh a, [hQuotient+2]
	push af
	ldh a, [hQuotient+3]
	push af
; multiply remainder (1/239ths of a second) by 100 then divide by 239 to approximate centiseconds
; hRemainder == hMultiplier so skip copying that
	xor a
	ldh [hMultiplicand], a
	ldh [hMultiplicand+1], a
	ld a, 100
	ldh [hMultiplicand+2], a
	call Multiply
; divide by 239 to get a rough cs value
	ld a, 239
	ldh [hDivisor], a
	ld b, 4
	call Divide
; move the result elsewhere since printnum uses the same hram
	ldh a, [hQuotient+3]
	ld [wBuffer1], a
; print the result (ms)
	ld bc, (SCREEN_WIDTH - 1 - 2 - 1)
	add hl, bc
	lb bc, (PRINTNUM_LEADINGZEROS | 1), 2
	ld de, wBuffer1
	call PrintNum
; now for seconds onwards
; from here on out we just straight up print either the quotient or the remainder
; start by restoring the quotient
	pop af
	ldh [hQuotient+3], a
	pop af
	ldh [hQuotient+2], a
	pop af
	ldh [hQuotient+1], a
	pop af
	ldh [hQuotient], a
; divide by 60 again for seconds
	ld a, 60
	ldh [hDivisor], a
	ld b, 4
	call Divide
; backup the result again since printnum and multiply/divide share memory
	ldh a, [hQuotient+1]
	push af
	ldh a, [hQuotient+2]
	push af
	ldh a, [hQuotient+3]
	push af
; move the printed number elsewhere
	ldh a, [hRemainder]
	ld [wBuffer1], a
; print seconds
	ld bc, -5
	add hl, bc
	lb bc, (PRINTNUM_LEADINGZEROS | 1), 2
	ld de, wBuffer1
	call PrintNum
	ld [hl], "."
; restore result
	pop af
	ldh [hQuotient+3], a
	pop af
	ldh [hQuotient+2], a
	pop af
	ldh [hQuotient+1], a
	xor a
	ldh [hQuotient], a
; divide by 60 again for minutes
	ld a, 60
	ldh [hDivisor], a
	ld b, 4
	call Divide
; move the result elsewhere
	ldh a, [hRemainder]
	ld [wBuffer1], a
	ldh a, [hQuotient+2]
	ld [wBuffer2], a
	ldh a, [hQuotient+3]
	ld [wBuffer3], a
; print minutes from wBuffer1
	ld bc, -5
	add hl, bc
	lb bc, (PRINTNUM_LEADINGZEROS | 1), 2
	ld de, wBuffer1
	call PrintNum
	ld [hl], ":"
; print hours from wBuffer2-3
	ld bc, -8
	add hl, bc
	lb bc, 2, 5
	ld de, wBuffer2
	call PrintNum
	ld [hl], ":"
	ret


Copy2ByteValueIntoPrintScratch:
	xor a
	ld [wBuffer1], a
	ld [wBuffer2], a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	ld [wBuffer4], a
	ld a, [hl]
	ld [wBuffer3], a
	ret

Copy4ByteValueIntoPrintScratch:
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	ld [wBuffer4], a
	ld a, [hli]
	ld [wBuffer3], a
	ld a, [hli]
	ld [wBuffer2], a
	ld a, [hl]
	ld [wBuffer1], a
	ret

Copy2ByteComparesIntoPrintScratch:
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	ld [wBuffer2], a
	ld a, [hl]
	ld [wBuffer1], a
	pop hl
	inc hl
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	ld [wBuffer4], a
	ld a, [hl]
	ld [wBuffer3], a
	ret

Copy4ByteComparesIntoPrintScratch:
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	ld [wBuffer4], a
	ld a, [hli]
	ld [wBuffer3], a
	ld a, [hli]
	ld [wBuffer2], a
	ld a, [hl]
	ld [wBuffer1], a
	pop hl
	inc hl
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	ld [wBuffer8], a
	ld a, [hli]
	ld [wBuffer7], a
	ld a, [hli]
	ld [wBuffer6], a
	ld a, [hl]
	ld [wBuffer5], a
	ret



RetrievePlaythroughStatsConfig::
	ld a, [wOptionsMenuID]
	ld hl, PlaythroughStatsScreens
	ld bc, wPlayStatsConfigEnds - wPlayStatsStringPtr
	call AddNTimes
	ld de, wPlayStatsStringPtr
	jp CopyBytes

stat_screen: MACRO
	dw (\1) ; title string
	dw (\2) ; pointer to config for entries on this page
ENDM

stat_screen_entry: MACRO
	dw (\1) ; description string
	db (\2) ; data type
	dw (\3) ; sram address
if \2 >= STATTYPE_2BYTE_COMPARE
	dw (\4) ; second sram address
endc
ENDM

PlaythroughStatsScreens::
	stat_screen PSTimersTitleString, PSTimersConfig
	stat_screen PSMovementTitleString, PSMovementConfig
	stat_screen PSBattle1TitleString, PSBattle1Config
	stat_screen PSBattle2TitleString, PSBattle2Config
	stat_screen PSBattle3TitleString, PSBattle3Config
	stat_screen PSBattle4TitleString, PSBattle4Config
	stat_screen PSMoneyItemsTitleString, PSMoneyItemsConfig
	stat_screen PSMiscTitleString, PSMiscConfig
PlaythroughStatsScreensEnd::

PSTimersConfig::
	stat_screen_entry PSTimersOverallString, STATTYPE_TIMER, sStatsFrameCount
	stat_screen_entry PSTimersOverworldString, STATTYPE_TIMER, sStatsOWFrameCount 
	stat_screen_entry PSTimersBattleString, STATTYPE_TIMER, sStatsBattleFrameCount
	stat_screen_entry PSTimersMenuString, STATTYPE_TIMER, sStatsMenuFrameCount
	stat_screen_entry PSTimersIntroString, STATTYPE_TIMER, sStatsIntrosFrameCount
	dw 0 ; end

PSMovementConfig::
	stat_screen_entry PSMovementTotalStepsString, STATTYPE_4BYTE, sStatsStepCount
	stat_screen_entry PSMovementStepsWalkedString, STATTYPE_4BYTE, sStatsStepCountWalk
	stat_screen_entry PSMovementStepsBikedString, STATTYPE_4BYTE, sStatsStepCountBike
	stat_screen_entry PSMovementStepsSurfedString, STATTYPE_4BYTE, sStatsStepCountSurf
	stat_screen_entry PSMovementBonksString, STATTYPE_2BYTE, sStatsBonks
	dw 0 ; end

PSBattle1Config::
	stat_screen_entry PSBattle1TotalBattlesString, STATTYPE_2BYTE, sStatsBattles
	stat_screen_entry PSBattle1WildBattlesString, STATTYPE_2BYTE, sStatsWildBattles
	stat_screen_entry PSBattle1TrainerBattlesString, STATTYPE_2BYTE, sStatsTrainerBattles
	stat_screen_entry PSBattle1BattlesFledFromString, STATTYPE_2BYTE, sStatsBattlesFled
	stat_screen_entry PSBattle1FailedEscapesString, STATTYPE_2BYTE, sStatsFailedRuns
	dw 0 ; end

PSBattle2Config::
	stat_screen_entry PSBattle2EnemyPKMNFaintedString, STATTYPE_2BYTE, sStatsEnemyPokemonFainted
	stat_screen_entry PSBattle2EXPGainedString, STATTYPE_4BYTE, sStatsExperienceGained
	stat_screen_entry PSBattle2OwnPKMNFaintedString, STATTYPE_2BYTE, sStatsPlayerPokemonFainted
	stat_screen_entry PSBattle2SwitchoutsString, STATTYPE_2BYTE, sStatsSwitchouts
	stat_screen_entry PSBattle2BallsThrownString, STATTYPE_2BYTE, sStatsBallsThrown
	stat_screen_entry PSBattle2PokemonCaughtString, STATTYPE_2BYTE, sStatsPokemonCaughtInBalls
	dw 0 ; end

PSBattle3Config::
	stat_screen_entry PSBattle3MovesHitString, STATTYPE_2BYTE_COMPARE, sStatsOwnMovesHit, sStatsEnemyMovesHit
	stat_screen_entry PSBattle3MovesMissedString, STATTYPE_2BYTE_COMPARE, sStatsOwnMovesMissed, sStatsEnemyMovesMissed
	stat_screen_entry PSBattle3SEMovesString, STATTYPE_2BYTE_COMPARE, sStatsOwnMovesSE, sStatsEnemyMovesSE
	stat_screen_entry PSBattle3NVEMovesString, STATTYPE_2BYTE_COMPARE, sStatsOwnMovesNVE, sStatsEnemyMovesNVE
	stat_screen_entry PSBattle3CriticalsDealtString, STATTYPE_2BYTE_COMPARE, sStatsCriticalsDealt, sStatsCriticalsTaken
	stat_screen_entry PSBattle3OHKOsDealtString, STATTYPE_2BYTE_COMPARE, sStatsOHKOsDealt, sStatsOHKOsTaken
	dw 0

PSBattle4Config::
	stat_screen_entry PSBattle4TotalDmgDealtString, STATTYPE_4BYTE_COMPARE, sStatsTotalDamageDealt, sStatsActualDamageDealt
	stat_screen_entry PSBattle4TotalDmgTakenString, STATTYPE_4BYTE_COMPARE, sStatsTotalDamageTaken, sStatsActualDamageTaken
	dw 0

PSMoneyItemsConfig::
	stat_screen_entry PSMIMoneyMadeString, STATTYPE_MONEY, sStatsMoneyMade
	stat_screen_entry PSMIMoneySpentString, STATTYPE_MONEY, sStatsMoneySpent
	stat_screen_entry PSMIMoneyLostString, STATTYPE_MONEY, sStatsMoneyLost
	stat_screen_entry PSMIItemsPickedUpString, STATTYPE_2BYTE, sStatsItemsPickedUp
	stat_screen_entry PSMIItemsBoughtString, STATTYPE_2BYTE, sStatsItemsBought
	stat_screen_entry PSMIItemsSoldString, STATTYPE_2BYTE, sStatsItemsSold
	dw 0

PSMiscConfig::
	stat_screen_entry PSMiscSavesString, STATTYPE_2BYTE, sStatsSaveCount
	stat_screen_entry PSMiscReloadsString, STATTYPE_2BYTE, sStatsReloadCount
	stat_screen_entry PSMiscClockResetsString, STATTYPE_2BYTE, sStatsClockResetCount
	stat_screen_entry PSMiscPokemaniacsFoughtString, STATTYPE_2BYTE, sStatsNumPokemaniacsFought
	dw 0

PlayerStatsString:
	db "   PLAYER STATS@"

PSTimersTitleString:
	db "      TIMERS@"
PSTimersOverallString:
	db "TOTAL TIME:@"
PSTimersOverworldString:
	db "OVERWORLD TIME:@"
PSTimersBattleString:
	db "TIME IN BATTLE:@"
PSTimersMenuString:
	db "TIME IN MENUS:@"
PSTimersIntroString:
	db "TIME IN INTROS:@"

PSMovementTitleString:
	db "     MOVEMENT@"
PSMovementTotalStepsString:
	db "TOTAL STEPS:@"
PSMovementStepsWalkedString:
	db "STEPS WALKED:@"
PSMovementStepsBikedString:
	db "STEPS BIKED:@"
PSMovementStepsSurfedString:
	db "STEPS SURFED:@"
PSMovementBonksString:
	db "BONKS:@"

PSBattle1TitleString:
	db "     BATTLE 1@"
PSBattle1TotalBattlesString:
	db "TOTAL BATTLES:@"
PSBattle1WildBattlesString:
	db "WILD BATTLES:@"
PSBattle1TrainerBattlesString:
	db "TRAINER BATTLES:@"
PSBattle1BattlesFledFromString:
	db "BATTLES FLED FROM:@"
PSBattle1FailedEscapesString:
	db "FAILED ESCAPES:@"

PSBattle2TitleString:
	db "     BATTLE 2@"
PSBattle2EnemyPKMNFaintedString:
	db "ENEMY <PK><MN> FAINTED:@"
PSBattle2EXPGainedString:
	db "EXP. GAINED:@"
PSBattle2OwnPKMNFaintedString:
	db "OWN <PK><MN> FAINTED:@"
PSBattle2SwitchoutsString:
	db "NUM. SWITCHOUTS:@"
PSBattle2BallsThrownString:
	db "BALLS THROWN:@"
PSBattle2PokemonCaughtString:
	db "<PK><MN> CAPTURED:@"

PSBattle3TitleString:
	db "     BATTLE 3@"

PSBattle3MovesHitString:
	db "MOVES HIT (BY):@"
PSBattle3MovesMissedString:
	db "MOVES MISSED:@"
PSBattle3SEMovesString:
	db "S.E. MOVES USED:@"
PSBattle3NVEMovesString:
	db "N.V.E. MOVES USED:@"
PSBattle3CriticalsDealtString:
	db "CRITICAL HITS:@"
PSBattle3OHKOsDealtString:
	db "OHKOs:@"

PSBattle4TitleString:
	db "     BATTLE 4@"
PSBattle4TotalDmgDealtString:
	db "DAMAGE DEALT:@"
PSBattle4TotalDmgTakenString:
	db "DAMAGE TAKEN:@"

PSMoneyItemsTitleString:
	db "  MONEY & ITEMS@"
PSMIMoneyMadeString:
	db "MONEY MADE:@"
PSMIMoneySpentString:
	db "MONEY SPENT:@"
PSMIMoneyLostString:
	db "MONEY LOST:@"
PSMIItemsPickedUpString:
	db "ITEMS PICKED UP:@"
PSMIItemsBoughtString:
	db "ITEMS BOUGHT:@"
PSMIItemsSoldString:
	db "ITEMS SOLD:@"


PSMiscTitleString:
	db "      MISC.@"
PSMiscSavesString:
	db "TIMES SAVED:@"
PSMiscReloadsString:
	db "SAVE RELOADS:@"
PSMiscClockResetsString:
	db "CLOCK RESETS:@"
PSMiscPokemaniacsFoughtString:
	db "No. #MANIACS:@"

PSPageStartString:
	db "PAGE@"
PSPageOfString:
	db "OF@"
