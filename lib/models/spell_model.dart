class Spell {
  const Spell({required this.name, this.description});

  final String name;
  final String? description;

  factory Spell.fromJson(Map<String, dynamic> json) => Spell(
    name: _spellText(json['name']) ?? 'Feitiço desconhecido',
    description: _spellText(json['description']),
  );

  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}

String? _spellText(dynamic value) {
  if (value is! String) return null;
  final text = value.trim();
  return text.isEmpty || text.toLowerCase() == 'null' ? null : text;
}
