import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/constants.dart';
import '../helpers/stats.dart';
import '../models/config.dart';
import '../models/core.dart';

enum StatsIntervals { oneWeek, oneMonth, threeMonths, oneYear, all }

class StatisticsSubPage extends StatefulWidget {
  const StatisticsSubPage({
    super.key,
    required this.entries,
    required this.habbit,
  });

  final List<HabbitEntryData>? entries;
  final HabbitData? habbit;

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

  List<Widget> _buildStats() {
    final habbit = widget.habbit;
    final list = <ListTile>[];
    if (habbit == null) {
      return list;
    }
    final config = HabbitConfig.getConfig(habbit.config);
    for (var element in config.statistics) {
      list.add(
        ListTile(
          title: Text(element.name),
          subtitle: Text(
            element.transform(getEntries()),
          ),
        ),
      );
    }
    return list;
  }

  List<Widget> _buildCharts() {
    final habbit = widget.habbit;
    final list = <BarChartData>[];
    if (habbit == null) {
      return [];
    }
    final config = HabbitConfig.getConfig(habbit.config);
    for (var element in config.charts) {
      const titlesData = FlTitlesData(
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
      );
      switch (element) {
        case HabbitChart.durationsChart:
          final durationsData = allDurationsData(getEntries())
            ..sort((a, b) =>
                a.start.millisecondsSinceEpoch -
                b.start.millisecondsSinceEpoch);
          final chartsData = durationsData
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
          list.add(
            BarChartData(
              titlesData: titlesData,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final end = DateTime.fromMillisecondsSinceEpoch(group.x);
                    final duration = Duration(seconds: rod.toY.floor());
                    return BarTooltipItem(
                      "${formatDate(end, HabbitDateFormat.shortTime)}\n",
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
              barGroups: chartsData,
              // read about it in the BarChartData section
            ),
          );
          break;
        case HabbitChart.dayCountsChart:
          final countsData = countPerDaysData(getEntries())
            ..sort((a, b) =>
                a.date.millisecondsSinceEpoch - b.date.millisecondsSinceEpoch);
          final chartsData = countsData
              .map(
                (e) => BarChartGroupData(
                  x: e.date.millisecondsSinceEpoch,
                  barRods: [
                    BarChartRodData(
                      toY: e.count.toDouble(),
                    )
                  ],
                ),
              )
              .toList();
          list.add(
            BarChartData(
              titlesData: titlesData,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final date = DateTime.fromMillisecondsSinceEpoch(group.x);
                    return BarTooltipItem(
                      "${formatDate(date, HabbitDateFormat.shortDate)}\n",
                      const TextStyle(),
                      children: [
                        TextSpan(
                          text: "${rod.toY.floor()}",
                        ),
                      ],
                    );
                  },
                ),
              ),
              barGroups: chartsData,
              // read about it in the BarChartData section
            ),
          );
          break;
      }
    }
    return list
        .map(
          (barChartData) => Container(
            padding: const EdgeInsets.all(8.0),
            height: 200,
            child: BarChart(
              barChartData,
              swapAnimationDuration:
                  const Duration(milliseconds: 150), // Optional
              swapAnimationCurve: Curves.linear,
            ),
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
        ..._buildStats(),
        ..._buildCharts(),
      ],
    );
  }
}
