import '../models/drift.dart';

Duration? currentStreak(List<RelapseData>? relapses) {
  if (relapses != null && relapses.isNotEmpty) {
    return DateTime.now().difference(relapses[0].creationTime);
  }
  return null;
}

Duration? longestStreak(List<RelapseData>? relapses) {
  if (relapses != null && relapses.isNotEmpty) {
    return allDurations(relapses).last;
  }
  return null;
}

Duration? shortestStreak(List<RelapseData>? relapses) {
  if (relapses != null && relapses.isNotEmpty) {
    return allDurations(relapses).first;
  }
  return null;
}

List<Duration> allDurations(List<RelapseData>? relapses) {
  final List<Duration> allDurations = [];
  if (relapses != null && relapses.isNotEmpty) {
    allDurations.add(DateTime.now().difference(relapses[0].creationTime));
    for (var i = 1; i < relapses.length; i++) {
      final newStreak =
          relapses[i - 1].creationTime.difference(relapses[i].creationTime);
      allDurations.add(newStreak);
    }
  }
  return allDurations
    ..sort((value, element) => value.inSeconds - element.inSeconds);
}

Duration averageDuration(List<RelapseData>? relapses) {
  final List<Duration> durations = allDurations(relapses);
  Duration totalDuration = const Duration();
  for (var duration in durations) {
    totalDuration += duration;
  }
  if (durations.isNotEmpty) {
    return Duration(
        seconds: (totalDuration.inSeconds / durations.length).round());
  }
  return const Duration();
}
