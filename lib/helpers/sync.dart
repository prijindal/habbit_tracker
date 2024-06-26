import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/core.dart';
import '../models/drift.dart';
import 'logger.dart';

// ignore: constant_identifier_names
const DB_EXPORT_NAME = "db.json";

Future<String> extractDbJson() async {
  final entries =
      await MyDatabase.instance.select(MyDatabase.instance.habbitEntry).get();
  final habbits =
      await MyDatabase.instance.select(MyDatabase.instance.habbit).get();
  String encoded = jsonEncode({"habbits": habbits, "entries": entries});
  AppLogger.instance.i("Extracted data from database");
  return encoded;
}

Future<void> jsonToDb(String jsonEncoded) async {
  final decoded = jsonDecode(jsonEncoded);
  List<dynamic> entries = decoded["entries"] as List<dynamic>;
  List<dynamic> habbits = decoded["habbits"] as List<dynamic>;
  await MyDatabase.instance.batch((batch) {
    batch.insertAll(
      MyDatabase.instance.habbit,
      habbits.map(
        (e) => HabbitData.fromJson(e as Map<String, dynamic>),
      ),
      mode: InsertMode.insertOrIgnore,
    );
    batch.insertAll(
      MyDatabase.instance.habbitEntry,
      entries.map(
        (a) => HabbitEntryData.fromJson(a as Map<String, dynamic>),
      ),
      mode: InsertMode.insertOrIgnore,
    );
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
