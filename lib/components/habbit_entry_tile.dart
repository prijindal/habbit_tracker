import 'package:flutter/material.dart';

import '../helpers/stats.dart';
import '../models/core.dart';
import '../models/theme.dart';
import 'deleteentrydialog.dart';
import 'entryform.dart';

class HabbitEntryTile extends StatelessWidget {
  const HabbitEntryTile({
    super.key,
    required this.entry,
    required this.habbit,
  });

  final HabbitEntryData entry;
  final String habbit;

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return DeleteEntryDialog(
          entry: entry,
        );
      },
    );
  }

  void _editEntry(BuildContext context) async {
    await EntryDialogForm.editEntry(
      context: context,
      habbitId: habbit,
      entry: entry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      background: deleteDismissible,
      secondaryBackground: deleteDismissible,
      confirmDismiss: (direction) => _confirmDelete(context),
      child: ListTile(
        title: Text(formatDate(entry.creationTime)),
        subtitle: (entry.description == null || entry.description!.isEmpty)
            ? null
            : Text(entry.description!),
        onTap: () => _editEntry(context),
      ),
    );
  }
}
