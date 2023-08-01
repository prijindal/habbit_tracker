import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:quick_actions/quick_actions.dart';

import '../components/habbitform.dart';
import '../components/habbittile.dart';
import '../helpers/entry.dart';
import '../helpers/logger.dart';
import '../helpers/sync.dart';
import '../models/core.dart';
import '../models/drift.dart';
import '../pages/habbit.dart';
import '../pages/login.dart';
import '../pages/profile.dart';

const mediaBreakpoint = 700;

const addHabbitShortcut = "add_habbit";

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<HabbitData>? _habbits;
  StreamSubscription<List<HabbitData>>? _subscription;
  int selectedHabbitIndex = 0;
  bool _showHidden = false;
  final QuickActions quickActions = const QuickActions();

  @override
  void initState() {
    _addWatcher();
    super.initState();
    Timer(
      const Duration(seconds: 5),
      _checkLoginAndSyncDb,
    );
    _addQuickActions();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _syncDb() async {
    try {
      await syncDb();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sync successfully"),
          ),
        );
      }
    } catch (e, stack) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              parseErrorToString(e, stack, "Error while syncing"),
            ),
          ),
        );
      }
    }
  }

  Future<void> _checkLoginAndSyncDb() async {
    final isInitialized = isFirebaseInitialized();
    if (isInitialized) {
      final user = await getUser();
      if (user != null) {
        await _syncDb();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Please login to allow sync"),
              action: SnackBarAction(
                label: "Login",
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                  await _syncDb();
                },
              ),
            ),
          );
        }
      }
    }
  }

  void _quickActionHandler(String type) async {
    if (type.startsWith("$addHabbitShortcut:")) {
      final habbitId = type.split("$addHabbitShortcut:")[1];
      final habbit = await ((MyDatabase.instance.habbit.select())
            ..where((u) => u.id.equals(habbitId)))
          .getSingleOrNull();
      if (habbit != null && context.mounted) {
        await recordEntry(
          habbit,
          context,
          snackBarDuration: const Duration(seconds: 3),
        );
        AppLogger.instance.d("Added Habbit $habbitId");
      }
    }
  }

  void _handleQuickActions() {
    quickActions.initialize((type) async {
      EasyThrottle.throttle(
        "quick-action-handler",
        const Duration(seconds: 10),
        () => _quickActionHandler(type),
      );
    });
  }

  Future<void> _addQuickActions() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return;
    }
    _handleQuickActions();
    final count = MyDatabase.instance.habbitEntry.id.count();
    final query = (MyDatabase.instance.habbitEntry.selectOnly())
      ..addColumns([MyDatabase.instance.habbitEntry.habbit, count])
      ..groupBy([MyDatabase.instance.habbitEntry.habbit])
      ..orderBy(
        [
          OrderingTerm(
            expression: count,
            mode: OrderingMode.desc,
          ),
        ],
      )
      ..limit(3);
    final results = await query.get();
    final List<String> habbitIds = [];
    for (final result in results) {
      final habbitId = result.read(MyDatabase.instance.habbitEntry.habbit);
      if (habbitId != null) {
        habbitIds.add(habbitId);
      }
    }
    final habbits = await ((MyDatabase.instance.habbit.select())
          ..where((tbl) => tbl.id.isIn(habbitIds)))
        .get();
    final List<ShortcutItem> shortcuts = [];
    for (final habbit in habbits) {
      final type = "$addHabbitShortcut:${habbit.id}";
      final localizedTitle = "Add ${habbit.name}";
      shortcuts.add(ShortcutItem(type: type, localizedTitle: localizedTitle));
    }
    quickActions.setShortcutItems(shortcuts);
  }

  void _addWatcher() {
    if (_subscription != null) {
      _subscription?.cancel();
    }
    final query = MyDatabase.instance.habbit.select();
    if (!_showHidden) {
      query.where((tbl) => tbl.hidden.equals(false));
    }
    _subscription = (query
          ..where((tbl) => tbl.deletionTime.isNull())
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
              setState(() {
                _showHidden = !_showHidden;
              });
              _addWatcher();
            },
            child: Icon(
              _showHidden ? Icons.visibility : Icons.visibility_off,
              size: 26.0,
            ),
          ),
        ),
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
      child: ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
        itemCount: _habbits != null ? _habbits!.length : 1,
        itemBuilder: (BuildContext context, int index) {
          if (_habbits == null) {
            return const Center(
              key: Key("HabbitsListLoading"),
              child: Text(
                "Loading...",
              ),
            );
          }
          if (_habbits!.isEmpty) {
            return const Center(
              key: Key("HabbitsListEmpty"),
              child: Text(
                "No Habbits added",
              ),
            );
          }
          final habbit = _habbits![index];
          return AnimationConfiguration.staggeredList(
            key: Key("AnimationConfiguration ${habbit.id}"),
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
        onReorder: (oldindex, newindex) {
          if (_habbits == null) {
            return;
          }
          if (newindex > oldindex) {
            newindex -= 1;
          }
          final items = _habbits!.removeAt(oldindex);
          _habbits!.insert(newindex, items);
          MyDatabase.instance.transaction(() async {
            for (var i = 0; i < _habbits!.length; i++) {
              var habbit = _habbits![i];
              await (MyDatabase.instance.update(MyDatabase.instance.habbit)
                    ..where(
                      (tbl) => tbl.id.equals(habbit.id),
                    ))
                  .write(
                HabbitCompanion(
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
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > mediaBreakpoint) {
            if (_habbits == null || _habbits!.isEmpty) {
              return _buildHabbitsList(false);
            }
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
            return RefreshIndicator(
              onRefresh: _checkLoginAndSyncDb,
              child: _buildHabbitsList(true),
            );
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
