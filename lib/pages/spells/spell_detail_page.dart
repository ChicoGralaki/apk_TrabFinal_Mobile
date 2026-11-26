import 'package:flutter/material.dart';

import '../../models/spell_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/gif_view.dart';

class SpellDetailPage extends StatelessWidget {
  const SpellDetailPage({super.key, required this.spell});
  final Spell spell;

  @override
  Widget build(BuildContext context) => Scaffold(
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
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.soft,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.primaryLight,
                          size: 25,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        spell.name,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 17),
                      const Text(
                        'Descrição',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            spell.description ??
                                'Descrição não informada pela HP-API.',
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 13,
                              height: 1.55,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 19),
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
                        query: spell.name,
                        height: 205,
                        label: spell.name,
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
