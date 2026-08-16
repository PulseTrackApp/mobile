import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/core/api/api_error.dart';

void main() {
  group('ApiProblem', () {
    test('reconnait un paiement requis par le statut HTTP 402', () {
      final problem = ApiProblem.fromJson({
        'title': 'Paiement requis',
        'status': 402,
        'detail': 'Active ton acces pour continuer.',
      });

      expect(problem.isPaymentRequired, isTrue);
    });

    test('reconnait un abonnement requis par le type probleme', () {
      final problem = ApiProblem.fromJson({
        'type': 'https://gymflow.app/problems/subscription-required',
        'title': 'Acces bloque',
        'status': 403,
        'detail': 'Ce module necessite un abonnement.',
      });

      expect(problem.isPaymentRequired, isTrue);
    });
  });
}
