#!/bin/python3

import argparse
import os
import hashlib
from typing import TextIO, BinaryIO

STARTERS = ['Cyndaquil', 'Totodile', 'Chikorita']
TUTORS = ['Flamethrower', 'Thunderbolt', 'IceBeam']
STATIC_POKES = ['Lapras',
                'Electrode1',
                'Electrode2',
                'Electrode3',
                'Lugia',
                'RedGyarados',
                'Sudowoodo',
                'Snorlax',
                'HoOh',
                'Suicune',
                'Voltorb',
                'Geodude',
                'Koffing',
                'Shuckle',
                'Tyrogue',
                'Togepi',
                'Kenya',
                'Eevee',
                'Dratini',
                'Raikou',
                'Entei',
		'Celebi']
GAME_CORNER = ['Abra',
               'Cubone',
               'Wobbuffet',
               'Pikachu',
               'Porygon',
               'Larvitar']


class Symfile(dict):
    @classmethod
    def from_fp(cls, fp):
        retval = cls()
        for line in fp:
            try:
                ptr, name = line.split()
                bank, addr = (int(x, 16) for x in ptr.split(':'))
                retval[name] = (bank << 14) | (addr & 0x3fff)
                # Because we can't tell from the SYM file whether a symbol
                # is actually is ROM or not, we just assume that it is in ROM.
            except ValueError:
                continue
        return retval


def fpeek(fp, size=1):
    tell = fp.tell()
    buff = fp.read(size)
    fp.seek(tell, os.SEEK_SET)
    return buff


class CLI(argparse.Namespace):
    rom: BinaryIO
    sym: Symfile
    out: TextIO

    _parser = argparse.ArgumentParser()
    _parser.add_argument('rom', type=argparse.FileType('rb'))
    _parser.add_argument('sym', type=lambda filename: Symfile.from_fp(open(filename)))
    _parser.add_argument('out', type=argparse.FileType('w'))

    @classmethod
    def parse_args(cls, args=None):
        return cls._parser.parse_args(args, cls())

    def setconfig(self, key, value):
        print('{}={}'.format(key, value), file=self.out)

    def set_symbol(self, key, sym, extra=0):
        self.setconfig(key, '0x{:X}'.format(self.sym[sym] + extra))
    
    def set_tm_text(self, num, key, txt):
        self.setconfig('TMText[]', '[{:d},0x{:X},{}]'.format(num, self.sym[key] + 1, txt))


def main():
    args = CLI.parse_args()

    args.rom.seek(0)
    romMD5 = str(hashlib.md5(args.rom.read()).hexdigest())
    # Print version
    args.rom.seek(0x14c)
    ver = int.from_bytes(args.rom.read(1), 'little')
    print('[Crystal SpeedChoice v{:d}]'.format(ver + 1), file=args.out)

    # Game code
    args.rom.seek(0x13f)
    code = args.rom.read(4).decode('ascii')
    args.setconfig('Game', code)
    args.setconfig('Version', str(ver))

    # Is Japanese?
    args.rom.seek(0x14a)
    jap = int.from_bytes(args.rom.read(1), 'little')
    args.setconfig('NonJapanese', str(jap))

    args.setconfig('Type', 'Crystal')
    args.setconfig('ExtraTableFile', 'gsc_english')

    args.set_symbol('PokemonNamesOffset', 'PokemonNames')
    args.setconfig('PokemonNamesLength', '10')
    args.set_symbol('PokemonStatsOffset', 'BaseData')
    args.set_symbol('WildPokemonOffset', 'JohtoGrassWildMons')
    args.set_symbol('FishingWildsOffset', 'FishGroupShore_Old')
    args.set_symbol('HeadbuttWildsOffset', 'TreeMonSet_City')
    args.setconfig('HeadbuttTableSize', 13)
    args.set_symbol('BCCWildsOffset', 'ContestMons')
    args.set_symbol('FleeingDataOffset', 'FleeMons')
    args.set_symbol('MoveDataOffset', 'MovesHMNerfs')
    args.set_symbol('MoveNamesOffset', 'MoveNamesNerfedHMs')
    args.set_symbol('ItemNamesOffset', 'ItemNames')
    args.set_symbol('PokemonMovesetsTableOffset', 'EvosAttacksPointers')
    args.setconfig('SupportsFourStartingMoves', str(1))
    for i, name in enumerate(STARTERS):
        key = 'Randomizer_Starter{}Offset{{:d}}'.format(name)
        offs = [args.sym[key.format(j + 1)] + 1 for j in range(4)]
        args.setconfig('StarterOffsets{:d}'.format(i + 1),
                  '[0x{:X}, 0x{:X}, 0x{:X}, 0x{:X}]'.format(*offs))
    offs = [args.sym['Randomizer_Starter{}Offset4'.format(starter)] + 3
            for starter in STARTERS]
    args.setconfig('StarterHeldItems',
              '[0x{:X}, 0x{:X}, 0x{:X}]'.format(*offs))
    offs = [args.sym['Randomizer_Starter{}TextOffset'.format(starter)] + 1
            for starter in STARTERS]
    args.setconfig('StarterTextOffsets',
              '[0x{:X}, 0x{:X}, 0x{:X}]'.format(*offs))

    args.setconfig('CanChangeStarterText', '1')
    args.setconfig('CanChangeTrainerText', '1')

    args.setconfig('TrainerClassAmount', '0x43')
    args.set_symbol('TrainerDataTableOffset', 'TrainerGroups')
    args.setconfig('TrainerDataClassCounts',
              '[1, 1, 1, 1, 1, 1, 1, 1, 15, 0, 1, 3, 1, 1, 1, 1, 1, 1, 1, 5, '
              '1, 14, 24, 19, 17, 1, 20, 21, 17, 15, 31, 5, 2, 3, 1, 19, '
              '25, 21, 19, 13, 14, 6, 2, 22, 9, 1, 3, 8, 6, 9, 4, 12, 26, '
              '22, 2, 12, 7, 3, 14, 6, 10, 6, 1, 1, 2, 5, 1]')
    args.set_symbol('TMMovesOffset', 'TMHMMoves')
    args.set_symbol('TrainerClassNamesOffset', 'TrainerClassNames')

    args.rom.seek(0x3bfff)
    while fpeek(args.rom) == b'\x00':
        args.rom.seek(-1, os.SEEK_CUR)
    tnamesize = 2691 + 0x3bfff - args.rom.tell()
    args.setconfig('MaxSumOfTrainerNameLengths', str(tnamesize))
    args.setconfig('DoublesTrainerClasses', '[60]')  # only twins

    args.set_symbol('IntroSpriteOffset', 'Randomizer_IntroSpriteOffset', 1)
    args.set_symbol('IntroCryOffset', 'Randomizer_IntroCryOffset', 1)
    args.set_symbol('MapHeaders', 'MapGroupPointers')
    args.set_symbol('LandmarkTableOffset', 'Landmarks')
    args.setconfig('LandmarkCount', '96')
    args.set_symbol('TradeTableOffset', 'NPCTrades')
    args.setconfig('TradeTableSize', '7')
    args.setconfig('TradeNameLength', '11')
    args.setconfig('TradeOTLength', '11')
    args.setconfig('TradesUnused', '[]')
    args.setconfig('TextDelayFunctionOffset', '0')

    key = 'Randomizer_CatchingTutorialMonOffset{:d}'
    offs = [args.sym[key.format(i)] + 1 for i in range(1, 4)]
    args.setconfig('CatchingTutorialOffsets',
              '[0x{:X}, 0x{:X}, 0x{:X}]'.format(*offs))

    args.set_symbol('PicPointers', 'PokemonPicPointers')
    args.set_symbol('PokemonPalettes', 'PokemonPalettes')

    offs = [args.sym['MoveTutorMove_{}'.format(move)] for move in TUTORS]
    args.setconfig('MoveTutorMoves', '[0x{:X}, 0x{:X}, 0x{:X}]'.format(*offs))

    args.set_symbol('MoveTutorMenuOffset', 'Randomizer_MoveTutorMenuOffset')
    args.set_symbol('MoveTutorMenuNewSpace', 'Randomizer_MoveTutorMenuNewSpace')
    args.set_symbol('CheckValueOffset', 'CheckValue')

    args.setconfig('StaticPokemonSupport', '1')
    args.setconfig('GameCornerPokemonNameLength', '11')

    for poke in STATIC_POKES:
        offs = [value + 1 for key, value in args.sym.items()
                if (key.startswith('Randomizer_{}'.format(poke)) and '.' not in key)]
        if len(offs) == 1:
            args.setconfig('StaticPokemon[]', '0x{:X}'.format(offs[0]))
        else:
            args.setconfig('StaticPokemon[]',
                      '[{}]'.format(', '.join(map('0x{:X}'.format, offs))))
    
    args.set_symbol('StaticPokemonOddEggOffset', 'Randomizer_OddEgg1')
    oddeggsize = args.sym['Randomizer_OddEgg2'] - args.sym['Randomizer_OddEgg1']
    args.setconfig('StaticPokemonOddEggDataSize', '0x{:X}'.format(oddeggsize))

    for poke in GAME_CORNER:
        offs = [args.sym['Randomizer_GameCorner{}Species1'.format(poke)] + 1,
                args.sym['Randomizer_GameCorner{}Species2'.format(poke)] + 1,
                args.sym['Randomizer_GameCorner{}Species3'.format(poke)] + 1,
                args.sym['Randomizer_GameCorner{}Name'.format(poke)]]
        args.setconfig('StaticPokemonGameCorner[]',
                  '[0x{:X}, 0x{:X}, 0x{:X}, 0x{:X}]'.format(*offs))

    args.set_tm_text(1, 'ChuckExplainTMText',
                'That is\\n%m.\\e')
    args.set_tm_text(3, 'CeladonMansionRoofHousePharmacistCurseText',
                'TM03 is\\n%m.\\p'
                'It\'s a terrifying\\n'
                'move!\\e')
    args.set_tm_text(5, 'Text_RoarOutro',
                'WROOOAR!\\nIT\'S %m!\\e')
    args.set_tm_text(6, 'JanineText_ToxicSpeech',
                'JANINE: You\'re so\\n'
                'tough! I have a \\l'
                'special gift!\\p'
                'It\'s %m!\\e')
    args.set_tm_text(7, 'PowerPlantManagerTM07IsZapCannonText',
                'MANAGER: TM07 is\\n'
                'my %m.\\p'
                'It\'s a powerful\\n'
                'technique!\\e')
    args.set_tm_text(8, 'RockSmashGuyText3',
                'That happens to be\\n'
                '%m.\\p'
                'If any rocks are\\n'
                'in your way, find\\l'
                'ROCK SMASH!\\e')
    args.set_tm_text(10, 'HiddenPowerGuyText2',
                'Do you see it? It\\n'
                'is %m!\\e')
    args.set_tm_text(11, 'RadioTower3FCooltrainerFItsSunnyDayText',
                'It\'s %m.\\n'
                'Use it wisely.\\e')
    args.set_tm_text(12, 'Route34IlexForestGateTeacher_GotSweetScent',
                'It\'s %m.\\p'
                'Use it on\\n'
                'enemy [POKé]MON.\\e')
    args.set_tm_text(13, 'FarmerFText_SnoreSpeech',
                'That there\'s\\n'
                '%m.\\p'
                'It\'s a rare move.\\e')
    args.set_tm_text(16, 'PryceText_IcyWindSpeech',
                'That TM contains\\n'
                '%m.\\p'
                'It demonstrates\\n'
                'the harshness of\\l'
                'winter.\\e')
    args.set_tm_text(19, 'ErikaExplainTMText',
                'That was a\\n'
                'delightful match.\\p'
                'I felt inspired.\\n'
                'Please, I wish you\\l'
                'to have this TM.\\p'
                'It\'s %m.\\p'
                'It is a wonderful\\n'
                'move!\\p'
                'Please use it if\\n'
                'it pleases you…\\e')
    args.set_tm_text(23, 'Jasmine_IronTailSpeech',
                '…That teaches\\n'
                '%m.\\e')
    args.set_tm_text(24, 'ClairText_DescribeDragonbreathDragonDen',
                'That contains\\n'
                '%m.\\p'
                'If you don\'t want\\n'
                'it, you don\'t have\\l'
                'to take it.\\e')
    args.set_tm_text(24, 'BlackthornGymClairText_DescribeTM24',
                'That contains\\n'
                '%m.\\p'
                'If you don\'t want\\n'
                'it, you don\'t have\\l'
                'to take it.\\e')
    args.set_tm_text(29, 'MrPsychicText2',
                'TM29 is\\n'
                '%m.\\p'
                'It may be\\n'
                'useful.\\e')
    args.set_tm_text(30, 'MortyText_ShadowBallSpeech',
                'It\'s %m.\\p'
                'Use it if it\\n'
                'appeals to you.\\e')
    args.set_tm_text(31, 'FalknerTMMudSlapText',
                'By using a TM, a\\n'
                '[POKé]MON will\\p'
                'instantly learn a\\n'
                'new move.\\p'
                'Think before you\\n'
                'act--a TM can be\\l'
                'used only once.\\p'
                'TM31 contains\\n%m.\\e')
    args.set_tm_text(37, 'SandstormHouseSandstormDescription',
                'TM37 happens to be\\n'
                '%m.\\p'
                'It\'s for advanced\\n'
                'trainers only.\\p'
                'Use it if you\\n'
                'dare. Good luck!\\e')
    args.set_tm_text(42, 'ViridianCityDreamEaterFisherGotDreamEaterText',
                'TM42 contains\\n'
                '%m…\\p'
                '…Zzz…\\e')
    args.set_tm_text(45, 'WhitneyAttractText',
                'It\'s %m!\\p'
                'Isn\'t it just per-\\n'
                'fect for a cutie\\l'
                'like me?\\e')
    args.set_tm_text(49, 'BugsyText_FuryCutterSpeech',
                'TM49 contains\\n'
                '%m.\\p'
                'Isn\'t it great?\\n'
                'I discovered it!\\e')
    args.set_tm_text(50, 'Text_Route31DescribeNightmare',
                'TM50 is\\n'
                '%m.\\p'
                'Ooooh…\\n'
                'It\'s scary…\\p'
                'I don\'t want to\\n'
                'have bad dreams.\\e')

    args.setconfig('MD5', romMD5)


if __name__ == '__main__':
    main()
