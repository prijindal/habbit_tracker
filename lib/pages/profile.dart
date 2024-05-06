import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../helpers/sync.dart';
import '../models/theme.dart';

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
    } else {
      final encoded = await extractDbJson();
      String? downloadDirectory;
      if (Platform.isAndroid) {
        final params = SaveFileDialogParams(
          data: Uint8List.fromList(encoded.codeUnits),
          fileName: DB_EXPORT_NAME,
        );
        final filePath = await FlutterFileDialog.saveFile(params: params);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Content saved at $filePath"),
            ),
          );
        }
      } else {
        final downloadFolder = await getDownloadsDirectory();
        if (downloadFolder != null) {
          downloadDirectory = downloadFolder.path;
        }
        if (downloadDirectory != null) {
          final path = p.join(downloadDirectory, DB_EXPORT_NAME);
          final file = File(path);
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
        try {
          await jsonToDb(jsonEncoded);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Successfully imported"),
              ),
            );
          }
        } catch (e, stack) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  parseErrorToString(e, stack, "Error while syncing"),
                ),
              ),
            );
          }
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
    if (isFirebaseInitialized()) {
      return const ProfileAuthTile();
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

  void _syncMetadata() async {
    if (user != null) {
      try {
        final ref = FirebaseStorage.instance.ref("${user!.uid}/db.json");
        final metadata = await ref.getMetadata();
        setState(() {
          this.metadata = metadata;
        });
      } catch (e, stack) {
        parseErrorToString(e, stack);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return user != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Sync database"),
                onTap: () async {
                  try {
                    await syncDb();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Sync successfully"),
                        ),
                      );
                    }
                  } catch (e, stack) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            parseErrorToString(e, stack, "Error while syncing"),
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                title: const Text("Upload Database"),
                onTap: () async {
                  try {
                    await uploadFile();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("File uploaded successfully"),
                        ),
                      );
                    }
                  } catch (e, stack) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            parseErrorToString(e, stack, "Error while syncing"),
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                title: const Text("Download database"),
                subtitle: metadata == null
                    ? const Text("Database not synced yet")
                    : Text("Last Synced at ${metadata!.updated}"),
                onTap: () async {
                  try {
                    await downloadFile();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("File downloaded successfully"),
                        ),
                      );
                    }
                  } catch (e, stack) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            parseErrorToString(e, stack, "Error while syncing"),
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                title: const Text("Logout"),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                },
              )
            ],
          )
        : ListTile(
            title: const Text(
              "Login",
            ),
            onTap: () async {
              await Navigator.pushNamed<UserCredential?>(context, "/login");
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
