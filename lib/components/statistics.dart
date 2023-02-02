import 'package:flutter/material.dart';
import '../helpers/stats.dart';
import '../models/core.dart';

class StatisticsSubPage extends StatefulWidget {
  const StatisticsSubPage({
    super.key,
    required this.relapses,
  });

  final List<RelapseData>? relapses;

  @override
  State<StatisticsSubPage> createState() => _StatisticsSubPageState();
}

class _StatisticsSubPageState extends State<StatisticsSubPage> {
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

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text("Total relapses"),
          subtitle: Text(
            (widget.relapses?.length ?? 0).toString(),
          ),
        ),
        ListTile(
          title: const Text("Current streak"),
          subtitle: Text(
            durationToStreak(currentStreak(widget.relapses)),
          ),
        ),
        ListTile(
          title: const Text("Shortest streak"),
          subtitle: Text(
            durationToStreak(shortestStreak(widget.relapses)),
          ),
        ),
        ListTile(
          title: const Text("Longest streak"),
          subtitle: Text(
            durationToStreak(longestStreak(widget.relapses)),
          ),
        ),
        ListTile(
          title: const Text("Average Duration"),
          subtitle: Text(
            durationToStreak(averageDuration(widget.relapses)),
          ),
        )
      ],
    );
  }
}
