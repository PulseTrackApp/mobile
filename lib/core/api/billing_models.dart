/// Tarification et droit d'usage, tels que le serveur les rend.
///
/// Rien n'est facturé aujourd'hui : le catalogue existe pour que l'écran de
/// tarifs s'affiche dès maintenant, chaque offre marquée « à venir ». Le champ
/// [SubscriptionState.enforced] dit si le serveur refuse déjà les comptes sans
/// droit — tant qu'il vaut `false`, un compte expiré continue de fonctionner.
library;

typedef JsonMap = Map<String, dynamic>;

/// État d'une offre au catalogue. Constante de protocole.
enum PlanAvailability {
  comingSoon('COMING_SOON'),
  available('AVAILABLE'),
  retired('RETIRED');

  const PlanAvailability(this.value);

  final String value;

  static PlanAvailability parse(Object? raw) {
    final value = raw?.toString();
    return PlanAvailability.values.firstWhere(
      (candidate) => candidate.value == value,
      // Une valeur inconnue ne doit pas faire planter l'écran : on la traite
      // comme non souscriptible, ce qui est le comportement le plus prudent.
      orElse: () => PlanAvailability.comingSoon,
    );
  }
}

/// Rythme de facturation.
enum BillingPeriod {
  monthly('MONTHLY'),
  yearly('YEARLY'),
  lifetime('LIFETIME');

  const BillingPeriod(this.value);

  final String value;

  static BillingPeriod parse(Object? raw) {
    final value = raw?.toString();
    return BillingPeriod.values.firstWhere(
      (candidate) => candidate.value == value,
      orElse: () => BillingPeriod.monthly,
    );
  }
}

/// Une offre du catalogue.
class BillingPlan {
  const BillingPlan({
    required this.code,
    required this.name,
    required this.description,
    required this.priceAmount,
    required this.currency,
    required this.priceLabel,
    required this.period,
    required this.availability,
    required this.highlighted,
    required this.features,
  });

  factory BillingPlan.fromJson(JsonMap json) {
    final rawFeatures = json['features'];
    return BillingPlan(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priceAmount: (json['priceAmount'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? '',
      priceLabel: json['priceLabel']?.toString() ?? '',
      period: BillingPeriod.parse(json['period']),
      availability: PlanAvailability.parse(json['availability']),
      highlighted: json['highlighted'] == true,
      features: rawFeatures is List
          ? rawFeatures.map((feature) => feature.toString()).toList(
              growable: false,
            )
          : const <String>[],
    );
  }

  final String code;
  final String name;
  final String description;
  final int priceAmount;
  final String currency;

  /// Prix déjà mis en forme par le serveur, « 2000 FCFA / mois ».
  ///
  /// À afficher tel quel : c'est ce qui garantit qu'Android et iOS montrent le
  /// même texte, et que la devise n'est codée en dur nulle part côté client.
  final String priceLabel;

  final BillingPeriod period;
  final PlanAvailability availability;

  /// Offre à mettre en avant. Une seule l'est.
  final bool highlighted;

  final List<String> features;

  /// Vrai tant que l'offre n'est pas souscriptible : le bouton reste inactif.
  bool get isComingSoon => availability == PlanAvailability.comingSoon;
}

/// Droit d'usage du compte courant.
enum SubscriptionStatus {
  trial('TRIAL'),
  active('ACTIVE'),
  expired('EXPIRED'),
  none('NONE');

  const SubscriptionStatus(this.value);

  final String value;

  static SubscriptionStatus parse(Object? raw) {
    final value = raw?.toString();
    return SubscriptionStatus.values.firstWhere(
      (candidate) => candidate.value == value,
      orElse: () => SubscriptionStatus.none,
    );
  }
}

/// Ce que le serveur dit du droit d'usage, et ce qu'il faut en faire.
class SubscriptionState {
  const SubscriptionState({
    required this.status,
    required this.accessGranted,
    required this.enforced,
    this.endsOn,
    this.daysLeft,
    this.planCode,
    required this.headline,
    required this.message,
  });

  factory SubscriptionState.fromJson(JsonMap json) {
    final rawEndsOn = json['endsOn']?.toString();
    return SubscriptionState(
      status: SubscriptionStatus.parse(json['status']),
      accessGranted: json['accessGranted'] == true,
      enforced: json['enforced'] == true,
      endsOn: rawEndsOn == null ? null : DateTime.tryParse(rawEndsOn),
      daysLeft: (json['daysLeft'] as num?)?.toInt(),
      planCode: json['planCode']?.toString(),
      headline: json['headline']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }

  final SubscriptionStatus status;

  /// **Le seul champ sur lequel router l'écran.** [status] sert à nuancer le
  /// message, pas à décider.
  final bool accessGranted;

  /// Vrai quand le serveur refuse déjà les comptes sans droit. Tant qu'il vaut
  /// `false`, un compte `expired` continue de fonctionner normalement.
  final bool enforced;

  final DateTime? endsOn;
  final int? daysLeft;
  final String? planCode;

  /// Titre et message rédigés côté serveur, prêts à afficher.
  final String headline;
  final String message;

  /// Vrai quand il faut inviter à payer : le droit est perdu **et** le serveur
  /// le fait respecter.
  bool get mustPayNow => enforced && !accessGranted;
}

/// Ce que l'API exige de l'application appelante.
class ClientRequirements {
  const ClientRequirements({
    required this.minimumVersion,
    required this.enforced,
    this.androidStoreUrl,
    this.iosStoreUrl,
  });

  factory ClientRequirements.fromJson(JsonMap json) {
    return ClientRequirements(
      minimumVersion: json['minimumVersion']?.toString() ?? '0.0.0',
      enforced: json['enforced'] == true,
      androidStoreUrl: json['androidStoreUrl']?.toString(),
      iosStoreUrl: json['iosStoreUrl']?.toString(),
    );
  }

  final String minimumVersion;

  /// Faux tant que le serveur n'oppose pas encore de refus : c'est le moment
  /// d'inviter à la mise à jour par un bandeau, pas par un mur.
  final bool enforced;

  final String? androidStoreUrl;
  final String? iosStoreUrl;
}
