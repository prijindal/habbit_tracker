import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import '../models/core.dart';

class HabbitDialogForm extends StatefulWidget {
  const HabbitDialogForm({super.key, this.name, this.description});

  final String? name;
  final String? description;

  @override
  State<HabbitDialogForm> createState() => _HabbitDialogFormState();
}

class _HabbitDialogFormState extends State<HabbitDialogForm> {
  final TextEditingController _nameFieldController = TextEditingController();
  final TextEditingController _descriptionFieldController =
      TextEditingController();

  @override
  void initState() {
    _nameFieldController.text = widget.name ?? "";
    _descriptionFieldController.text = widget.description ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter name and description'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (value) {},
            controller: _nameFieldController,
            decoration: const InputDecoration(hintText: "Name"),
          ),
          TextField(
            onChanged: (value) {},
            controller: _descriptionFieldController,
            decoration: const InputDecoration(hintText: "Description"),
          ),
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
            Navigator.of(context).pop<HabbitCompanion>(
              HabbitCompanion(
                name: drift.Value(_nameFieldController.text),
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
