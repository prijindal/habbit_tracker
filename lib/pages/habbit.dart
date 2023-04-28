import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:habbit_tracker/components/habbitform.dart';
import '../components/entryform.dart';
import '../models/core.dart';
import '../models/drift.dart';
import '../components/counter.dart';
import '../components/statistics.dart';
import '../components/listentries.dart';

class HabbitPage extends StatefulWidget {
  const HabbitPage({super.key, required this.habbitId});

  final String habbitId;

  @override
  State<HabbitPage> createState() => HabbitPageState();
}

class HabbitPageState extends State<HabbitPage> {
  int _selectedIndex = 0;
  Widget _getWidget() {
    final List<Widget> widgetOptions = <Widget>[
      CounterSubPage(
        entries: _entries,
      ),
      StatisticsSubPage(
        entries: _entries,
      ),
      ListEntriesSubPage(
        habbit: widget.habbitId,
        entries: _entries,
      ),
    ];
    return widgetOptions.elementAt(_selectedIndex);
  }

  HabbitData? _habbit;
  List<HabbitEntryData>? _entries;
  StreamSubscription<List<HabbitData>>? _subscription;
  StreamSubscription<List<HabbitEntryData>>? _entriesSubscription;

  @override
  void initState() {
    _addWatcher();
    _addEntriesWatcher();
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _entriesSubscription?.cancel();
    super.dispose();
  }

  void _addWatcher() {
    _subscription = (MyDatabase.instance.habbit.select()
          ..where((tbl) => tbl.id.equals(widget.habbitId))
          ..limit(1))
        .watch()
        .listen((event) {
      setState(() {
        _habbit = event.first;
      });
    });
  }

  void _addEntriesWatcher() {
    _entriesSubscription = (MyDatabase.instance.habbitEntry.select()
          ..where((tbl) => tbl.habbit.equals(widget.habbitId))
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
        _entries = event;
      });
    });
  }

  void _recordEntry() async {
    final entries = await showDialog<HabbitEntryCompanion?>(
      context: context,
      builder: (BuildContext context) {
        return EntryDialogForm(habbit: widget.habbitId);
      },
    );
    if (entries != null) {
      await MyDatabase.instance
          .into(MyDatabase.instance.habbitEntry)
          .insert(entries);
    }
  }

  void _editHabbit() async {
    if (_habbit == null) {
      throw StateError("habbit should not be null");
    }
    final habbit = await showDialog<HabbitCompanion?>(
      context: context,
      builder: (BuildContext context) {
        return HabbitDialogForm(
          name: _habbit!.name,
          description: _habbit!.description,
        );
      },
    );
    if (habbit != null) {
      (MyDatabase.instance.update(MyDatabase.instance.habbit)
            ..where((tbl) => tbl.id.equals(widget.habbitId)))
          .write(habbit);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _habbit == null
            ? null
            : RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  text: _habbit!.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  children: <TextSpan>[
                    if (_habbit!.description != null &&
                        _habbit!.description!.isNotEmpty)
                      TextSpan(
                        text: '\n${_habbit!.description}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                  ],
                ),
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                _editHabbit();
              },
              child: const Icon(
                Icons.edit,
                size: 26.0,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: _getWidget(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recordEntry,
        tooltip: 'Entry',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
