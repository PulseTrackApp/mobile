import 'package:flutter/material.dart';

import '../features/tracking/models/sport_mode.dart';

enum LocalePreference { system, french, english }

enum MeasurementUnit { metric, imperial }

enum GpsAccuracyPreference { balanced, high, best }

class AppSettingsController extends ChangeNotifier {
  AppSettingsController({Locale? initialLocale}) {
    if (initialLocale?.languageCode == 'fr') {
      _localePreference = LocalePreference.french;
    } else if (initialLocale?.languageCode == 'en') {
      _localePreference = LocalePreference.english;
    }
  }

  ThemeMode _themeMode = ThemeMode.light;
  LocalePreference _localePreference = LocalePreference.french;
  MeasurementUnit _measurementUnit = MeasurementUnit.metric;
  GpsAccuracyPreference _gpsAccuracy = GpsAccuracyPreference.high;
  SportMode _defaultSport = SportMode.run;
  int _weeklyTargetKm = 20;
  bool _autoPause = true;
  bool _countdown = true;
  bool _voiceCues = false;
  bool _keepScreenAwake = true;
  bool _saveRoutes = true;
  bool _privateActivities = true;

  ThemeMode get themeMode => _themeMode;
  LocalePreference get localePreference => _localePreference;
  MeasurementUnit get measurementUnit => _measurementUnit;
  GpsAccuracyPreference get gpsAccuracy => _gpsAccuracy;
  SportMode get defaultSport => _defaultSport;
  int get weeklyTargetKm => _weeklyTargetKm;
  bool get autoPause => _autoPause;
  bool get countdown => _countdown;
  bool get voiceCues => _voiceCues;
  bool get keepScreenAwake => _keepScreenAwake;
  bool get saveRoutes => _saveRoutes;
  bool get privateActivities => _privateActivities;

  Locale? get locale {
    return switch (_localePreference) {
      LocalePreference.system => null,
      LocalePreference.french => const Locale('fr'),
      LocalePreference.english => const Locale('en'),
    };
  }

  void setThemeMode(ThemeMode value) {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
  }

  void setLocalePreference(LocalePreference value) {
    if (_localePreference == value) return;
    _localePreference = value;
    notifyListeners();
  }

  void setMeasurementUnit(MeasurementUnit value) {
    if (_measurementUnit == value) return;
    _measurementUnit = value;
    notifyListeners();
  }

  void setGpsAccuracy(GpsAccuracyPreference value) {
    if (_gpsAccuracy == value) return;
    _gpsAccuracy = value;
    notifyListeners();
  }

  void setDefaultSport(SportMode value) {
    if (_defaultSport == value) return;
    _defaultSport = value;
    notifyListeners();
  }

  void setWeeklyTargetKm(int value) {
    final nextValue = value.clamp(5, 100);
    if (_weeklyTargetKm == nextValue) return;
    _weeklyTargetKm = nextValue;
    notifyListeners();
  }

  void setAutoPause(bool value) {
    if (_autoPause == value) return;
    _autoPause = value;
    notifyListeners();
  }

  void setCountdown(bool value) {
    if (_countdown == value) return;
    _countdown = value;
    notifyListeners();
  }

  void setVoiceCues(bool value) {
    if (_voiceCues == value) return;
    _voiceCues = value;
    notifyListeners();
  }

  void setKeepScreenAwake(bool value) {
    if (_keepScreenAwake == value) return;
    _keepScreenAwake = value;
    notifyListeners();
  }

  void setSaveRoutes(bool value) {
    if (_saveRoutes == value) return;
    _saveRoutes = value;
    notifyListeners();
  }

  void setPrivateActivities(bool value) {
    if (_privateActivities == value) return;
    _privateActivities = value;
    notifyListeners();
  }
}

class AppSettingsScope extends InheritedNotifier<AppSettingsController> {
  const AppSettingsScope({
    super.key,
    required AppSettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppSettingsController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope not found in widget tree.');
    return scope!.notifier!;
  }
}
