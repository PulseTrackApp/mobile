import 'dart:async';

import 'package:flutter/foundation.dart';

import '../api/api_error.dart';
import '../api/api_formatters.dart';
import '../api/auth_token_store.dart';
import '../api/pulse_track_api.dart';
import 'app_module.dart';

class ModuleAccessState {
  const ModuleAccessState({
    required this.modules,
    this.isLoading = false,
    this.error,
  });

  factory ModuleAccessState.allEnabled({bool isLoading = false}) {
    return ModuleAccessState(
      isLoading: isLoading,
      modules: {for (final module in AppModule.values) module: true},
    );
  }

  final Map<AppModule, bool> modules;
  final bool isLoading;
  final Object? error;

  bool isEnabled(AppModule module) => modules[module] ?? true;

  ModuleAccessState copyWith({
    Map<AppModule, bool>? modules,
    bool? isLoading,
    Object? error,
  }) {
    return ModuleAccessState(
      modules: modules ?? this.modules,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ModuleAccessController extends ChangeNotifier {
  ModuleAccessController({required this.api, required this.tokenStore}) {
    tokenStore.addListener(_onSessionChanged);
    unawaited(refresh());
  }

  final PulseTrackApi api;
  final AuthTokenStore tokenStore;

  ModuleAccessState _state = ModuleAccessState.allEnabled();

  ModuleAccessState get state => _state;

  bool isEnabled(AppModule module) => _state.isEnabled(module);

  Future<void> refresh() async {
    if (!tokenStore.isAuthenticated) {
      _state = ModuleAccessState.allEnabled();
      notifyListeners();
      return;
    }

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final rows = await api.getModules();
      final modules = {for (final module in AppModule.values) module: true};

      for (final row in rows) {
        final module = AppModule.fromApiValue(row['module']);
        if (module == null) continue;
        modules[module] = jsonBool(row, 'enabled');
      }

      _state = ModuleAccessState(modules: modules);
    } on ApiProblem catch (problem) {
      _state = _state.copyWith(isLoading: false, error: problem);
    } catch (error) {
      _state = _state.copyWith(isLoading: false, error: error);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    tokenStore.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() => unawaited(refresh());
}
