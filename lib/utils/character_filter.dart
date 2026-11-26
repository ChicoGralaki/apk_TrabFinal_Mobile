import '../models/character_model.dart';

List<Character> filterCharacters(
  Iterable<Character> characters, {
  String query = '',
  String filter = 'Todos',
}) {
  final needle = query.trim().toLowerCase();
  final selected = filter.toLowerCase();
  return characters
      .where((character) {
        final matchesQuery =
            needle.isEmpty || character.name.toLowerCase().contains(needle);
        final house = character.house?.toLowerCase() ?? '';
        final matchesFilter = switch (selected) {
          'gryffindor' ||
          'slytherin' ||
          'ravenclaw' ||
          'hufflepuff' => house == selected,
          'alunos' => character.hogwartsStudent == true,
          'staff' => character.hogwartsStaff == true,
          _ => true,
        };
        return matchesQuery && matchesFilter;
      })
      .toList(growable: false);
}
