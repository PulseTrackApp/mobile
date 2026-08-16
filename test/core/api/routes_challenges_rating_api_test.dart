import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/core/api/api_config.dart';
import 'package:mobile_flutter/core/api/api_contract.dart';
import 'package:mobile_flutter/core/api/api_formatters.dart';
import 'package:mobile_flutter/core/api/pulse_track_api.dart';

/// Les appels des trois écrans ajoutés : parcours, défis, note.
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

  group('Parcours', () {
    test('lit la liste paginée, où le tracé est absent', () async {
      server.body = '''
        {"content": [
          {"id": "r1", "name": "Boucle du barrage", "distanceMeters": 6300.0,
           "loop": true, "pointCount": 312, "attemptCount": 4,
           "bestDurationSeconds": 2210, "points": null}
        ], "page": {"size": 20, "number": 0, "totalElements": 1}}
      ''';

      final routes = await api.getRoutes();

      expect(server.lastPath, 'me/routes');
      expect(routes, hasLength(1));
      expect(routes.first['name'], 'Boucle du barrage');
      // La liste ne charge pas trois cents points par ligne.
      expect(routes.first['points'], isNull);
      expect(routes.first['pointCount'], 312);
    });

    test('lit le classement des passages', () async {
      server.body = '''
        [
          {"rank": 1, "workoutId": "w1", "movingDurationSeconds": 2150,
           "isBest": true, "deltaSecondsVsBest": 0},
          {"rank": 2, "workoutId": "w2", "movingDurationSeconds": 2305,
           "isBest": false, "deltaSecondsVsBest": 155}
        ]
      ''';

      final attempts = await api.getRouteAttempts('r1');

      expect(server.lastPath, 'me/routes/r1/attempts');
      expect(attempts.first['isBest'], isTrue);
      // Un écart positif est plus lent : c'est la convention du chronomètre.
      expect(attempts.last['deltaSecondsVsBest'], 155);
    });

    test('crée un parcours depuis une séance', () async {
      server.body = '{"id": "r1", "name": "Boucle"}';

      await api.createRoute(workoutId: 'w1', name: 'Boucle');

      expect(server.lastPath, 'me/routes');
      expect(server.lastBody, contains('w1'));
    });
  });

  group('Défis', () {
    test('filtre la liste sur plusieurs statuts', () async {
      server.body = '{"content": [], "page": {"size": 20, "number": 0}}';

      await api.getChallenges(statuses: ['DRAFT', 'ACTIVE']);

      expect(server.lastQuery?['status'], 'DRAFT,ACTIVE');
    });

    test('arme un défi et récupère son plan', () async {
      server.body = '''
        {"id": "c1", "status": "ACTIVE", "targetDistanceMeters": 10000,
         "targetDurationSeconds": 3300,
         "plan": {"requiredPaceSecondsPerKm": 330,
                  "cues": [{"trigger": "REMAINING_SECONDS", "threshold": 300,
                            "kind": "DEADLINE_ALERT", "title": "5 minutes",
                            "message": "Cinq minutes avant l'échéance."}]}}
      ''';

      final armed = await api.startChallenge('c1');

      expect(server.lastPath, 'me/challenges/c1/start');
      expect(armed['status'], 'ACTIVE');
      // Le plan voyage avec l'armement : c'est lui que le téléphone joue hors
      // ligne, sans rappeler le serveur pendant la course.
      expect(armed['plan'], isNotNull);
    });
  });

  group('Note', () {
    test('lit la note et son détail', () async {
      server.body = '''
        {"score": 72, "grade": "B", "tier": "SOLID", "title": "Régulier",
         "message": "Quatre semaines de suite.", "windowDays": 28,
         "streakDays": 4, "nextTier": "STRONG", "pointsToNextTier": 8,
         "trend": {"previousScore": 64, "delta": 8, "direction": "UP"},
         "components": [{"key": "REGULARITY", "label": "Régularité",
                         "score": 80, "weight": 30, "comment": "12 jours actifs."}]}
      ''';

      final rating = await api.getRating(zone: 'Africa/Ouagadougou');

      expect(server.lastPath, 'me/rating');
      expect(rating['score'], 72);
      expect(rating['title'], 'Régulier');
      expect((rating['components'] as List), hasLength(1));
    });

    test('rend un score nul pour un compte sans séance', () async {
      // Le serveur n'envoie pas zéro : il n'envoie rien. L'écran doit traiter
      // ce cas à part, sous peine d'afficher « 0/100 » à un nouvel arrivant.
      server.body = '''
        {"score": null, "grade": null, "tier": "NEW", "title": null,
         "message": "Aucune séance enregistrée pour l'instant.",
         "windowDays": 28, "streakDays": 0, "components": []}
      ''';

      final rating = await api.getRating();

      expect(rating['score'], isNull);
      expect(rating['tier'], 'NEW');
      expect((rating['components'] as List), isEmpty);
    });
  });

  group('formatChrono', () {
    test('affiche un temps de course en minutes et secondes', () {
      expect(formatChrono(2150), '35:50');
      expect(formatChrono(59), '0:59');
    });

    test('passe aux heures au-delà de soixante minutes', () {
      expect(formatChrono(3661), '1:01:01');
    });

    test('signe les écarts comme un chronomètre', () {
      // Négatif veut dire plus rapide : contre-intuitif à l'écrit, mais c'est la
      // convention de tous les sports de temps.
      expect(formatChronoDelta(-60), '−1:00');
      expect(formatChronoDelta(155), '+2:35');
      expect(formatChronoDelta(0), '=');
    });
  });

  test('les sports se traduisent dans le type attendu par l\'API', () {
    // Le filtre des records passe par ce type : une valeur inventée ferait
    // répondre le serveur en 400.
    expect(ApiSportType.run.value, 'RUN');
    expect(ApiSportType.ride.value, 'RIDE');
  });
}

class _FakeServer implements HttpClientAdapter {
  String body = '{}';
  int status = 200;
  String? lastPath;
  String? lastBody;
  Map<String, dynamic>? lastQuery;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastPath = options.path;
    lastQuery = Map<String, dynamic>.from(options.queryParameters);
    lastBody = options.data?.toString();
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
