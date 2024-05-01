// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Habbit extends _Habbit with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Habbit(
    ObjectId id,
    String name,
    DateTime creationTime, {
    String? description,
    String? config,
    int? order,
    DateTime? deletionTime,
    bool hidden = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Habbit>({
        'hidden': false,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'config', config);
    RealmObjectBase.set(this, 'order', order);
    RealmObjectBase.set(this, 'creationTime', creationTime);
    RealmObjectBase.set(this, 'deletionTime', deletionTime);
    RealmObjectBase.set(this, 'hidden', hidden);
  }

  Habbit._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get config => RealmObjectBase.get<String>(this, 'config') as String?;
  @override
  set config(String? value) => RealmObjectBase.set(this, 'config', value);

  @override
  int? get order => RealmObjectBase.get<int>(this, 'order') as int?;
  @override
  set order(int? value) => RealmObjectBase.set(this, 'order', value);

  @override
  DateTime get creationTime =>
      RealmObjectBase.get<DateTime>(this, 'creationTime') as DateTime;
  @override
  set creationTime(DateTime value) =>
      RealmObjectBase.set(this, 'creationTime', value);

  @override
  DateTime? get deletionTime =>
      RealmObjectBase.get<DateTime>(this, 'deletionTime') as DateTime?;
  @override
  set deletionTime(DateTime? value) =>
      RealmObjectBase.set(this, 'deletionTime', value);

  @override
  bool get hidden => RealmObjectBase.get<bool>(this, 'hidden') as bool;
  @override
  set hidden(bool value) => RealmObjectBase.set(this, 'hidden', value);

  @override
  Stream<RealmObjectChanges<Habbit>> get changes =>
      RealmObjectBase.getChanges<Habbit>(this);

  @override
  Habbit freeze() => RealmObjectBase.freezeObject<Habbit>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'description': description.toEJson(),
      'config': config.toEJson(),
      'order': order.toEJson(),
      'creationTime': creationTime.toEJson(),
      'deletionTime': deletionTime.toEJson(),
      'hidden': hidden.toEJson(),
    };
  }

  static EJsonValue _toEJson(Habbit value) => value.toEJson();
  static Habbit _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'description': EJsonValue description,
        'config': EJsonValue config,
        'order': EJsonValue order,
        'creationTime': EJsonValue creationTime,
        'deletionTime': EJsonValue deletionTime,
        'hidden': EJsonValue hidden,
      } =>
        Habbit(
          fromEJson(id),
          fromEJson(name),
          fromEJson(creationTime),
          description: fromEJson(description),
          config: fromEJson(config),
          order: fromEJson(order),
          deletionTime: fromEJson(deletionTime),
          hidden: fromEJson(hidden),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Habbit._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.realmObject, Habbit, 'Habbit', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty('config', RealmPropertyType.string, optional: true),
      SchemaProperty('order', RealmPropertyType.int, optional: true),
      SchemaProperty('creationTime', RealmPropertyType.timestamp),
      SchemaProperty('deletionTime', RealmPropertyType.timestamp,
          optional: true),
      SchemaProperty('hidden', RealmPropertyType.bool),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class HabbitEntry extends _HabbitEntry
    with RealmEntity, RealmObjectBase, RealmObject {
  HabbitEntry(
    ObjectId id,
    DateTime creationTime, {
    String? description,
    DateTime? deletionTime,
    Habbit? habbit,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'creationTime', creationTime);
    RealmObjectBase.set(this, 'deletionTime', deletionTime);
    RealmObjectBase.set(this, 'habbit', habbit);
  }

  HabbitEntry._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  DateTime get creationTime =>
      RealmObjectBase.get<DateTime>(this, 'creationTime') as DateTime;
  @override
  set creationTime(DateTime value) =>
      RealmObjectBase.set(this, 'creationTime', value);

  @override
  DateTime? get deletionTime =>
      RealmObjectBase.get<DateTime>(this, 'deletionTime') as DateTime?;
  @override
  set deletionTime(DateTime? value) =>
      RealmObjectBase.set(this, 'deletionTime', value);

  @override
  Habbit? get habbit => RealmObjectBase.get<Habbit>(this, 'habbit') as Habbit?;
  @override
  set habbit(covariant Habbit? value) =>
      RealmObjectBase.set(this, 'habbit', value);

  @override
  Stream<RealmObjectChanges<HabbitEntry>> get changes =>
      RealmObjectBase.getChanges<HabbitEntry>(this);

  @override
  HabbitEntry freeze() => RealmObjectBase.freezeObject<HabbitEntry>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'description': description.toEJson(),
      'creationTime': creationTime.toEJson(),
      'deletionTime': deletionTime.toEJson(),
      'habbit': habbit.toEJson(),
    };
  }

  static EJsonValue _toEJson(HabbitEntry value) => value.toEJson();
  static HabbitEntry _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'description': EJsonValue description,
        'creationTime': EJsonValue creationTime,
        'deletionTime': EJsonValue deletionTime,
        'habbit': EJsonValue habbit,
      } =>
        HabbitEntry(
          fromEJson(id),
          fromEJson(creationTime),
          description: fromEJson(description),
          deletionTime: fromEJson(deletionTime),
          habbit: fromEJson(habbit),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(HabbitEntry._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.realmObject, HabbitEntry, 'HabbitEntry', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty('creationTime', RealmPropertyType.timestamp),
      SchemaProperty('deletionTime', RealmPropertyType.timestamp,
          optional: true),
      SchemaProperty('habbit', RealmPropertyType.object,
          optional: true, linkTarget: 'Habbit'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
