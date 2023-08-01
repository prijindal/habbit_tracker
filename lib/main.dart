import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';

import './firebase_options.dart';
import './helpers/logger.dart';
import './models/theme.dart';
import './pages/home.dart';
import '../helpers/entry.dart';
import '../models/drift.dart';

void main() async {
  runApp(
    const MyApp(),
  );
  try {
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stack) {
    AppLogger.instance.e(
      "Firebase cannot be initialized",
      error: e,
      stackTrace: stack,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  final QuickActions quickActions = const QuickActions();

  void _handleQuickActions(BuildContext context) {
    quickActions.initialize((type) async {
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
    });
  }

  Future<void> _addQuickActions(BuildContext context) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return;
    }
    _handleQuickActions(context);
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

  @override
  Widget build(BuildContext context) {
    Timer(
      const Duration(seconds: 3),
      () => _addQuickActions(context),
    );
    return ChangeNotifierProvider<ThemeModeNotifier>(
      child: const MyMaterialApp(),
      create: (context) => ThemeModeNotifier(ThemeMode.system),
    );
  }
}

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeModeNotifier>(context);
    AppLogger.instance.d("Building MyApp");
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeNotifier.getTheme(),
      home: const MyHomePage(),
    );
  }
}
