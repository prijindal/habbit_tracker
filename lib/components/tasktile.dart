import 'dart:async';

import 'package:flutter/material.dart';

import '../components/deletetaskdialog.dart';
import '../components/taskform.dart';
import '../models/core.dart';
import '../models/theme.dart';

class TaskTile extends StatefulWidget {
  const TaskTile({
    super.key,
    required this.task,
    this.onTap,
    this.selected = false,
  });

  final TaskData task;
  final GestureTapCallback? onTap;
  final bool selected;

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  Future<bool?> _confirmDelete() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return DeleteTaskDialog(
          task: widget.task,
        );
      },
    );
  }

  Future<bool> _editTask() async {
    await TaskDialogForm.editEntry(
      context: context,
      taskId: widget.task.id,
      task: widget.task,
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.task.id),
      confirmDismiss: (direction) {
        if (direction == DismissDirection.startToEnd) {
          return _confirmDelete();
        } else {
          return _editTask();
        }
      },
      background: deleteDismissible,
      secondaryBackground: editDismissible,
      child: ListTile(
        leading: TaskItemToggle(
          task: widget.task,
        ),
        selected: widget.selected,
        title: Text(widget.task.name),
        onTap: widget.onTap,
      ),
    );
  }
}

class TaskItemToggle extends StatelessWidget {
  const TaskItemToggle({
    super.key,
    required this.task,
  });
  final TaskData task;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {},
        child: Container(
          constraints: const BoxConstraints.expand(
            width: 48,
            height: 48,
          ),
          child: Center(
            child: AnimatedContainer(
              constraints: const BoxConstraints(
                maxWidth: 20,
                maxHeight: 20,
              ),
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: task.completionTime == null
                    ? Theme.of(context).scaffoldBackgroundColor
                    : Theme.of(context).primaryColor,
                border: Border.all(
                  width: 2,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(18)),
              ),
            ),
          ),
        ),
      );
}
