import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/features/activity/models/workout_outcome.dart';
import 'package:mobile_flutter/features/activity/models/workout_rating.dart';

/// Ce que l'application lit dans la réponse d'enregistrement d'une séance.
///
/// L'enjeu de ces tests : les félicitations ne se devinent plus côté client.
/// Le serveur applique des marges anti-bruit que l'application ne peut pas
/// reproduire, et compare sur tout l'historique du sport.
void main() {
  group('WorkoutOutcome', () {
    test('lit les records tombés et met le premier en avant', () {
      final outcome = WorkoutOutcome.fromWorkoutResponse({
        'summary': {'id': 'abc'},
        'achievements': [
          {
            'kind': 'LONGEST_DISTANCE',
            'label': 'Plus longue sortie',
            'headline': 'Nouveau record de distance',
            'message': '6,3 km, soit 1,18 km de plus que ton précédent record.',
            'improvement': 1180.0,
            'unit': 'm',
          },
          {
            'kind': 'BEST_AVERAGE_PACE',
            'label': 'Meilleure allure moyenne',
            'headline': 'Nouveau record d\'allure',
            'message': '5:12/km.',
            'improvement': 20.0,
            'unit': 's/km',
          },
        ],
      });

      expect(outcome.hasAchievements, isTrue);
      expect(outcome.headlineAchievement?.kind, 'LONGEST_DISTANCE');
      // Les textes viennent du serveur : rien n'est recomposé ici.
      expect(
        outcome.headlineAchievement?.headline,
        'Nouveau record de distance',
      );
      // Le gain est toujours positif, même pour une allure qui baisse.
      expect(outcome.achievements.last.improvement, 20.0);
    });

    test('ne célèbre rien quand la séance ne bat aucun record', () {
      final outcome = WorkoutOutcome.fromWorkoutResponse({
        'summary': {'id': 'abc'},
        'achievements': <dynamic>[],
        'routeComparison': null,
        'challengeResult': null,
      });

      expect(outcome.hasAchievements, isFalse);
      expect(outcome.shouldCelebrateChallenge, isFalse);
      expect(outcome.isNewRouteBest, isFalse);
    });

    test('suit le serveur pour fêter un défi manqué de peu', () {
      // Le défi échoue, mais un record est tombé : c'est le serveur qui tranche
      // que cela mérite mieux qu'un écran rouge.
      final outcome = WorkoutOutcome.fromWorkoutResponse({
        'challengeResult': {
          'succeeded': false,
          'celebrate': true,
          'appreciation': {
            'tier': 'BEHIND',
            'headline': 'À quelques secondes près',
            'message': 'Il ne manquait presque rien.',
          },
        },
      });

      expect(outcome.challengeSucceeded, isFalse);
      expect(outcome.shouldCelebrateChallenge, isTrue);
      expect(outcome.challengeHeadline, 'À quelques secondes près');
    });

    test('reconnaît un meilleur temps sur un parcours rejoué', () {
      final outcome = WorkoutOutcome.fromWorkoutResponse({
        'routeComparison': {
          'isNewBest': true,
          'rank': 1,
          'deltaSecondsVsBest': -60,
          'headline': 'Nouveau meilleur temps',
          'message': '1 min de mieux sur Boucle du barrage.',
        },
      });

      expect(outcome.isNewRouteBest, isTrue);
      expect(outcome.routeHeadline, 'Nouveau meilleur temps');
    });

    test('supporte une réponse sans aucun des trois champs', () {
      // Une ancienne réponse, ou un serveur pas encore déployé : rien ne doit
      // planter, la séance est enregistrée et c'est l'essentiel.
      final outcome = WorkoutOutcome.fromWorkoutResponse({
        'summary': {'id': 'abc'},
      });

      expect(outcome.achievements, isEmpty);
      expect(outcome.routeComparison, isNull);
      expect(outcome.challengeResult, isNull);
    });
  });

  group('PersonalRecordSnapshot', () {
    test('lit les records courants du sport', () {
      final snapshot = PersonalRecordSnapshot.fromSportRecords([
        {
          'sportType': 'RUN',
          'sessionCount': 42,
          'records': [
            {'kind': 'LONGEST_DISTANCE', 'value': 6300.0, 'unit': 'm'},
            {'kind': 'BEST_AVERAGE_PACE', 'value': 312.0, 'unit': 's/km'},
            {'kind': 'HIGHEST_ELEVATION_GAIN', 'value': 42.0, 'unit': 'm'},
          ],
        },
      ]);

      expect(snapshot.longestDistanceMeters, 6300.0);
      expect(snapshot.bestPaceSecondsPerKm, 312);
    });

    test('reste vide pour un sport sans historique', () {
      // Un compte neuf n'a aucun bloc : l'aperçu ne doit rien affirmer.
      final snapshot = PersonalRecordSnapshot.fromSportRecords([]);

      expect(snapshot.longestDistanceMeters, 0);
      expect(snapshot.bestPaceSecondsPerKm, 0);
    });

    test('ignore une catégorie de record absente', () {
      final snapshot = PersonalRecordSnapshot.fromSportRecords([
        {
          'sportType': 'OTHER',
          'records': [
            {'kind': 'LONGEST_MOVING_DURATION', 'value': 3600.0, 'unit': 's'},
          ],
        },
      ]);

      expect(snapshot.longestDistanceMeters, 0);
      expect(snapshot.bestPaceSecondsPerKm, 0);
    });
  });
}
