Marts:
; entries correspond to MART_* constants
	dw MartCherrygrove
	dw MartCherrygroveDex
	dw MartViolet
	dw MartAzalea
	dw MartCianwood
	dw MartGoldenrod2F1
	dw MartGoldenrod2F2
	dw MartGoldenrod3F
	dw MartGoldenrod4F
	dw MartOlivine
	dw MartEcruteak
	dw MartMahogany1
	dw MartMahogany2
	dw MartBlackthorn
	dw MartViridian
	dw MartPewter
	dw MartCerulean
	dw MartLavender
	dw MartVermilion
	dw MartCeladon2F1
	dw MartCeladon2F2
	dw MartCeladon3F
	dw MartCeladon4F
	dw MartCeladon5F1
	dw MartCeladon5F2
	dw MartFuchsia
	dw MartSaffron
	dw MartMtMoon
	dw MartIndigoPlateau
	dw MartUnderground
	dw MartCherrygroveBetter
	dw MartVioletBetter
	dw MartAzaleaBetter
	dw MartGoldenrod4FBetter
	dw MartGoldenrod5FNoTMs
	dw MartGoldenrod5FTM02
	dw MartGoldenrod5FTM08
	dw MartGoldenrod5FTM0208
	dw MartGoldenrod5FTM12
	dw MartGoldenrod5FTM0212
	dw MartGoldenrod5FTM0812
	dw MartGoldenrod5FTM020812
.End


shopitem: MACRO
; type, name
        db \1, \2
ENDM

MartCherrygrove:
	db 4 ; # items
	shopitem	1, POTION
	shopitem	1, ANTIDOTE
	shopitem	1, PARLYZ_HEAL
	shopitem	1, AWAKENING
	db -1, -1 ; end

MartCherrygroveDex:
	db 5 ; # items
	shopitem	1, POKE_BALL
	shopitem	1, POTION
	shopitem	1, ANTIDOTE
	shopitem	1, PARLYZ_HEAL
	shopitem	1, AWAKENING
	db -1, -1 ; end

MartViolet:
	db 10 ; # items
	shopitem	1, POKE_BALL
	shopitem	1, POTION
	shopitem	1, ESCAPE_ROPE
	shopitem	1, ANTIDOTE
	shopitem	1, PARLYZ_HEAL
	shopitem	1, AWAKENING
	shopitem	1, X_DEFEND
	shopitem	1, X_ATTACK
	shopitem	1, X_SPEED
	shopitem	1, FLOWER_MAIL
	db -1, -1 ; end

MartAzalea:
	db 9 ; # items
	shopitem	1, CHARCOAL
	shopitem	1, POKE_BALL
	shopitem	1, POTION
	shopitem	1, SUPER_POTION
	shopitem	1, ESCAPE_ROPE
	shopitem	1, REPEL
	shopitem	1, ANTIDOTE
	shopitem	1, PARLYZ_HEAL
	shopitem	1, FLOWER_MAIL
	db -1, -1 ; end

MartCianwood:
	db 5 ; # items
	shopitem	1, POTION
	shopitem	1, SUPER_POTION
	shopitem	1, HYPER_POTION
	shopitem	1, FULL_HEAL
	shopitem	1, REVIVE
	db -1, -1 ; end

MartGoldenrod2F1:
	db 7 ; # items
	shopitem	1, POTION
	shopitem	1, SUPER_POTION
	shopitem	1, ANTIDOTE
	shopitem	1, PARLYZ_HEAL
	shopitem	1, AWAKENING
	shopitem	1, BURN_HEAL
	shopitem	1, ICE_HEAL
	db -1, -1 ; end

MartGoldenrod2F2:
	db 8 ; # items
	shopitem	1, POKE_BALL
	shopitem	1, GREAT_BALL
	shopitem	1, ESCAPE_ROPE
	shopitem	1, REPEL
	shopitem	1, REVIVE
	shopitem	1, FULL_HEAL
	shopitem	1, POKE_DOLL
	shopitem	1, FLOWER_MAIL
	db -1, -1 ; end

MartGoldenrod3F:
	db 7 ; # items
	shopitem	1, X_SPEED
	shopitem	1, X_SPECIAL
	shopitem	1, X_DEFEND
	shopitem	1, X_ATTACK
	shopitem	1, DIRE_HIT
	shopitem	1, GUARD_SPEC
	shopitem	1, X_ACCURACY
	db -1, -1 ; end

MartGoldenrod4F:
	db 5 ; # items
	shopitem	1, PROTEIN
	shopitem	1, IRON
	shopitem	1, CARBOS
	shopitem	1, CALCIUM
	shopitem	1, HP_UP
	db -1, -1 ; end

MartOlivine:
	db 9 ; # items
	shopitem	1, GREAT_BALL
	shopitem	1, SUPER_POTION
	shopitem	1, HYPER_POTION
	shopitem	1, ANTIDOTE
	shopitem	1, PARLYZ_HEAL
	shopitem	1, AWAKENING
	shopitem	1, ICE_HEAL
	shopitem	1, SUPER_REPEL
	shopitem	1, SURF_MAIL
	db -1, -1 ; end

MartEcruteak:
	db 10 ; # items
	shopitem	1, POKE_BALL
	shopitem	1, GREAT_BALL
	shopitem	1, POTION
	shopitem	1, SUPER_POTION
	shopitem	1, ANTIDOTE
	shopitem	1, PARLYZ_HEAL
	shopitem	1, AWAKENING
	shopitem	1, BURN_HEAL
	shopitem	1, ICE_HEAL
	shopitem	1, REVIVE
	db -1, -1 ; end

MartMahogany1:
	db 4 ; # items
	shopitem	1, TINYMUSHROOM
	shopitem	1, SLOWPOKETAIL
	shopitem	1, POKE_BALL
	shopitem	1, POTION
	db -1, -1 ; end

MartMahogany2:
	db 9 ; # items
	shopitem	1, RAGECANDYBAR
	shopitem	1, GREAT_BALL
	shopitem	1, SUPER_POTION
	shopitem	1, HYPER_POTION
	shopitem	1, ANTIDOTE
	shopitem	1, PARLYZ_HEAL
	shopitem	1, SUPER_REPEL
	shopitem	1, REVIVE
	shopitem	1, FLOWER_MAIL
	db -1, -1 ; end

MartBlackthorn:
	db 9 ; # items
	shopitem	1, GREAT_BALL
	shopitem	1, ULTRA_BALL
	shopitem	1, HYPER_POTION
	shopitem	1, MAX_POTION
	shopitem	1, FULL_HEAL
	shopitem	1, REVIVE
	shopitem	1, MAX_REPEL
	shopitem	1, X_DEFEND
	shopitem	1, X_ATTACK
	db -1, -1 ; end

MartViridian:
	db 9 ; # items
	shopitem	1, ULTRA_BALL
	shopitem	1, HYPER_POTION
	shopitem	1, FULL_HEAL
	shopitem	1, REVIVE
	shopitem	1, ANTIDOTE
	shopitem	1, PARLYZ_HEAL
	shopitem	1, AWAKENING
	shopitem	1, BURN_HEAL
	shopitem	1, FLOWER_MAIL
	db -1, -1 ; end

MartPewter:
	db 7 ; # items
	shopitem	1, GREAT_BALL
	shopitem	1, SUPER_POTION
	shopitem	1, SUPER_REPEL
	shopitem	1, ANTIDOTE
	shopitem	1, PARLYZ_HEAL
	shopitem	1, AWAKENING
	shopitem	1, BURN_HEAL
	db -1, -1 ; end

MartCerulean:
	db 9 ; # items
	shopitem	1, GREAT_BALL
	shopitem	1, ULTRA_BALL
	shopitem	1, SUPER_POTION
	shopitem	1, SUPER_REPEL
	shopitem	1, FULL_HEAL
	shopitem	1, X_DEFEND
	shopitem	1, X_ATTACK
	shopitem	1, DIRE_HIT
	shopitem	1, SURF_MAIL
	db -1, -1 ; end

MartLavender:
	db 8 ; # items
	shopitem	1, GREAT_BALL
	shopitem	1, POTION
	shopitem	1, SUPER_POTION
	shopitem	1, MAX_REPEL
	shopitem	1, ANTIDOTE
	shopitem	1, PARLYZ_HEAL
	shopitem	1, AWAKENING
	shopitem	1, BURN_HEAL
	db -1, -1 ; end

MartVermilion:
	db 8 ; # items
	shopitem	1, ULTRA_BALL
	shopitem	1, SUPER_POTION
	shopitem	1, HYPER_POTION
	shopitem	1, REVIVE
	shopitem	1, PARLYZ_HEAL
	shopitem	1, AWAKENING
	shopitem	1, BURN_HEAL
	shopitem	1, LITEBLUEMAIL
	db -1, -1 ; end

MartCeladon2F1:
	db 7 ; # items
	shopitem	1, POTION
	shopitem	1, SUPER_POTION
	shopitem	1, HYPER_POTION
	shopitem	1, MAX_POTION
	shopitem	1, REVIVE
	shopitem	1, SUPER_REPEL
	shopitem	1, MAX_REPEL
	db -1, -1 ; end

MartCeladon2F2:
	db 10 ; # items
	shopitem	1, POKE_BALL
	shopitem	1, GREAT_BALL
	shopitem	1, ULTRA_BALL
	shopitem	1, ESCAPE_ROPE
	shopitem	1, FULL_HEAL
	shopitem	1, ANTIDOTE
	shopitem	1, BURN_HEAL
	shopitem	1, ICE_HEAL
	shopitem	1, AWAKENING
	shopitem	1, PARLYZ_HEAL
	db -1, -1 ; end

MartCeladon3F:
	db 5 ; # items
	shopitem	1, TM_HIDDEN_POWER
	shopitem	1, TM_SUNNY_DAY
	shopitem	1, TM_PROTECT
	shopitem	1, TM_RAIN_DANCE
	shopitem	1, TM_SANDSTORM
	db -1, -1 ; end

MartCeladon4F:
	db 3 ; # items
	shopitem	1, POKE_DOLL
	shopitem	1, LOVELY_MAIL
	shopitem	1, SURF_MAIL
	db -1, -1 ; end

MartCeladon5F1:
	db 5 ; # items
	shopitem	1, HP_UP
	shopitem	1, PROTEIN
	shopitem	1, IRON
	shopitem	1, CARBOS
	shopitem	1, CALCIUM
	db -1, -1 ; end

MartCeladon5F2:
	db 7 ; # items
	shopitem	1, X_ACCURACY
	shopitem	1, GUARD_SPEC
	shopitem	1, DIRE_HIT
	shopitem	1, X_ATTACK
	shopitem	1, X_DEFEND
	shopitem	1, X_SPEED
	shopitem	1, X_SPECIAL
	db -1, -1 ; end

MartFuchsia:
	db 7 ; # items
	shopitem	1, GREAT_BALL
	shopitem	1, ULTRA_BALL
	shopitem	1, SUPER_POTION
	shopitem	1, HYPER_POTION
	shopitem	1, FULL_HEAL
	shopitem	1, MAX_REPEL
	shopitem	1, FLOWER_MAIL
	db -1, -1 ; end

MartSaffron:
	db 8 ; # items
	shopitem	1, GREAT_BALL
	shopitem	1, ULTRA_BALL
	shopitem	1, HYPER_POTION
	shopitem	1, MAX_POTION
	shopitem	1, FULL_HEAL
	shopitem	1, X_ATTACK
	shopitem	1, X_DEFEND
	shopitem	1, FLOWER_MAIL
	db -1, -1 ; end

MartMtMoon:
	db 6 ; # items
	shopitem	1, POKE_DOLL
	shopitem	1, FRESH_WATER
	shopitem	1, SODA_POP
	shopitem	1, LEMONADE
	shopitem	1, REPEL
	shopitem	1, PORTRAITMAIL
	db -1, -1 ; end

MartIndigoPlateau:
	db 7 ; # items
	shopitem	1, ULTRA_BALL
	shopitem	1, MAX_REPEL
	shopitem	1, HYPER_POTION
	shopitem	1, MAX_POTION
	shopitem	1, FULL_RESTORE
	shopitem	1, REVIVE
	shopitem	1, FULL_HEAL
	db -1, -1 ; end

MartUnderground:
	db 4 ; # items
	shopitem	1, ENERGYPOWDER
	shopitem	1, ENERGY_ROOT
	shopitem	1, HEAL_POWDER
	shopitem	1, REVIVAL_HERB
	db -1, -1 ; end

MartCherrygroveBetter:
	db 7 ; # items
	shopitem	1, POKE_BALL
	shopitem	1, POTION
	shopitem	1, REPEL
	shopitem	1, ANTIDOTE
	shopitem	1, PARLYZ_HEAL
	shopitem	1, AWAKENING
	shopitem	1, ICE_HEAL
	db -1, -1 ; end
	
MartVioletBetter:
	db 11 ; # items
	shopitem	1, POKE_BALL
	shopitem	1, POTION
	shopitem	1, ESCAPE_ROPE
	shopitem	1, REPEL
	shopitem	1, ANTIDOTE
	shopitem	1, PARLYZ_HEAL
	shopitem	1, AWAKENING
	shopitem	1, ICE_HEAL
	shopitem	1, X_DEFEND
	shopitem	1, X_ATTACK
	shopitem	1, X_SPEED
	db -1, -1 ; end

MartAzaleaBetter:
	db 9 ; # items
	shopitem	1, CHARCOAL
	shopitem	1, POKE_BALL
	shopitem	1, POTION
	shopitem	1, SUPER_POTION
	shopitem	1, ESCAPE_ROPE
	shopitem	1, REPEL
	shopitem	1, ANTIDOTE
	shopitem	1, PARLYZ_HEAL
	shopitem	1, ICE_HEAL
	db -1, -1 ; end

MartGoldenrod4FBetter:
	db 11 ; # items
	shopitem	1, FIRE_STONE
	shopitem	1, WATER_STONE
	shopitem	1, LEAF_STONE
	shopitem	1, THUNDERSTONE
	shopitem	1, SUN_STONE
	shopitem	1, MOON_STONE
	shopitem	1, PROTEIN
	shopitem	1, IRON
	shopitem	1, CARBOS
	shopitem	1, CALCIUM
	shopitem	1, HP_UP
	db -1, -1 ; end

MartGoldenrod5FNoTMs:
	db 3 ; # items
	shopitem	1, TM_THUNDERPUNCH
	shopitem	1, TM_FIRE_PUNCH
	shopitem	1, TM_ICE_PUNCH
	db -1, -1 ; end

MartGoldenrod5FTM02:
	db 4 ; # items
	shopitem	1, TM_THUNDERPUNCH
	shopitem	1, TM_FIRE_PUNCH
	shopitem	1, TM_ICE_PUNCH
	shopitem	1, TM_HEADBUTT
	db -1, -1 ; end

MartGoldenrod5FTM08:
	db 4 ; # items
	shopitem	1, TM_THUNDERPUNCH
	shopitem	1, TM_FIRE_PUNCH
	shopitem	1, TM_ICE_PUNCH
	shopitem	1, TM_ROCK_SMASH
	db -1, -1 ; end

MartGoldenrod5FTM0208:
	db 5 ; # items
	shopitem	1, TM_THUNDERPUNCH
	shopitem	1, TM_FIRE_PUNCH
	shopitem	1, TM_ICE_PUNCH
	shopitem	1, TM_HEADBUTT
	shopitem	1, TM_ROCK_SMASH
	db -1, -1 ; end

MartGoldenrod5FTM12:
	db 4 ; # items
	shopitem	1, TM_THUNDERPUNCH
	shopitem	1, TM_FIRE_PUNCH
	shopitem	1, TM_ICE_PUNCH
	shopitem	1, TM_SWEET_SCENT
	db -1, -1 ; end

MartGoldenrod5FTM0212:
	db 5 ; # items
	shopitem	1, TM_THUNDERPUNCH
	shopitem	1, TM_FIRE_PUNCH
	shopitem	1, TM_ICE_PUNCH
	shopitem	1, TM_HEADBUTT
	shopitem	1, TM_SWEET_SCENT
	db -1, -1 ; end

MartGoldenrod5FTM0812:
	db 5 ; # items
	shopitem	1, TM_THUNDERPUNCH
	shopitem	1, TM_FIRE_PUNCH
	shopitem	1, TM_ICE_PUNCH
	shopitem	1, TM_ROCK_SMASH
	shopitem	1, TM_SWEET_SCENT
	db -1, -1 ; end

MartGoldenrod5FTM020812:
	db 6 ; # items
	shopitem	1, TM_THUNDERPUNCH
	shopitem	1, TM_FIRE_PUNCH
	shopitem	1, TM_ICE_PUNCH
	shopitem	1, TM_HEADBUTT
	shopitem	1, TM_ROCK_SMASH
	shopitem	1, TM_SWEET_SCENT
	db -1, -1 ; end

DefaultMart:
	db 2 ; # items
	shopitem	1, POKE_BALL
	shopitem	1, POTION
	db -1, -1 ; end

