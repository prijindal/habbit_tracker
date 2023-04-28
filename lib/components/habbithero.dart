import 'package:flutter/material.dart';
import '../models/core.dart';

class HabbitTitleHero extends StatelessWidget {
  const HabbitTitleHero({super.key, required this.habbit});

  final HabbitData habbit;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: habbit.id,
      child: Material(
        color: Colors.transparent,
        child: Text(habbit.name),
      ),
    );
  }
}
