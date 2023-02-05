import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../components/entryform.dart';
import '../models/core.dart';
import '../models/drift.dart';
import '../components/appbar.dart';
import '../components/counter.dart';
import '../components/statistics.dart';
import '../components/listentries.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
        entries: _entries,
      ),
    ];
    return widgetOptions.elementAt(_selectedIndex);
  }

  List<HabbitEntryData>? _entries;
  StreamSubscription<List<HabbitEntryData>>? _subscription;

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
    _subscription = (MyDatabase.instance.habbitEntry.select()
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
        return const EntryDialogForm();
      },
    );
    if (entries != null) {
      await MyDatabase.instance
          .into(MyDatabase.instance.habbitEntry)
          .insert(entries);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        context: context,
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
        child: const Icon(Icons.thumb_down),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
