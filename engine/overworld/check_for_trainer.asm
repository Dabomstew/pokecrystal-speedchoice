CheckForRangedTrainerOnMap::
	ld a, [wCurrentMapPersonEventCount]
	and a
	ret z
	push de
	push bc
	ld e, a
	ld hl, wMap1Object + MAPOBJECT_COLOR
.loop
	push hl
	ld a, [hli]
	and $0f
	cp PERSONTYPE_TRAINER ; trainer
	jr nz, .nextLoop
	ld a, [hl]
	and a
	jr nz, .returnTrue
.nextLoop
	pop hl
	dec e
	jr z, .returnFalse
	ld bc, wMap2Object - wMap1Object
	add hl, bc
	jr .loop
.returnTrue
	scf
	jr .return
.returnFalse
	and a
.return
	pop bc
	pop de
	ret
