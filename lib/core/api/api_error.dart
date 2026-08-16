import 'package:dio/dio.dart';

class ApiProblem implements Exception {
  const ApiProblem({
    this.type,
    required this.title,
    this.status,
    required this.detail,
    this.instance,
    this.module,
    this.fieldErrors = const {},
    this.extensions = const {},
  });

  factory ApiProblem.fromDioException(DioException exception) {
    final response = exception.response;
    final data = response?.data;

    if (data is Map<String, dynamic>) {
      return ApiProblem.fromJson(data, fallbackStatus: response?.statusCode);
    }

    if (data is Map) {
      return ApiProblem.fromJson(
        Map<String, dynamic>.from(data),
        fallbackStatus: response?.statusCode,
      );
    }

    return ApiProblem(
      title: 'Erreur réseau',
      status: response?.statusCode,
      detail: exception.message ?? 'Impossible de joindre le serveur.',
    );
  }

  factory ApiProblem.fromJson(
    Map<String, dynamic> json, {
    int? fallbackStatus,
  }) {
    final rawErrors = json['errors'];
    final fieldErrors = <String, String>{};

    if (rawErrors is Map) {
      rawErrors.forEach((key, value) {
        if (key != null && value != null) {
          fieldErrors[key.toString()] = value.toString();
        }
      });
    }

    return ApiProblem(
      type: _uriOrNull(json['type']),
      title: json['title']?.toString() ?? 'Erreur',
      status: _intOrNull(json['status']) ?? fallbackStatus,
      detail: json['detail']?.toString() ?? '',
      instance: _uriOrNull(json['instance']),
      module: json['module']?.toString(),
      fieldErrors: fieldErrors,
      extensions: Map<String, dynamic>.fromEntries(
        json.entries.where((entry) => !_standardMembers.contains(entry.key)),
      ),
    );
  }

  /// Membres definis par la RFC 9457. Tout le reste est une extension posee par
  /// le serveur : `minimumVersion`, `storeUrl`, `suggestedPlan`, `module`...
  static const _standardMembers = {
    'type',
    'title',
    'status',
    'detail',
    'instance',
    'errors',
  };

  final Uri? type;
  final String title;
  final int? status;
  final String detail;
  final Uri? instance;
  final String? module;
  final Map<String, String> fieldErrors;

  /// Proprietes hors RFC posees par le serveur, portees a la racine du document.
  final Map<String, dynamic> extensions;

  bool get isUnauthorized => status == 401;

  /// Le jeton etait valide, il ne l'est plus.
  ///
  /// A distinguer de [isUnauthenticated] : ici l'utilisateur avait bien une
  /// session, il faut la renouveler puis, en cas d'echec seulement, le prevenir.
  /// Sans cette distinction, une expiration ressemble a une panne reseau et on
  /// affiche « une erreur est survenue » a quelqu'un qui n'a qu'a se reconnecter.
  bool get isSessionExpired =>
      status == 401 && _typeEndsWith('/token-expired');

  /// Aucune session, ou un jeton illisible. Retour a la connexion, sans alarmer.
  bool get isUnauthenticated =>
      status == 401 && _typeEndsWith('/unauthenticated');

  /// L'application est trop ancienne pour cette API.
  ///
  /// Le serveur repond `426` et joint la version minimale ainsi que l'adresse du
  /// magasin : un refus sans porte de sortie serait une impasse.
  bool get isUpgradeRequired =>
      status == 426 || _typeEndsWith('/client-upgrade-required');

  /// Version minimale exigee, quand le refus est un [isUpgradeRequired].
  String? get minimumVersion => extensions['minimumVersion']?.toString();

  /// Ou envoyer l'utilisateur pour se mettre a jour ; `null` si non configure.
  String? get storeUrl => extensions['storeUrl']?.toString();

  /// Offre a mettre en avant sur l'ecran de paiement, jointe au refus `402`
  /// pour eviter une seconde requete au moment ou tout est refuse.
  Map<String, dynamic>? get suggestedPlan {
    final plan = extensions['suggestedPlan'];
    if (plan is Map<String, dynamic>) return plan;
    if (plan is Map) return Map<String, dynamic>.from(plan);
    return null;
  }

  bool _typeEndsWith(String suffix) =>
      type?.path.toLowerCase().endsWith(suffix) == true;

  /// Le droit d'usage est expire : c'est ce refus qui ouvre l'ecran de paiement.
  ///
  /// On s'en tient au code HTTP et au `type`, sans chercher de mots dans le
  /// texte : le contrat serveur est ferme depuis le 16 aout 2026, et reconnaitre
  /// un paiement d'apres une phrase en francais ferait ouvrir l'ecran de
  /// paiement sur n'importe quelle erreur qui se trouve mentionner un abonnement.
  bool get isPaymentRequired =>
      status == 402 ||
      _typeEndsWith('/subscription-required') ||
      _typeEndsWith('/payment-required');

  bool get isModuleLocked =>
      status == 403 && type?.path.endsWith('/module-locked') == true;

  bool get isEmailNotVerified =>
      status == 403 && type?.path.endsWith('/email-not-verified') == true;

  /// Le compte a ete suspendu par un administrateur.
  ///
  /// A distinguer des deux autres `403` : une rubrique fermee laisse le reste de
  /// l'application utilisable, une adresse non verifiee se corrige avec un code.
  /// Ici rien ne se corrige depuis le telephone — la seule chose juste a faire
  /// est de dire pourquoi, en citant la raison que le serveur joint au refus.
  bool get isAccountDisabled =>
      status == 403 && type?.path.endsWith('/account-disabled') == true;

  String get message => detail.isNotEmpty ? detail : title;

  @override
  String toString() {
    final code = status == null ? '' : ' ($status)';
    return 'ApiProblem$code: $message';
  }
}

Uri? _uriOrNull(Object? value) {
  if (value == null) return null;
  return Uri.tryParse(value.toString());
}

int? _intOrNull(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
