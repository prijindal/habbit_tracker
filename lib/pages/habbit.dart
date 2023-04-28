import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../components/habbithero.dart';
import '../components/entryform.dart';
import '../models/core.dart';
import '../models/drift.dart';
import '../components/appbar.dart';
import '../components/counter.dart';
import '../components/statistics.dart';
import '../components/listentries.dart';

class HabbitPage extends StatefulWidget {
  const HabbitPage({super.key, required this.habbit});

  final HabbitData habbit;

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
        habbit: widget.habbit,
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
          ..where((tbl) => tbl.habbit.equals(widget.habbit.id))
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
        return EntryDialogForm(habbit: widget.habbit.id);
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
        title: HabbitTitleHero(habbit: widget.habbit),
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
