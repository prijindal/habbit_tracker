import 'dart:convert';
// import 'dart:html' as web_file;
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/core.dart';
import '../models/drift.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _downloadContent(BuildContext context) async {
    final relapses =
        await MyDatabase.instance.select(MyDatabase.instance.relapse).get();
    String encoded = jsonEncode(relapses);
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Not Supported"),
        ),
      );
      // var blob = web_file.Blob([encoded], 'text/plain', 'native');
      // var anchorElement = web_file.AnchorElement(
      //   href: web_file.Url.createObjectUrlFromBlob(blob).toString(),
      // )
      //   ..setAttribute("download", "db.json")
      //   ..click();
    } else {
      String? downloadDirectory;
      if (Platform.isAndroid) {
        final externalStorageFolders = await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        );
        if (externalStorageFolders != null &&
            externalStorageFolders.isNotEmpty) {
          downloadDirectory = externalStorageFolders.first.path;
        }
      } else {
        final downloadFolder = await getDownloadsDirectory();
        if (downloadFolder != null) {
          downloadDirectory = downloadFolder.path;
        }
      }
      if (downloadDirectory != null) {
        final path = p.join(downloadDirectory, 'db.json');
        final file = File(path);
        await file.writeAsString(encoded);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Content saved at $path"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Can't find download directory"),
          ),
        );
      }
    }
  }

  void _uploadContent(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.bytes != null) {
      String jsonEncoded = utf8.decode(result.files.single.bytes!);
      List<dynamic> relapses = jsonDecode(jsonEncoded);
      try {
        await MyDatabase.instance.batch((batch) {
          batch.insertAll(MyDatabase.instance.relapse,
              relapses.map((a) => RelapseData.fromJson(a)));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully imported"),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cancelled file upload"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Download as JSON"),
            onTap: () => _downloadContent(context),
          ),
          ListTile(
            title: const Text("Upload from file"),
            onTap: () => _uploadContent(context),
          ),
        ],
      ),
    );
  }
}
