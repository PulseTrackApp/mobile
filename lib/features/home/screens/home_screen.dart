import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/modules/app_module.dart';
import '../../../core/ui/module_gate.dart';
import '../../../l10n/app_localizations.dart';
import '../../activity/screens/activity_screen.dart';
import '../../menu/screens/menu_screen.dart';
import '../../stats/screens/stats_screen.dart';
import '../../tracking/models/sport_mode.dart';
import '../widgets/dashboard_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  SportMode _selectedSport = SportMode.run;
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = [
      DashboardView(
        selectedSport: _selectedSport,
        onSportChanged: (sport) => setState(() => _selectedSport = sport),
        onStartWorkout: () => setState(() => _selectedTab = 1),
      ),
      ModuleGate(
        module: AppModule.workouts,
        child: ActivityScreen(selectedSport: _selectedSport),
      ),
      const ModuleGate(module: AppModule.stats, child: StatsScreen()),
      const MenuScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedTab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard_rounded),
            label: l10n.homeTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.play_circle_outline_rounded),
            selectedIcon: const Icon(Icons.play_circle_fill_rounded),
            label: l10n.activityTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.query_stats_rounded),
            selectedIcon: const Icon(Icons.query_stats_rounded),
            label: l10n.statsTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_rounded),
            selectedIcon: const Icon(Icons.menu_open_rounded),
            label: l10n.menuTab,
          ),
        ],
      ),
    );
  }
}
