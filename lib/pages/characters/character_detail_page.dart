import 'package:flutter/material.dart';

import '../../models/character_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/gif_view.dart';

class CharacterDetailPage extends StatelessWidget {
  const CharacterDetailPage({super.key, required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) {
    final personal = <(String, String?)>[
      ('Espécie', character.species),
      ('Gênero', character.gender),
      (
        'Nomes alternativos',
        character.alternateNames.isEmpty
            ? null
            : character.alternateNames.join(', '),
      ),
      ('Data de nascimento', character.dateOfBirth),
      ('Ano de nascimento', character.yearOfBirth?.toString()),
      ('Ancestralidade', character.ancestry),
      ('Cor dos olhos', character.eyeColour),
      ('Cor do cabelo', character.hairColour),
    ];
    final school = <(String, String?)>[
      ('Casa', character.house),
      ('Varinha', character.wand == null ? null : 'Disponível abaixo'),
      ('Patrono', character.patronus),
      ('Bruxo(a)', _yesNo(character.wizard)),
      ('Aluno(a) de Hogwarts', _yesNo(character.hogwartsStudent)),
      ('Funcionário(a)', _yesNo(character.hogwartsStaff)),
      ('Ator / atriz', character.actor),
      ('Status', _alive(character.alive)),
    ];
    final wand = <(String, String?)>[
      ('Madeira', character.wand?.wood),
      ('Núcleo', character.wand?.core),
      (
        'Comprimento',
        character.wand?.length == null
            ? null
            : '${character.wand!.length} pol.',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                AppHeader(onBack: () => Navigator.of(context).maybePop()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 205,
                            width: double.infinity,
                            child: character.image == null
                                ? const _PortraitFallback()
                                : Image.network(
                                    character.image!,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, progress) =>
                                            progress == null
                                            ? child
                                            : const _PortraitFallback(),
                                    errorBuilder: (context, error, stack) =>
                                        const _PortraitFallback(),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          character.name,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (character.alternateNames.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            character.alternateNames.join(' • '),
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                        const SizedBox(height: 17),
                        _InfoSection(title: 'Informações', fields: personal),
                        _InfoSection(title: 'Hogwarts e magia', fields: school),
                        if (wand.any((field) => field.$2 != null))
                          _InfoSection(title: 'Varinha', fields: wand),
                        const SizedBox(height: 3),
                        const Text(
                          'GIF relacionado',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 9),
                        GifView(
                          query: character.name,
                          height: 186,
                          label: character.name,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.fields});
  final String title;
  final List<(String, String?)> fields;

  @override
  Widget build(BuildContext context) {
    final available = fields
        .where((field) => field.$2 != null && field.$2!.trim().isNotEmpty)
        .toList();
    if (available.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: Column(
                children: [
                  for (var i = 0; i < available.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: AppColors.line),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              available[i].$1,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 5,
                            child: Text(
                              available[i].$2!,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortraitFallback extends StatelessWidget {
  const _PortraitFallback();
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.soft,
    child: const Center(
      child: Icon(Icons.person_rounded, size: 96, color: Color(0xFFCFC7BC)),
    ),
  );
}

String? _yesNo(bool? value) => value == null
    ? null
    : value
    ? 'Sim'
    : 'Não';
String? _alive(bool? value) => value == null
    ? null
    : value
    ? 'Vivo(a)'
    : 'Falecido(a)';
