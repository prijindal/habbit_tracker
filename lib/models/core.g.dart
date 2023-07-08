// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core.dart';

// ignore_for_file: type=lint
class $HabbitTable extends Habbit with TableInfo<$HabbitTable, HabbitData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabbitTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
      clientDefault: () => _uuid.v4());
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _configMeta = const VerificationMeta('config');
  @override
  late final GeneratedColumn<String> config = GeneratedColumn<String>(
      'config', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _creationTimeMeta =
      const VerificationMeta('creationTime');
  @override
  late final GeneratedColumn<DateTime> creationTime = GeneratedColumn<DateTime>(
      'creation_time', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletionTimeMeta =
      const VerificationMeta('deletionTime');
  @override
  late final GeneratedColumn<DateTime> deletionTime = GeneratedColumn<DateTime>(
      'deletion_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden =
      GeneratedColumn<bool>('hidden', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("hidden" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }),
          clientDefault: () => false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        config,
        order,
        creationTime,
        deletionTime,
        hidden
      ];
  @override
  String get aliasedName => _alias ?? 'habbit';
  @override
  String get actualTableName => 'habbit';
  @override
  VerificationContext validateIntegrity(Insertable<HabbitData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('config')) {
      context.handle(_configMeta,
          config.isAcceptableOrUnknown(data['config']!, _configMeta));
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    }
    if (data.containsKey('creation_time')) {
      context.handle(
          _creationTimeMeta,
          creationTime.isAcceptableOrUnknown(
              data['creation_time']!, _creationTimeMeta));
    }
    if (data.containsKey('deletion_time')) {
      context.handle(
          _deletionTimeMeta,
          deletionTime.isAcceptableOrUnknown(
              data['deletion_time']!, _deletionTimeMeta));
    }
    if (data.containsKey('hidden')) {
      context.handle(_hiddenMeta,
          hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  HabbitData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabbitData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      config: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}config']),
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order']),
      creationTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}creation_time'])!,
      deletionTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deletion_time']),
      hidden: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}hidden'])!,
    );
  }

  @override
  $HabbitTable createAlias(String alias) {
    return $HabbitTable(attachedDatabase, alias);
  }
}

class HabbitData extends DataClass implements Insertable<HabbitData> {
  final String id;
  final String name;
  final String? description;
  final String? config;
  final int? order;
  final DateTime creationTime;
  final DateTime? deletionTime;
  final bool hidden;
  const HabbitData(
      {required this.id,
      required this.name,
      this.description,
      this.config,
      this.order,
      required this.creationTime,
      this.deletionTime,
      required this.hidden});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || config != null) {
      map['config'] = Variable<String>(config);
    }
    if (!nullToAbsent || order != null) {
      map['order'] = Variable<int>(order);
    }
    map['creation_time'] = Variable<DateTime>(creationTime);
    if (!nullToAbsent || deletionTime != null) {
      map['deletion_time'] = Variable<DateTime>(deletionTime);
    }
    map['hidden'] = Variable<bool>(hidden);
    return map;
  }

  HabbitCompanion toCompanion(bool nullToAbsent) {
    return HabbitCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      config:
          config == null && nullToAbsent ? const Value.absent() : Value(config),
      order:
          order == null && nullToAbsent ? const Value.absent() : Value(order),
      creationTime: Value(creationTime),
      deletionTime: deletionTime == null && nullToAbsent
          ? const Value.absent()
          : Value(deletionTime),
      hidden: Value(hidden),
    );
  }

  factory HabbitData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabbitData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      config: serializer.fromJson<String?>(json['config']),
      order: serializer.fromJson<int?>(json['order']),
      creationTime: serializer.fromJson<DateTime>(json['creationTime']),
      deletionTime: serializer.fromJson<DateTime?>(json['deletionTime']),
      hidden: serializer.fromJson<bool>(json['hidden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'config': serializer.toJson<String?>(config),
      'order': serializer.toJson<int?>(order),
      'creationTime': serializer.toJson<DateTime>(creationTime),
      'deletionTime': serializer.toJson<DateTime?>(deletionTime),
      'hidden': serializer.toJson<bool>(hidden),
    };
  }

  HabbitData copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> config = const Value.absent(),
          Value<int?> order = const Value.absent(),
          DateTime? creationTime,
          Value<DateTime?> deletionTime = const Value.absent(),
          bool? hidden}) =>
      HabbitData(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        config: config.present ? config.value : this.config,
        order: order.present ? order.value : this.order,
        creationTime: creationTime ?? this.creationTime,
        deletionTime:
            deletionTime.present ? deletionTime.value : this.deletionTime,
        hidden: hidden ?? this.hidden,
      );
  @override
  String toString() {
    return (StringBuffer('HabbitData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('config: $config, ')
          ..write('order: $order, ')
          ..write('creationTime: $creationTime, ')
          ..write('deletionTime: $deletionTime, ')
          ..write('hidden: $hidden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, description, config, order, creationTime, deletionTime, hidden);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabbitData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.config == this.config &&
          other.order == this.order &&
          other.creationTime == this.creationTime &&
          other.deletionTime == this.deletionTime &&
          other.hidden == this.hidden);
}

class HabbitCompanion extends UpdateCompanion<HabbitData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> config;
  final Value<int?> order;
  final Value<DateTime> creationTime;
  final Value<DateTime?> deletionTime;
  final Value<bool> hidden;
  final Value<int> rowid;
  const HabbitCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.config = const Value.absent(),
    this.order = const Value.absent(),
    this.creationTime = const Value.absent(),
    this.deletionTime = const Value.absent(),
    this.hidden = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabbitCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.config = const Value.absent(),
    this.order = const Value.absent(),
    this.creationTime = const Value.absent(),
    this.deletionTime = const Value.absent(),
    this.hidden = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<HabbitData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? config,
    Expression<int>? order,
    Expression<DateTime>? creationTime,
    Expression<DateTime>? deletionTime,
    Expression<bool>? hidden,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (config != null) 'config': config,
      if (order != null) 'order': order,
      if (creationTime != null) 'creation_time': creationTime,
      if (deletionTime != null) 'deletion_time': deletionTime,
      if (hidden != null) 'hidden': hidden,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabbitCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? config,
      Value<int?>? order,
      Value<DateTime>? creationTime,
      Value<DateTime?>? deletionTime,
      Value<bool>? hidden,
      Value<int>? rowid}) {
    return HabbitCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      config: config ?? this.config,
      order: order ?? this.order,
      creationTime: creationTime ?? this.creationTime,
      deletionTime: deletionTime ?? this.deletionTime,
      hidden: hidden ?? this.hidden,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (config.present) {
      map['config'] = Variable<String>(config.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (creationTime.present) {
      map['creation_time'] = Variable<DateTime>(creationTime.value);
    }
    if (deletionTime.present) {
      map['deletion_time'] = Variable<DateTime>(deletionTime.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabbitCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('config: $config, ')
          ..write('order: $order, ')
          ..write('creationTime: $creationTime, ')
          ..write('deletionTime: $deletionTime, ')
          ..write('hidden: $hidden, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabbitEntryTable extends HabbitEntry
    with TableInfo<$HabbitEntryTable, HabbitEntryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabbitEntryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
      clientDefault: () => _uuid.v4());
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _creationTimeMeta =
      const VerificationMeta('creationTime');
  @override
  late final GeneratedColumn<DateTime> creationTime = GeneratedColumn<DateTime>(
      'creation_time', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletionTimeMeta =
      const VerificationMeta('deletionTime');
  @override
  late final GeneratedColumn<DateTime> deletionTime = GeneratedColumn<DateTime>(
      'deletion_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _habbitMeta = const VerificationMeta('habbit');
  @override
  late final GeneratedColumn<String> habbit = GeneratedColumn<String>(
      'habbit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES habbit (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, description, creationTime, deletionTime, habbit];
  @override
  String get aliasedName => _alias ?? 'habbit_entry';
  @override
  String get actualTableName => 'habbit_entry';
  @override
  VerificationContext validateIntegrity(Insertable<HabbitEntryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('creation_time')) {
      context.handle(
          _creationTimeMeta,
          creationTime.isAcceptableOrUnknown(
              data['creation_time']!, _creationTimeMeta));
    }
    if (data.containsKey('deletion_time')) {
      context.handle(
          _deletionTimeMeta,
          deletionTime.isAcceptableOrUnknown(
              data['deletion_time']!, _deletionTimeMeta));
    }
    if (data.containsKey('habbit')) {
      context.handle(_habbitMeta,
          habbit.isAcceptableOrUnknown(data['habbit']!, _habbitMeta));
    } else if (isInserting) {
      context.missing(_habbitMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  HabbitEntryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabbitEntryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      creationTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}creation_time'])!,
      deletionTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deletion_time']),
      habbit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}habbit'])!,
    );
  }

  @override
  $HabbitEntryTable createAlias(String alias) {
    return $HabbitEntryTable(attachedDatabase, alias);
  }
}

class HabbitEntryData extends DataClass implements Insertable<HabbitEntryData> {
  final String id;
  final String? description;
  final DateTime creationTime;
  final DateTime? deletionTime;
  final String habbit;
  const HabbitEntryData(
      {required this.id,
      this.description,
      required this.creationTime,
      this.deletionTime,
      required this.habbit});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['creation_time'] = Variable<DateTime>(creationTime);
    if (!nullToAbsent || deletionTime != null) {
      map['deletion_time'] = Variable<DateTime>(deletionTime);
    }
    map['habbit'] = Variable<String>(habbit);
    return map;
  }

  HabbitEntryCompanion toCompanion(bool nullToAbsent) {
    return HabbitEntryCompanion(
      id: Value(id),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      creationTime: Value(creationTime),
      deletionTime: deletionTime == null && nullToAbsent
          ? const Value.absent()
          : Value(deletionTime),
      habbit: Value(habbit),
    );
  }

  factory HabbitEntryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabbitEntryData(
      id: serializer.fromJson<String>(json['id']),
      description: serializer.fromJson<String?>(json['description']),
      creationTime: serializer.fromJson<DateTime>(json['creationTime']),
      deletionTime: serializer.fromJson<DateTime?>(json['deletionTime']),
      habbit: serializer.fromJson<String>(json['habbit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'description': serializer.toJson<String?>(description),
      'creationTime': serializer.toJson<DateTime>(creationTime),
      'deletionTime': serializer.toJson<DateTime?>(deletionTime),
      'habbit': serializer.toJson<String>(habbit),
    };
  }

  HabbitEntryData copyWith(
          {String? id,
          Value<String?> description = const Value.absent(),
          DateTime? creationTime,
          Value<DateTime?> deletionTime = const Value.absent(),
          String? habbit}) =>
      HabbitEntryData(
        id: id ?? this.id,
        description: description.present ? description.value : this.description,
        creationTime: creationTime ?? this.creationTime,
        deletionTime:
            deletionTime.present ? deletionTime.value : this.deletionTime,
        habbit: habbit ?? this.habbit,
      );
  @override
  String toString() {
    return (StringBuffer('HabbitEntryData(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('creationTime: $creationTime, ')
          ..write('deletionTime: $deletionTime, ')
          ..write('habbit: $habbit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, description, creationTime, deletionTime, habbit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabbitEntryData &&
          other.id == this.id &&
          other.description == this.description &&
          other.creationTime == this.creationTime &&
          other.deletionTime == this.deletionTime &&
          other.habbit == this.habbit);
}

class HabbitEntryCompanion extends UpdateCompanion<HabbitEntryData> {
  final Value<String> id;
  final Value<String?> description;
  final Value<DateTime> creationTime;
  final Value<DateTime?> deletionTime;
  final Value<String> habbit;
  final Value<int> rowid;
  const HabbitEntryCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.creationTime = const Value.absent(),
    this.deletionTime = const Value.absent(),
    this.habbit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabbitEntryCompanion.insert({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.creationTime = const Value.absent(),
    this.deletionTime = const Value.absent(),
    required String habbit,
    this.rowid = const Value.absent(),
  }) : habbit = Value(habbit);
  static Insertable<HabbitEntryData> custom({
    Expression<String>? id,
    Expression<String>? description,
    Expression<DateTime>? creationTime,
    Expression<DateTime>? deletionTime,
    Expression<String>? habbit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (creationTime != null) 'creation_time': creationTime,
      if (deletionTime != null) 'deletion_time': deletionTime,
      if (habbit != null) 'habbit': habbit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabbitEntryCompanion copyWith(
      {Value<String>? id,
      Value<String?>? description,
      Value<DateTime>? creationTime,
      Value<DateTime?>? deletionTime,
      Value<String>? habbit,
      Value<int>? rowid}) {
    return HabbitEntryCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      creationTime: creationTime ?? this.creationTime,
      deletionTime: deletionTime ?? this.deletionTime,
      habbit: habbit ?? this.habbit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (creationTime.present) {
      map['creation_time'] = Variable<DateTime>(creationTime.value);
    }
    if (deletionTime.present) {
      map['deletion_time'] = Variable<DateTime>(deletionTime.value);
    }
    if (habbit.present) {
      map['habbit'] = Variable<String>(habbit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabbitEntryCompanion(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('creationTime: $creationTime, ')
          ..write('deletionTime: $deletionTime, ')
          ..write('habbit: $habbit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$SharedDatabase extends GeneratedDatabase {
  _$SharedDatabase(QueryExecutor e) : super(e);
  late final $HabbitTable habbit = $HabbitTable(this);
  late final $HabbitEntryTable habbitEntry = $HabbitEntryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [habbit, habbitEntry];
}
