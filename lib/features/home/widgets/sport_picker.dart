import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../tracking/models/sport_mode.dart';

class SportPicker extends StatelessWidget {
  const SportPicker({
    super.key,
    required this.selectedSport,
    required this.onChanged,
  });

  final SportMode selectedSport;
  final ValueChanged<SportMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SegmentedButton<SportMode>(
      segments: SportMode.values
          .map(
            (sport) => ButtonSegment<SportMode>(
              value: sport,
              label: Text(sport.label(l10n)),
              icon: Icon(sport.icon),
            ),
          )
          .toList(),
      selected: {selectedSport},
      onSelectionChanged: (selection) => onChanged(selection.first),
      showSelectedIcon: false,
    );
  }
}
