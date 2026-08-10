import 'package:flutter/material.dart';

import 'pulse_track_logo.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key, this.trailing});

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: PulseTrackLogo()),
        ?trailing,
      ],
    );
  }
}
