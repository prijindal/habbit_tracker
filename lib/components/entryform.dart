import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

import '../models/core.dart';
import '../models/database.dart';

class EntryDialogForm extends StatefulWidget {
  const EntryDialogForm({
    super.key,
    required this.habbit,
    this.creationTime,
    this.description,
  });

  final DateTime? creationTime;
  final String? description;
  final ObjectId? habbit;

  @override
  State<EntryDialogForm> createState() => _EntryDialogFormState();

  static Future<void> editEntry({
    required BuildContext context,
    required ObjectId? habbitId,
    required HabbitEntry entry,
  }) async {
    final editedData = await showDialog<HabbitEntry>(
      context: context,
      builder: (BuildContext context) {
        return EntryDialogForm(
          habbit: habbitId,
          creationTime: entry.creationTime,
          description: entry.description,
        );
      },
    );
    if (editedData != null) {
      editedData.id = entry.id;
      await MyDatabase.instance.writeAsync(
        () => MyDatabase.instance.add(editedData, update: true),
      );
    }
  }
}

class _EntryDialogFormState extends State<EntryDialogForm> {
  final TextEditingController _descriptionFieldController =
      TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    _descriptionFieldController.text = widget.description ?? "";
    _selectedDate = widget.creationTime ?? DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter time and description'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (value) {},
            controller: _descriptionFieldController,
            decoration: const InputDecoration(hintText: "Description"),
          ),
          DateTimeField(
            decoration:
                const InputDecoration(hintText: 'Please select date and time'),
            value: _selectedDate,
            onChanged: (DateTime? value) {
              if (value != null) {
                setState(() {
                  _selectedDate = value;
                });
              }
            },
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop<HabbitEntry>(
              HabbitEntry(
                ObjectId(),
                _selectedDate,
                description: _descriptionFieldController.text,
                habbit: MyDatabase.instance.find(widget.habbit),
              ),
            );
          },
          child: const Text("Submit"),
        )
      ],
    );
  }
}
