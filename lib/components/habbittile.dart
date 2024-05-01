import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

import '../components/deletehabbitdialog.dart';
import '../components/habbitform.dart';
import '../helpers/entry.dart';
import '../helpers/stats.dart';
import '../models/config.dart';
import '../models/core.dart';
import '../models/database.dart';
import '../models/theme.dart';
import '../pages/habbit.dart';

class HabbitTile extends StatefulWidget {
  const HabbitTile({
    super.key,
    required this.habbit,
    this.onTap,
    this.selected = false,
  });

  final Habbit habbit;
  final GestureTapCallback? onTap;
  final bool selected;

  @override
  State<HabbitTile> createState() => _HabbitTileState();
}

class _HabbitTileState extends State<HabbitTile> {
  List<HabbitEntry>? _habbitEntries;
  StreamSubscription<RealmResultsChanges<HabbitEntry>>? _subscription;

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
    final query = MyDatabase.instance.query<HabbitEntry>(
        r'habbit.id == $0 AND deletionTime == nil SORT(creationTime DESC)',
        [widget.habbit.id]);

    _subscription = query.changes.listen((event) {
      setState(() {
        _habbitEntries = event.results.toList();
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
      habbit: widget.habbit,
    );
    return false;
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
    final lastEntry = MyDatabase.instance.query<HabbitEntry>(
        r'habbit.id == $0 AND deletionTime == nil SORT(creationTime DESC) LIMIT(1)',
        [widget.habbit.id]).firstOrNull;
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
      await MyDatabase.instance.writeAsync(() {
        MyDatabase.instance.delete<HabbitEntry>(lastEntry);
      });
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
              onPressed: () => recordEntry(widget.habbit, context),
            ),
          ],
        );
      case QuickAddButtonConfigType.add:
        return IconButton(
          icon: Icon(
            Icons.add,
            color: config.colorScheme.primary,
          ),
          onPressed: () => recordEntry(widget.habbit, context),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.habbit.id.toString()),
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

  final Habbit habbit;

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
