import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 16.0 : 21.0;
    return Semantics(
      label: 'Hogwarts Explorer',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 30 : 39,
            height: compact ? 30 : 39,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(compact ? 9 : 12),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              size: iconSize,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'HOGWARTS',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: compact ? 9 : 11,
                  letterSpacing: 1.25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'EXPLORER',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: compact ? 8 : 9,
                  letterSpacing: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
