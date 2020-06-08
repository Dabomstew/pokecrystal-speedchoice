; Characteristics of each move.

move: MACRO
	db \1 ; animation
	db \2 ; effect
	db \3 ; power
	db \4 ; type
	db \5 percent ; accuracy
	db \6 ; pp
	db \7 percent ; effect chance
ENDM

INCLUDE "data/moves/moves_normal.asm"
INCLUDE "data/moves/moves_hmnerfs.asm"
