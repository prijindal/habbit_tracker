import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

import '../components/entryform.dart';
import '../models/core.dart';
import '../models/database.dart';

void editEntry(HabbitEntry entry, BuildContext context) async {
  await EntryDialogForm.editEntry(
    context: context,
    habbitId: entry.habbit?.id,
    entry: entry,
  );
}

Future<void> recordEntry(
  Habbit habbit,
  BuildContext context, {
  Duration snackBarDuration = const Duration(milliseconds: 100),
}) async {
  final entry = HabbitEntry(
    ObjectId(),
    DateTime.now(),
    habbit: habbit,
  );

  final savedEntry = await MyDatabase.instance.writeAsync<HabbitEntry>(() {
    return MyDatabase.instance.add(entry);
  });

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: snackBarDuration,
        content: Text("New entry for ${habbit.name} saved"),
        action: SnackBarAction(
          label: "Edit",
          onPressed: () async {
            if (context.mounted) {
              editEntry(savedEntry, context);
            }
          },
        ),
      ),
    );
  }
}
