/// Coordonnées de l'éditeur, telles que les écrans d'aide les affichent.
///
/// Passées par `--dart-define` plutôt que codées en dur : une adresse de support
/// change sans que l'application change, et une valeur figée dans le binaire
/// obligerait à republier pour la corriger.
library;

class AppContact {
  const AppContact._();

  /// Adresse à laquelle écrire pour de l'aide.
  ///
  /// **À confirmer avant publication.** La valeur par défaut est une convention,
  /// pas une boîte vérifiée : un écran d'aide qui donne une adresse morte est
  /// pire qu'un écran d'aide sans adresse.
  static const supportEmail = String.fromEnvironment(
    'GYMFLOW_SUPPORT_EMAIL',
    defaultValue: 'support@liceli-technologies.com',
  );

  /// Éditeur, affiché par l'écran « à propos » et les mentions légales.
  static const publisher = String.fromEnvironment(
    'GYMFLOW_PUBLISHER',
    defaultValue: 'Liceli Technologies',
  );
}
