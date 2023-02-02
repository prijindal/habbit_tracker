import 'dart:async';

import 'package:flutter/material.dart';
import 'package:relapse/models/drift.dart';

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
  String _currentStreak = "";
  String _longestStreak = "";
  Timer? countdownTimer;

  @override
  void initState() {
    _setCurrentStreak();
    _setLargestStreak();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _setCurrentStreak();
      _setLargestStreak();
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
    final relapses = widget.relapses;
    if (relapses != null && relapses.isNotEmpty) {
      final daysSince =
          DateTime.now().difference(relapses[0].creationTime).inDays;
      text = "$daysSince Days";
    }
    return Text(
      text,
      style: const TextStyle(
        fontSize: 48,
      ),
    );
  }

  String durationToStreak(Duration streak) {
    return "${streak.inDays}d ${streak.inHours % 24}m ${streak.inMinutes % 60}m ${streak.inSeconds % 60}s";
  }

  void _setCurrentStreak() {
    var text = "No Data";
    final relapses = widget.relapses;
    if (relapses != null && relapses.isNotEmpty) {
      final streak = DateTime.now().difference(relapses[0].creationTime);
      text = "Current Streak: ${durationToStreak(streak)}";
    }
    setState(() {
      _currentStreak = text;
    });
  }

  void _setLargestStreak() {
    var text = "No Data";
    final relapses = widget.relapses;
    if (relapses != null && relapses.isNotEmpty) {
      Duration streak = DateTime.now().difference(relapses[0].creationTime);
      for (var i = 1; i < relapses.length; i++) {
        final newStreak =
            relapses[i - 1].creationTime.difference(relapses[i].creationTime);
        if (newStreak > streak) {
          streak = newStreak;
        }
      }
      text = "Longest Streak: ${durationToStreak(streak)}";
    }
    setState(() {
      _longestStreak = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: widget.relapses == null
          ? const Text("Loading")
          : Column(children: [
              _daysSince(),
              Text(
                _currentStreak,
              ),
              Text(
                _longestStreak,
              )
            ]),
    );
  }
}
