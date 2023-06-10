import 'dart:async';

import 'package:animations/animations.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../components/deletehabbitdialog.dart';
import '../components/entryform.dart';
import '../components/habbitform.dart';
import '../helpers/stats.dart';
import '../models/config.dart';
import '../models/core.dart';
import '../models/drift.dart';
import '../models/theme.dart';
import '../pages/habbit.dart';

class HabbitTile extends StatefulWidget {
  const HabbitTile({
    super.key,
    required this.habbit,
    this.onTap,
    this.selected = false,
  });

  final HabbitData habbit;
  final GestureTapCallback? onTap;
  final bool selected;

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
          ..where((tbl) => tbl.deletionTime.isNull())
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

  Future<bool> _editHabbit() async {
    await HabbitDialogForm.editEntry(
      context: context,
      habbitId: widget.habbit.id,
      habbit: widget.habbit,
    );
    return false;
  }

  void _editEntry(HabbitEntryData entry) async {
    await EntryDialogForm.editEntry(
      context: context,
      habbitId: widget.habbit.id,
      entry: entry,
    );
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
          duration: const Duration(milliseconds: 100),
          content: Text("New entry for ${widget.habbit.name} saved"),
          action: SnackBarAction(
            label: "Edit",
            onPressed: () async {
              final savedEntry = await (MyDatabase.instance.habbitEntry.select()
                    ..where(
                      (tbl) => tbl.rowId.equals(savedEntryId),
                    )
                    ..where((tbl) => tbl.deletionTime.isNull()))
                  .getSingle();
              _editEntry(savedEntry);
            },
          ),
        ),
      );
    }
  }

  String _getTodayCount() {
    var text = "No Data";
    final count = getTodayCount(_habbitEntries);
    if (count == 0) {
      return text;
    }
    text = "Today: $count";
    return text;
  }

  void _removeEntry() async {
    final lastEntry = await (MyDatabase.instance.habbitEntry.select()
          ..where((tbl) => tbl.habbit.equals(widget.habbit.id))
          ..where((tbl) => tbl.deletionTime.isNull())
          ..limit(1)
          ..orderBy(
            [
              (t) => OrderingTerm(
                    expression: t.creationTime,
                    mode: OrderingMode.desc,
                  ),
            ],
          ))
        .getSingleOrNull();
    if (lastEntry == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 100),
            content: Text("No entry for ${widget.habbit.name}"),
          ),
        );
      }
    } else {
      await MyDatabase.instance.habbitEntry.deleteWhere(
        (tbl) => tbl.id.equals(lastEntry.id),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 100),
            content: Text("Last entry for t${widget.habbit.name}"),
          ),
        );
      }
    }
  }

  Widget _buildSubtitle() {
    final config = HabbitConfig.getConfig(widget.habbit.config);
    switch (config.quickSubtitleType) {
      case QuickSubtitleType.currentStreak:
        return Text(currentStreakString(_habbitEntries));
      case QuickSubtitleType.todayCount:
        return Text(_getTodayCount());
    }
  }

  Widget _buildTrailing() {
    final config = HabbitConfig.getConfig(widget.habbit.config);
    switch (config.quickAddButtonConfigType) {
      case QuickAddButtonConfigType.addSubtract:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.remove,
                color: config.colorScheme.primary,
              ),
              onPressed: () => _removeEntry(),
            ),
            IconButton(
              icon: Icon(
                Icons.add,
                color: config.colorScheme.primary,
              ),
              onPressed: () => _recordEntry(),
            ),
          ],
        );
      case QuickAddButtonConfigType.add:
        return IconButton(
          icon: Icon(
            Icons.add,
            color: config.colorScheme.primary,
          ),
          onPressed: () => _recordEntry(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.habbit.id),
      confirmDismiss: (direction) {
        if (direction == DismissDirection.startToEnd) {
          return _confirmDelete();
        } else {
          return _editHabbit();
        }
      },
      background: deleteDismissible,
      secondaryBackground: editDismissible,
      child: ListTile(
        selected: widget.selected,
        title: Text(widget.habbit.name),
        subtitle: _buildSubtitle(),
        onTap: widget.onTap,
        trailing: _buildTrailing(),
      ),
    );
  }
}

class HabbitContainerTile extends StatelessWidget {
  const HabbitContainerTile({super.key, required this.habbit});

  final HabbitData habbit;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      openColor: Theme.of(context).colorScheme.background,
      closedColor: Theme.of(context).colorScheme.background,
      openBuilder: (context, action) => HabbitPage(habbitId: habbit.id),
      closedBuilder: (BuildContext _, VoidCallback openContainer) => HabbitTile(
        habbit: habbit,
        onTap: openContainer,
      ),
    );
  }
}
