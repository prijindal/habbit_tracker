import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/logger.dart';
import '../models/theme.dart';
import './pages/home.dart';

void main() => runApp(
      ChangeNotifierProvider<ThemeModeNotifier>(
        child: const MyApp(),
        create: (context) => ThemeModeNotifier(ThemeMode.system),
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
