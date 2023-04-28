import 'package:flutter/material.dart';
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
  Future<bool?> _confirmDelete(HabbitEntryData entry) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return DeleteEntryDialog(
          entry: entry,
        );
      },
    );
  }

  void _editEntry(HabbitEntryData entry) async {
    final editedData = await showDialog<HabbitEntryCompanion>(
      context: context,
      builder: (BuildContext context) {
        return EntryDialogForm(
          habbit: widget.habbit,
          creationTime: entry.creationTime,
          description: entry.description,
        );
      },
    );
    if (editedData != null) {
      (MyDatabase.instance.update(MyDatabase.instance.habbitEntry)
            ..where((tbl) => tbl.id.equals(entry.id)))
          .write(editedData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.entries;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
      itemCount: entries != null ? entries.length : 1,
      itemBuilder: (BuildContext context, int index) {
        if (entries == null) {
          return const Text("Loading...");
        }
        final entry = entries[index];
        return Dismissible(
          key: Key(entry.id),
          background: Container(color: Colors.red),
          confirmDismiss: (direction) => _confirmDelete(entry),
          child: ListTile(
            title: Text(formatDate(entry.creationTime)),
            subtitle: (entry.description == null || entry.description!.isEmpty)
                ? null
                : Text(entry.description!),
            onTap: () => _editEntry(entry),
          ),
        );
      },
    );
  }
}
