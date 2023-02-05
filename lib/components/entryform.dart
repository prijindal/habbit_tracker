import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import '../models/core.dart';

class EntryDialogForm extends StatefulWidget {
  const EntryDialogForm({super.key, this.creationTime, this.description});

  final DateTime? creationTime;
  final String? description;

  @override
  State<EntryDialogForm> createState() => _EntryDialogFormState();
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
              ),
            );
          },
          child: const Text("Submit"),
        )
      ],
    );
  }
}
