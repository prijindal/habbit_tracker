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

Duration? currentStreak(List<HabbitEntryData>? entries) {
  if (entries != null && entries.isNotEmpty) {
    return DateTime.now().difference(entries[0].creationTime);
  }
  return null;
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

Duration? shortestStreak(List<HabbitEntryData>? entries) {
  if (entries != null &&
      entries.isNotEmpty &&
      allDurationsData(entries).isNotEmpty) {
    return allDurationsData(entries).first.duration;
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

Duration averageDuration(List<HabbitEntryData>? entries) {
  final List<DurationData> durations = allDurationsData(entries);
  Duration totalDuration = const Duration();
  for (var durationData in durations) {
    totalDuration += durationData.duration;
  }
  if (durations.isNotEmpty) {
    return Duration(
        seconds: (totalDuration.inSeconds / durations.length).round());
  }
  return const Duration();
}

String formatDate(DateTime date, [bool short = false]) {
  if (short) {
    return "${DateFormat.E().format(date)} ${DateFormat.jm().format(date)}";
  }
  return "${DateFormat.yMMMEd().format(date)} ${DateFormat.jm().format(date)}";
}
