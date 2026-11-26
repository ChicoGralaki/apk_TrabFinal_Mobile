import 'package:flutter/material.dart';

import '../../models/spell_model.dart';
import '../../services/hp_api_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/list_pagination.dart';
import '../../widgets/app_header.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/search_field.dart';
import '../../widgets/spell_card.dart';
import 'spell_detail_page.dart';

class SpellsPage extends StatefulWidget {
  const SpellsPage({super.key});

  @override
  State<SpellsPage> createState() => _SpellsPageState();
}

class _SpellsPageState extends State<SpellsPage> {
  final _searchController = TextEditingController();
  late Future<List<Spell>> _spells;
  String _query = '';
  int _visible = pageSize;

  @override
  void initState() {
    super.initState();
    _spells = hpApiService.getSpells();
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Feitiços',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Palavras mágicas, encantamentos e seus efeitos.',
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                    const SizedBox(height: 12),
                    SearchField(
                      controller: _searchController,
                      hint: 'Pesquisar feitiço...',
                      onChanged: (value) => setState(() {
                        _query = value;
                        _visible = pageSize;
                      }),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Spell>>(
                  future: _spells,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingView();
                    }
                    if (snapshot.hasError) {
                      return ErrorView(
                        onRetry: () =>
                            setState(() => _spells = hpApiService.getSpells()),
                      );
                    }
                    final query = _query.trim().toLowerCase();
                    final filtered = (snapshot.data ?? const <Spell>[])
                        .where(
                          (spell) =>
                              query.isEmpty ||
                              spell.name.toLowerCase().contains(query),
                        )
                        .toList(growable: false);
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
                    return CustomScrollView(
                      key: const PageStorageKey('spell-list'),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                          sliver: SliverList.builder(
                            itemCount: count,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SpellCard(
                                spell: filtered[index],
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        SpellDetailPage(spell: filtered[index]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (hasMore)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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
                        const SliverToBoxAdapter(child: SizedBox(height: 15)),
                      ],
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
