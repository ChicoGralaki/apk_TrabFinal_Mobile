import 'package:flutter_test/flutter_test.dart';
import 'package:hogwarts_explorer/models/character_model.dart';
import 'package:hogwarts_explorer/models/giphy_model.dart';
import 'package:hogwarts_explorer/models/spell_model.dart';
import 'package:hogwarts_explorer/services/giphy_service.dart';
import 'package:hogwarts_explorer/utils/character_filter.dart';
import 'package:hogwarts_explorer/utils/list_pagination.dart';

void main() {
  group('Character parsing', () {
    test('handles absent, empty and unexpected values', () {
      final character = Character.fromJson({
        'id': 'harry-id',
        'name': ' Harry Potter ',
        'house': '',
        'yearOfBirth': '1980',
        'alternate_names': ['The Boy Who Lived', null, ''],
        'wand': {'wood': 'holly', 'length': '11'},
        'wizard': 'true',
        'alive': false,
      });

      expect(character.id, 'harry-id');
      expect(character.name, 'Harry Potter');
      expect(character.house, isNull);
      expect(character.yearOfBirth, 1980);
      expect(character.alternateNames, ['The Boy Who Lived']);
      expect(character.wand?.wood, 'holly');
      expect(character.wand?.length, 11.0);
      expect(character.wizard, isTrue);
      expect(character.alive, isFalse);
      expect(character.actor, isNull);
    });
  });

  group('Spell parsing', () {
    test('handles missing description', () {
      final spell = Spell.fromJson({'name': 'Expecto Patronum'});
      expect(spell.name, 'Expecto Patronum');
      expect(spell.description, isNull);
      expect(Spell.fromJson({'name': 42}).name, 'Feitiço desconhecido');
    });
  });

  test('GIPHY parsing selects a bounded fixed-height rendition', () {
    final gif = GiphyGif.fromJson({
      'images': {
        'fixed_height_small': {'url': 'https://example.test/small.gif'},
        'fixed_height': {'url': 'https://example.test/fixed.gif'},
      },
    });
    expect(gif.url, 'https://example.test/fixed.gif');
  });

  group('Character filtering and visual pagination', () {
    final characters = [
      const Character(
        id: '1',
        name: 'Harry Potter',
        house: 'Gryffindor',
        hogwartsStudent: true,
      ),
      const Character(
        id: '2',
        name: 'Hermione Granger',
        house: 'Gryffindor',
        hogwartsStudent: true,
      ),
      const Character(
        id: '3',
        name: 'Severus Snape',
        house: 'Slytherin',
        hogwartsStaff: true,
      ),
    ];

    test('combines case-insensitive name search with house filter', () {
      final result = filterCharacters(
        characters,
        query: 'hArRy',
        filter: 'Gryffindor',
      );
      expect(result.map((character) => character.name), ['Harry Potter']);
      expect(
        filterCharacters(characters, filter: 'Staff').single.name,
        'Severus Snape',
      );
    });

    test('reveals results in groups of twelve and clamps at the total', () {
      expect(visibleItemCount(30), 12);
      expect(nextVisibleItemCount(30), 24);
      expect(nextVisibleItemCount(30, current: 24), 30);
      expect(visibleItemCount(5), 5);
    });
  });

  test('GIPHY returns its fallback value when no key is configured', () async {
    final service = GiphyService();
    expect(service.isConfigured, isFalse);
    expect(await service.searchGif('hogwarts'), isNull);
  });
}
