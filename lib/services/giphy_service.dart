import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_keys.dart';
import '../models/giphy_model.dart';

class GiphyService {
  GiphyService({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = apiKey ?? ApiKeys.giphyApiKey;

  final http.Client _client;
  final String _apiKey;
  final Map<String, String?> _cache = {};
  final Map<String, Future<String?>> _pending = {};
  final Map<String, List<GiphyGif>> _pageCache = {};
  final Map<String, Future<List<GiphyGif>>> _pagePending = {};

  bool get isConfigured =>
      _apiKey.trim().isNotEmpty && _apiKey != 'COLE_SUA_CHAVE_AQUI';

  void dispose() => _client.close();

  Future<String?> searchGif(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty || !isConfigured) return null;
    if (_cache.containsKey(normalized)) return _cache[normalized];
    final pending = _pending.putIfAbsent(normalized, () async {
      final gifs = await searchGifs(normalized, limit: 1);
      return gifs.isEmpty ? null : gifs.first.url;
    });
    try {
      final url = await pending;
      _cache[normalized] = url;
      return url;
    } finally {
      _pending.remove(normalized);
    }
  }

  Future<List<GiphyGif>> searchGifs(
    String query, {
    int offset = 0,
    int limit = 18,
  }) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty || !isConfigured) return const [];
    final key = '$normalized:$offset:$limit';
    if (_pageCache.containsKey(key)) return _pageCache[key]!;
    final future = _pagePending.putIfAbsent(
      key,
      () => _requestGifs(normalized, offset: offset, limit: limit),
    );
    try {
      final result = await future;
      _pageCache[key] = result;
      return result;
    } finally {
      _pagePending.remove(key);
    }
  }

  Future<Map<String, String?>> loadHomeGifs() async {
    const queries = <String>[
      'hogwarts',
      'harry potter characters',
      'harry potter spells',
      'harry potter houses',
    ];
    final results = await Future.wait(queries.map(searchGif));
    return Map<String, String?>.fromIterables(queries, results);
  }

  Future<List<GiphyGif>> _requestGifs(
    String query, {
    required int offset,
    required int limit,
  }) async {
    try {
      final uri = Uri.https('api.giphy.com', '/v1/gifs/search', {
        'api_key': _apiKey,
        'q': query,
        'limit': '$limit',
        'offset': '$offset',
        'rating': 'g',
        'lang': 'en',
      });
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 14));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('GIPHY request failed (${response.statusCode}).');
      }
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is! Map ||
          body['data'] is! List ||
          (body['data'] as List).isEmpty) {
        return const [];
      }
      return (body['data'] as List)
          .whereType<Map>()
          .map((item) {
            try {
              return GiphyGif.fromJson(Map<String, dynamic>.from(item));
            } on FormatException {
              return null;
            }
          })
          .whereType<GiphyGif>()
          .toList();
    } on Exception {
      rethrow;
    }
  }
}

final giphyService = GiphyService();
