LoadHLMovesPlusType::
	push bc
	ld bc, MOVE_TYPE
	jr LoadHLMovesCommon
	
LoadHLMovesPlusPower::
	push bc
	ld bc, MOVE_POWER
	jr LoadHLMovesCommon
	
LoadHLMovesPlusEffect::
	push bc
	ld bc, MOVE_EFFECT
	jr LoadHLMovesCommon
	
LoadHLMovesPlusPP::
	push bc
	ld bc, MOVE_PP
	jr LoadHLMovesCommon
	
LoadHLMoves::
	push bc
	ld bc, 0
LoadHLMovesCommon::
	push af
	sboptioncheck NERF_HMS
	ld hl, Moves
	jr z, .done
	ld hl, MovesHMNerfs
.done
	add hl, bc
	pop af
	pop bc
	ret
