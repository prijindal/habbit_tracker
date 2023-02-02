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

Duration? currentStreak(List<RelapseData>? relapses) {
  if (relapses != null && relapses.isNotEmpty) {
    return DateTime.now().difference(relapses[0].creationTime);
  }
  return null;
}

Duration? longestStreak(List<RelapseData>? relapses) {
  if (relapses != null && relapses.isNotEmpty) {
    return allDurationsData(relapses).last.duration;
  }
  return null;
}

Duration? shortestStreak(List<RelapseData>? relapses) {
  if (relapses != null && relapses.isNotEmpty) {
    return allDurationsData(relapses).first.duration;
  }
  return null;
}

List<DurationData> allDurationsData(List<RelapseData>? relapses) {
  final List<DurationData> allDurations = [];
  if (relapses != null && relapses.isNotEmpty) {
    final now = DateTime.now();
    allDurations.add(
      DurationData(
        duration: now.difference(
          relapses[0].creationTime,
        ),
        start: relapses[0].creationTime,
        end: now,
      ),
    );
    for (var i = 1; i < relapses.length; i++) {
      final newStreak =
          relapses[i - 1].creationTime.difference(relapses[i].creationTime);
      allDurations.add(
        DurationData(
          duration: newStreak,
          start: relapses[i].creationTime,
          end: relapses[i - 1].creationTime,
        ),
      );
    }
  }
  return allDurations
    ..sort((value, element) =>
        value.duration.inSeconds - element.duration.inSeconds);
}

Duration averageDuration(List<RelapseData>? relapses) {
  final List<DurationData> durations = allDurationsData(relapses);
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
