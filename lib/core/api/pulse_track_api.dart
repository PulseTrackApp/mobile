import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_contract.dart';
import 'api_error.dart';
import 'auth_session.dart';
import 'auth_token_store.dart';

typedef JsonMap = Map<String, dynamic>;

class PulseTrackApi {
  PulseTrackApi({ApiConfig? config, AuthTokenStore? tokenStore, Dio? dio})
    : config = config ?? ApiConfig.fromEnvironment(),
      tokenStore = tokenStore ?? AuthTokenStore(),
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: (config ?? ApiConfig.fromEnvironment()).dioBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              headers: const {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = this.tokenStore.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final ApiConfig config;
  final AuthTokenStore tokenStore;
  final Dio _dio;

  Future<AuthSession> register({
    required String email,
    required String password,
  }) async {
    final session = await _send(
      () => _dio.post<Object?>(
        'auth/register',
        data: {'email': email, 'password': password},
      ),
      (response) => AuthSession.fromJson(_asJsonMap(response.data)),
      retryOnUnauthorized: false,
    );
    await tokenStore.save(session);
    return session;
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _send(
      () => _dio.post<Object?>(
        'auth/login',
        data: {'email': email, 'password': password},
      ),
      (response) => AuthSession.fromJson(_asJsonMap(response.data)),
      retryOnUnauthorized: false,
    );
    await tokenStore.save(session);
    return session;
  }

  Future<AuthSession> refreshSession() async {
    final refreshToken = tokenStore.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const ApiProblem(
        title: 'Session expiree',
        status: 401,
        detail: 'Session expiree.',
      );
    }

    final session = await _send(
      () => _dio.post<Object?>(
        'auth/refresh',
        data: {'refreshToken': refreshToken},
      ),
      (response) => AuthSession.fromJson(_asJsonMap(response.data)),
      retryOnUnauthorized: false,
    );
    await tokenStore.save(session);
    return session;
  }

  Future<void> logout() async {
    final refreshToken = tokenStore.refreshToken;

    try {
      if (refreshToken != null &&
          refreshToken.isNotEmpty &&
          tokenStore.isAuthenticated) {
        await _send(
          () => _dio.post<Object?>(
            'auth/logout',
            data: {'refreshToken': refreshToken},
          ),
          (_) {},
          retryOnUnauthorized: false,
        );
      }
    } on ApiProblem {
      // La deconnexion doit rester possible meme sans reseau.
    } finally {
      await tokenStore.clear();
    }
  }

  /// Declare l'appareil courant aupres du serveur pour qu'il recoive les
  /// rappels d'entrainement.
  ///
  /// Le jeton vient du SDK FCM ; [platform] vaut `ANDROID`, `IOS` ou `WEB`.
  /// Appeler cette methode plusieurs fois avec le meme jeton est sans effet :
  /// le serveur le reconnait et se contente de rafraichir sa date de derniere
  /// vue.
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) {
    return _send(
      () => _dio.put<Object?>(
        'me/device-tokens',
        data: {'token': token, 'platform': platform},
      ),
      (_) {},
    );
  }

  /// Retire l'appareil de la liste des destinataires.
  ///
  /// A appeler avant d'effacer la session : l'endpoint exige un jeton d'acces
  /// valide. Sans cela, un telephone partage continuerait de recevoir les
  /// rappels du compte precedent.
  Future<void> unregisterDeviceToken(String token) {
    return _send(
      () => _dio.delete<Object?>(
        'me/device-tokens/${Uri.encodeComponent(token)}',
      ),
      (_) {},
    );
  }

  Future<JsonMap> getProfile() {
    return _getJson('me/profile');
  }

  Future<JsonMap> saveProfile(JsonMap profile) {
    return _putJson('me/profile', data: profile);
  }

  Future<JsonMap> createWorkout(JsonMap workout) {
    return _postJson('workouts', data: workout);
  }

  Future<JsonMap> listWorkouts({
    ApiSportType? sport,
    int page = 0,
    int size = 20,
  }) {
    return _getJson(
      'workouts',
      queryParameters: {'sport': sport?.value, 'page': page, 'size': size},
    );
  }

  Future<JsonMap> getWorkout(String id) {
    return _getJson('workouts/$id');
  }

  Future<void> deleteWorkout(String id) {
    return _deleteNoContent('workouts/$id');
  }

  Future<JsonMap> getStats({
    ApiStatsPeriod period = ApiStatsPeriod.week,
    DateTime? reference,
    String? zone,
  }) {
    return _getJson(
      'me/stats',
      queryParameters: {
        'period': period.value,
        'reference': _dateOrNull(reference),
        'zone': zone,
      },
    );
  }

  Future<JsonMap> getWeeklySummary({DateTime? weekStart, String? zone}) {
    return _getJson(
      'me/weekly-summary',
      queryParameters: {'weekStart': _dateOrNull(weekStart), 'zone': zone},
    );
  }

  Future<JsonMap> saveBodyCheckIn(JsonMap checkIn) {
    return _putJson('me/body-checkins', data: checkIn);
  }

  Future<JsonMap> listBodyCheckIns({int page = 0, int size = 20}) {
    return _getJson(
      'me/body-checkins',
      queryParameters: {'page': page, 'size': size},
    );
  }

  Future<JsonMap> getBodyProgress() {
    return _getJson('me/body-checkins/progress');
  }

  /// Objectifs de l'utilisateur, une page a la fois.
  ///
  /// L'endpoint renvoie une page — comme l'historique des seances — et non un
  /// tableau : avec [activeOnly] a `false` la liste contient les archives et
  /// grossit d'un objectif par semaine. Seul le contenu de la page demandee est
  /// retourne ; les objectifs en cours tiennent tous dans la premiere, leur
  /// nombre etant borne par celui des types.
  Future<List<JsonMap>> getGoals({
    bool activeOnly = true,
    int page = 0,
    int size = 20,
  }) async {
    return _send(
      () => _dio.get<Object?>(
        'me/goals',
        queryParameters: _cleanQuery({
          'activeOnly': activeOnly,
          'page': page,
          'size': size,
        }),
      ),
      (response) => _asJsonPageContent(response.data),
    );
  }

  Future<JsonMap> createGoal(JsonMap goal) {
    return _postJson('me/goals', data: goal);
  }

  Future<JsonMap> updateGoal(String id, JsonMap goal) {
    return _putJson('me/goals/$id', data: goal);
  }

  Future<JsonMap> archiveGoal(String id) {
    return _postJson('me/goals/$id/archive');
  }

  Future<void> deleteGoal(String id) {
    return _deleteNoContent('me/goals/$id');
  }

  Future<JsonMap> getCoachSettings() {
    return _getJson('me/coach/settings');
  }

  Future<JsonMap> updateCoachSettings({
    required bool enabled,
    required ApiCoachingTone coachingTone,
    required bool weeklyReviewEnabled,
    required bool effortWarningsEnabled,
  }) {
    return _putJson(
      'me/coach/settings',
      data: {
        'enabled': enabled,
        'coachingTone': coachingTone.value,
        'weeklyReviewEnabled': weeklyReviewEnabled,
        'effortWarningsEnabled': effortWarningsEnabled,
      },
    );
  }

  Future<JsonMap> requestWeeklyReview({
    DateTime? weekStart,
    String? zone,
    bool refresh = false,
  }) {
    return _postJson(
      'me/coach/weekly-review',
      queryParameters: {
        'weekStart': _dateOrNull(weekStart),
        'zone': zone,
        'refresh': refresh,
      },
    );
  }

  Future<JsonMap> askCoach({required String question, String? zone}) {
    return _postJson(
      'me/coach/ask',
      data: {'question': question},
      queryParameters: {'zone': zone},
    );
  }

  Future<JsonMap?> getLatestCoachMessage() {
    return _send(() => _dio.get<Object?>('me/coach/latest'), (response) {
      if (response.statusCode == 204 || response.data == null) return null;
      return _asJsonMap(response.data);
    });
  }

  Future<JsonMap> exportUserData() {
    return _getJson('me/export');
  }

  Future<JsonMap> _getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      () => _dio.get<Object?>(
        path,
        queryParameters: _cleanQuery(queryParameters),
      ),
      (response) => _asJsonMap(response.data),
    );
  }

  Future<JsonMap> _postJson(
    String path, {
    JsonMap? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      () => _dio.post<Object?>(
        path,
        data: data,
        queryParameters: _cleanQuery(queryParameters),
      ),
      (response) => _asJsonMap(response.data),
    );
  }

  Future<JsonMap> _putJson(
    String path, {
    JsonMap? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      () => _dio.put<Object?>(
        path,
        data: data,
        queryParameters: _cleanQuery(queryParameters),
      ),
      (response) => _asJsonMap(response.data),
    );
  }

  Future<void> _deleteNoContent(String path) {
    return _send(() => _dio.delete<Object?>(path), (_) {});
  }

  Future<T> _send<T>(
    Future<Response<Object?>> Function() request,
    T Function(Response<Object?> response) decode, {
    bool retryOnUnauthorized = true,
  }) async {
    try {
      final response = await request();
      return decode(response);
    } on DioException catch (exception) {
      final problem = ApiProblem.fromDioException(exception);
      if (retryOnUnauthorized &&
          problem.isUnauthorized &&
          await _tryRefreshSession()) {
        try {
          final response = await request();
          return decode(response);
        } on DioException catch (retryException) {
          throw ApiProblem.fromDioException(retryException);
        }
      }
      throw problem;
    }
  }

  Future<bool> _tryRefreshSession() async {
    final refreshToken = tokenStore.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      await refreshSession();
      return true;
    } catch (_) {
      await tokenStore.clear();
      return false;
    }
  }
}

JsonMap _asJsonMap(Object? data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  throw FormatException('Reponse JSON inattendue: ${data.runtimeType}');
}

List<JsonMap> _asJsonList(Object? data) {
  if (data is List) {
    return data.map(_asJsonMap).toList(growable: false);
  }
  throw FormatException('Liste JSON inattendue: ${data.runtimeType}');
}

List<JsonMap> _asJsonPageContent(Object? data) {
  if (data is List) return _asJsonList(data);
  if (data is Map) {
    final content = data['content'];
    if (content is List) return _asJsonList(content);
  }
  throw FormatException('Page JSON inattendue: ${data.runtimeType}');
}

Map<String, dynamic>? _cleanQuery(Map<String, dynamic>? queryParameters) {
  if (queryParameters == null) return null;

  final cleaned = <String, dynamic>{};
  for (final entry in queryParameters.entries) {
    final value = entry.value;
    if (value != null && value.toString().isNotEmpty) {
      cleaned[entry.key] = value;
    }
  }

  return cleaned.isEmpty ? null : cleaned;
}

String? _dateOrNull(DateTime? value) {
  if (value == null) return null;
  return value.toIso8601String().split('T').first;
}
