import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:habbit_tracker/models/drift.dart';
import '../models/core.dart';

class EntryDialogForm extends StatefulWidget {
  const EntryDialogForm({
    super.key,
    required this.habbit,
    this.creationTime,
    this.description,
  });

  final DateTime? creationTime;
  final String? description;
  final String habbit;

  @override
  State<EntryDialogForm> createState() => _EntryDialogFormState();

  static Future<void> editEntry({
    required BuildContext context,
    required String habbitId,
    required HabbitEntryData entry,
  }) async {
    final editedData = await showDialog<HabbitEntryCompanion>(
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
      (MyDatabase.instance.update(MyDatabase.instance.habbitEntry)
            ..where((tbl) => tbl.id.equals(entry.id)))
          .write(editedData);
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
            selectedDate: _selectedDate,
            onDateSelected: (DateTime value) {
              setState(() {
                _selectedDate = value;
              });
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
            Navigator.of(context).pop<HabbitEntryCompanion>(
              HabbitEntryCompanion(
                creationTime: drift.Value(_selectedDate),
                description: drift.Value(_descriptionFieldController.text),
                habbit: drift.Value(widget.habbit),
              ),
            );
          },
          child: const Text("Submit"),
        )
      ],
    );
  }
}
