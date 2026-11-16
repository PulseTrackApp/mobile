# GymFlow Mobile

Application mobile de suivi sportif : enregistrer une séance de course, de vélo ou de marche avec son tracé GPS, suivre ses progrès, atteindre ses objectifs et relever des défis. Interface en français et en anglais, thèmes clair et sombre.

*English: a Flutter sports-tracking app (GPS routes, goals, body progress, challenges, AI coach) backed by a Spring Boot API.*

Projet personnel, conçu et développé de bout en bout : produit, maquettes, application et API. Le code est visible à titre de démonstration.

## Fonctionnalités

- **Séances** : course, vélo et marche, avec chronomètre, distance, allure (vitesse en km/h pour le vélo), dénivelé et calories. Le tracé GPS est filtré pour limiter le bruit du capteur.
- **Parcours** : carte OpenStreetMap, trace de la séance, mise en évidence des points marquants. Aucune clé de carte payante n'est nécessaire.
- **Historique** : liste des séances, filtres par sport, détail avec le parcours.
- **Évolution physique** : poids et mensurations, avec des courbes de progression.
- **Objectifs et défis** : objectifs hebdomadaires, records, défis et succès.
- **Coach** : bilan de la semaine et conseils, générés par l'assistant du serveur.
- **Compte** : inscription, vérification de l'e-mail, abonnement avec période d'essai, notifications.
- **Interface** : mode clair et sombre, français et anglais, première ouverture guidée une seule fois.

## Technologies

| Domaine | Choix |
|---|---|
| Application | Flutter et Dart |
| État | Riverpod |
| Navigation | go_router |
| Réseau | dio, jetons stockés dans le coffre sécurisé de l'appareil |
| Cartes | flutter_map avec tuiles OpenStreetMap |
| Graphiques | fl_chart |
| Notifications | Firebase Cloud Messaging |
| Traductions | fichiers ARB, génération `flutter gen-l10n` |

## Architecture

L'application est découpée par fonctionnalité. Chaque dossier contient ses écrans, ses composants et sa logique.

```
lib/
  app/        démarrage, navigation, paramètres
  core/       client d'API, thème, composants partagés, notifications
  features/   une fonctionnalité par dossier :
              tracking, activity, history, routes, body, goals,
              challenges, coach, stats, account, pricing, onboarding...
  l10n/       traductions française et anglaise
test/         tests unitaires et de widgets
```

L'interface ne parle jamais directement au réseau : elle passe par un client d'API unique, qui centralise l'authentification, le renouvellement de session et la gestion des erreurs.

## Lancer le projet

Prérequis : Flutter (version stable récente) et un appareil ou un émulateur.

```bash
flutter pub get
flutter run
```

L'application a besoin de l'API [GymFlow Backend](https://github.com/PulseTrackApp/backend). Indiquez son adresse au lancement :

```bash
flutter run --dart-define=GYMFLOW_API_BASE_URL=http://10.0.2.2:8080
```

`10.0.2.2` désigne votre ordinateur depuis l'émulateur Android. Sur un téléphone réel, utilisez l'adresse IP locale de l'ordinateur.

Pour produire un APK :

```bash
flutter build apk --release --dart-define=GYMFLOW_API_BASE_URL=https://votre-api.example.com
```

## Tests et qualité

```bash
flutter analyze
flutter test
```

Les tests couvrent le filtrage du tracé GPS, les calculs de distance et d'allure, la navigation selon l'état de la session, le client d'API et l'enregistrement des notifications.

## Documentation

Le guide de développement détaillé (structure, traductions, thème, cartographie, ajout d'une fonctionnalité) est dans [DEVELOPPEMENT.md](DEVELOPPEMENT.md).

## Dépôts liés

- [GymFlow Backend](https://github.com/PulseTrackApp/backend) : API Spring Boot et PostgreSQL.

## Auteur

Ouettéré Nicolas MILLOGO, ingénieur logiciel.
nicolasmillogo3@gmail.com · [Portfolio](https://nicolas-millogo.vercel.app)

## Licence

Propriétaire, tous droits réservés. Voir [LICENSE](LICENSE).
