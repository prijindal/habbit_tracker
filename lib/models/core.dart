// assuming that your file is called filename.dart. This will give an error at
// first, but it's needed for drift to know about the generated code
import 'package:realm/realm.dart';

part 'core.realm.dart';

// this will generate a table called "todos" for us. The rows of that table will
// be represented by a class called "Todo".

@RealmModel()
class _Habbit {
  @PrimaryKey()
  late ObjectId id;

  late String name;
  String? description;
  String? config;
  int? order;
  late DateTime creationTime;
  DateTime? deletionTime;
  bool hidden = false;
}

@RealmModel()
class _HabbitEntry {
  @PrimaryKey()
  late ObjectId id;

  String? description;
  late DateTime creationTime;
  DateTime? deletionTime;
  late _Habbit? habbit;
}
