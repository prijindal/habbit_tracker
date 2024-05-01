import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

import '../models/config.dart';
import '../models/core.dart';
import '../models/database.dart';

class HabbitDialogForm extends StatefulWidget {
  const HabbitDialogForm({
    super.key,
    this.name,
    this.description,
    this.hidden,
    this.config,
  });

  final String? name;
  final String? description;
  final String? config;
  final bool? hidden;

  @override
  State<HabbitDialogForm> createState() => _HabbitDialogFormState();

  static Future<void> editEntry({
    required BuildContext context,
    required Habbit? habbit,
  }) async {
    final _habbit = habbit;
    if (_habbit == null) {
      throw StateError("habbit should not be null");
    }
    final editedData = await showDialog<Habbit>(
      context: context,
      builder: (BuildContext context) {
        return HabbitDialogForm(
          name: _habbit.name,
          description: _habbit.description,
          config: _habbit.config,
          hidden: _habbit.hidden,
        );
      },
    );
    if (editedData != null) {
      editedData.id = _habbit.id;
      MyDatabase.instance.writeAsync(() {
        MyDatabase.instance.add<Habbit>(editedData, update: true);
      });
    }
  }
}

class _HabbitDialogFormState extends State<HabbitDialogForm> {
  final TextEditingController _nameFieldController = TextEditingController();
  final TextEditingController _descriptionFieldController =
      TextEditingController();
  HabbitConfig _habbitConfig = HabbitConfig.positive;
  bool _hidden = false;

  @override
  void initState() {
    _nameFieldController.text = widget.name ?? "";
    _descriptionFieldController.text = widget.description ?? "";
    _habbitConfig = HabbitConfig.getConfig(widget.config);
    _hidden = widget.hidden ?? false;
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
            CheckboxListTile(
              onChanged: (value) {
                setState(() {
                  _hidden = value ?? false;
                });
              },
              value: _hidden,
              title: const Text("Hidden"),
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
              Navigator.of(context).pop<Habbit>(
                Habbit(
                  ObjectId(),
                  _nameFieldController.text,
                  DateTime.now(),
                  description: _descriptionFieldController.text,
                  config: _habbitConfig.code,
                  hidden: _hidden,
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
