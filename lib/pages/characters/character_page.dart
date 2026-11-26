import 'package:flutter/material.dart';

import '../../models/character_model.dart';
import '../../services/hp_api_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/character_filter.dart';
import '../../utils/list_pagination.dart';
import '../../widgets/app_header.dart';
import '../../widgets/character_card.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/search_field.dart';
import 'character_detail_page.dart';

class CharacterPage extends StatefulWidget {
  const CharacterPage({super.key});

  @override
  State<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage> {
  static const _filters = [
    'Todos',
    'Gryffindor',
    'Slytherin',
    'Ravenclaw',
    'Hufflepuff',
    'Alunos',
    'Staff',
  ];
  final _searchController = TextEditingController();
  late Future<List<Character>> _characters;
  String _query = '';
  String _filter = 'Todos';
  int _visible = pageSize;

  @override
  void initState() {
    super.initState();
    _characters = hpApiService.getCharacters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(onBack: () => Navigator.of(context).maybePop()),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personagens',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Uma enciclopédia de bruxos, alunos e criaturas.',
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                    const SizedBox(height: 12),
                    SearchField(
                      controller: _searchController,
                      hint: 'Pesquisar personagem...',
                      onChanged: (value) => setState(() {
                        _query = value;
                        _visible = pageSize;
                      }),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 33,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 6),
                        itemBuilder: (context, index) {
                          final filter = _filters[index];
                          final selected = _filter == filter;
                          return ChoiceChip(
                            label: Text(
                              filter,
                              style: TextStyle(
                                color: selected ? Colors.white : AppColors.ink,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            selected: selected,
                            onSelected: (_) => setState(() {
                              _filter = filter;
                              _visible = pageSize;
                            }),
                            showCheckmark: false,
                            visualDensity: VisualDensity.compact,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Character>>(
                  future: _characters,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingView();
                    }
                    if (snapshot.hasError) {
                      return ErrorView(
                        onRetry: () => setState(
                          () => _characters = hpApiService.getCharacters(),
                        ),
                      );
                    }
                    final filtered = filterCharacters(
                      snapshot.data ?? const [],
                      query: _query,
                      filter: _filter,
                    );
                    if (filtered.isEmpty) {
                      return EmptyView(
                        onClear: _query.isEmpty
                            ? null
                            : () {
                                _searchController.clear();
                                setState(() {
                                  _query = '';
                                  _visible = pageSize;
                                });
                              },
                      );
                    }
                    final count = visibleItemCount(
                      filtered.length,
                      current: _visible,
                    );
                    final hasMore = count < filtered.length;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 680
                            ? 4
                            : constraints.maxWidth >= 480
                            ? 3
                            : 2;
                        return CustomScrollView(
                          key: const PageStorageKey('character-grid'),
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
                              sliver: SliverGrid.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                      childAspectRatio: .78,
                                    ),
                                itemCount: count,
                                itemBuilder: (context, index) => CharacterCard(
                                  character: filtered[index],
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => CharacterDetailPage(
                                        character: filtered[index],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (hasMore)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    7,
                                    20,
                                    24,
                                  ),
                                  child: Center(
                                    child: OutlinedButton(
                                      onPressed: () => setState(
                                        () => _visible = nextVisibleItemCount(
                                          filtered.length,
                                          current: _visible,
                                        ),
                                      ),
                                      child: const Text('Carregar mais'),
                                    ),
                                  ),
                                ),
                              ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 15),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
