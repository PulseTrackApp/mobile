import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/features/pricing/widgets/update_available_banner.dart';

void main() {
  group('UpdateAvailableBanner.isOutdated', () {
    test('reconnaît une version antérieure au minimum', () {
      expect(UpdateAvailableBanner.isOutdated('1.2.0', '1.3.0'), isTrue);
      expect(UpdateAvailableBanner.isOutdated('0.9.9', '1.0.0'), isTrue);
      expect(UpdateAvailableBanner.isOutdated('1.2.0', '1.2.1'), isTrue);
    });

    test('ne réclame rien quand la version suffit', () {
      expect(UpdateAvailableBanner.isOutdated('1.3.0', '1.3.0'), isFalse);
      expect(UpdateAvailableBanner.isOutdated('2.0.0', '1.9.9'), isFalse);
    });

    test('compare les nombres, pas les caractères', () {
      // Le piège de l'ordre alphabétique : « 1.10.0 » y passerait pour
      // antérieure à « 1.9.0 », et le bandeau réclamerait une mise à jour à
      // l'utilisateur le plus à jour de tous.
      expect(UpdateAvailableBanner.isOutdated('1.10.0', '1.9.0'), isFalse);
      expect(UpdateAvailableBanner.isOutdated('1.9.0', '1.10.0'), isTrue);
    });

    test('complète les composantes absentes par zéro', () {
      expect(UpdateAvailableBanner.isOutdated('1.2', '1.2.0'), isFalse);
      expect(UpdateAvailableBanner.isOutdated('1.2', '1.2.1'), isTrue);
    });

    test('ne réclame rien sur une version illisible', () {
      // Mieux vaut se taire que harceler à cause d'une valeur mal saisie côté
      // serveur : le vrai verrou reste le refus 426, qui lui ne dépend pas de
      // cette comparaison.
      expect(UpdateAvailableBanner.isOutdated('1.2.0', 'bientôt'), isFalse);
      expect(UpdateAvailableBanner.isOutdated('', '1.2.0'), isFalse);
      expect(UpdateAvailableBanner.isOutdated('1.2.0.4', '9.9.9'), isFalse);
    });
  });
}
