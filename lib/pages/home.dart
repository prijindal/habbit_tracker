import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:habbit_tracker/components/habbittile.dart';
import '../components/habbitform.dart';
import '../models/core.dart';
import '../models/drift.dart';
import '../components/appbar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<HabbitData>? _habbits;
  StreamSubscription<List<HabbitData>>? _subscription;

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
    _subscription = (MyDatabase.instance.habbit.select()
          ..orderBy(
            [
              (t) => OrderingTerm(
                    expression: t.creationTime,
                    mode: OrderingMode.desc,
                  ),
            ],
          ))
        .watch()
        .listen((event) {
      setState(() {
        _habbits = event;
      });
    });
  }

  void _recordHabbit() async {
    final entries = await showDialog<HabbitCompanion?>(
      context: context,
      builder: (BuildContext context) {
        return const HabbitDialogForm();
      },
    );
    if (entries != null) {
      await MyDatabase.instance
          .into(MyDatabase.instance.habbit)
          .insert(entries);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        context: context,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
        itemCount: _habbits != null ? _habbits!.length : 1,
        itemBuilder: (BuildContext context, int index) {
          if (_habbits == null) {
            return const Text("Loading...");
          }
          final habbit = _habbits![index];
          return HabbitTile(habbit: habbit);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recordHabbit,
        tooltip: 'Habbit',
        child: const Icon(Icons.add),
      ),
    );
  }
}
