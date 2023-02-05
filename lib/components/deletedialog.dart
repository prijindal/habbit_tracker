import 'package:flutter/material.dart';
import '../helpers/stats.dart';
import '../models/core.dart';
import '../models/drift.dart';

class DeleteEntryDialog extends StatelessWidget {
  const DeleteEntryDialog({
    super.key,
    required this.entry,
  });

  final HabbitEntryData entry;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Are you sure you want to delete"),
      content: Text(formatDate(entry.creationTime)),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            (MyDatabase.instance.delete(MyDatabase.instance.habbitEntry)
                  ..where((tbl) => tbl.id.equals(entry.id)))
                .go();
            Navigator.of(context).pop();
          },
          child: const Text("Yes"),
        )
      ],
    );
  }
}
