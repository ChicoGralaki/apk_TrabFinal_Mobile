class Character {
  const Character({
    required this.id,
    required this.name,
    this.alternateNames = const [],
    this.species,
    this.gender,
    this.house,
    this.dateOfBirth,
    this.yearOfBirth,
    this.wizard,
    this.ancestry,
    this.eyeColour,
    this.hairColour,
    this.wand,
    this.patronus,
    this.hogwartsStudent,
    this.hogwartsStaff,
    this.actor,
    this.alive,
    this.image,
  });

  final String id;
  final String name;
  final List<String> alternateNames;
  final String? species;
  final String? gender;
  final String? house;
  final String? dateOfBirth;
  final int? yearOfBirth;
  final bool? wizard;
  final String? ancestry;
  final String? eyeColour;
  final String? hairColour;
  final Wand? wand;
  final String? patronus;
  final bool? hogwartsStudent;
  final bool? hogwartsStaff;
  final String? actor;
  final bool? alive;
  final String? image;

  factory Character.fromJson(Map<String, dynamic> json) {
    final wandJson = json['wand'];
    final rawYear = json['yearOfBirth'];
    return Character(
      id: _text(json['id']) ?? _text(json['name']) ?? 'unknown',
      name: _text(json['name']) ?? 'Nome desconhecido',
      alternateNames: _stringList(
        json['alternate_names'] ?? json['alternateNames'],
      ),
      species: _text(json['species']),
      gender: _text(json['gender']),
      house: _text(json['house']),
      dateOfBirth: _text(json['dateOfBirth']),
      yearOfBirth: rawYear is num ? rawYear.toInt() : int.tryParse('$rawYear'),
      wizard: _boolean(json['wizard']),
      ancestry: _text(json['ancestry']),
      eyeColour: _text(json['eyeColour']),
      hairColour: _text(json['hairColour']),
      wand: wandJson is Map
          ? Wand.fromJson(Map<String, dynamic>.from(wandJson))
          : null,
      patronus: _text(json['patronus']),
      hogwartsStudent: _boolean(json['hogwartsStudent']),
      hogwartsStaff: _boolean(json['hogwartsStaff']),
      actor: _text(json['actor']),
      alive: _boolean(json['alive']),
      image: _text(json['image']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'alternate_names': alternateNames,
    'species': species,
    'gender': gender,
    'house': house,
    'dateOfBirth': dateOfBirth,
    'yearOfBirth': yearOfBirth,
    'wizard': wizard,
    'ancestry': ancestry,
    'eyeColour': eyeColour,
    'hairColour': hairColour,
    'wand': wand?.toJson(),
    'patronus': patronus,
    'hogwartsStudent': hogwartsStudent,
    'hogwartsStaff': hogwartsStaff,
    'actor': actor,
    'alive': alive,
    'image': image,
  };
}

class Wand {
  const Wand({this.wood, this.core, this.length});

  final String? wood;
  final String? core;
  final double? length;

  factory Wand.fromJson(Map<String, dynamic> json) {
    final rawLength = json['length'];
    return Wand(
      wood: _text(json['wood']),
      core: _text(json['core']),
      length: rawLength is num
          ? rawLength.toDouble()
          : double.tryParse('$rawLength'),
    );
  }

  Map<String, dynamic> toJson() => {
    'wood': wood,
    'core': core,
    'length': length,
  };
}

String? _text(dynamic value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return null;
  return trimmed;
}

List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  return value.map(_text).whereType<String>().toList(growable: false);
}

bool? _boolean(dynamic value) {
  if (value is bool) return value;
  if (value is String) {
    switch (value.toLowerCase().trim()) {
      case 'true':
        return true;
      case 'false':
        return false;
    }
  }
  return null;
}
