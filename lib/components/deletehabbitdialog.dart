import 'package:drift/drift.dart';
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
            Navigator.of(context).pop<bool>(false);
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            (MyDatabase.instance.update(MyDatabase.instance.habbitEntry)
                  ..where((tbl) => tbl.habbit.equals(habbit.id)))
                .write(
              HabbitEntryCompanion(
                deletionTime: Value(
                  DateTime.now(),
                ),
              ),
            );
            (MyDatabase.instance.update(MyDatabase.instance.habbit)
                  ..where((tbl) => tbl.id.equals(habbit.id)))
                .write(
              HabbitCompanion(
                deletionTime: Value(
                  DateTime.now(),
                ),
              ),
            );
            Navigator.of(context).pop<bool>(true);
          },
          child: const Text("Yes"),
        )
      ],
    );
  }
}
