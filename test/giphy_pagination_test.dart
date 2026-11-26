import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:hogwarts_explorer/services/giphy_service.dart';

void main() {
  test('GIPHY requests pages by offset and caches repeated pages', () async {
    final offsets = <String?>[];
    final client = MockClient((request) async {
      offsets.add(request.url.queryParameters['offset']);
      final offset = int.parse(request.url.queryParameters['offset']!);
      final count = offset == 0 ? 2 : 1;
      return http.Response(
        jsonEncode({
          'data': List.generate(
            count,
            (index) => {
              'images': {
                'fixed_height': {
                  'url': 'https://media.example/${offset + index}.gif',
                },
              },
            },
          ),
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final service = GiphyService(client: client, apiKey: 'test-key');

    final first = await service.searchGifs('Hogwarts', limit: 2);
    final second = await service.searchGifs('Hogwarts', offset: 2, limit: 2);
    final cached = await service.searchGifs('Hogwarts', offset: 2, limit: 2);

    expect(first, hasLength(2));
    expect(second.single.url, 'https://media.example/2.gif');
    expect(cached, second);
    expect(offsets, ['0', '2']);
    service.dispose();
  });
}
