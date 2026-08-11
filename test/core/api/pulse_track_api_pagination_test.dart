import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/core/api/api_config.dart';
import 'package:mobile_flutter/core/api/api_formatters.dart';
import 'package:mobile_flutter/core/api/pulse_track_api.dart';

/// Lecture des reponses paginees du serveur.
///
/// Le serveur sert desormais du `PagedModel` : le contenu reste sous `content`,
/// mais les metadonnees sont passees sous `page`. Ces tests figent cette
/// lecture cote client, faute de quoi un retour a l'ancienne forme passerait
/// inapercu jusqu'a l'ecran vide chez l'utilisateur.
void main() {
  late Dio dio;
  late _FakeServer server;
  late PulseTrackApi api;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    server = _FakeServer();
    dio = Dio(BaseOptions(baseUrl: 'https://exemple.test/api/v1/'));
    dio.httpClientAdapter = server;
    api = PulseTrackApi(
      config: const ApiConfig(baseUrl: 'https://exemple.test/api/v1'),
      dio: dio,
    );
  });

  test('lit le contenu d une page d objectifs', () async {
    server.body = '''
      {
        "content": [
          {"id": "1", "type": "WEEKLY_DISTANCE", "targetValue": 30},
          {"id": "2", "type": "WEEKLY_SESSIONS", "targetValue": 3}
        ],
        "page": {"size": 20, "number": 0, "totalElements": 2, "totalPages": 1}
      }
    ''';

    final goals = await api.getGoals();

    expect(goals, hasLength(2));
    expect(goals.first['type'], 'WEEKLY_DISTANCE');
  });

  test(
    'lit aussi les objectifs quand le serveur renvoie encore un tableau',
    () async {
      server.body = '''
      [
        {"id": "1", "type": "WEEKLY_DISTANCE", "targetValue": 30}
      ]
    ''';

      final goals = await api.getGoals();

      expect(goals, hasLength(1));
      expect(goals.first['targetValue'], 30);
    },
  );

  test('demande la page et la taille au serveur', () async {
    server.body =
        '{"content": [], "page": {"size": 5, "number": 2, "totalElements": 0, "totalPages": 0}}';

    await api.getGoals(activeOnly: false, page: 2, size: 5);

    expect(server.lastQuery['page'], 2);
    expect(server.lastQuery['size'], 5);
    expect(server.lastQuery['activeOnly'], false);
  });

  test('rend une liste vide sur une page sans contenu', () async {
    server.body =
        '{"content": [], "page": {"size": 20, "number": 0, "totalElements": 0, "totalPages": 0}}';

    expect(await api.getGoals(), isEmpty);
  });

  test('pageContent lit la meme cle que le serveur ecrit', () {
    // `content` est le seul champ commun a l'ancienne et a la nouvelle forme :
    // c'est ce qui a permis a l'historique des seances de traverser le
    // changement sans modification.
    final page = {
      'content': [
        {'id': 'a'},
      ],
      'page': {'size': 20, 'number': 0, 'totalElements': 1, 'totalPages': 1},
    };

    expect(pageContent(page), hasLength(1));
  });
}

/// Adaptateur Dio qui repond toujours [body], et retient la requete recue.
class _FakeServer implements HttpClientAdapter {
  String body = '{}';
  Map<String, dynamic> lastQuery = const {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastQuery = Map<String, dynamic>.from(options.queryParameters);
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
