import 'package:flutter/material.dart';
import 'relapseform.dart';
import '../components/deletedialog.dart';
import '../helpers/stats.dart';
import '../models/core.dart';
import '../models/drift.dart';

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
  void _confirmDelete(RelapseData relapse) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteRelapseDialog(
          relapse: relapse,
        );
      },
    );
  }

  void _editRelapse(RelapseData relapse) async {
    final editedData = await showDialog<RelapseCompanion>(
      context: context,
      builder: (BuildContext context) {
        return RelapseDialogForm(
          creationTime: relapse.creationTime,
          description: relapse.description,
        );
      },
    );
    if (editedData != null) {
      (MyDatabase.instance.update(MyDatabase.instance.relapse)
            ..where((tbl) => tbl.id.equals(relapse.id)))
          .write(editedData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final relapses = widget.relapses;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
      itemCount: relapses != null ? relapses.length : 1,
      itemBuilder: (BuildContext context, int index) {
        if (relapses == null) {
          return const Text("Loading...");
        }
        final relapse = relapses[index];
        return ListTile(
          title: Text(formatDate(relapse.creationTime)),
          subtitle:
              (relapse.description == null || relapse.description!.isEmpty)
                  ? null
                  : Text(relapse.description!),
          onTap: () => _editRelapse(relapse),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(relapse),
          ),
        );
      },
    );
  }
}
