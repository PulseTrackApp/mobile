# PulseTrack — Application mobile

Application Flutter de suivi sportif personnel : enregistrement des séances,
tracé GPS du parcours, suivi de l'évolution physique, objectifs et coach IA.

Elle consomme l'API du dépôt [PulseTrackApp/backend](https://github.com/PulseTrackApp/backend).

**Auteur** : Ouettéré Nicolas MILLOGO — nicolasmillogo@yahoo.com
**Licence** : propriétaire, tous droits réservés (voir [LICENSE](LICENSE))

---

## 1. Ce que fait l'application

- **Suivi de séance** : course, vélo, marche, avec chronomètre et tracé GPS
- **Carte du parcours** : tuiles OpenStreetMap via `flutter_map`
- **Historique** : liste des séances, filtres par sport, détail avec parcours
- **Évolution physique** : poids, mensurations, courbes de progression
- **Objectifs** : distance, séances, temps et calories hebdomadaires
- **Coach IA** : bilan de la semaine et conseils, via l'assistant du backend
- **Thème clair/sombre** et interface bilingue français/anglais

## 2. Prérequis

| Outil | Version | Vérifier |
|---|---|---|
| Flutter | 3.44 ou plus | `flutter --version` |
| Dart | 3.12 ou plus | fourni avec Flutter |
| Android SDK | pour compiler sur téléphone | `flutter doctor` |

```bash
flutter doctor
```

Cette commande signale tout ce qui manque. Corrigez ses avertissements avant
d'aller plus loin : la plupart des problèmes de compilation viennent de là.

## 3. Démarrer

```bash
flutter pub get      # installe les dépendances
flutter run          # lance sur l'appareil ou l'émulateur connecté
```

Pour vérifier que le projet est sain sans le lancer :

```bash
flutter analyze      # doit afficher « No issues found! »
flutter test
```

### Se connecter au backend en réseau local

L'API tourne sur votre ordinateur, l'application sur le téléphone : les deux
doivent être sur le même Wi-Fi.

1. Relevez l'adresse IP locale du poste (`ipconfig` sous Windows), du type
   `192.168.1.42`. **Pas `localhost`** : sur le téléphone, `localhost` désigne
   le téléphone lui-même. Sur émulateur Android, c'est `10.0.2.2`.
2. Autorisez le port 8080 en entrée dans le pare-feu Windows.
3. Android 9 et suivants bloquent le HTTP en clair. Il faut autoriser
   explicitement cette adresse dans
   `android/app/src/main/res/xml/network_security_config.xml`, sans quoi toutes
   les requêtes échouent sans message clair.

## 4. Structure du projet

Le code est organisé **par domaine fonctionnel**, pas par type technique.

```text
lib/
├── main.dart                  Point d'entrée
├── app/                       Configuration globale
│   ├── pulse_track_app.dart   MaterialApp, thèmes, langues
│   └── app_settings_controller Préférences (thème, langue, unités, GPS)
├── core/
│   ├── theme/                 Couleurs et thèmes clair/sombre
│   └── ui/                    Composants réutilisables (AppPanel, AppButton…)
├── features/                  Une fonctionnalité par dossier
│   ├── home/                  Accueil et tableau de bord
│   ├── activity/              Écran de suivi et carte
│   ├── stats/                 Statistiques
│   ├── history/               Historique des séances
│   ├── body/                  Évolution physique
│   ├── goals/                 Objectifs
│   ├── coach/                 Assistant IA
│   ├── profile/               Profil sportif
│   ├── settings/              Paramètres
│   ├── menu/                  Menu principal
│   └── tracking/              Modèles partagés (SportMode…)
└── l10n/                      Traductions FR/EN et fichiers générés
```

Règle simple : `core/ui` contient le générique, `features/<domaine>/widgets` le
spécifique. Un composant utilisé par une seule fonctionnalité reste chez elle.

## 5. Traductions

Les textes affichés ne sont jamais écrits en dur dans les widgets. Ils vivent
dans `lib/l10n/app_fr.arb` (référence) et `lib/l10n/app_en.arb`.

Après toute modification d'un fichier `.arb` :

```bash
flutter gen-l10n
```

Dans le code :

```dart
final l10n = AppLocalizations.of(context);
Text(l10n.startWorkout)
```

Oublier `flutter gen-l10n` provoque une erreur du type
« The getter 'maClé' isn't defined for the type 'AppLocalizations' ».

## 6. Thème et identité visuelle

L'application suit automatiquement le mode clair ou sombre du téléphone :

```dart
theme: AppTheme.light,
darkTheme: AppTheme.dark,
themeMode: ThemeMode.system,
```

Palette : `#00A676` (progression), `#FFB703` (énergie), `#121417` (contraste),
`#EF476F` (records et alertes), `#3A86FF` (GPS et parcours).

Le logo est dessiné en Flutter dans `lib/core/ui/pulse_track_logo.dart` : il
combine une ligne de parcours GPS, une pulsation cardio, un point de départ bleu
et un point d'arrivée rose.

## 7. Cartographie

Les tuiles viennent d'**OpenStreetMap**, sans clé d'API ni compte. Deux
obligations, respectées dans `MapPreview` :

- renseigner `userAgentPackageName` sur le `TileLayer`, faute de quoi les
  requêtes sont rejetées ;
- afficher l'attribution « OpenStreetMap contributors » sur la carte.

## 8. Ajouter une fonctionnalité

1. Créer `lib/features/<domaine>/` avec ses sous-dossiers `screens/` et
   `widgets/`
2. Ajouter les textes dans les deux `.arb`, puis lancer `flutter gen-l10n`
3. Réutiliser les composants de `core/ui` plutôt que de redessiner
4. Vérifier avec `flutter analyze` avant de commiter

## 9. Avertissement

PulseTrack est une application de suivi personnel. Les estimations qu'elle
affiche — calories, IMC, tendances de poids — et les suggestions de l'assistant
sont indicatives et ne constituent pas un avis médical. Consultez un
professionnel de santé avant d'entreprendre un programme sportif, et en cas de
douleur ou de malaise.
