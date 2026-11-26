import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HouseInfo {
  const HouseInfo(this.slug, this.name, this.motto, this.color, this.icon);
  final String slug;
  final String name;
  final String motto;
  final Color color;
  final IconData icon;
}

const houses = <HouseInfo>[
  HouseInfo(
    'gryffindor',
    'Gryffindor',
    'Coragem e determinação',
    Color(0xFF8D1C2D),
    Icons.local_fire_department_rounded,
  ),
  HouseInfo(
    'slytherin',
    'Slytherin',
    'Ambição e engenhosidade',
    Color(0xFF315A43),
    Icons.water_rounded,
  ),
  HouseInfo(
    'ravenclaw',
    'Ravenclaw',
    'Sabedoria e criatividade',
    Color(0xFF354F79),
    Icons.air_rounded,
  ),
  HouseInfo(
    'hufflepuff',
    'Hufflepuff',
    'Lealdade e dedicação',
    Color(0xFFA47A27),
    Icons.wb_sunny_rounded,
  ),
];

class HouseCard extends StatelessWidget {
  const HouseCard({super.key, required this.house, required this.onTap});
  final HouseInfo house;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: house.color.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(house.icon, color: house.color, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    house.name.toUpperCase(),
                    style: TextStyle(
                      color: house.color,
                      fontSize: 12,
                      letterSpacing: .8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    house.motto,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.muted,
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );
}
