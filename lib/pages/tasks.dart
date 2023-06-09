import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../models/core.dart';
import '../components/taskform.dart';
import '../components/tasktile.dart';
import '../helpers/constants.dart';
import '../models/drift.dart';

class TodosList extends StatefulWidget {
  const TodosList({super.key});

  @override
  State<TodosList> createState() => _TodosListState();
}

class _TodosListState extends State<TodosList> {
  List<TaskData>? _tasks;
  StreamSubscription<List<TaskData>>? _subscription;
  int selectedTaskIndex = 0;

  @override
  void initState() {
    _addWatcher();
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _addWatcher() {
    _subscription = (MyDatabase.instance.task.select()
          ..orderBy(
            [
              (t) => OrderingTerm(
                    expression: t.order,
                    mode: OrderingMode.asc,
                  ),
              (t) => OrderingTerm(
                    expression: t.creationTime,
                    mode: OrderingMode.desc,
                  ),
            ],
          ))
        .watch()
        .listen((event) {
      setState(() {
        _tasks = event;
      });
    });
  }

  void _recordTask(BuildContext context) async {
    final entries = await showDialog<TaskCompanion?>(
      context: context,
      builder: (BuildContext context) {
        return const TaskDialogForm();
      },
    );
    if (entries != null) {
      await MyDatabase.instance.into(MyDatabase.instance.task).insert(entries);
    }
  }

  Widget _buildFab() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > mediaBreakpoint) {
          return FloatingActionButton.extended(
            onPressed: () => _recordTask(context),
            tooltip: "Task",
            icon: const Icon(Icons.add),
            label: const Text("New Task"),
          );
        } else {
          return FloatingActionButton(
            onPressed: () => _recordTask(context),
            tooltip: "Task",
            child: const Icon(Icons.add),
          );
        }
      },
    );
  }

  Widget _buildTasksList() {
    return AnimationLimiter(
      child: ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
        itemCount: _tasks != null ? _tasks!.length : 1,
        itemBuilder: (BuildContext context, int index) {
          if (_tasks == null) {
            return const Center(
              key: Key("TasksListLoading"),
              child: Text(
                "Loading...",
              ),
            );
          }
          final task = _tasks![index];
          return AnimationConfiguration.staggeredList(
            key: Key("AnimationConfiguration Tasks ${task.id}"),
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: TaskTile(
                  key: Key("${task.id}-tile"),
                  task: task,
                  selected: selectedTaskIndex == index,
                  onTap: () {
                    setState(() {
                      selectedTaskIndex = index;
                    });
                  },
                ),
              ),
            ),
          );
        },
        onReorder: (oldindex, newindex) {
          if (_tasks == null) {
            return;
          }
          if (newindex > oldindex) {
            newindex -= 1;
          }
          final items = _tasks!.removeAt(oldindex);
          _tasks!.insert(newindex, items);
          MyDatabase.instance.transaction(() async {
            for (var i = 0; i < _tasks!.length; i++) {
              var task = _tasks![i];
              await (MyDatabase.instance.update(MyDatabase.instance.task)
                    ..where(
                      (tbl) => tbl.id.equals(task.id),
                    ))
                  .write(
                TaskCompanion(
                  order: Value(i),
                ),
              );
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      body: _buildTasksList(),
      floatingActionButtonLocation:
          MediaQuery.of(context).size.width > mediaBreakpoint
              ? FloatingActionButtonLocation.startFloat
              : FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFab(),
    );
  }
}
