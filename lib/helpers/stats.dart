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

Duration? currentStreak(List<HabbitEntryData>? entries) {
  if (entries != null && entries.isNotEmpty) {
    return DateTime.now().difference(entries[0].creationTime);
  }
  return null;
}

String currentStreakString(List<HabbitEntryData>? entries) {
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

int getTodayCount(List<HabbitEntryData>? entries) {
  if (entries == null) {
    return 0;
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final todayEntries = entries.where((element) {
    final aDate = DateTime(element.creationTime.year,
        element.creationTime.month, element.creationTime.day);
    return aDate == today;
  });
  return todayEntries.length;
}

Duration? longestStreak(
  List<HabbitEntryData>? entries, {
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

List<DurationData> allDurationsData(
  List<HabbitEntryData>? entries, {
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

String formatDate(DateTime date, [bool short = false]) {
  if (short) {
    return "${DateFormat.E().format(date)} ${DateFormat.jm().format(date)}";
  }
  return "${DateFormat.yMMMEd().format(date)} ${DateFormat.jm().format(date)}";
}
