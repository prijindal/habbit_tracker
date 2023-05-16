import 'package:flutter/material.dart';

class HabbitConfig {
  final String name;
  final String code;
  final ColorScheme colorScheme;

  final QuickAddButtonConfigType quickAddButtonConfigType;
  final QuickSubtitleType quickSubtitleType;

  static final positive = HabbitConfig(
    name: "Positive Habbit",
    code: "positive_habbit",
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.lightGreen,
      primaryColorDark: Colors.green,
    ),
    quickAddButtonConfigType: QuickAddButtonConfigType.addSubtract,
    quickSubtitleType: QuickSubtitleType.todayCount,
  );
  static final negative = HabbitConfig(
    name: "Negative Habbit",
    code: "negative_habbit",
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.purple,
      primaryColorDark: Colors.deepPurple,
    ),
    quickAddButtonConfigType: QuickAddButtonConfigType.add,
    quickSubtitleType: QuickSubtitleType.currentStreak,
  );

  static final values = [
    HabbitConfig.positive,
    HabbitConfig.negative,
  ];

  HabbitConfig({
    required this.name,
    required this.code,
    required this.colorScheme,
    required this.quickAddButtonConfigType,
    required this.quickSubtitleType,
  });

  static HabbitConfig getConfig(String? code) => HabbitConfig.values.firstWhere(
        (element) => element.code == code,
        orElse: () => HabbitConfig.positive,
      );

  ThemeData getThemeData(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = this.colorScheme;

    return theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        primary: colorScheme.primary,
        primaryContainer: colorScheme.primaryContainer,
      ),
    );
  }
}

enum QuickAddButtonConfigType {
  addSubtract,
  add,
}

enum QuickSubtitleType {
  currentStreak,
  todayCount,
}
