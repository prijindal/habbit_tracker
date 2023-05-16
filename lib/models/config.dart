import 'package:flutter/material.dart';
import '../helpers/stats.dart' as stats;
import '../models/core.dart';

class HabbitConfig {
  final String name;
  final String code;
  final ColorScheme colorScheme;

  final QuickAddButtonConfigType quickAddButtonConfigType;
  final QuickSubtitleType quickSubtitleType;

  final CounterTitle counterTitle;
  final List<ExtraCounter> extraCounters;

  final List<HabbitStatistic> statistics;

  final List<HabbitChart> charts;

  static final positive = HabbitConfig(
    name: "Positive Habbit",
    code: "positive_habbit",
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.lightGreen,
      primaryColorDark: Colors.green,
    ),
    quickAddButtonConfigType: QuickAddButtonConfigType.addSubtract,
    quickSubtitleType: QuickSubtitleType.todayCount,
    counterTitle: CounterTitle.todayCount,
    extraCounters: [],
    statistics: [
      HabbitStatistic.total,
      HabbitStatistic.averageCounts,
    ],
    charts: [HabbitChart.dayCountsChart],
  );

  static final negative = HabbitConfig(
    name: "Negative Habbit",
    code: "negative_habbit",
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.purple,
      primaryColorDark: Colors.deepPurple,
    ),
    quickAddButtonConfigType: QuickAddButtonConfigType.add,
    quickSubtitleType: QuickSubtitleType.currentStreak,
    counterTitle: CounterTitle.daysStreak,
    extraCounters: [
      ExtraCounter.currentStreak,
      ExtraCounter.largestStreak,
    ],
    statistics: [
      HabbitStatistic.total,
      HabbitStatistic.currentStreak,
      HabbitStatistic.shortestStreak,
      HabbitStatistic.longestStreak,
      HabbitStatistic.averageDuration,
    ],
    charts: [HabbitChart.durationsChart],
  );

  static final values = [
    HabbitConfig.positive,
    HabbitConfig.negative,
  ];

  HabbitConfig({
    required this.name,
    required this.code,
    required this.colorScheme,
    required this.quickAddButtonConfigType,
    required this.quickSubtitleType,
    required this.counterTitle,
    required this.extraCounters,
    required this.statistics,
    required this.charts,
  });

  static HabbitConfig getConfig(String? code) => HabbitConfig.values.firstWhere(
        (element) => element.code == code,
        orElse: () => HabbitConfig.positive,
      );

  ThemeData getThemeData(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = this.colorScheme;

    return theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        primary: colorScheme.primary,
        primaryContainer: colorScheme.primaryContainer,
      ),
    );
  }
}

enum QuickAddButtonConfigType {
  addSubtract,
  add,
}

enum QuickSubtitleType {
  currentStreak,
  todayCount,
}

enum CounterTitle {
  daysStreak,
  todayCount,
}

enum ExtraCounter {
  currentStreak,
  largestStreak,
}

class HabbitStatistic {
  String name;
  String Function(List<HabbitEntryData> entries) transform;

  HabbitStatistic({
    required this.name,
    required this.transform,
  });

  static final total = HabbitStatistic(
    name: "Total entries",
    transform: (entries) => entries.length.toString(),
  );

  static final currentStreak = HabbitStatistic(
    name: "Current streak",
    transform: (entries) =>
        stats.durationToStreak(stats.currentStreak(entries)),
  );

  static final shortestStreak = HabbitStatistic(
    name: "Shortest streak",
    transform: (entries) {
      if (entries.isNotEmpty && stats.allDurationsData(entries).isNotEmpty) {
        final shortest = stats.allDurationsData(entries).first.duration;
        return stats.durationToStreak(shortest);
      }
      return "No Data";
    },
  );

  static final longestStreak = HabbitStatistic(
    name: "Longest streak",
    transform: (entries) =>
        stats.durationToStreak(stats.longestStreak(entries)),
  );

  static final averageDuration = HabbitStatistic(
    name: "Average Duration",
    transform: (entries) {
      final List<stats.DurationData> durations =
          stats.allDurationsData(entries);
      Duration totalDuration = const Duration();
      for (var durationData in durations) {
        totalDuration += durationData.duration;
      }
      if (durations.isNotEmpty) {
        final duration = Duration(
          seconds: (totalDuration.inSeconds / durations.length).round(),
        );
        return stats.durationToStreak(duration);
      }
      return "No Data";
    },
  );

  static final averageCounts = HabbitStatistic(
    name: "Average counts",
    transform: (entries) {
      final counts = stats.countPerDaysData(entries);
      var sum = 0;
      for (var element in counts) {
        sum += element.count;
      }
      return (sum / counts.length).toStringAsFixed(2);
    },
  );
}

enum HabbitChart {
  durationsChart,
  dayCountsChart,
}
