import 'package:flutter/material.dart';
import '../models/core.dart';
import '../models/drift.dart';

class DeleteTaskDialog extends StatelessWidget {
  const DeleteTaskDialog({
    super.key,
    required this.task,
  });

  final TaskData task;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Are you sure you want to delete"),
      content: Text(task.name),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop<bool>(false);
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            (MyDatabase.instance.delete(MyDatabase.instance.task)
                  ..where((tbl) => tbl.id.equals(task.id)))
                .go();
            Navigator.of(context).pop<bool>(true);
          },
          child: const Text("Yes"),
        )
      ],
    );
  }
}
