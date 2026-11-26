import 'package:flutter/material.dart';

import '../services/giphy_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/gif_view.dart';
import 'characters/character_page.dart';
import 'houses/houses_page.dart';
import 'spells/spells_page.dart';
import 'giphy_explorer_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.showLogin = false});
  final bool showLogin;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<Map<String, String?>> _homeGifs = giphyService
      .loadHomeGifs();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 15, 22, 17),
                child: Row(
                  children: [
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AppLogo(),
                      ),
                    ),
                    if (widget.showLogin)
                      IconButton(
                        tooltip: 'Entrar na sua conta',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.account_circle_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Map<String, String?>>(
                        future: _homeGifs,
                        builder: (context, snapshot) => GifView(
                          url: snapshot.data?['hogwarts'],
                          height: 186,
                          label: 'Hogwarts • Um mundo de descobertas',
                        ),
                      ),
                      const SizedBox(height: 17),
                      const Text(
                        'HOGWARTS EXPLORER',
                        style: TextStyle(
                          color: AppColors.primary,
                          letterSpacing: 1.1,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Explore o universo mágico.',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Explore',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Escolha uma categoria para começar.',
                        style: TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                      const SizedBox(height: 11),
                      _HomeLink(
                        icon: Icons.menu_book_rounded,
                        title: 'PERSONAGENS',
                        description:
                            'Conheça bruxos, alunos, professores e criaturas.',
                        gifQuery: 'harry potter characters',
                        onTap: () => _open(context, const CharacterPage()),
                      ),
                      const SizedBox(height: 9),
                      _HomeLink(
                        icon: Icons.auto_awesome_rounded,
                        title: 'FEITIÇOS',
                        description:
                            'Explore feitiços e encantamentos do mundo mágico.',
                        gifQuery: 'harry potter spells',
                        onTap: () => _open(context, const SpellsPage()),
                      ),
                      const SizedBox(height: 9),
                      _HomeLink(
                        icon: Icons.castle_rounded,
                        title: 'CASAS',
                        description: 'Descubra as quatro casas de Hogwarts.',
                        gifQuery: 'harry potter houses',
                        onTap: () => _open(context, const HousesPage()),
                      ),
                      const SizedBox(height: 9),
                      _HomeLink(
                        icon: Icons.gif_box_outlined,
                        title: 'GIFS MÁGICOS',
                        description: 'Busque imagens animadas e carregue mais resultados.',
                        gifQuery: 'harry potter magic',
                        onTap: () => _open(context, const GiphyExplorerPage()),
                      ),
                      const SizedBox(height: 13),
                      Center(
                        child: Text(
                          'Dados mágicos fornecidos pela HP-API',
                          style: TextStyle(
                            color: AppColors.muted.withValues(alpha: .8),
                            fontSize: 9,
                          ),
                        ),
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

  void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

class _HomeLink extends StatelessWidget {
  const _HomeLink({
    required this.icon,
    required this.title,
    required this.description,
    required this.gifQuery,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String description;
  final String gifQuery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.soft,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: AppColors.primaryLight, size: 19),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      letterSpacing: .6,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 35,
              height: 35,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: GifView(query: gifQuery, height: 35, label: ''),
              ),
            ),
            const SizedBox(width: 3),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.muted,
              size: 18,
            ),
          ],
        ),
      ),
    ),
  );
}
