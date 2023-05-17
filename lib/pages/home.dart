import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:habbit_tracker/pages/habbit.dart';
import '../pages/profile.dart';
import '../components/habbittile.dart';
import '../components/habbitform.dart';
import '../models/core.dart';
import '../models/drift.dart';

const mediaBreakpoint = 700;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<HabbitData>? _habbits;
  StreamSubscription<List<HabbitData>>? _subscription;
  int selectedHabbitIndex = 0;

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

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Habbits"),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            child: const Icon(
              Icons.person,
              size: 26.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFab() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > mediaBreakpoint) {
          return FloatingActionButton.extended(
            onPressed: _recordHabbit,
            tooltip: 'Habbit',
            icon: const Icon(Icons.add),
            label: const Text("New Habbit"),
          );
        } else {
          return FloatingActionButton(
            onPressed: _recordHabbit,
            tooltip: 'Habbit',
            child: const Icon(Icons.add),
          );
        }
      },
    );
  }

  Widget _buildHabbitsList(bool container) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
        itemCount: _habbits != null ? _habbits!.length : 1,
        itemBuilder: (BuildContext context, int index) {
          if (_habbits == null) {
            return const Text("Loading...");
          }
          final habbit = _habbits![index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: container
                    ? HabbitContainerTile(
                        key: Key("${habbit.id}-tile"),
                        habbit: habbit,
                      )
                    : HabbitTile(
                        key: Key("${habbit.id}-tile"),
                        habbit: habbit,
                        selected: selectedHabbitIndex == index,
                        onTap: () {
                          setState(() {
                            selectedHabbitIndex = index;
                          });
                        },
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > mediaBreakpoint) {
            return Flex(
              direction: Axis.horizontal,
              children: [
                SizedBox(
                  width: mediaBreakpoint / 2,
                  child: _buildHabbitsList(false),
                ),
                if (_habbits != null && selectedHabbitIndex < _habbits!.length)
                  Expanded(
                    child: HabbitPage(
                      key: Key(
                        "HabbitPage${_habbits![selectedHabbitIndex].id}",
                      ),
                      habbitId: _habbits![selectedHabbitIndex].id,
                      primary: false,
                    ),
                  ),
              ],
            );
          } else {
            return _buildHabbitsList(true);
          }
        },
      ),
      floatingActionButtonLocation:
          MediaQuery.of(context).size.width > mediaBreakpoint
              ? FloatingActionButtonLocation.startFloat
              : FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFab(),
    );
  }
}
