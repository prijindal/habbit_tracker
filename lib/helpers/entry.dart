import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../components/entryform.dart';
import '../models/core.dart';
import '../models/drift.dart';

void editEntry(HabbitEntryData entry, BuildContext context) async {
  await EntryDialogForm.editEntry(
    context: context,
    habbitId: entry.habbit,
    entry: entry,
  );
}

Future<void> recordEntry(
  HabbitData habbit,
  BuildContext context, {
  Duration snackBarDuration = const Duration(milliseconds: 100),
}) async {
  final entry = HabbitEntryCompanion(
    creationTime: Value(DateTime.now()),
    habbit: Value(habbit.id),
  );
  final savedEntryId = await MyDatabase.instance
      .into(MyDatabase.instance.habbitEntry)
      .insert(entry);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: snackBarDuration,
        content: Text("New entry for ${habbit.name} saved"),
        action: SnackBarAction(
          label: "Edit",
          onPressed: () async {
            final savedEntry = await (MyDatabase.instance.habbitEntry.select()
                  ..where(
                    (tbl) => tbl.rowId.equals(savedEntryId),
                  )
                  ..where((tbl) => tbl.deletionTime.isNull()))
                .getSingle();
            if (context.mounted) {
              editEntry(savedEntry, context);
            }
          },
        ),
      ),
    );
  }
}
