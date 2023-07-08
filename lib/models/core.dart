import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

// assuming that your file is called filename.dart. This will give an error at
// first, but it's needed for drift to know about the generated code
part 'core.g.dart';

// this will generate a table called "todos" for us. The rows of that table will
// be represented by a class called "Todo".

const _uuid = Uuid();

class Habbit extends Table {
  TextColumn get id => text().unique().clientDefault(() => _uuid.v4())();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get config => text().nullable()();
  IntColumn get order => integer().nullable()();
  DateTimeColumn get creationTime =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletionTime => dateTime().nullable()();
  BoolColumn get hidden => boolean().clientDefault(() => false)();
}

class HabbitEntry extends Table {
  TextColumn get id => text().unique().clientDefault(() => _uuid.v4())();
  TextColumn get description => text().nullable()();
  DateTimeColumn get creationTime =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletionTime => dateTime().nullable()();
  TextColumn get habbit => text().references(Habbit, #id)();
}

// this annotation tells drift to prepare a database class that uses both of the
// tables we just defined. We'll see how to use that database class in a moment.
@DriftDatabase(tables: [HabbitEntry])
class SharedDatabase extends _$SharedDatabase {
  SharedDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}
