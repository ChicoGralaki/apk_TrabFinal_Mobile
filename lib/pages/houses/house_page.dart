import 'package:flutter/material.dart';

import '../../models/character_model.dart';
import '../../services/hp_api_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/list_pagination.dart';
import '../../widgets/app_header.dart';
import '../../widgets/character_card.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/house_card.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/search_field.dart';
import '../characters/character_detail_page.dart';

class HousePage extends StatefulWidget {
  const HousePage({super.key, required this.house});
  final HouseInfo house;

  @override
  State<HousePage> createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  final _searchController = TextEditingController();
  late Future<List<Character>> _characters;
  String _query = '';
  int _visible = pageSize;

  @override
  void initState() {
    super.initState();
    _characters = hpApiService.getCharactersByHouse(widget.house.slug);
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: widget.house.color.withValues(alpha: .09),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: widget.house.color.withValues(alpha: .13),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.house.icon,
                              color: widget.house.color,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.house.name.toUpperCase(),
                                  style: TextStyle(
                                    color: widget.house.color,
                                    fontSize: 13,
                                    letterSpacing: .8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  widget.house.motto,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                          () => _characters = hpApiService.getCharactersByHouse(
                            widget.house.slug,
                          ),
                        ),
                      );
                    }
                    final query = _query.trim().toLowerCase();
                    final filtered = (snapshot.data ?? const <Character>[])
                        .where(
                          (character) =>
                              query.isEmpty ||
                              character.name.toLowerCase().contains(query),
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
                    final columnsWidth = MediaQuery.sizeOf(context).width;
                    final columns = columnsWidth >= 950
                        ? 4
                        : columnsWidth >= 680
                        ? 3
                        : 2;
                    return CustomScrollView(
                      key: PageStorageKey('house-${widget.house.slug}'),
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
                        if (count < filtered.length)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 7, 20, 24),
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
