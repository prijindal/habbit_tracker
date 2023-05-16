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
    required this.entries,
  });

  final List<HabbitEntryData>? entries;

  @override
  State<StatisticsSubPage> createState() => _StatisticsSubPageState();
}

class _StatisticsSubPageState extends State<StatisticsSubPage> {
  StatsIntervals statsIntervals = StatsIntervals.all;

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      final preference = instance.getInt(statsIntervalPreference);
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

  List<HabbitEntryData> getEntries() {
    if (widget.entries == null) {
      return [];
    }
    final now = DateTime.now();
    final entries = widget.entries!;
    switch (statsIntervals) {
      case StatsIntervals.oneYear:
        return entries
            .where(
                (element) => now.difference(element.creationTime).inDays <= 365)
            .toList();
      case StatsIntervals.threeMonths:
        return entries
            .where(
                (element) => now.difference(element.creationTime).inDays <= 90)
            .toList();
      case StatsIntervals.oneMonth:
        return entries
            .where(
                (element) => now.difference(element.creationTime).inDays <= 30)
            .toList();
      case StatsIntervals.oneWeek:
        return entries
            .where(
                (element) => now.difference(element.creationTime).inDays <= 7)
            .toList();
      case StatsIntervals.all:
        return entries;
      default:
        return entries;
    }
  }

  getChartData() {
    final durationsData = allDurationsData(getEntries())
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
                statsIntervalPreference,
                newValue?.index ?? StatsIntervals.all.index,
              );
            },
          ),
        ),
        ListTile(
          title: const Text("Total entries"),
          subtitle: Text(
            (getEntries().length).toString(),
          ),
        ),
        ListTile(
          title: const Text("Current streak"),
          subtitle: Text(
            durationToStreak(currentStreak(getEntries())),
          ),
        ),
        ListTile(
          title: const Text("Shortest streak"),
          subtitle: Text(
            durationToStreak(shortestStreak(getEntries())),
          ),
        ),
        ListTile(
          title: const Text("Longest streak"),
          subtitle: Text(
            durationToStreak(longestStreak(getEntries())),
          ),
        ),
        ListTile(
          title: const Text("Average Duration"),
          subtitle: Text(
            durationToStreak(averageDuration(getEntries())),
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
              swapAnimationDuration:
                  const Duration(milliseconds: 150), // Optional
              swapAnimationCurve: Curves.linear, // Optional
            )),
      ],
    );
  }
}
