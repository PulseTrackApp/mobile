import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';
import 'api_contract.dart';
import 'api_error.dart';
import 'auth_session.dart';
import 'auth_token_store.dart';
import 'billing_models.dart';

typedef JsonMap = Map<String, dynamic>;

class PulseTrackApi {
  static const _appVersion = String.fromEnvironment(
    'GYMFLOW_APP_VERSION',
    defaultValue: '1.2.0',
  );
  static const _appBuild = String.fromEnvironment(
    'GYMFLOW_APP_BUILD',
    defaultValue: '8',
  );

  /// Version annoncee au serveur, et affichee par l'ecran « à propos ».
  ///
  /// Exposee pour qu'il n'existe qu'une seule verite : un ecran qui afficherait
  /// une version differente de celle envoyee dans l'en-tete rendrait tout
  /// rapport d'anomalie trompeur.
  static String get appVersion => _appVersion;

  static String get appBuild => _appBuild;

  /// Adresse du serveur interroge. Utile a joindre a un signalement.
  String get baseUrl => _dio.options.baseUrl;

  /// Plateforme annoncee au serveur, telle qu'il l'attend : `ANDROID`, `IOS`,
  /// `WEB` ou `DESKTOP`.
  ///
  /// `defaultTargetPlatform` plutot que `dart:io` : ce fichier doit rester
  /// compilable pour le web, ou `Platform` n'existe pas.
  static String get _platform {
    if (kIsWeb) return 'WEB';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ANDROID';
      case TargetPlatform.iOS:
        return 'IOS';
      default:
        return 'DESKTOP';
    }
  }

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
          // Les deux en-tetes que le serveur regarde reellement. Ce sont eux qui
          // permettront un jour de refuser les APK trop anciennes : le verrou
          // repose sur leur ABSENCE dans les versions deja distribuees. Les
          // omettre ici rendrait le dispositif inactivable sans tout casser.
          options.headers['X-GymFlow-Client-Version'] = _appVersion;
          options.headers['X-GymFlow-Platform'] = _platform;
          // Conserves pour le diagnostic : le serveur ne s'en sert pas.
          options.headers['X-GymFlow-Client'] = 'mobile-flutter';
          options.headers['X-GymFlow-App-Build'] = _appBuild;
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

  Future<void> requestPasswordResetCode({required String email}) {
    return _send(
      () => _dio.post<Object?>('auth/forgot-password', data: {'email': email}),
      (_) {},
      retryOnUnauthorized: false,
    );
  }

  Future<void> resetPassword({
    required String code,
    required String newPassword,
  }) {
    return _send(
      () => _dio.post<Object?>(
        'auth/reset-password',
        data: {'code': code, 'newPassword': newPassword},
      ),
      (_) {},
      retryOnUnauthorized: false,
    );
  }

  Future<void> resendVerificationEmail({required String email}) {
    return _send(
      () => _dio.post<Object?>(
        'auth/resend-verification',
        data: {'email': email},
      ),
      (_) {},
      retryOnUnauthorized: false,
    );
  }

  Future<void> verifyEmail({required String code}) {
    return _send(
      () => _dio.post<Object?>('auth/verify-email', data: {'code': code}),
      (_) {},
      retryOnUnauthorized: false,
    );
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

  Future<AuthSession> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final session = await _send(
      () => _dio.post<Object?>(
        'me/password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      ),
      (response) => AuthSession.fromJson(_asJsonMap(response.data)),
    );
    await tokenStore.save(session);
    return session;
  }

  Future<void> deleteAccount({required String password}) async {
    await _send(
      () => _dio.delete<Object?>('me', data: {'password': password}),
      (_) {},
    );
    await tokenStore.clear();
  }

  Future<List<JsonMap>> getModules() {
    return _send(
      () => _dio.get<Object?>('me/modules'),
      (response) => _asJsonPageOrPayloadList(response.data, 'modules'),
    );
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

  Future<JsonMap> patchProfile(JsonMap changes) {
    return _patchJson('me/profile', data: changes);
  }

  /// Catalogue des offres. Reste accessible meme a un compte expire : un ecran
  /// de paiement dont les prix se font refuser n'aurait aucun sens.
  Future<List<BillingPlan>> getBillingPlans() async {
    final raw = await _send(
      () => _dio.get<Object?>('billing/plans'),
      (response) => _asJsonList(response.data),
    );
    return raw.map(BillingPlan.fromJson).toList(growable: false);
  }

  /// Droit d'usage du compte courant. A appeler au demarrage et a chaque retour
  /// au premier plan, comme les modules.
  Future<SubscriptionState> getSubscription() async {
    return SubscriptionState.fromJson(await _getJson('me/subscription'));
  }

  /// Version minimale exigee par l'API.
  ///
  /// Route ouverte et jamais verrouillee : elle repond meme sans session, et
  /// meme a une application deja perimee — c'est precisement ce qui lui permet
  /// d'apprendre qu'elle l'est.
  Future<ClientRequirements> getClientRequirements() async {
    return ClientRequirements.fromJson(await _getJson('client/requirements'));
  }

  /// Records courants, sport par sport.
  Future<List<JsonMap>> getRecords({ApiSportType? sport}) {
    return _send(
      () => _dio.get<Object?>(
        'workouts/records',
        queryParameters: _cleanQuery({'sport': sport?.value}),
      ),
      (response) => _asJsonList(response.data),
    );
  }

  /// Parcours enregistres, pagines et **sans le trace** : `points` y est nul.
  Future<List<JsonMap>> getRoutes({ApiSportType? sport, int page = 0, int size = 20}) {
    return _send(
      () => _dio.get<Object?>(
        'me/routes',
        queryParameters: _cleanQuery({
          'sport': sport?.value,
          'page': page,
          'size': size,
        }),
      ),
      (response) => _asJsonPageContent(response.data),
    );
  }

  /// Detail d'un parcours, trace compris.
  Future<JsonMap> getRoute(String id) => _getJson('me/routes/$id');

  /// Enregistre le trace d'une seance sous un nom, pour pouvoir le reprendre.
  Future<JsonMap> createRoute({required String workoutId, required String name}) {
    return _postJson('me/routes', data: {'workoutId': workoutId, 'name': name});
  }

  Future<JsonMap> renameRoute({required String id, required String name}) {
    return _putJson('me/routes/$id', data: {'name': name});
  }

  Future<void> deleteRoute(String id) => _deleteNoContent('me/routes/$id');

  /// Classement des passages sur un circuit, du plus rapide au plus lent.
  Future<List<JsonMap>> getRouteAttempts(String id) {
    return _send(
      () => _dio.get<Object?>('me/routes/$id/attempts'),
      (response) => _asJsonList(response.data),
    );
  }

  /// Defis, filtrables par statut : `?status=DRAFT,ACTIVE`.
  Future<List<JsonMap>> getChallenges({
    List<String>? statuses,
    int page = 0,
    int size = 20,
  }) {
    return _send(
      () => _dio.get<Object?>(
        'me/challenges',
        queryParameters: _cleanQuery({
          'status': statuses == null || statuses.isEmpty
              ? null
              : statuses.join(','),
          'page': page,
          'size': size,
        }),
      ),
      (response) => _asJsonPageContent(response.data),
    );
  }

  Future<JsonMap> getChallenge(String id) => _getJson('me/challenges/$id');

  Future<JsonMap> createChallenge(JsonMap challenge) {
    return _postJson('me/challenges', data: challenge);
  }

  /// Arme le chronometre. La reponse porte le `plan` : seuils et messages a
  /// jouer **localement** pendant la course, sans rappeler le serveur.
  Future<JsonMap> startChallenge(String id) {
    return _postJson('me/challenges/$id/start');
  }

  /// Point d'etape a la demande. N'ecrit rien et ne peut pas faire echouer le
  /// defi : le plan suffit aux alertes, cet appel est un confort.
  Future<JsonMap> challengeProgress({
    required String id,
    required int elapsedSeconds,
    required double distanceMeters,
  }) {
    return _postJson(
      'me/challenges/$id/progress',
      data: {
        'elapsedSeconds': elapsedSeconds,
        'distanceMeters': distanceMeters,
      },
    );
  }

  Future<JsonMap> abandonChallenge(String id) {
    return _postJson('me/challenges/$id/abandon');
  }

  Future<void> deleteChallenge(String id) =>
      _deleteNoContent('me/challenges/$id');

  /// Note de l'utilisateur sur vingt-huit jours, et l'encouragement qui va avec.
  Future<JsonMap> getRating({String? zone}) {
    return _getJson('me/rating', queryParameters: {'zone': zone});
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

  /// Modification partielle. À préférer au `PUT` partout sauf à l'inscription :
  /// un remplacement incomplet passe la validation tant que les champs
  /// obligatoires sont là, et efface au passage la date de naissance et le sexe.
  Future<JsonMap> _patchJson(
    String path, {
    JsonMap? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      () => _dio.patch<Object?>(
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
      // Verifie avant le paiement : une application trop ancienne doit
      // apprendre qu'elle est perimee, pas qu'il faut payer. Lui montrer un
      // ecran de paiement qu'elle ne sait peut-etre meme pas afficher
      // enverrait l'utilisateur dans une impasse.
      if (problem.isUpgradeRequired) {
        tokenStore.markUpgradeRequired(
          minimumVersion: problem.minimumVersion,
          storeUrl: problem.storeUrl,
        );
        throw problem;
      }
      if (problem.isPaymentRequired) {
        tokenStore.markPaymentRequired(
          suggestedPlanCode: problem.suggestedPlan?['code']?.toString(),
        );
        throw problem;
      }
      if (retryOnUnauthorized &&
          problem.isUnauthorized &&
          await _tryRefreshSession()) {
        try {
          final response = await request();
          return decode(response);
        } on DioException catch (retryException) {
          final retryProblem = ApiProblem.fromDioException(retryException);
          if (retryProblem.isPaymentRequired) {
            tokenStore.markPaymentRequired(
              suggestedPlanCode:
                  retryProblem.suggestedPlan?['code']?.toString(),
            );
          }
          if (retryProblem.isUnauthorized) {
            await tokenStore.expireSession();
          }
          throw retryProblem;
        }
      }
      if (retryOnUnauthorized && problem.isUnauthorized) {
        await tokenStore.expireSession();
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
      await tokenStore.expireSession();
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

List<JsonMap> _asJsonPageOrPayloadList(Object? data, String key) {
  if (data is List) return _asJsonList(data);
  if (data is Map) {
    final payload = data[key];
    if (payload is List) return _asJsonList(payload);
    final content = data['content'];
    if (content is List) return _asJsonList(content);
  }
  throw FormatException('Liste JSON inattendue: ${data.runtimeType}');
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
