import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:realm/realm.dart';

import '../models/core.dart';
import '../models/database.dart';
import 'logger.dart';

// ignore: constant_identifier_names
const DB_EXPORT_NAME = "db.json";

Future<String> extractDbJson() async {
  final entries = MyDatabase.instance.all<HabbitEntry>();
  final habbits = MyDatabase.instance.all<Habbit>();

  String encoded =
      jsonEncode({"habbits": toEJson(habbits), "entries": toEJson(entries)});
  AppLogger.instance.i("Extracted data from database");
  return encoded;
}

Future<void> jsonToDb(String jsonEncoded) async {
  final decoded = jsonDecode(jsonEncoded);
  List<dynamic> entries = decoded["entries"] as List<dynamic>;
  List<dynamic> habbits = decoded["habbits"] as List<dynamic>;
  Map<String, ObjectId> oldToNewIds = {};
  for (var i = 0; i < habbits.length; i++) {
    if (habbits[i]["id"] is String) {
      final newObjectId = ObjectId();
      oldToNewIds[habbits[i]["id"] as String] = newObjectId;
      habbits[i]["id"] = newObjectId.toEJson();
    }
    if (habbits[i]["creationTime"] is int) {
      habbits[i]["creationTime"] = toEJson(DateTime.fromMillisecondsSinceEpoch(
          habbits[i]["creationTime"] as int));
    }
    if (habbits[i]["deletionTime"] is int) {
      habbits[i]["deletionTime"] = toEJson(DateTime.fromMillisecondsSinceEpoch(
          habbits[i]["deletionTime"] as int));
    }
  }
  await MyDatabase.instance.writeAsync(() {
    MyDatabase.instance.addAll(
        habbits.map(
          (e) => fromEJson<Habbit>(e),
        ),
        update: true);
  });
  for (var i = 0; i < entries.length; i++) {
    if (entries[i]["id"] is String) {
      entries[i]["id"] = ObjectId().toEJson();
    }
    if (entries[i]["creationTime"] is int) {
      entries[i]["creationTime"] = toEJson(DateTime.fromMillisecondsSinceEpoch(
          entries[i]["creationTime"] as int));
    }
    if (entries[i]["deletionTime"] is int) {
      entries[i]["deletionTime"] = toEJson(DateTime.fromMillisecondsSinceEpoch(
          entries[i]["deletionTime"] as int));
    }
    if (entries[i]["habbit"] is String) {
      entries[i]["habbit"] = toEJson(MyDatabase.instance
          .find<Habbit>(oldToNewIds[entries[i]["habbit"] as String]));
    }
  }
  await MyDatabase.instance.writeAsync(() {
    MyDatabase.instance.addAll(
        entries.map(
          (e) => fromEJson<HabbitEntry>(e),
        ),
        update: true);
  });

  AppLogger.instance.d("Loaded data into database");
}

bool isFirebaseInitialized() {
  try {
    return Firebase.apps.isNotEmpty;
  } catch (e, stack) {
    AppLogger.instance.e(
      "Firebase.apps error",
      error: e,
      stackTrace: stack,
    );
    return false;
  }
}

Future<auth.User?> getUser() async {
  if (!isFirebaseInitialized()) {
    AppLogger.instance.i("Firebase App not initialized");
    return null;
  }
  return auth.FirebaseAuth.instance.currentUser;
}

Future<void> uploadFile() async {
  final user = await getUser();
  if (user != null) {
    final ref = FirebaseStorage.instance.ref("${user.uid}/$DB_EXPORT_NAME");
    final encoded = await extractDbJson();
    await ref.putString(encoded);
  }
}

Future<void> downloadFile() async {
  final user = await getUser();
  if (user != null) {
    final ref = FirebaseStorage.instance.ref("${user.uid}/$DB_EXPORT_NAME");
    final dbBytes = await ref.getData();
    if (dbBytes != null) {
      final jsonEncoded = String.fromCharCodes(dbBytes);
      await jsonToDb(jsonEncoded);
    }
  }
}

Future<void> syncDb() async {
  await downloadFile();
  await uploadFile();
}

String parseErrorToString(
  Object e,
  StackTrace stack, [
  String defaultMessage = "Error While syncing",
]) {
  AppLogger.instance.e(
    defaultMessage,
    error: e,
    stackTrace: stack,
  );
  var error = defaultMessage;
  if (e is FirebaseException && e.message != null) {
    error = e.message!;
  }
  return error;
}
