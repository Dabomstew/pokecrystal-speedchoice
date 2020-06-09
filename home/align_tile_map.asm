AlignTileMap::
	ldh a, [rSVBK]
	push af
	ld a, BANK(wAlignedTileMap)
	ldh [rSVBK], a
	ldh a, [hBGMapMode]
	bit 0, a
	ld hl, wTilemap
	jr nz, .loadSP
	ld hl, wAttrmap
.loadSP
	ld [hSPBuffer], sp
	ld sp, hl
; load hl with tilemap buffer
	ld hl, wAlignedTileMap
; do stack copy similar to AutoBGMapTransfer
	ld bc, BG_MAP_WIDTH - (SCREEN_WIDTH - 1)
	ld a, SCREEN_HEIGHT
	
TransferBgRowsHBL:
	rept SCREEN_WIDTH / 2 - 1
	pop de
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	endr

	pop de
	ld [hl], e
	inc l
	ld [hl], d

	add hl, bc
	dec a
	jr nz, TransferBgRowsHBL

	ldh a, [hSPBuffer]
	ld l, a
	ldh a, [hSPBuffer + 1]
	ld h, a
	ld sp, hl
	pop af
	ldh [rSVBK], a
	ld a, 1
	ldh [hHasAlignedBGMap], a
	ret
