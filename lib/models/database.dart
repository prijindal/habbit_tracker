import 'package:realm/realm.dart';

import 'core.dart';

class MyDatabase {
  static final Configuration config =
      Configuration.local([Habbit.schema, HabbitEntry.schema]);
  static final instance = Realm(config);
}
