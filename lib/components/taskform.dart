import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';

import '../models/drift.dart';
import '../models/core.dart';

class TaskDialogForm extends StatefulWidget {
  const TaskDialogForm({
    super.key,
    this.name,
    this.description,
  });

  final String? name;
  final String? description;

  @override
  State<TaskDialogForm> createState() => _TaskDialogFormState();

  static Future<void> editEntry({
    required BuildContext context,
    required String taskId,
    required TaskData? task,
  }) async {
    if (task == null) {
      throw StateError("task should not be null");
    }
    final editedData = await showDialog<TaskCompanion>(
      context: context,
      builder: (BuildContext context) {
        return TaskDialogForm(
          name: task.name,
          description: task.description,
        );
      },
    );
    if (editedData != null) {
      (MyDatabase.instance.update(MyDatabase.instance.task)
            ..where((tbl) => tbl.id.equals(taskId)))
          .write(editedData);
    }
  }
}

class _TaskDialogFormState extends State<TaskDialogForm> {
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
            Navigator.of(context).pop<TaskCompanion>(
              TaskCompanion(
                name: drift.Value(_nameFieldController.text),
                description: drift.Value(_descriptionFieldController.text),
              ),
            );
          },
          child: const Text("Save"),
        )
      ],
    );
  }
}
