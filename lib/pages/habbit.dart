import 'dart:async';

import 'package:animations/animations.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:habbit_tracker/components/habbitform.dart';
import 'package:habbit_tracker/models/config.dart';
import '../components/entryform.dart';
import '../models/core.dart';
import '../models/drift.dart';
import '../components/counter.dart';
import '../components/statistics.dart';
import '../components/listentries.dart';

class HabbitPage extends StatefulWidget {
  const HabbitPage({super.key, required this.habbitId, this.primary = true});

  final String habbitId;
  final bool primary;

  @override
  State<HabbitPage> createState() => HabbitPageState();
}

class HabbitPageState extends State<HabbitPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    _addWatcher();
    _addEntriesWatcher();
    super.initState();
  }

  HabbitData? _habbit;
  List<HabbitEntryData>? _entries;
  StreamSubscription<List<HabbitData>>? _subscription;
  StreamSubscription<List<HabbitEntryData>>? _entriesSubscription;

  Widget _getWidget() {
    final List<Widget> widgetOptions = <Widget>[
      CounterSubPage(
        habbit: _habbit,
        entries: _entries,
      ),
      StatisticsSubPage(
        habbit: _habbit,
        entries: _entries,
      ),
      ListEntriesSubPage(
        habbit: widget.habbitId,
        entries: _entries,
      ),
    ];

    return widgetOptions.elementAt(_selectedIndex);
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
    await HabbitDialogForm.editEntry(
      context: context,
      habbitId: widget.habbitId,
      habbit: _habbit,
    );
  }

  ThemeData? _getThemeData() {
    if (_habbit == null) {
      return null;
    }
    return HabbitConfig.getConfig(_habbit!.config).getThemeData(context);
  }

  Widget _buildPage() {
    return Scaffold(
      primary: widget.primary,
      appBar: widget.primary == true
          ? AppBar(
              title: _habbit == null ? null : Text(_habbit!.name),
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
            )
          : null,
      body: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: _getWidget(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        useLegacyColorScheme: false,
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
      floatingActionButton: widget.primary == true
          ? FloatingActionButton(
              onPressed: _recordEntry,
              tooltip: 'Entry',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _entriesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: _getThemeData() ?? Theme.of(context),
        child: _buildPage(),
      );
}
