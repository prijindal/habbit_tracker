import 'package:flutter/material.dart';

import '../helpers/stats.dart';
import '../models/core.dart';
import '../models/database.dart';

class DeleteEntryDialog extends StatelessWidget {
  const DeleteEntryDialog({
    super.key,
    required this.entry,
  });

  final HabbitEntry entry;

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
            await MyDatabase.instance.writeAsync(() {
              entry.deletionTime = DateTime.now();
            });
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
