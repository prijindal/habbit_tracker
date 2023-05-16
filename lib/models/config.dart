import 'package:flutter/material.dart';

class HabbitConfig {
  final String name;
  final String code;
  final ColorScheme colorScheme;

  HabbitConfig({
    required this.name,
    required this.code,
    required this.colorScheme,
  });

  static final positive = HabbitConfig(
    name: "Positive",
    code: "positive",
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.green,
      primaryColorDark: Colors.green,
    ),
  );
  static final negative = HabbitConfig(
    name: "Negative",
    code: "negative",
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.purple,
      primaryColorDark: Colors.purple,
    ),
  );

  static final values = [
    HabbitConfig.positive,
    HabbitConfig.negative,
  ];

  static HabbitConfig getConfig(String? code) => HabbitConfig.values.firstWhere(
        (element) => element.code == code,
        orElse: () => HabbitConfig.positive,
      );
}
