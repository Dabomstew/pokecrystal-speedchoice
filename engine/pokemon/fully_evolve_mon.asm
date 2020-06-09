FullyEvolveMonInB:
; exactly what it says on the tin.
	push bc
	dec b
	ld c, b
	ld b, 0
	ld hl, FullyEvolvedMonTable
	add hl, bc
	pop bc
	ld a, [hl]
	and a
	jr z, .Eeveelutions
	cp $FC
	jr z, .Tyrogue
	cp $FD
	jr z, .Poli
	cp $FE
	jr z, .Slow
	cp $FF
	jr z, .Gloom
	ld b, a
	ret
.Eeveelutions
	ld a, [CheckValue]
	and $1C ; $7 << 2
	srl a
	srl a
	push bc
	ld c, a
	ld b, 0
	ld hl, EeveelutionsTable
	add hl, bc
	pop bc
	ld a, [hl]
	ld b, a
	ret
.Tyrogue
	ld a, [CheckValue]
	and $3
	cp $2
	ld b, HITMONLEE
	ret c
	ld b, HITMONCHAN
	ret nz
	ld b, HITMONTOP
	ret
.Poli
	ld a, [CheckValue]
	and $20
	ld b, POLIWRATH
	ret z
	ld b, POLITOED
	ret
.Slow
	ld a, [CheckValue]
	and $40
	ld b, SLOWKING
	ret z
	ld b, SLOWBRO
	ret
.Gloom
	ld a, [CheckValue]
	and $80
	ld b, VILEPLUME
	ret z
	ld b, BELLOSSOM
	ret

EeveelutionsTable::
; there are only 5 eeveelutions but we need 8 values.
; so make the best 3 (Jolteon, Vaporeon, Espeon) more common.
	db JOLTEON
	db JOLTEON
	db VAPOREON
	db VAPOREON
	db ESPEON
	db ESPEON
	db FLAREON
	db UMBREON


femon: MACRO
	rept \1
	db \2
	endr
ENDM

FullyEvolvedMonTable::
	femon 3, VENUSAUR
	femon 3, CHARIZARD
	femon 3, BLASTOISE
	femon 3, BUTTERFREE
	femon 3, BEEDRILL
	femon 3, PIDGEOT
	femon 2, RATICATE
	femon 2, FEAROW
	femon 2, ARBOK
	femon 2, RAICHU
	femon 2, SANDSLASH
	femon 3, NIDOQUEEN
	femon 3, NIDOKING
	femon 2, CLEFABLE
	femon 2, NINETALES
	femon 2, WIGGLYTUFF
	femon 2, CROBAT
	femon 2, $FF ; oddish & gloom
	db VILEPLUME
	femon 2, PARASECT
	femon 2, VENOMOTH
	femon 2, DUGTRIO
	femon 2, PERSIAN
	femon 2, GOLDUCK
	femon 2, PRIMEAPE
	femon 2, ARCANINE
	femon 2, $FD ; poli
	db POLIWRATH
	femon 3, ALAKAZAM
	femon 3, MACHAMP
	femon 3, VICTREEBEL
	femon 2, TENTACRUEL
	femon 3, GOLEM
	femon 2, RAPIDASH
	db $FE ; slowpoke
	db SLOWBRO
	femon 2, MAGNETON
	db FARFETCH_D
	femon 2, DODRIO
	femon 2, DEWGONG
	femon 2, MUK
	femon 2, CLOYSTER
	femon 3, GENGAR
	db STEELIX
	femon 2, HYPNO
	femon 2, KINGLER
	femon 2, ELECTRODE
	femon 2, EXEGGUTOR
	femon 2, MAROWAK
	db HITMONLEE
	db HITMONCHAN
	db LICKITUNG
	femon 2, WEEZING
	femon 2, RHYDON
	db BLISSEY
	db TANGELA
	db KANGASKHAN
	femon 2, KINGDRA
	femon 2, SEAKING
	femon 2, STARMIE
	db MR__MIME
	db SCYTHER
	db JYNX
	db ELECTABUZZ
	db MAGMAR
	db PINSIR
	db TAUROS
	femon 2, GYARADOS
	db LAPRAS
	db DITTO
	db $00 ; eevee
	db VAPOREON
	db JOLTEON
	db FLAREON
	db PORYGON2
	femon 2, OMASTAR
	femon 2, KABUTOPS
	db AERODACTYL
	db SNORLAX
	db ARTICUNO
	db ZAPDOS
	db MOLTRES
	femon 3, DRAGONITE
	db MEWTWO
	db MEW
	femon 3, MEGANIUM
	femon 3, TYPHLOSION
	femon 3, FERALIGATR
	femon 2, FURRET
	femon 2, NOCTOWL
	femon 2, LEDIAN
	femon 2, ARIADOS
	db CROBAT
	femon 2, LANTURN
	db RAICHU
	db CLEFABLE
	db WIGGLYTUFF
	femon 2, TOGETIC
	femon 2, XATU
	femon 3, AMPHAROS
	db BELLOSSOM
	femon 2, AZUMARILL
	db SUDOWOODO
	db POLITOED
	femon 3, JUMPLUFF
	db AIPOM
	femon 2, SUNFLORA
	db YANMA
	femon 2, QUAGSIRE
	db ESPEON
	db UMBREON
	db MURKROW
	db SLOWKING
	db MISDREAVUS
	db UNOWN
	db WOBBUFFET
	db GIRAFARIG
	femon 2, FORRETRESS
	db DUNSPARCE
	db GLIGAR
	db STEELIX
	femon 2, GRANBULL
	db QWILFISH
	db SCIZOR
	db SHUCKLE
	db HERACROSS
	db SNEASEL
	femon 2, URSARING
	femon 2, MAGCARGO
	femon 2, PILOSWINE
	db CORSOLA
	femon 2, OCTILLERY
	db DELIBIRD
	db MANTINE
	db SKARMORY
	femon 2, HOUNDOOM
	db KINGDRA
	femon 2, DONPHAN
	db PORYGON2
	db STANTLER
	db SMEARGLE
	db $FC ; tyrogue
	db HITMONTOP
	db JYNX
	db ELECTABUZZ
	db MAGMAR
	db MILTANK
	db BLISSEY
	db RAIKOU
	db ENTEI
	db SUICUNE
	femon 3, TYRANITAR
	db LUGIA
	db HO_OH
	db CELEBI
