import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:relapse/models/drift.dart';

class NewRelapseDialog extends StatefulWidget {
  const NewRelapseDialog({super.key});

  @override
  State<NewRelapseDialog> createState() => _NewRelapseDialogState();
}

class _NewRelapseDialogState extends State<NewRelapseDialog> {
  final TextEditingController _descriptionFieldController =
      TextEditingController();
  DateTime _selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter time and description'),
      content: Column(
        children: [
          TextField(
            onChanged: (value) {},
            controller: _descriptionFieldController,
            decoration: const InputDecoration(hintText: "Description"),
          ),
          DateTimeField(
            decoration: const InputDecoration(
                hintText: 'Please select your birthday date and time'),
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
            Navigator.of(context).pop<RelapseCompanion>(
              RelapseCompanion(
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
