import 'dart:async';
import 'dart:convert';
// import 'dart:html' as web_file;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:habbit_tracker/helpers/logger.dart';
import 'package:habbit_tracker/models/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../pages/login.dart';
import '../models/core.dart';
import '../models/drift.dart';

Future<String> _extractDbJson() async {
  final entries =
      await MyDatabase.instance.select(MyDatabase.instance.habbitEntry).get();
  final habbits =
      await MyDatabase.instance.select(MyDatabase.instance.habbit).get();
  String encoded = jsonEncode({"habbits": habbits, "entries": entries});
  return encoded;
}

Future<void> _jsonToDb(String jsonEncoded, BuildContext context) async {
  final decoded = jsonDecode(jsonEncoded);
  List<dynamic> entries = decoded["entries"];
  List<dynamic> habbits = decoded["habbits"];
  try {
    await MyDatabase.instance.batch((batch) {
      batch.insertAll(
        MyDatabase.instance.habbit,
        habbits.map(
          (e) => HabbitData.fromJson(e),
        ),
      );
      batch.insertAll(
        MyDatabase.instance.habbitEntry,
        entries.map(
          (a) => HabbitEntryData.fromJson(a),
        ),
      );
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully imported"),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _downloadContent(BuildContext context) async {
    if (kIsWeb) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Not Supported"),
          ),
        );
      }
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
        final encoded = await _extractDbJson();
        await file.writeAsString(encoded);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Content saved at $path"),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Can't find download directory"),
            ),
          );
        }
      }
    }
  }

  void _uploadContent(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String? jsonEncoded;
      if (result.files.single.bytes != null) {
        jsonEncoded = utf8.decode(result.files.single.bytes!);
      } else if (result.files.single.path != null) {
        jsonEncoded = await File(result.files.single.path!).readAsString();
      }
      if (jsonEncoded != null) {
        if (context.mounted) {
          await _jsonToDb(jsonEncoded, context);
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cancelled file upload"),
          ),
        );
      }
    }
  }

  Widget _profileTile() {
    try {
      if (Firebase.apps.isNotEmpty) {
        return const ProfileAuthTile();
      }
    } catch (e, stack) {
      AppLogger.instance.e("Firebase.apps error", e, stack);
    }
    return const ListTile(
      title: Text("Firebase is not available"),
    );
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
          const ThemeSelectorTile(),
          _profileTile(),
        ],
      ),
    );
  }
}

class ProfileAuthTile extends StatefulWidget {
  const ProfileAuthTile({super.key});

  @override
  State<ProfileAuthTile> createState() => _ProfileAuthTileState();
}

class _ProfileAuthTileState extends State<ProfileAuthTile> {
  StreamSubscription<User?>? _subscription;
  User? user;
  FullMetadata? metadata;

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser;
    _subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        this.user = user;
      });
      _syncMetadata();
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _downloadFile() async {
    if (user != null) {
      try {
        final ref = FirebaseStorage.instance.ref("${user!.uid}/db.json");
        final dbBytes = await ref.getData();
        if (dbBytes != null) {
          final jsonEncoded = String.fromCharCodes(dbBytes);
          if (context.mounted) {
            await _jsonToDb(jsonEncoded, context);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("File downloaded successfully"),
                ),
              );
            }
          }
        }
      } on FirebaseException catch (e, stack) {
        AppLogger.instance.e("Error while downloading", e, stack);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? "Error while downloading"),
            ),
          );
        }
      }
    }
  }

  Future<void> _uploadFile() async {
    if (user != null) {
      try {
        final ref = FirebaseStorage.instance.ref("${user!.uid}/db.json");
        final encoded = await _extractDbJson();
        await ref.putString(encoded);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("File uploaded successfully"),
            ),
          );
        }
      } on FirebaseException catch (e, stack) {
        AppLogger.instance.e("Error while uploading", e, stack);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? "Error while uploading"),
            ),
          );
        }
      }
    }
  }

  void _syncMetadata() async {
    final ref = FirebaseStorage.instance.ref("${user!.uid}/db.json");
    final metadata = await ref.getMetadata();
    setState(() {
      this.metadata = metadata;
    });
  }

  @override
  Widget build(BuildContext context) {
    return user != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Upload Database"),
                onTap: () async {
                  _uploadFile();
                },
              ),
              ListTile(
                title: const Text("Download database"),
                subtitle: metadata == null
                    ? const Text("Database not synced yet")
                    : Text("Last Synced at ${metadata!.updated}"),
                onTap: () async {
                  _downloadFile();
                },
              )
            ],
          )
        : ListTile(
            title: const Text(
              "Login",
            ),
            onTap: () async {
              await Navigator.push<UserCredential?>(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          );
  }
}

class ThemeSelectorTile extends StatelessWidget {
  const ThemeSelectorTile({super.key});

  String themeDataToText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return "System";
      case ThemeMode.dark:
        return "Dark";
      case ThemeMode.light:
        return "Light";
      default:
        return "None";
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeModeNotifier>(context);
    return ListTile(
      title: DropdownButton<ThemeMode>(
        value: themeNotifier.getTheme(),
        items: ThemeMode.values
            .map(
              (e) => DropdownMenuItem<ThemeMode>(
                value: e,
                child: Text(themeDataToText(e)),
              ),
            )
            .toList(),
        onChanged: (newValue) async {
          await themeNotifier.setTheme(newValue ?? ThemeMode.system);
        },
      ),
    );
  }
}
