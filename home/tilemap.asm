ClearBGPalettes::
	call ClearPalettes
WaitBGMap::
	ldh a, [hCGB]
	and a
	jr z, WaitBGMapSlow

WaitBGMap1Fast::
; Tell VBlank to update BG Map
	ld a, 1 ; BG Map 0 tiles
	ldh [hBGMapMode], a
WaitBGMapFast::
; Wait for it to do its magic
	ldh a, [hBGMapAddress]
	and a
	jr nz, WaitBGMapSlowInner
	ldh a, [rLY]
	cp $7E
	call nc, DelayFrame
	jp DelayFrame

WaitBGMap2::
	ldh a, [hCGB]
	and a
	jr z, WaitBGMapSlow

	ld a, 2
	ldh [hBGMapMode], a
	call WaitBGMapFast
	jr WaitBGMap1Fast

WaitBGMapSlow::
	ld a, 1
	ldh [hBGMapMode], a
WaitBGMapSlowInner::
	ld c, 4
	call DelayFrames
	ret

IsCGB::
	ldh a, [hCGB]
	and a
	ret

ApplyTilemap::
	ldh a, [hCGB]
	and a
	jr z, WaitBGMapSlow

	ld a, [wSpriteUpdatesEnabled]
	and a
	jr z, WaitBGMap

	ld a, 1
	ldh [hBGMapMode], a
	jr CopyTilemapAtOnce

CGBOnly_CopyTilemapAtOnce::
	ldh a, [hCGB]
	and a
	jr z, WaitBGMapSlow

CopyTilemapAtOnce::
	ldh a, [hBGMapMode]
	push af
	xor a
	ldh [hBGMapMode], a

	ldh a, [hMapAnims]
	push af
	xor a
	ldh [hMapAnims], a

; why lol
	ldh a, [rLY]
	cp $7E
	call nc, DelayFrame

	ld a, 1
	ldh [hBGMapMode], a
	call DelayFrame
	
	ld a, 2
	ldh [hBGMapMode], a
	call DelayFrame

	pop af
	ldh [hMapAnims], a
	pop af
	ldh [hBGMapMode], a
	ret

SetPalettes::
; Inits the Palettes
; depending on the system the monochromes palettes or color palettes
	ldh a, [hCGB]
	and a
	jr nz, .SetPalettesForGameBoyColor
	ld a, %11100100
	ldh [rBGP], a
	ld a, %11010000
	ldh [rOBP0], a
	ldh [rOBP1], a
	ret

.SetPalettesForGameBoyColor:
	push de
	ld a, %11100100
	call DmgToCgbBGPals
	lb de, %11100100, %11100100
	call DmgToCgbObjPals
	pop de
	ret

ClearPalettes::
; Make all palettes white

; CGB: make all the palette colors white
	ldh a, [hCGB]
	and a
	jr nz, .cgb

; DMG: just change palettes to 0 (white)
	xor a
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ret

.cgb
	ldh a, [rSVBK]
	push af

	ld a, BANK(wBGPals2)
	ldh [rSVBK], a

; Fill wBGPals2 and wOBPals2 with $ffff (white)
	ld hl, wBGPals2
	ld bc, 16 palettes
	ld a, $ff
	call ByteFill

	pop af
	ldh [rSVBK], a

; Request palette update
	ld a, 1
	ldh [hCGBPalUpdate], a
	ret

GetMemSGBLayout::
	ld b, SCGB_RAM
GetSGBLayout::
; load sgb packets unless dmg

	ldh a, [hCGB]
	and a
	jr nz, .sgb

	ldh a, [hSGB]
	and a
	ret z

.sgb
	predef_jump LoadSGBLayout

SetHPPal::
; Set palette for hp bar pixel length e at hl.
	call GetHPPal
	ld [hl], d
	ret

GetHPPal::
; Get palette for hp bar pixel length e in d.
	ld d, HP_GREEN
	ld a, e
	cp (HP_BAR_LENGTH_PX * 50 / 100) ; 24
	ret nc
	inc d ; HP_YELLOW
	cp (HP_BAR_LENGTH_PX * 21 / 100) ; 10
	ret nc
	inc d ; HP_RED
	ret
