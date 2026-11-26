import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/character_model.dart';
import '../models/spell_model.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class HpApiService {
  HpApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://hp-api.onrender.com/api';
  final http.Client _client;
  Future<List<Character>>? _charactersRequest;
  Future<List<Spell>>? _spellsRequest;
  final Map<String, Future<List<Character>>> _houseRequests = {};

  Future<List<Character>> getCharacters() {
    final request = _charactersRequest ??= _fetchCharacters();
    return request.catchError((Object error) {
      _charactersRequest = null;
      throw error;
    });
  }

  Future<List<Spell>> getSpells() {
    final request = _spellsRequest ??= _fetchSpells();
    return request.catchError((Object error) {
      _spellsRequest = null;
      throw error;
    });
  }

  Future<List<Character>> getCharactersByHouse(String house) {
    final normalized = house.trim().toLowerCase();
    if (normalized.isEmpty) return Future.value(const []);
    final request = _houseRequests.putIfAbsent(
      normalized,
      () => _fetchHouse(normalized),
    );
    return request.catchError((Object error) {
      _houseRequests.remove(normalized);
      throw error;
    });
  }

  Future<List<Character>> _fetchCharacters() async {
    final data = await _getJson('$_baseUrl/characters');
    if (data is! List) {
      throw const ApiException('Formato de personagens inválido.');
    }
    return data
        .whereType<Map>()
        .map((item) => Character.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<Spell>> _fetchSpells() async {
    final data = await _getJson('$_baseUrl/spells');
    if (data is! List) {
      throw const ApiException('Formato de feitiços inválido.');
    }
    return data
        .whereType<Map>()
        .map((item) => Spell.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<Character>> _fetchHouse(String house) async {
    final data = await _getJson(
      '$_baseUrl/characters/house/${Uri.encodeComponent(house)}',
    );
    if (data is! List) {
      throw const ApiException('Formato de personagens da casa inválido.');
    }
    return data
        .whereType<Map>()
        .map((item) => Character.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<dynamic> _getJson(String url) async {
    http.Response response;
    try {
      response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 18));
    } on Exception catch (error) {
      throw ApiException('Falha de conexão com a HP-API: $error');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('A HP-API respondeu com HTTP ${response.statusCode}.');
    }
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ApiException('A HP-API retornou um JSON inválido.');
    }
  }
}

final hpApiService = HpApiService();
