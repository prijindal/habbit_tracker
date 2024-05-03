import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../models/core.dart';
import 'habbit_entry_tile.dart';

class ListEntriesSubPage extends StatefulWidget {
  const ListEntriesSubPage({
    super.key,
    required this.habbit,
    required this.entries,
  });

  final String habbit;
  final List<HabbitEntryData>? entries;

  @override
  State<ListEntriesSubPage> createState() => _ListEntriesSubPageState();
}

class _ListEntriesSubPageState extends State<ListEntriesSubPage> {
  @override
  Widget build(BuildContext context) {
    final entries = widget.entries;
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
        itemCount: entries != null ? entries.length : 1,
        itemBuilder: (BuildContext context, int index) {
          if (entries == null) {
            return const Text("Loading...");
          }
          final entry = entries[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: HabbitEntryTile(
                  habbit: widget.habbit,
                  entry: entry,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
