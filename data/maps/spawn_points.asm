spawn: MACRO
; map, x, y
	map_id \1
	db \2, \3
ENDM

dangerouswarp: MACRO
; map, warp_id
	map_id \1
	db \2
ENDM

SpawnPoints:
; entries correspond to SPAWN_* constants

	spawn PLAYERS_HOUSE_2F,            3,  3
	spawn VIRIDIAN_POKECENTER_1F,      5,  3

	spawn PALLET_TOWN,                 5,  6
	spawn VIRIDIAN_CITY,              23, 26
	spawn PEWTER_CITY,                13, 26
	spawn CERULEAN_CITY,              19, 22
	spawn ROUTE_10_NORTH,             11,  2
	spawn VERMILION_CITY,              9,  6
	spawn LAVENDER_TOWN,               5,  6
	spawn SAFFRON_CITY,                9, 30
	spawn CELADON_CITY,               29, 10
	spawn FUCHSIA_CITY,               19, 28
	spawn CINNABAR_ISLAND,            11, 12
	spawn ROUTE_23,                    9,  6

	spawn NEW_BARK_TOWN,              13,  6
	spawn CHERRYGROVE_CITY,           29,  4
	spawn VIOLET_CITY,                31, 26
	spawn ROUTE_32,                   11, 74
	spawn AZALEA_TOWN,                15, 10
	spawn CIANWOOD_CITY,              23, 44
	spawn GOLDENROD_CITY,             15, 28
	spawn OLIVINE_CITY,               13, 22
	spawn ECRUTEAK_CITY,              23, 28
	spawn MAHOGANY_TOWN,              15, 14
	spawn LAKE_OF_RAGE,               21, 29
	spawn BLACKTHORN_CITY,            21, 30
	spawn SILVER_CAVE_OUTSIDE,        23, 20
	spawn FAST_SHIP_CABINS_SW_SSW_NW,  6,  2

	spawn N_A,                        -1, -1

DangerousWarps:
	dangerouswarp CELADON_CITY,	8
	dangerouswarp ROUTE_10_NORTH,	2
	dangerouswarp BLACKTHORN_CITY,	8
	dangerouswarp BLACKTHORN_CITY,	1
	dangerouswarp GOLDENROD_CITY,	4
	dangerouswarp GOLDENROD_CITY,	7
	dangerouswarp GOLDENROD_CITY,	10
	dangerouswarp GOLDENROD_CITY,	14
	dangerouswarp AZALEA_TOWN,	5
	dangerouswarp AZALEA_TOWN,	6
	dangerouswarp MAHOGANY_TOWN,	3
	dangerouswarp VERMILION_CITY,	7
	dangerouswarp FUCHSIA_CITY,	1
	dangerouswarp ECRUTEAK_CITY,	12
	dangerouswarp VERMILION_CITY,	10


	dangerouswarp N_A, 		-1
