import 'dart:async';

import 'package:drift/drift.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import '../components/entryform.dart';
import '../helpers/stats.dart';
import '../models/drift.dart';
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

  void _editEntry(HabbitEntryData entry) async {
    final editedData = await showDialog<HabbitEntryCompanion>(
      context: context,
      builder: (BuildContext context) {
        return EntryDialogForm(
          habbit: widget.habbit.id,
          creationTime: entry.creationTime,
          description: entry.description,
        );
      },
    );
    if (editedData != null) {
      (MyDatabase.instance.update(MyDatabase.instance.habbitEntry)
            ..where((tbl) => tbl.id.equals(entry.id)))
          .write(editedData);
    }
  }

  void _recordEntry() async {
    final entry = HabbitEntryCompanion(
      creationTime: Value(DateTime.now()),
      habbit: Value(widget.habbit.id),
    );
    final savedEntryId = await MyDatabase.instance
        .into(MyDatabase.instance.habbitEntry)
        .insert(entry);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("New entry for ${widget.habbit.name} saved"),
          action: SnackBarAction(
            label: "Edit",
            onPressed: () async {
              final savedEntry = await (MyDatabase.instance.habbitEntry.select()
                    ..where(
                      (tbl) => tbl.rowId.equals(savedEntryId),
                    ))
                  .getSingle();
              _editEntry(savedEntry);
            },
          ),
        ),
      );
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
      background: Container(
        color: Colors.red,
        alignment: AlignmentDirectional.centerStart,
        child: const Padding(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: AlignmentDirectional.centerEnd,
        child: const Padding(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      child: OpenContainer(
        openColor: Theme.of(context).colorScheme.background,
        closedColor: Theme.of(context).colorScheme.background,
        openBuilder: (context, action) =>
            HabbitPage(habbitId: widget.habbit.id),
        closedBuilder: (BuildContext _, VoidCallback openContainer) => ListTile(
          title: Text(widget.habbit.name),
          subtitle: Text(_getCurrentStreak()),
          onTap: openContainer,
          // onTap: () => Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => HabbitPage(
          //       habbitId: widget.habbit.id,
          //     ),
          //   ),
          // ),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _recordEntry(),
          ),
        ),
      ),
    );
  }
}
