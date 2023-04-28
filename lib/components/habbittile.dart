import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:habbit_tracker/components/entryform.dart';
import 'package:habbit_tracker/helpers/stats.dart';
import 'package:habbit_tracker/models/drift.dart';
import '../components/deletehabbitdialog.dart';
import '../pages/habbit.dart';
import '../models/core.dart';

class HabbitTile extends StatefulWidget {
  const HabbitTile({super.key, required this.habbit});

  final HabbitData habbit;

  @override
  State<HabbitTile> createState() => _HabbitTileState();
}

class _HabbitTileState extends State<HabbitTile> {
  List<HabbitEntryData>? _habbitEntries;
  StreamSubscription<List<HabbitEntryData>>? _subscription;

  @override
  void initState() {
    _addWatcher();
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _addWatcher() {
    _subscription = (MyDatabase.instance.habbitEntry.select()
          ..where((tbl) => tbl.habbit.equals(widget.habbit.id))
          ..limit(1)
          ..orderBy(
            [
              (t) => OrderingTerm(
                    expression: t.creationTime,
                    mode: OrderingMode.desc,
                  ),
            ],
          ))
        .watch()
        .listen((event) {
      setState(() {
        _habbitEntries = event;
      });
    });
  }

  Future<bool?> _confirmDelete() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return DeleteHabbitDialog(
          habbit: widget.habbit,
        );
      },
    );
  }

  void _recordEntry() async {
    final entries = await showDialog<HabbitEntryCompanion?>(
      context: context,
      builder: (BuildContext context) {
        return EntryDialogForm(habbit: widget.habbit.id);
      },
    );
    if (entries != null) {
      await MyDatabase.instance
          .into(MyDatabase.instance.habbitEntry)
          .insert(entries);
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

  String _getCurrentStreak() {
    var text = "No Data";
    final streak = currentStreak(_habbitEntries);
    if (streak != null) {
      text = "${streak.inDays} Days";
    }
    if (streak != null) {
      text = "Current Streak: ${durationToStreak(streak)}";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.habbit.id),
      confirmDismiss: (direction) {
        return _confirmDelete();
      },
      background: Container(color: Colors.red),
      child: ListTile(
        title: Text(widget.habbit.name),
        subtitle: Text(_getCurrentStreak()),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HabbitPage(
              habbit: widget.habbit,
            ),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _recordEntry(),
        ),
      ),
    );
  }
}
