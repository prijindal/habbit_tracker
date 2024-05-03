import 'package:drift/drift.dart';
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
            Navigator.of(context).pop<bool>(false);
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            (MyDatabase.instance.update(MyDatabase.instance.habbitEntry)
                  ..where((tbl) => tbl.id.equals(entry.id)))
                .write(
              HabbitEntryCompanion(
                deletionTime: Value(
                  DateTime.now(),
                ),
              ),
            );
            if (context.mounted) {
              Navigator.of(context).pop<bool>(true);
            }
          },
          child: const Text("Yes"),
        )
      ],
    );
  }
}
