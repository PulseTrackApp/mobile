import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

enum SportMode {
  run(Icons.directions_run_rounded),
  ride(Icons.directions_bike_rounded),
  walk(Icons.directions_walk_rounded);

  const SportMode(this.icon);

  final IconData icon;

  static SportMode? fromApiValue(String? value) {
    return switch (value) {
      'RUN' => SportMode.run,
      'RIDE' => SportMode.ride,
      'WALK' => SportMode.walk,
      _ => null,
    };
  }

  String get apiValue {
    return switch (this) {
      SportMode.run => 'RUN',
      SportMode.ride => 'RIDE',
      SportMode.walk => 'WALK',
    };
  }

  String label(AppLocalizations l10n) {
    return switch (this) {
      SportMode.run => l10n.run,
      SportMode.ride => l10n.ride,
      SportMode.walk => l10n.walk,
    };
  }
}
