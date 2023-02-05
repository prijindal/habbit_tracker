// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core.dart';

// ignore_for_file: type=lint
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
  @override
  List<GeneratedColumn> get $columns => [id, description, creationTime];
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
  const HabbitEntryData(
      {required this.id, this.description, required this.creationTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['creation_time'] = Variable<DateTime>(creationTime);
    return map;
  }

  HabbitEntryCompanion toCompanion(bool nullToAbsent) {
    return HabbitEntryCompanion(
      id: Value(id),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      creationTime: Value(creationTime),
    );
  }

  factory HabbitEntryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabbitEntryData(
      id: serializer.fromJson<String>(json['id']),
      description: serializer.fromJson<String?>(json['description']),
      creationTime: serializer.fromJson<DateTime>(json['creationTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'description': serializer.toJson<String?>(description),
      'creationTime': serializer.toJson<DateTime>(creationTime),
    };
  }

  HabbitEntryData copyWith(
          {String? id,
          Value<String?> description = const Value.absent(),
          DateTime? creationTime}) =>
      HabbitEntryData(
        id: id ?? this.id,
        description: description.present ? description.value : this.description,
        creationTime: creationTime ?? this.creationTime,
      );
  @override
  String toString() {
    return (StringBuffer('HabbitEntryData(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('creationTime: $creationTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, description, creationTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabbitEntryData &&
          other.id == this.id &&
          other.description == this.description &&
          other.creationTime == this.creationTime);
}

class HabbitEntryCompanion extends UpdateCompanion<HabbitEntryData> {
  final Value<String> id;
  final Value<String?> description;
  final Value<DateTime> creationTime;
  const HabbitEntryCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.creationTime = const Value.absent(),
  });
  HabbitEntryCompanion.insert({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.creationTime = const Value.absent(),
  });
  static Insertable<HabbitEntryData> custom({
    Expression<String>? id,
    Expression<String>? description,
    Expression<DateTime>? creationTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (creationTime != null) 'creation_time': creationTime,
    });
  }

  HabbitEntryCompanion copyWith(
      {Value<String>? id,
      Value<String?>? description,
      Value<DateTime>? creationTime}) {
    return HabbitEntryCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      creationTime: creationTime ?? this.creationTime,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabbitEntryCompanion(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('creationTime: $creationTime')
          ..write(')'))
        .toString();
  }
}

abstract class _$SharedDatabase extends GeneratedDatabase {
  _$SharedDatabase(QueryExecutor e) : super(e);
  late final $HabbitEntryTable habbitEntry = $HabbitEntryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [habbitEntry];
}
