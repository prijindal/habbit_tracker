import 'dart:async';

import 'package:flutter/material.dart';
import 'package:habbit_tracker/models/config.dart';
import '../helpers/stats.dart';
import '../models/core.dart';

class CounterSubPage extends StatefulWidget {
  const CounterSubPage({
    super.key,
    required this.entries,
    required this.habbit,
  });
  final List<HabbitEntryData>? entries;
  final HabbitData? habbit;

  @override
  State<CounterSubPage> createState() => _CounterSubPageState();
}

class _CounterSubPageState extends State<CounterSubPage> {
  Timer? countdownTimer;

  @override
  void initState() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  Widget _daysSince() {
    var text = "No Data";
    final streak = currentStreak(widget.entries);
    if (streak != null) {
      text = "${streak.inDays} Days";
    }
    return Text(
      text,
      style: const TextStyle(
        fontSize: 48,
      ),
    );
  }

  String durationToStreak(Duration streak) {
    return "${streak.inDays}d ${streak.inHours % 24}h ${streak.inMinutes % 60}m ${streak.inSeconds % 60}s";
  }

  String _getLargestStreak() {
    var text = "No Data";
    final streak = longestStreak(widget.entries, includeCurrent: true);
    if (streak != null) {
      text = "Longest Streak: ${durationToStreak(streak)}";
    }
    return text;
  }

  List<Widget> _buildTitle() {
    final habbit = widget.habbit;
    final list = <Widget>[];
    if (habbit == null) {
      return list;
    }
    final config = HabbitConfig.getConfig(habbit.config);
    switch (config.counterTitle) {
      case CounterTitle.daysStreak:
        list.addAll(
          [
            const Text("Streak"),
            _daysSince(),
          ],
        );
        break;
      case CounterTitle.todayCount:
        list.addAll(
          [
            const Text("Today"),
            Text(
              getTodayCount(widget.entries).toString(),
              style: const TextStyle(
                fontSize: 48,
              ),
            ),
          ],
        );
        break;
    }
    return list;
  }

  List<Widget> _buildExtraCounters() {
    final habbit = widget.habbit;
    final list = <Widget>[];
    if (habbit == null) {
      return list;
    }
    final config = HabbitConfig.getConfig(habbit.config);
    for (var element in config.extraCounters) {
      switch (element) {
        case ExtraCounter.currentStreak:
          list.add(Text(currentStreakString(widget.entries)));
          break;
        case ExtraCounter.largestStreak:
          list.add(Text(_getLargestStreak()));
          break;
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: widget.entries == null
          ? const Text("Loading")
          : Column(
              children: [
                ..._buildTitle(),
                ..._buildExtraCounters(),
              ],
            ),
    );
  }
}
