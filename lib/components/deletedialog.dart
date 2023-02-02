import 'package:flutter/material.dart';
import '../helpers/stats.dart';
import '../models/core.dart';
import '../models/drift.dart';

class DeleteRelapseDialog extends StatelessWidget {
  const DeleteRelapseDialog({
    super.key,
    required this.relapse,
  });

  final RelapseData relapse;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Are you sure you want to delete"),
      content: Text(formatDate(relapse.creationTime)),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            (MyDatabase.instance.delete(MyDatabase.instance.relapse)
                  ..where((tbl) => tbl.id.equals(relapse.id)))
                .go();
            Navigator.of(context).pop();
          },
          child: const Text("Yes"),
        )
      ],
    );
  }
}
