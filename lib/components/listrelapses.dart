import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:relapse/models/drift.dart';

class ListRelapsesSubPage extends StatefulWidget {
  const ListRelapsesSubPage({
    super.key,
    required this.relapses,
  });

  final List<RelapseData>? relapses;

  @override
  State<ListRelapsesSubPage> createState() => _ListRelapsesSubPageState();
}

class _ListRelapsesSubPageState extends State<ListRelapsesSubPage> {
  String _formatDate(DateTime date) {
    return "${DateFormat.yMMMEd().format(date)} ${DateFormat.jm().format(date)}";
  }

  void _confirmDelete(RelapseData relapse) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Are you sure you want to delete"),
          content: Text(_formatDate(relapse.creationTime)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                (MyDatabase.instance.delete(MyDatabase.instance.relapse)
                      ..where((tbl) => tbl.id.equals(relapse.id)))
                    .go();
                Navigator.of(context).pop();
              },
              child: const Text("Yes"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final relapses = widget.relapses;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 80),
      itemCount: relapses != null ? relapses.length : 1,
      itemBuilder: (BuildContext context, int index) {
        if (relapses == null) {
          return const Text("Loading...");
        }
        final relapse = relapses[index];
        return ListTile(
          title: Text(_formatDate(relapse.creationTime)),
          subtitle:
              (relapse.description == null || relapse.description!.isEmpty)
                  ? null
                  : Text(relapse.description!),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _confirmDelete(relapse);
            },
          ),
        );
      },
    );
  }
}
