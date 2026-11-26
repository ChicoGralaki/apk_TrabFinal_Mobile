import 'package:flutter/material.dart';

import '../config/api_keys.dart';
import '../models/giphy_model.dart';
import '../services/giphy_service.dart';
import '../theme/app_theme.dart';

class GiphyExplorerPage extends StatefulWidget {
  const GiphyExplorerPage({super.key});
  @override
  State<GiphyExplorerPage> createState() => _GiphyExplorerPageState();
}

class _GiphyExplorerPageState extends State<GiphyExplorerPage> {
  final _query = TextEditingController();
  final _scroll = ScrollController();
  final List<GiphyGif> _gifs = [];
  bool _loading = false;
  bool _hasMore = false;
  String? _error;
  int _offset = 0;
  static const _pageSize = 18;

  @override
  void dispose() {
    _query.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _search({bool reset = false}) async {
    final query = _query.text.trim();
    if (query.isEmpty || _loading) return;
    if (reset) {
      _gifs.clear();
      _offset = 0;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await giphyService.searchGifs(
        query,
        offset: _offset,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _gifs.addAll(page);
        _offset += page.length;
        _hasMore = page.length == _pageSize;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Não foi possível carregar os GIFs. Verifique a conexão e tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Explorar GIFs')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _query,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(reset: true),
                  decoration: const InputDecoration(
                    hintText: 'Ex.: feitiços, Hogwarts...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _loading ? null : () => _search(reset: true),
                child: const Text('Buscar'),
              ),
            ],
          ),
        ),
        if (ApiKeys.giphyApiKey.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Configure GIPHY_API_KEY com --dart-define para habilitar a busca. Sem a chave, o app mantém imagens de fallback.',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              _error!,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        Expanded(
          child: _gifs.isEmpty && !_loading
              ? const Center(
                  child: Text(
                    'Pesquise para ver os resultados da GIPHY.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                )
              : GridView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: .88,
                  ),
                  itemCount: _gifs.length,
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      _gifs[index].url,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : const ColoredBox(
                              color: AppColors.soft,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                      errorBuilder: (_, _, _) => const ColoredBox(
                        color: AppColors.soft,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          ),
        if (_hasMore && !_loading)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
            child: OutlinedButton.icon(
              onPressed: () => _search(),
              icon: const Icon(Icons.expand_more),
              label: const Text('Carregar mais'),
            ),
          ),
      ],
    ),
  );
}
