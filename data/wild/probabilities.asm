mon_prob: MACRO
; percent, index
	db \1, \2 * 2
ENDM

GrassMonProbTable:
	mon_prob 30,  0 ; 30% chance
	mon_prob 60,  1 ; 30% chance
	mon_prob 80,  2 ; 20% chance
	mon_prob 90,  3 ; 10% chance
	mon_prob 95,  4 ;  5% chance
	mon_prob 99,  5 ;  4% chance
	mon_prob 100, 6 ;  1% chance

BetterGrassMonProbTable:
	mon_prob 20,  0 ; 20% chance
	mon_prob 40,  1 ; 20% chance
	mon_prob 55,  2 ; 15% chance
	mon_prob 70,  3 ; 15% chance
	mon_prob 80,  4 ; 10% chance
	mon_prob 90,  5 ; 10% chance
	mon_prob 100, 6 ; 10% chance

WaterMonProbTable:
	mon_prob 60,  0 ; 60% chance
	mon_prob 90,  1 ; 30% chance
	mon_prob 100, 2 ; 10% chance
