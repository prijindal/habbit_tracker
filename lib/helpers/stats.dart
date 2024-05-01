import 'package:intl/intl.dart';

import '../models/core.dart';

class DurationData {
  DurationData({
    required this.duration,
    required this.start,
    required this.end,
  });
  final Duration duration;
  final DateTime start;
  final DateTime end;
}

class CountsDayData {
  final DateTime date;
  final int count;

  CountsDayData({required this.date, required this.count});
}

String durationToStreak(Duration? streak) {
  if (streak == null) {
    return "No Data";
  }
  if (streak.inDays > 0) {
    return "${streak.inDays}d ${streak.inHours % 24}h";
  }
  if (streak.inHours > 0) {
    return "${streak.inHours % 24}h ${streak.inMinutes % 60}m";
  }
  return "${streak.inMinutes % 60}m";
}

Duration? currentStreak(List<HabbitEntry>? entries) {
  if (entries != null && entries.isNotEmpty) {
    return DateTime.now().difference(entries[0].creationTime);
  }
  return null;
}

String currentStreakString(List<HabbitEntry>? entries) {
  var text = "No Data";
  final streak = currentStreak(entries);
  if (streak != null) {
    text = "${streak.inDays} Days";
  }
  if (streak != null) {
    text = "Current Streak: ${durationToStreak(streak)}";
  }
  return text;
}

int getTodayCount(List<HabbitEntry>? entries) {
  if (entries == null) {
    return 0;
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final todayEntries = entries.where((element) {
    final creationTime = element.creationTime.toLocal();
    final aDate = DateTime(
      creationTime.year,
      creationTime.month,
      creationTime.day,
    );
    return aDate == today;
  });
  return todayEntries.length;
}

Duration? longestStreak(
  List<HabbitEntry>? entries, {
  bool includeCurrent = false,
}) {
  if (entries != null &&
      entries.isNotEmpty &&
      allDurationsData(entries, includeCurrent: includeCurrent).isNotEmpty) {
    return allDurationsData(entries, includeCurrent: includeCurrent)
        .last
        .duration;
  }
  return null;
}

List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
  List<DateTime> days = [];
  for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
    days.add(startDate.add(Duration(days: i)));
  }
  return days;
}

List<CountsDayData> countPerDaysData(List<HabbitEntry>? entries,
    [bool includeEmptyDates = true, DateTime? startDate]) {
  final counts = <DateTime, int>{};
  if (entries == null) {
    return [];
  }
  for (var entry in entries) {
    final creationTime = entry.creationTime.toLocal();
    final date = DateTime(
      creationTime.year,
      creationTime.month,
      creationTime.day,
    );
    if (!counts.containsKey(date)) {
      counts[date] = 0;
    }
    counts.update(date, (value) => value + 1);
  }
  if (includeEmptyDates && entries.isNotEmpty) {
    final daysInBetween = getDaysInBetween(
      startDate?.toLocal() ?? entries.last.creationTime.toLocal(),
      entries.first.creationTime.toLocal(),
    );
    for (var day in daysInBetween) {
      final date = DateTime(
        day.year,
        day.month,
        day.day,
      );
      if (!counts.containsKey(date)) {
        counts[date] = 0;
      }
    }
  }
  return counts.entries
      .map((e) => CountsDayData(
            count: e.value,
            date: e.key,
          ))
      .toList();
}

List<DurationData> allDurationsData(
  List<HabbitEntry>? entries, {
  bool includeCurrent = false,
}) {
  final List<DurationData> allDurations = [];
  if (entries != null && entries.isNotEmpty) {
    if (includeCurrent) {
      final now = DateTime.now();
      allDurations.add(
        DurationData(
          duration: now.difference(
            entries[0].creationTime,
          ),
          start: entries[0].creationTime,
          end: now,
        ),
      );
    }
    for (var i = 1; i < entries.length; i++) {
      final newStreak =
          entries[i - 1].creationTime.difference(entries[i].creationTime);
      allDurations.add(
        DurationData(
          duration: newStreak,
          start: entries[i].creationTime,
          end: entries[i - 1].creationTime,
        ),
      );
    }
  }
  return allDurations
    ..sort((value, element) =>
        value.duration.inSeconds - element.duration.inSeconds);
}

String formatDate(DateTime originalDate,
    [HabbitDateFormat format = HabbitDateFormat.long]) {
  final date = originalDate.toLocal();
  switch (format) {
    case HabbitDateFormat.long:
      return "${DateFormat.yMMMEd().format(date)} ${DateFormat.jm().format(date)}";
    case HabbitDateFormat.shortTime:
      return "${DateFormat.E().format(date)} ${DateFormat.jm().format(date)}";
    case HabbitDateFormat.shortDate:
      return DateFormat.MMMEd().format(date);
  }
}

enum HabbitDateFormat { shortTime, shortDate, long }
