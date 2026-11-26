import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.message = 'Nenhum resultado encontrado.',
    this.onClear,
  });
  final String message;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, size: 35, color: AppColors.gold),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (onClear != null) ...[
            const SizedBox(height: 17),
            OutlinedButton(
              onPressed: onClear,
              child: const Text('Limpar pesquisa'),
            ),
          ],
        ],
      ),
    ),
  );
}
