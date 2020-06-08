time_group EQUS "0," ; use the nth TimeFishGroups entry

fishgroup: MACRO
; chance, old rod, good rod, super rod
	dbwww \1, \2, \3, \4
ENDM

FishGroups::
; entries correspond to FISHGROUP_* constants
	fishgroup 50 percent + 1, FishGroupShore_Old,            FishGroupShore_Good,            FishGroupShore_Super
	fishgroup 50 percent + 1, FishGroupOcean_Old,            FishGroupOcean_Good,            FishGroupOcean_Super
	fishgroup 50 percent + 1, FishGroupLake_Old,             FishGroupLake_Good,             FishGroupLake_Super
	fishgroup 50 percent + 1, FishGroupPond_Old,             FishGroupPond_Good,             FishGroupPond_Super
	fishgroup 50 percent + 1, FishGroupDratini_Old,          FishGroupDratini_Good,          FishGroupDratini_Super
	fishgroup 50 percent + 1, FishGroupQwilfish_Swarm_Old,   FishGroupQwilfish_Swarm_Good,   FishGroupQwilfish_Swarm_Super
	fishgroup 50 percent + 1, FishGroupRemoraid_Swarm_Old,   FishGroupRemoraid_Swarm_Good,   FishGroupRemoraid_Swarm_Super
	fishgroup 50 percent + 1, FishGroupGyarados_Old,         FishGroupGyarados_Good,         FishGroupGyarados_Super
	fishgroup 50 percent + 1, FishGroupDratini_2_Old,        FishGroupDratini_2_Good,        FishGroupDratini_2_Super
	fishgroup 50 percent + 1, FishGroupWhirlIslands_Old,     FishGroupWhirlIslands_Good,     FishGroupWhirlIslands_Super
	fishgroup 50 percent + 1, FishGroupQwilfish_Old,         FishGroupQwilfish_Good,         FishGroupQwilfish_Super
	fishgroup 50 percent + 1, FishGroupRemoraid_Old,         FishGroupRemoraid_Good,         FishGroupRemoraid_Super
	fishgroup 50 percent + 1, FishGroupQwilfish_NoSwarm_Old, FishGroupQwilfish_NoSwarm_Good, FishGroupQwilfish_NoSwarm_Super

FishGroupShore_Old::
	db  70 percent + 1, MAGIKARP,   10
	db  85 percent + 1, MAGIKARP,   10
	db 100 percent,     KRABBY,     10
FishGroupShore_Good::
	db  35 percent,     MAGIKARP,   20
	db  70 percent,     KRABBY,     20
	db  90 percent + 1, KRABBY,     20
	db 100 percent,     time_group 0
FishGroupShore_Super::
	db  40 percent,     KRABBY,     40
	db  70 percent,     time_group 1
	db  90 percent + 1, KRABBY,     40
	db 100 percent,     KINGLER,    40

FishGroupOcean_Old::
	db  70 percent + 1, MAGIKARP,   10
	db  85 percent + 1, MAGIKARP,   10
	db 100 percent,     TENTACOOL,  10
FishGroupOcean_Good::
	db  35 percent,     MAGIKARP,   20
	db  70 percent,     TENTACOOL,  20
	db  90 percent + 1, CHINCHOU,   20
	db 100 percent,     time_group 2
FishGroupOcean_Super::
	db  40 percent,     CHINCHOU,   40
	db  70 percent,     time_group 3
	db  90 percent + 1, TENTACRUEL, 40
	db 100 percent,     LANTURN,    40

FishGroupLake_Old::
	db  70 percent + 1, MAGIKARP,   10
	db  85 percent + 1, MAGIKARP,   10
	db 100 percent,     GOLDEEN,    10
FishGroupLake_Good::
	db  35 percent,     MAGIKARP,   20
	db  70 percent,     GOLDEEN,    20
	db  90 percent + 1, GOLDEEN,    20
	db 100 percent,     time_group 4
FishGroupLake_Super::
	db  40 percent,     GOLDEEN,    40
	db  70 percent,     time_group 5
	db  90 percent + 1, MAGIKARP,   40
	db 100 percent,     SEAKING,    40

FishGroupPond_Old::
	db  70 percent + 1, MAGIKARP,   10
	db  85 percent + 1, MAGIKARP,   10
	db 100 percent,     POLIWAG,    10
FishGroupPond_Good::
	db  35 percent,     MAGIKARP,   20
	db  70 percent,     POLIWAG,    20
	db  90 percent + 1, POLIWAG,    20
	db 100 percent,     time_group 6
FishGroupPond_Super::
	db  40 percent,     POLIWAG,    40
	db  70 percent,     time_group 7
	db  90 percent + 1, MAGIKARP,   40
	db 100 percent,     POLIWAG,    40

FishGroupDratini_Old::
	db  70 percent + 1, MAGIKARP,   10
	db  85 percent + 1, MAGIKARP,   10
	db 100 percent,     MAGIKARP,   10
FishGroupDratini_Good::
	db  35 percent,     MAGIKARP,   20
	db  70 percent,     MAGIKARP,   20
	db  90 percent + 1, MAGIKARP,   20
	db 100 percent,     time_group 8
FishGroupDratini_Super::
	db  40 percent,     MAGIKARP,   40
	db  70 percent,     time_group 9
	db  90 percent + 1, MAGIKARP,   40
	db 100 percent,     DRAGONAIR,  40

FishGroupQwilfish_Swarm_Old::
	db  70 percent + 1, MAGIKARP,   5
	db  85 percent + 1, MAGIKARP,   5
	db 100 percent,     QWILFISH,   5
FishGroupQwilfish_Swarm_Good::
	db  35 percent,     MAGIKARP,   20
	db  70 percent,     QWILFISH,   20
	db  90 percent + 1, QWILFISH,   20
	db 100 percent,     time_group 10
FishGroupQwilfish_Swarm_Super::
	db  40 percent,     QWILFISH,   40
	db  70 percent,     time_group 11
	db  90 percent + 1, QWILFISH,   40
	db 100 percent,     QWILFISH,   40

FishGroupRemoraid_Swarm_Old::
	db  70 percent + 1, MAGIKARP,   10
	db  85 percent + 1, MAGIKARP,   10
	db 100 percent,     REMORAID,   10
FishGroupRemoraid_Swarm_Good::
	db  35 percent,     MAGIKARP,   20
	db  70 percent,     REMORAID,   20
	db  90 percent + 1, REMORAID,   20
	db 100 percent,     time_group 12
FishGroupRemoraid_Swarm_Super::
	db  40 percent,     REMORAID,   40
	db  70 percent,     time_group 13
	db  90 percent + 1, REMORAID,   40
	db 100 percent,     REMORAID,   40

FishGroupGyarados_Old::
	db  70 percent + 1, MAGIKARP,   10
	db  85 percent + 1, MAGIKARP,   10
	db 100 percent,     MAGIKARP,   10
FishGroupGyarados_Good::
	db  35 percent,     MAGIKARP,   20
	db  70 percent,     MAGIKARP,   20
	db  90 percent + 1, MAGIKARP,   20
	db 100 percent,     time_group 14
FishGroupGyarados_Super::
	db  40 percent,     MAGIKARP,   40
	db  70 percent,     time_group 15
	db  90 percent + 1, MAGIKARP,   40
	db 100 percent,     MAGIKARP,   40

FishGroupDratini_2_Old::
	db  70 percent + 1, MAGIKARP,   10
	db  85 percent + 1, MAGIKARP,   10
	db 100 percent,     MAGIKARP,   10
FishGroupDratini_2_Good::
	db  35 percent,     MAGIKARP,   10
	db  70 percent,     MAGIKARP,   10
	db  90 percent + 1, MAGIKARP,   10
	db 100 percent,     time_group 16
FishGroupDratini_2_Super::
	db  40 percent,     MAGIKARP,   10
	db  70 percent,     time_group 17
	db  90 percent + 1, MAGIKARP,   10
	db 100 percent,     DRAGONAIR,  10

FishGroupWhirlIslands_Old::
	db  70 percent + 1, MAGIKARP,   10
	db  85 percent + 1, MAGIKARP,   10
	db 100 percent,     KRABBY,     10
FishGroupWhirlIslands_Good::
	db  35 percent,     MAGIKARP,   20
	db  70 percent,     KRABBY,     20
	db  90 percent + 1, KRABBY,     20
	db 100 percent,     time_group 18
FishGroupWhirlIslands_Super::
	db  40 percent,     KRABBY,     40
	db  70 percent,     time_group 19
	db  90 percent + 1, KINGLER,    40
	db 100 percent,     SEADRA,     40

FishGroupQwilfish_NoSwarm_Old::
FishGroupQwilfish_Old::
	db  70 percent + 1, MAGIKARP,   10
	db  85 percent + 1, MAGIKARP,   10
	db 100 percent,     TENTACOOL,  10
FishGroupQwilfish_NoSwarm_Good::
FishGroupQwilfish_Good::
	db  35 percent,     MAGIKARP,   20
	db  70 percent,     TENTACOOL,  20
	db  90 percent + 1, TENTACOOL,  20
	db 100 percent,     time_group 20
FishGroupQwilfish_NoSwarm_Super::
FishGroupQwilfish_Super::
	db  40 percent,     TENTACOOL,  40
	db  70 percent,     time_group 21
	db  90 percent + 1, MAGIKARP,   40
	db 100 percent,     QWILFISH,   40

FishGroupRemoraid_Old::
	db  70 percent + 1, MAGIKARP,   10
	db  85 percent + 1, MAGIKARP,   10
	db 100 percent,     POLIWAG,    10
FishGroupRemoraid_Good::
	db  35 percent,     MAGIKARP,   20
	db  70 percent,     POLIWAG,    20
	db  90 percent + 1, POLIWAG,    20
	db 100 percent,     time_group 6
FishGroupRemoraid_Super::
	db  40 percent,     POLIWAG,    40
	db  70 percent,     time_group 7
	db  90 percent + 1, MAGIKARP,   40
	db 100 percent,     REMORAID,   40

TimeFishGroups::
	;  day              nite
	db CORSOLA,    20,  STARYU,     20 ; 0
	db CORSOLA,    40,  STARYU,     40 ; 1
	db SHELLDER,   20,  SHELLDER,   20 ; 2
	db SHELLDER,   40,  SHELLDER,   40 ; 3
	db GOLDEEN,    20,  GOLDEEN,    20 ; 4
	db GOLDEEN,    40,  GOLDEEN,    40 ; 5
	db POLIWAG,    20,  POLIWAG,    20 ; 6
	db POLIWAG,    40,  POLIWAG,    40 ; 7
	db DRATINI,    20,  DRATINI,    20 ; 8
	db DRATINI,    40,  DRATINI,    40 ; 9
	db QWILFISH,   20,  QWILFISH,   20 ; 10
	db QWILFISH,   40,  QWILFISH,   40 ; 11
	db REMORAID,   20,  REMORAID,   20 ; 12
	db REMORAID,   40,  REMORAID,   40 ; 13
	db GYARADOS,   20,  GYARADOS,   20 ; 14
	db GYARADOS,   40,  GYARADOS,   40 ; 15
	db DRATINI,    10,  DRATINI,    10 ; 16
	db DRATINI,    10,  DRATINI,    10 ; 17
	db HORSEA,     20,  HORSEA,     20 ; 18
	db HORSEA,     40,  HORSEA,     40 ; 19
	db TENTACOOL,  20,  TENTACOOL,  20 ; 20
	db TENTACOOL,  40,  TENTACOOL,  40 ; 21
