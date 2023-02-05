import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/stats.dart';
import '../models/core.dart';
import '../helpers/constants.dart';

enum StatsIntervals { oneWeek, oneMonth, threeMonths, oneYear, all }

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
  StatsIntervals statsIntervals = StatsIntervals.all;

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      final preference = instance.getInt(STATS_INTERVAL_PREFERENCE);
      setState(() {
        statsIntervals =
            StatsIntervals.values[preference ?? StatsIntervals.all.index];
      });
    });
    super.initState();
  }

  String statsIntervalToText(StatsIntervals statsInterval) {
    switch (statsInterval) {
      case StatsIntervals.oneYear:
        return "Last One Year";
      case StatsIntervals.threeMonths:
        return "Last Three Months";
      case StatsIntervals.oneMonth:
        return "Last One Month";
      case StatsIntervals.oneWeek:
        return "Last One Week";
      case StatsIntervals.all:
        return "All";
      default:
        return "None";
    }
  }

  List<RelapseData> getRelapses() {
    if (widget.relapses == null) {
      return [];
    }
    final now = DateTime.now();
    final relapses = widget.relapses!;
    switch (statsIntervals) {
      case StatsIntervals.oneYear:
        return relapses
            .where(
                (element) => now.difference(element.creationTime).inDays <= 365)
            .toList();
      case StatsIntervals.threeMonths:
        return relapses
            .where(
                (element) => now.difference(element.creationTime).inDays <= 90)
            .toList();
      case StatsIntervals.oneMonth:
        return relapses
            .where(
                (element) => now.difference(element.creationTime).inDays <= 30)
            .toList();
      case StatsIntervals.oneWeek:
        return relapses
            .where(
                (element) => now.difference(element.creationTime).inDays <= 7)
            .toList();
      case StatsIntervals.all:
        return relapses;
      default:
        return relapses;
    }
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

  getChartData() {
    final durationsData = allDurationsData(getRelapses())
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
          title: DropdownButton<StatsIntervals>(
            value: statsIntervals,
            items: StatsIntervals.values
                .map(
                  (e) => DropdownMenuItem<StatsIntervals>(
                    value: e,
                    child: Text(statsIntervalToText(e)),
                  ),
                )
                .toList(),
            onChanged: (newValue) async {
              setState(() {
                statsIntervals = newValue ?? StatsIntervals.all;
              });
              (await SharedPreferences.getInstance()).setInt(
                STATS_INTERVAL_PREFERENCE,
                newValue?.index ?? StatsIntervals.all.index,
              );
            },
          ),
        ),
        ListTile(
          title: const Text("Total relapses"),
          subtitle: Text(
            (getRelapses().length).toString(),
          ),
        ),
        ListTile(
          title: const Text("Current streak"),
          subtitle: Text(
            durationToStreak(currentStreak(getRelapses())),
          ),
        ),
        ListTile(
          title: const Text("Shortest streak"),
          subtitle: Text(
            durationToStreak(shortestStreak(getRelapses())),
          ),
        ),
        ListTile(
          title: const Text("Longest streak"),
          subtitle: Text(
            durationToStreak(longestStreak(getRelapses())),
          ),
        ),
        ListTile(
          title: const Text("Average Duration"),
          subtitle: Text(
            durationToStreak(averageDuration(getRelapses())),
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
