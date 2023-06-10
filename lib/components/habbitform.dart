import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';

import '../models/config.dart';
import '../models/core.dart';
import '../models/drift.dart';

class HabbitDialogForm extends StatefulWidget {
  const HabbitDialogForm({
    super.key,
    this.name,
    this.description,
    this.config,
  });

  final String? name;
  final String? description;
  final String? config;

  @override
  State<HabbitDialogForm> createState() => _HabbitDialogFormState();

  static Future<void> editEntry({
    required BuildContext context,
    required String habbitId,
    required HabbitData? habbit,
  }) async {
    if (habbit == null) {
      throw StateError("habbit should not be null");
    }
    final editedData = await showDialog<HabbitCompanion>(
      context: context,
      builder: (BuildContext context) {
        return HabbitDialogForm(
          name: habbit.name,
          description: habbit.description,
          config: habbit.config,
        );
      },
    );
    if (editedData != null) {
      (MyDatabase.instance.update(MyDatabase.instance.habbit)
            ..where((tbl) => tbl.id.equals(habbitId)))
          .write(editedData);
    }
  }
}

class _HabbitDialogFormState extends State<HabbitDialogForm> {
  final TextEditingController _nameFieldController = TextEditingController();
  final TextEditingController _descriptionFieldController =
      TextEditingController();
  HabbitConfig _habbitConfig = HabbitConfig.positive;

  @override
  void initState() {
    _nameFieldController.text = widget.name ?? "";
    _descriptionFieldController.text = widget.description ?? "";
    _habbitConfig = HabbitConfig.getConfig(widget.config);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _habbitConfig.getThemeData(context),
      child: AlertDialog(
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
            DropdownButton<HabbitConfig>(
              isExpanded: true,
              value: _habbitConfig,
              items: HabbitConfig.values
                  .map(
                    (e) => DropdownMenuItem<HabbitConfig>(
                      value: e,
                      child: Text(e.name),
                    ),
                  )
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  if (newValue != null) {
                    _habbitConfig = newValue;
                  }
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
              Navigator.of(context).pop<HabbitCompanion>(
                HabbitCompanion(
                  name: drift.Value(_nameFieldController.text),
                  description: drift.Value(_descriptionFieldController.text),
                  config: drift.Value(_habbitConfig.code),
                ),
              );
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }
}
