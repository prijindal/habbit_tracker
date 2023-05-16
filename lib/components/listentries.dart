import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:habbit_tracker/models/theme.dart';
import 'entryform.dart';
import '../components/deleteentrydialog.dart';
import '../helpers/stats.dart';
import '../models/core.dart';
import '../models/drift.dart';

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

class HabbitEntryTile extends StatelessWidget {
  const HabbitEntryTile({
    super.key,
    required this.entry,
    required this.habbit,
  });

  final HabbitEntryData entry;
  final String habbit;

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return DeleteEntryDialog(
          entry: entry,
        );
      },
    );
  }

  void _editEntry(BuildContext context) async {
    await EntryDialogForm.editEntry(
      context: context,
      habbitId: habbit,
      entry: entry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      background: deleteDismissible,
      secondaryBackground: deleteDismissible,
      confirmDismiss: (direction) => _confirmDelete(context),
      child: ListTile(
        title: Text(formatDate(entry.creationTime)),
        subtitle: (entry.description == null || entry.description!.isEmpty)
            ? null
            : Text(entry.description!),
        onTap: () => _editEntry(context),
      ),
    );
  }
}
