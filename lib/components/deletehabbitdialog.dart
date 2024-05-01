import 'package:flutter/material.dart';

import '../models/core.dart';
import '../models/database.dart';

class DeleteHabbitDialog extends StatelessWidget {
  const DeleteHabbitDialog({
    super.key,
    required this.habbit,
  });

  final Habbit habbit;

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
          onPressed: () async {
            final entries = MyDatabase.instance
                .query<HabbitEntry>(r'habbit.id == $0', [habbit.id]);

            await MyDatabase.instance.writeAsync(() {
              for (var element in entries) {
                element.deletionTime = DateTime.now();
              }
              habbit.deletionTime = DateTime.now();
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
