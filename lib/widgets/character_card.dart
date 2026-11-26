import 'package:flutter/material.dart';

import '../models/character_model.dart';
import '../theme/app_theme.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
  });
  final Character character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final house = character.house?.isNotEmpty == true
        ? character.house!
        : 'Sem casa';
    final subtitle = character.actor?.isNotEmpty == true
        ? character.actor!
        : character.hogwartsStudent == true
        ? 'Estudante'
        : character.hogwartsStaff == true
        ? 'Professor(a)'
        : character.species ?? 'Personagem';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppColors.soft,
                    child: character.image == null
                        ? const _CharacterPlaceholder()
                        : Image.network(
                            character.image!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                ? child
                                : const _CharacterPlaceholder(),
                            errorBuilder: (context, error, stack) =>
                                const _CharacterPlaceholder(),
                          ),
                  ),
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: _houseColor(house),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    house,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterPlaceholder extends StatelessWidget {
  const _CharacterPlaceholder();
  @override
  Widget build(BuildContext context) => const Center(
    child: Icon(Icons.person_rounded, size: 54, color: Color(0xFFCFC7BC)),
  );
}

Color _houseColor(String house) => switch (house.toLowerCase()) {
  'gryffindor' => const Color(0xFF8D1C2D),
  'slytherin' => const Color(0xFF315A43),
  'ravenclaw' => const Color(0xFF354F79),
  'hufflepuff' => AppColors.gold,
  _ => AppColors.muted,
};
