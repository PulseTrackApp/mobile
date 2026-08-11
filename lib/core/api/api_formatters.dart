import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

const gymFlowDefaultZone = 'Africa/Ouagadougou';

double jsonDouble(Map<String, dynamic>? json, String key) {
  final value = json?[key];
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int jsonInt(Map<String, dynamic>? json, String key) {
  final value = json?[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

String? jsonString(Map<String, dynamic>? json, String key) {
  return json?[key]?.toString();
}

bool jsonBool(Map<String, dynamic>? json, String key) {
  final value = json?[key];
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}

Map<String, dynamic>? jsonMap(Map<String, dynamic>? json, String key) {
  final value = json?[key];
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<Map<String, dynamic>> jsonList(Map<String, dynamic>? json, String key) {
  final value = json?[key];
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

List<Map<String, dynamic>> pageContent(Map<String, dynamic>? page) {
  return jsonList(page, 'content');
}

String formatKm(double meters) {
  return (meters / 1000).toStringAsFixed(2);
}

String formatMetersAsKm(double meters, AppLocalizations l10n) {
  return '${formatKm(meters)} ${l10n.kilometersUnit}';
}

String formatDurationShort(Object? longSeconds, AppLocalizations l10n) {
  final seconds = longSeconds is num ? longSeconds.toInt() : 0;
  final duration = Duration(seconds: seconds);
  if (duration.inHours > 0) {
    final minutes = duration.inMinutes.remainder(60);
    return '${duration.inHours} h ${minutes.toString().padLeft(2, '0')}';
  }
  return '${duration.inMinutes} min';
}

String formatPace(int secondsPerKm, AppLocalizations l10n) {
  if (secondsPerKm <= 0) return l10n.emptyPace;
  final minutes = secondsPerKm ~/ 60;
  final seconds = secondsPerKm.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds ${l10n.paceUnit}';
}

String formatBmi(double value) {
  return value <= 0 ? '--' : value.toStringAsFixed(1);
}

String? bmiCategoryLabel(String? category, AppLocalizations l10n) {
  return switch (category) {
    'UNDERWEIGHT' => l10n.bmiCategoryUnderweight,
    'NORMAL' => l10n.bmiCategoryNormal,
    'OVERWEIGHT' => l10n.bmiCategoryOverweight,
    'OBESE' => l10n.bmiCategoryObese,
    _ => null,
  };
}

String todayIsoDate() {
  final now = DateTime.now();
  return DateUtils.dateOnly(now).toIso8601String().split('T').first;
}

double parseLocalizedDouble(String value) {
  return double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;
}

String goalTitle(String type, AppLocalizations l10n) {
  return switch (type) {
    'WEEKLY_DISTANCE' => l10n.weeklyDistanceTarget,
    'WEEKLY_SESSIONS' => l10n.weeklySessionsTarget,
    'WEEKLY_DURATION' => l10n.weeklyTrainingTimeTarget,
    'WEEKLY_CALORIES' => l10n.weeklyCaloriesTarget,
    'TARGET_WEIGHT' => l10n.weightTarget,
    _ => type,
  };
}
