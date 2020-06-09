; LCD handling

LCD::
	push af
	ldh a, [hLCDCPointer]
	and a
	jr nz, LYOverrideCode
	ld a, [wRequested2bpp]
	and a
	jr nz, _Serve2bppRequestHB
	ld a, [wRequested1bpp]
	and a
	jr nz, _Serve1bppRequestHB
	ldh a, [hBGMapMode]
	and a
	jr z, LCDDone
	ldh a, [rLY]
	cp $80
	jr nz, LCDDone
	push hl
	push de
	push bc
	call AlignTileMap
	pop bc
	pop de
	pop hl
	jr LCDDone

LYOverrideCode::
; At this point it's assumed we're in WRAM bank 5!
	push bc
	ldh a, [rLY]
	ld c, a
	ld b, HIGH(wLYOverrides)
	ld a, [bc]
	ld b, a
	ldh a, [hLCDCPointer]
	ld c, a
	ld a, b
	ldh [c], a
	pop bc

LCDDone::
	pop af
	reti
	
_Serve2bppRequestHB:
	push hl
	push de
	ld hl, wRequested2bppDest
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld hl, wRequested2bppSource
	ld a, [hli]
	ld h, [hl]
	ld l, a
; Destination
	ldh a, [rSTAT]
	and $3
	jr nz, RequestDone
rept 3
	ld a, [hli]
	ld [de], a
	inc e
endr
	ld a, [hli]
	ld [de], a
	inc de
	ld a, e
	ld [wRequested2bppDest], a
	ld a, d
	ld [wRequested2bppDest + 1], a
	ld a, l
	ld [wRequested2bppSource], a
	ld a, h
	ld [wRequested2bppSource + 1], a
	ld hl, wRequested2bppQuarters
	dec [hl]
	jr nz, RequestDone
	ld [hl], 4
	ld hl, wRequested2bpp
	dec [hl]
RequestDone::
	pop de
	pop hl
	jr LCDDone
	
_Serve1bppRequestHB:
	push hl
	push de
	ld hl, wRequested1bppDest
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld hl, wRequested1bppSource
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ldh a, [rSTAT]
	and $3
	jr nz, RequestDone
; Destination
	ld a, [hli]
	ld [de], a
	inc e
	ld [de], a
	inc e
	ld a, [hli]
	ld [de], a
	inc e
	ld [de], a
	ld a, [rSTAT]
	and a
	cp 3
	jr z, RequestDone
	inc de
	ld a, e
	ld [wRequested1bppDest], a
	ld a, d
	ld [wRequested1bppDest + 1], a
	ld a, l
	ld [wRequested1bppSource], a
	ld a, h
	ld [wRequested1bppSource + 1], a
	ld hl, wRequested1bppQuarters
	dec [hl]
	jr nz, RequestDone
	ld [hl], 4
	ld hl, wRequested1bpp
	dec [hl]
	jr RequestDone
	
Wait2bpp::
	ldh a, [hLCDCPointer]
	push af
	xor a
	ldh [hLCDCPointer], a
.loop
	halt
	nop
	ld a, [wRequested2bpp]
	and a
	jr nz, .loop
	pop af
	ldh [hLCDCPointer], a
	ret

DisableLCD::
; Turn the LCD off

; Don't need to do anything if the LCD is already off
	ldh a, [rLCDC]
	bit rLCDC_ENABLE, a
	ret z

	xor a
	ldh [rIF], a
	ldh a, [rIE]
	ld b, a

; Disable VBlank
	res VBLANK, a
	ldh [rIE], a

.wait
; Wait until VBlank would normally happen
	ldh a, [rLY]
	cp LY_VBLANK + 1
	jr nz, .wait

	ldh a, [rLCDC]
	and $ff ^ (1 << rLCDC_ENABLE)
	ldh [rLCDC], a

	xor a
	ldh [rIF], a
	ld a, b
	ldh [rIE], a
	ret

EnableLCD::
	ldh a, [rLCDC]
	set rLCDC_ENABLE, a
	ldh [rLCDC], a
	ret
