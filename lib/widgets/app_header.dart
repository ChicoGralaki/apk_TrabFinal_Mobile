import 'package:flutter/material.dart';

import 'app_logo.dart';
import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key, this.onBack, this.trailing});

  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 9, 20, 17),
      child: Row(
        children: [
          if (onBack != null) ...[
            Tooltip(
              message: 'Voltar',
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17),
                visualDensity: VisualDensity.compact,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 2),
          ],
          const AppLogo(compact: true),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}
