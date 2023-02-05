import 'package:flutter/material.dart';
import '../models/core.dart';
import '../models/drift.dart';

class DeleteHabbitDialog extends StatelessWidget {
  const DeleteHabbitDialog({
    super.key,
    required this.habbit,
  });

  final HabbitData habbit;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Are you sure you want to delete"),
      content: Text(habbit.name),
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
                  ..where((tbl) => tbl.habbit.equals(habbit.id)))
                .go();
            (MyDatabase.instance.delete(MyDatabase.instance.habbit)
                  ..where((tbl) => tbl.id.equals(habbit.id)))
                .go();
            Navigator.of(context).pop();
          },
          child: const Text("Yes"),
        )
      ],
    );
  }
}
