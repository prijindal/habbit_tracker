import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../components/newrelapse.dart';
import '../models/drift.dart';
import '../components/appbar.dart';
import '../components/counter.dart';
import '../components/statistics.dart';
import '../components/listrelapses.dart';

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
        relapses: _relapses,
      ),
      StatisticsSubPage(
        relapses: _relapses,
      ),
      ListRelapsesSubPage(
        relapses: _relapses,
      ),
    ];
    return widgetOptions.elementAt(_selectedIndex);
  }

  List<RelapseData>? _relapses;
  StreamSubscription<List<RelapseData>>? _subscription;

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
    _subscription = (MyDatabase.instance.relapse.select()
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
        _relapses = event;
      });
    });
  }

  void _recordRelapse() async {
    final relapse = await showDialog<RelapseCompanion?>(
      context: context,
      builder: (BuildContext context) {
        return const NewRelapseDialog();
      },
    );
    if (relapse != null) {
      await MyDatabase.instance
          .into(MyDatabase.instance.relapse)
          .insert(relapse);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
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
        onPressed: _recordRelapse,
        tooltip: 'Relapse',
        child: const Icon(Icons.thumb_down),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
