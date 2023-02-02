import 'dart:async';

import 'package:flutter/material.dart';
import '../helpers/stats.dart';
import '../models/core.dart';

class CounterSubPage extends StatefulWidget {
  const CounterSubPage({
    super.key,
    required this.relapses,
  });
  final List<RelapseData>? relapses;

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
    final streak = currentStreak(widget.relapses);
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

  String _getCurrentStreak() {
    var text = "No Data";
    final streak = currentStreak(widget.relapses);
    if (streak != null) {
      text = "${streak.inDays} Days";
    }
    if (streak != null) {
      text = "Current Streak: ${durationToStreak(streak)}";
    }
    return text;
  }

  String _getLargestStreak() {
    var text = "No Data";
    final streak = longestStreak(widget.relapses);
    if (streak != null) {
      text = "Longest Streak: ${durationToStreak(streak)}";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: widget.relapses == null
          ? const Text("Loading")
          : Column(children: [
              _daysSince(),
              Text(
                _getCurrentStreak(),
              ),
              Text(
                _getLargestStreak(),
              )
            ]),
    );
  }
}
