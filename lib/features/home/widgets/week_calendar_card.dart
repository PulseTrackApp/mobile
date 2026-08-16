import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_panel.dart';
import '../../../l10n/app_localizations.dart';

/// Un jour de la semaine, tel que le bilan hebdomadaire le decrit.
class WeekDay {
  const WeekDay({
    required this.date,
    required this.sessionCount,
    required this.distanceMeters,
  });

  final DateTime date;
  final int sessionCount;
  final double distanceMeters;

  bool get isActive => sessionCount > 0;
}

/// La meilleure performance du sport affiche, telle que le serveur la formule.
///
/// Le libelle et l'unite viennent du serveur : c'est lui qui sait quelle
/// categorie de record existe pour un sport, et le formuler une seconde fois ici
/// ferait diverger les deux textes a la premiere evolution.
class BestEffort {
  const BestEffort({required this.label, required this.value});

  final String label;

  /// Deja mis en forme : « 12,4 km », « 5:12 /km ».
  final String value;
}

/// Le mini calendrier de la semaine : quels jours ont vu du sport, combien, et
/// la meilleure performance en reference.
///
/// <p>Les sept jours sont toujours dessines, jours vides compris, et les jours a
/// venir sont grises. Un calendrier dont les jours sans sport manqueraient
/// donnerait l'illusion d'une regularite qui n'existe pas — c'est justement
/// l'inverse de ce que cette carte doit montrer.
class WeekCalendarCard extends StatelessWidget {
  const WeekCalendarCard({
    super.key,
    this.days = const [],
    this.activeDayCount = 0,
    this.streak = 0,
    this.best,
  });

  final List<WeekDay> days;

  /// Nombre de jours de la semaine ayant vu au moins une seance.
  final int activeDayCount;

  /// Jours consecutifs avec seance, calcule cote serveur.
  final int streak;

  final BestEffort? best;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final narrowDay = DateFormat.EEEEE(locale);
    final today = DateUtils.dateOnly(DateTime.now());
    final streakLabel = streak > 1 ? l10n.weekCalendarStreak(streak) : '';
    // Bilan pas encore charge, ou compte non connecte : on dessine quand meme
    // les sept jours, vides. Une rangee absente ferait sauter la mise en page au
    // moment ou les donnees arrivent.
    final week = days.isEmpty ? _currentWeekSkeleton(today) : days;

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.weekCalendarTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Text(
                l10n.weekCalendarDaysDone(activeDayCount),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final day in week)
                _DayDot(
                  letter: narrowDay.format(day.date).toUpperCase(),
                  day: day,
                  isToday: DateUtils.isSameDay(day.date, today),
                  isFuture: DateUtils.dateOnly(day.date).isAfter(today),
                ),
            ],
          ),
          if (streakLabel.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 6),
                Text(streakLabel, style: theme.textTheme.bodyMedium),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.gps.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 20,
                  color: AppColors.gps,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.weekCalendarBestTitle,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      best == null
                          ? l10n.weekCalendarNoBest
                          : '${best!.value} · ${best!.label}',
                      style: best == null
                          ? theme.textTheme.bodyMedium
                          : theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Les sept jours de la semaine en cours, tous vides.
///
/// Du lundi au dimanche, comme le serveur les renvoie : deux ordres differents
/// selon que les donnees sont arrivees ou non feraient danser la rangee.
List<WeekDay> _currentWeekSkeleton(DateTime today) {
  final monday = today.subtract(Duration(days: today.weekday - DateTime.monday));
  return [
    for (var i = 0; i < 7; i++)
      WeekDay(
        date: monday.add(Duration(days: i)),
        sessionCount: 0,
        distanceMeters: 0,
      ),
  ];
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.letter,
    required this.day,
    required this.isToday,
    required this.isFuture,
  });

  final String letter;
  final WeekDay day;
  final bool isToday;
  final bool isFuture;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    // Un jour a venir n'est pas un jour rate : il est simplement grise. Le
    // peindre comme un jour vide ferait lire un echec la ou il n'y a rien encore.
    final background = day.isActive
        ? AppColors.primary
        : theme.colorScheme.surfaceContainerHighest;
    final foreground = day.isActive
        ? Colors.white
        : theme.colorScheme.onSurfaceVariant.withValues(
            alpha: isFuture ? 0.4 : 1,
          );

    return Semantics(
      label: isToday ? l10n.weekCalendarToday : null,
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              border: isToday
                  ? Border.all(color: AppColors.accent, width: 2)
                  : null,
            ),
            child: day.isActive
                ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                : Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: foreground.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
          const SizedBox(height: 5),
          Text(
            letter,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(
                alpha: isFuture ? 0.4 : 1,
              ),
              fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
