import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

  getChartData() {
    final durationsData = allDurationsData(widget.relapses)
      ..sort((a, b) =>
          a.start.millisecondsSinceEpoch - b.start.millisecondsSinceEpoch);
    return durationsData
        .map(
          (e) => BarChartGroupData(
            x: e.end.millisecondsSinceEpoch,
            barRods: [
              BarChartRodData(
                toY: e.duration.inSeconds.toDouble(),
              )
            ],
          ),
        )
        .toList();
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
        ),
        Container(
            padding: const EdgeInsets.all(8.0),
            height: 200,
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final end = DateTime.fromMillisecondsSinceEpoch(group.x);
                      final duration = Duration(seconds: rod.toY.floor());
                      return BarTooltipItem(
                        "${formatDate(end, true)}\n",
                        const TextStyle(),
                        children: [
                          TextSpan(
                            text: durationToStreak(duration),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                barGroups: getChartData(),
                // read about it in the BarChartData section
              ),
              swapAnimationDuration: Duration(milliseconds: 150), // Optional
              swapAnimationCurve: Curves.linear, // Optional
            )),
      ],
    );
  }
}
