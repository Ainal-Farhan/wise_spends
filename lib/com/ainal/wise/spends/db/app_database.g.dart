// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserTableTable extends UserTable
    with TableInfo<$UserTableTable, CmmnUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => UuidGenerator().v4());
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
      'date_created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _dateUpdatedMeta =
      const VerificationMeta('dateUpdated');
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
      'date_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, dateCreated, dateUpdated, name];
  @override
  String get aliasedName => _alias ?? 'user_table';
  @override
  String get actualTableName => 'user_table';
  @override
  VerificationContext validateIntegrity(Insertable<CmmnUser> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('date_updated')) {
      context.handle(
          _dateUpdatedMeta,
          dateUpdated.isAcceptableOrUnknown(
              data['date_updated']!, _dateUpdatedMeta));
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {name},
      ];
  @override
  CmmnUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CmmnUser(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
      dateUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_updated'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $UserTableTable createAlias(String alias) {
    return $UserTableTable(attachedDatabase, alias);
  }
}

class CmmnUser extends DataClass implements Insertable<CmmnUser> {
  final String id;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String name;
  const CmmnUser(
      {required this.id,
      required this.dateCreated,
      required this.dateUpdated,
      required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['name'] = Variable<String>(name);
    return map;
  }

  UserTableCompanion toCompanion(bool nullToAbsent) {
    return UserTableCompanion(
      id: Value(id),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      name: Value(name),
    );
  }

  factory CmmnUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CmmnUser(
      id: serializer.fromJson<String>(json['id']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'name': serializer.toJson<String>(name),
    };
  }

  CmmnUser copyWith(
          {String? id,
          DateTime? dateCreated,
          DateTime? dateUpdated,
          String? name}) =>
      CmmnUser(
        id: id ?? this.id,
        dateCreated: dateCreated ?? this.dateCreated,
        dateUpdated: dateUpdated ?? this.dateUpdated,
        name: name ?? this.name,
      );
  @override
  String toString() {
    return (StringBuffer('CmmnUser(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dateCreated, dateUpdated, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CmmnUser &&
          other.id == this.id &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.name == this.name);
}

class UserTableCompanion extends UpdateCompanion<CmmnUser> {
  final Value<String> id;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> name;
  const UserTableCompanion({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.name = const Value.absent(),
  });
  UserTableCompanion.insert({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required String name,
  })  : dateUpdated = Value(dateUpdated),
        name = Value(name);
  static Insertable<CmmnUser> custom({
    Expression<String>? id,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (name != null) 'name': name,
    });
  }

  UserTableCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? dateCreated,
      Value<DateTime>? dateUpdated,
      Value<String>? name}) {
    return UserTableCompanion(
      id: id ?? this.id,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserTableCompanion(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $GroupReferenceTableTable extends GroupReferenceTable
    with TableInfo<$GroupReferenceTableTable, MstrdtGroupReference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupReferenceTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => UuidGenerator().v4());
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
      'date_created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _dateUpdatedMeta =
      const VerificationMeta('dateUpdated');
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
      'date_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, dateCreated, dateUpdated, label, value];
  @override
  String get aliasedName => _alias ?? 'group_reference_table';
  @override
  String get actualTableName => 'group_reference_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<MstrdtGroupReference> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('date_updated')) {
      context.handle(
          _dateUpdatedMeta,
          dateUpdated.isAcceptableOrUnknown(
              data['date_updated']!, _dateUpdatedMeta));
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MstrdtGroupReference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MstrdtGroupReference(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
      dateUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_updated'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $GroupReferenceTableTable createAlias(String alias) {
    return $GroupReferenceTableTable(attachedDatabase, alias);
  }
}

class MstrdtGroupReference extends DataClass
    implements Insertable<MstrdtGroupReference> {
  final String id;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String label;
  final String value;
  const MstrdtGroupReference(
      {required this.id,
      required this.dateCreated,
      required this.dateUpdated,
      required this.label,
      required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['label'] = Variable<String>(label);
    map['value'] = Variable<String>(value);
    return map;
  }

  GroupReferenceTableCompanion toCompanion(bool nullToAbsent) {
    return GroupReferenceTableCompanion(
      id: Value(id),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      label: Value(label),
      value: Value(value),
    );
  }

  factory MstrdtGroupReference.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MstrdtGroupReference(
      id: serializer.fromJson<String>(json['id']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      label: serializer.fromJson<String>(json['label']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'label': serializer.toJson<String>(label),
      'value': serializer.toJson<String>(value),
    };
  }

  MstrdtGroupReference copyWith(
          {String? id,
          DateTime? dateCreated,
          DateTime? dateUpdated,
          String? label,
          String? value}) =>
      MstrdtGroupReference(
        id: id ?? this.id,
        dateCreated: dateCreated ?? this.dateCreated,
        dateUpdated: dateUpdated ?? this.dateUpdated,
        label: label ?? this.label,
        value: value ?? this.value,
      );
  @override
  String toString() {
    return (StringBuffer('MstrdtGroupReference(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('label: $label, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dateCreated, dateUpdated, label, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MstrdtGroupReference &&
          other.id == this.id &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.label == this.label &&
          other.value == this.value);
}

class GroupReferenceTableCompanion
    extends UpdateCompanion<MstrdtGroupReference> {
  final Value<String> id;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> label;
  final Value<String> value;
  const GroupReferenceTableCompanion({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.label = const Value.absent(),
    this.value = const Value.absent(),
  });
  GroupReferenceTableCompanion.insert({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required String label,
    required String value,
  })  : dateUpdated = Value(dateUpdated),
        label = Value(label),
        value = Value(value);
  static Insertable<MstrdtGroupReference> custom({
    Expression<String>? id,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? label,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (label != null) 'label': label,
      if (value != null) 'value': value,
    });
  }

  GroupReferenceTableCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? dateCreated,
      Value<DateTime>? dateUpdated,
      Value<String>? label,
      Value<String>? value}) {
    return GroupReferenceTableCompanion(
      id: id ?? this.id,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      label: label ?? this.label,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupReferenceTableCompanion(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('label: $label, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $ReferenceTableTable extends ReferenceTable
    with TableInfo<$ReferenceTableTable, MstrdtReference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReferenceTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => UuidGenerator().v4());
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
      'date_created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _dateUpdatedMeta =
      const VerificationMeta('dateUpdated');
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
      'date_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive =
      GeneratedColumn<bool>('is_active', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("is_active" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }),
          defaultValue: const Constant(false));
  static const VerificationMeta _belongToMeta =
      const VerificationMeta('belongTo');
  @override
  late final GeneratedColumn<String> belongTo = GeneratedColumn<String>(
      'belong_to', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES reference_table (id)'));
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES group_reference_table (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, dateCreated, dateUpdated, label, value, isActive, belongTo, groupId];
  @override
  String get aliasedName => _alias ?? 'reference_table';
  @override
  String get actualTableName => 'reference_table';
  @override
  VerificationContext validateIntegrity(Insertable<MstrdtReference> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('date_updated')) {
      context.handle(
          _dateUpdatedMeta,
          dateUpdated.isAcceptableOrUnknown(
              data['date_updated']!, _dateUpdatedMeta));
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('belong_to')) {
      context.handle(_belongToMeta,
          belongTo.isAcceptableOrUnknown(data['belong_to']!, _belongToMeta));
    } else if (isInserting) {
      context.missing(_belongToMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MstrdtReference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MstrdtReference(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
      dateUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_updated'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      belongTo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}belong_to'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
    );
  }

  @override
  $ReferenceTableTable createAlias(String alias) {
    return $ReferenceTableTable(attachedDatabase, alias);
  }
}

class MstrdtReference extends DataClass implements Insertable<MstrdtReference> {
  final String id;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String label;
  final String value;
  final bool isActive;
  final String belongTo;
  final String groupId;
  const MstrdtReference(
      {required this.id,
      required this.dateCreated,
      required this.dateUpdated,
      required this.label,
      required this.value,
      required this.isActive,
      required this.belongTo,
      required this.groupId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['label'] = Variable<String>(label);
    map['value'] = Variable<String>(value);
    map['is_active'] = Variable<bool>(isActive);
    map['belong_to'] = Variable<String>(belongTo);
    map['group_id'] = Variable<String>(groupId);
    return map;
  }

  ReferenceTableCompanion toCompanion(bool nullToAbsent) {
    return ReferenceTableCompanion(
      id: Value(id),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      label: Value(label),
      value: Value(value),
      isActive: Value(isActive),
      belongTo: Value(belongTo),
      groupId: Value(groupId),
    );
  }

  factory MstrdtReference.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MstrdtReference(
      id: serializer.fromJson<String>(json['id']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      label: serializer.fromJson<String>(json['label']),
      value: serializer.fromJson<String>(json['value']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      belongTo: serializer.fromJson<String>(json['belongTo']),
      groupId: serializer.fromJson<String>(json['groupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'label': serializer.toJson<String>(label),
      'value': serializer.toJson<String>(value),
      'isActive': serializer.toJson<bool>(isActive),
      'belongTo': serializer.toJson<String>(belongTo),
      'groupId': serializer.toJson<String>(groupId),
    };
  }

  MstrdtReference copyWith(
          {String? id,
          DateTime? dateCreated,
          DateTime? dateUpdated,
          String? label,
          String? value,
          bool? isActive,
          String? belongTo,
          String? groupId}) =>
      MstrdtReference(
        id: id ?? this.id,
        dateCreated: dateCreated ?? this.dateCreated,
        dateUpdated: dateUpdated ?? this.dateUpdated,
        label: label ?? this.label,
        value: value ?? this.value,
        isActive: isActive ?? this.isActive,
        belongTo: belongTo ?? this.belongTo,
        groupId: groupId ?? this.groupId,
      );
  @override
  String toString() {
    return (StringBuffer('MstrdtReference(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('label: $label, ')
          ..write('value: $value, ')
          ..write('isActive: $isActive, ')
          ..write('belongTo: $belongTo, ')
          ..write('groupId: $groupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, dateCreated, dateUpdated, label, value, isActive, belongTo, groupId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MstrdtReference &&
          other.id == this.id &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.label == this.label &&
          other.value == this.value &&
          other.isActive == this.isActive &&
          other.belongTo == this.belongTo &&
          other.groupId == this.groupId);
}

class ReferenceTableCompanion extends UpdateCompanion<MstrdtReference> {
  final Value<String> id;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> label;
  final Value<String> value;
  final Value<bool> isActive;
  final Value<String> belongTo;
  final Value<String> groupId;
  const ReferenceTableCompanion({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.label = const Value.absent(),
    this.value = const Value.absent(),
    this.isActive = const Value.absent(),
    this.belongTo = const Value.absent(),
    this.groupId = const Value.absent(),
  });
  ReferenceTableCompanion.insert({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required String label,
    required String value,
    this.isActive = const Value.absent(),
    required String belongTo,
    required String groupId,
  })  : dateUpdated = Value(dateUpdated),
        label = Value(label),
        value = Value(value),
        belongTo = Value(belongTo),
        groupId = Value(groupId);
  static Insertable<MstrdtReference> custom({
    Expression<String>? id,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? label,
    Expression<String>? value,
    Expression<bool>? isActive,
    Expression<String>? belongTo,
    Expression<String>? groupId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (label != null) 'label': label,
      if (value != null) 'value': value,
      if (isActive != null) 'is_active': isActive,
      if (belongTo != null) 'belong_to': belongTo,
      if (groupId != null) 'group_id': groupId,
    });
  }

  ReferenceTableCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? dateCreated,
      Value<DateTime>? dateUpdated,
      Value<String>? label,
      Value<String>? value,
      Value<bool>? isActive,
      Value<String>? belongTo,
      Value<String>? groupId}) {
    return ReferenceTableCompanion(
      id: id ?? this.id,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      label: label ?? this.label,
      value: value ?? this.value,
      isActive: isActive ?? this.isActive,
      belongTo: belongTo ?? this.belongTo,
      groupId: groupId ?? this.groupId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (belongTo.present) {
      map['belong_to'] = Variable<String>(belongTo.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceTableCompanion(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('label: $label, ')
          ..write('value: $value, ')
          ..write('isActive: $isActive, ')
          ..write('belongTo: $belongTo, ')
          ..write('groupId: $groupId')
          ..write(')'))
        .toString();
  }
}

class $ReferenceDataTableTable extends ReferenceDataTable
    with TableInfo<$ReferenceDataTableTable, MstrdtReferenceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReferenceDataTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => UuidGenerator().v4());
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
      'date_created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _dateUpdatedMeta =
      const VerificationMeta('dateUpdated');
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
      'date_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupLabelMeta =
      const VerificationMeta('groupLabel');
  @override
  late final GeneratedColumn<String> groupLabel = GeneratedColumn<String>(
      'group_label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupValueMeta =
      const VerificationMeta('groupValue');
  @override
  late final GeneratedColumn<String> groupValue = GeneratedColumn<String>(
      'group_value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenceIdMeta =
      const VerificationMeta('referenceId');
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
      'reference_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES reference_table (id)'));
  static const VerificationMeta _isHasNextMeta =
      const VerificationMeta('isHasNext');
  @override
  late final GeneratedColumn<bool> isHasNext =
      GeneratedColumn<bool>('is_has_next', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("is_has_next" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }),
          defaultValue: const Constant(false));
  static const VerificationMeta _nextReferenceDataIdMeta =
      const VerificationMeta('nextReferenceDataId');
  @override
  late final GeneratedColumn<String> nextReferenceDataId =
      GeneratedColumn<String>('next_reference_data_id', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES reference_data_table (id)'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dateCreated,
        dateUpdated,
        label,
        groupLabel,
        value,
        groupValue,
        referenceId,
        isHasNext,
        nextReferenceDataId
      ];
  @override
  String get aliasedName => _alias ?? 'reference_data_table';
  @override
  String get actualTableName => 'reference_data_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<MstrdtReferenceData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('date_updated')) {
      context.handle(
          _dateUpdatedMeta,
          dateUpdated.isAcceptableOrUnknown(
              data['date_updated']!, _dateUpdatedMeta));
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('group_label')) {
      context.handle(
          _groupLabelMeta,
          groupLabel.isAcceptableOrUnknown(
              data['group_label']!, _groupLabelMeta));
    } else if (isInserting) {
      context.missing(_groupLabelMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('group_value')) {
      context.handle(
          _groupValueMeta,
          groupValue.isAcceptableOrUnknown(
              data['group_value']!, _groupValueMeta));
    } else if (isInserting) {
      context.missing(_groupValueMeta);
    }
    if (data.containsKey('reference_id')) {
      context.handle(
          _referenceIdMeta,
          referenceId.isAcceptableOrUnknown(
              data['reference_id']!, _referenceIdMeta));
    }
    if (data.containsKey('is_has_next')) {
      context.handle(
          _isHasNextMeta,
          isHasNext.isAcceptableOrUnknown(
              data['is_has_next']!, _isHasNextMeta));
    }
    if (data.containsKey('next_reference_data_id')) {
      context.handle(
          _nextReferenceDataIdMeta,
          nextReferenceDataId.isAcceptableOrUnknown(
              data['next_reference_data_id']!, _nextReferenceDataIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MstrdtReferenceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MstrdtReferenceData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
      dateUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_updated'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      groupLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_label'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      groupValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_value'])!,
      referenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_id']),
      isHasNext: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_has_next'])!,
      nextReferenceDataId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}next_reference_data_id']),
    );
  }

  @override
  $ReferenceDataTableTable createAlias(String alias) {
    return $ReferenceDataTableTable(attachedDatabase, alias);
  }
}

class MstrdtReferenceData extends DataClass
    implements Insertable<MstrdtReferenceData> {
  final String id;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String label;
  final String groupLabel;
  final String value;
  final String groupValue;
  final String? referenceId;
  final bool isHasNext;
  final String? nextReferenceDataId;
  const MstrdtReferenceData(
      {required this.id,
      required this.dateCreated,
      required this.dateUpdated,
      required this.label,
      required this.groupLabel,
      required this.value,
      required this.groupValue,
      this.referenceId,
      required this.isHasNext,
      this.nextReferenceDataId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['label'] = Variable<String>(label);
    map['group_label'] = Variable<String>(groupLabel);
    map['value'] = Variable<String>(value);
    map['group_value'] = Variable<String>(groupValue);
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    map['is_has_next'] = Variable<bool>(isHasNext);
    if (!nullToAbsent || nextReferenceDataId != null) {
      map['next_reference_data_id'] = Variable<String>(nextReferenceDataId);
    }
    return map;
  }

  ReferenceDataTableCompanion toCompanion(bool nullToAbsent) {
    return ReferenceDataTableCompanion(
      id: Value(id),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      label: Value(label),
      groupLabel: Value(groupLabel),
      value: Value(value),
      groupValue: Value(groupValue),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      isHasNext: Value(isHasNext),
      nextReferenceDataId: nextReferenceDataId == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReferenceDataId),
    );
  }

  factory MstrdtReferenceData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MstrdtReferenceData(
      id: serializer.fromJson<String>(json['id']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      label: serializer.fromJson<String>(json['label']),
      groupLabel: serializer.fromJson<String>(json['groupLabel']),
      value: serializer.fromJson<String>(json['value']),
      groupValue: serializer.fromJson<String>(json['groupValue']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      isHasNext: serializer.fromJson<bool>(json['isHasNext']),
      nextReferenceDataId:
          serializer.fromJson<String?>(json['nextReferenceDataId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'label': serializer.toJson<String>(label),
      'groupLabel': serializer.toJson<String>(groupLabel),
      'value': serializer.toJson<String>(value),
      'groupValue': serializer.toJson<String>(groupValue),
      'referenceId': serializer.toJson<String?>(referenceId),
      'isHasNext': serializer.toJson<bool>(isHasNext),
      'nextReferenceDataId': serializer.toJson<String?>(nextReferenceDataId),
    };
  }

  MstrdtReferenceData copyWith(
          {String? id,
          DateTime? dateCreated,
          DateTime? dateUpdated,
          String? label,
          String? groupLabel,
          String? value,
          String? groupValue,
          Value<String?> referenceId = const Value.absent(),
          bool? isHasNext,
          Value<String?> nextReferenceDataId = const Value.absent()}) =>
      MstrdtReferenceData(
        id: id ?? this.id,
        dateCreated: dateCreated ?? this.dateCreated,
        dateUpdated: dateUpdated ?? this.dateUpdated,
        label: label ?? this.label,
        groupLabel: groupLabel ?? this.groupLabel,
        value: value ?? this.value,
        groupValue: groupValue ?? this.groupValue,
        referenceId: referenceId.present ? referenceId.value : this.referenceId,
        isHasNext: isHasNext ?? this.isHasNext,
        nextReferenceDataId: nextReferenceDataId.present
            ? nextReferenceDataId.value
            : this.nextReferenceDataId,
      );
  @override
  String toString() {
    return (StringBuffer('MstrdtReferenceData(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('label: $label, ')
          ..write('groupLabel: $groupLabel, ')
          ..write('value: $value, ')
          ..write('groupValue: $groupValue, ')
          ..write('referenceId: $referenceId, ')
          ..write('isHasNext: $isHasNext, ')
          ..write('nextReferenceDataId: $nextReferenceDataId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      dateCreated,
      dateUpdated,
      label,
      groupLabel,
      value,
      groupValue,
      referenceId,
      isHasNext,
      nextReferenceDataId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MstrdtReferenceData &&
          other.id == this.id &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.label == this.label &&
          other.groupLabel == this.groupLabel &&
          other.value == this.value &&
          other.groupValue == this.groupValue &&
          other.referenceId == this.referenceId &&
          other.isHasNext == this.isHasNext &&
          other.nextReferenceDataId == this.nextReferenceDataId);
}

class ReferenceDataTableCompanion extends UpdateCompanion<MstrdtReferenceData> {
  final Value<String> id;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> label;
  final Value<String> groupLabel;
  final Value<String> value;
  final Value<String> groupValue;
  final Value<String?> referenceId;
  final Value<bool> isHasNext;
  final Value<String?> nextReferenceDataId;
  const ReferenceDataTableCompanion({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.label = const Value.absent(),
    this.groupLabel = const Value.absent(),
    this.value = const Value.absent(),
    this.groupValue = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.isHasNext = const Value.absent(),
    this.nextReferenceDataId = const Value.absent(),
  });
  ReferenceDataTableCompanion.insert({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required String label,
    required String groupLabel,
    required String value,
    required String groupValue,
    this.referenceId = const Value.absent(),
    this.isHasNext = const Value.absent(),
    this.nextReferenceDataId = const Value.absent(),
  })  : dateUpdated = Value(dateUpdated),
        label = Value(label),
        groupLabel = Value(groupLabel),
        value = Value(value),
        groupValue = Value(groupValue);
  static Insertable<MstrdtReferenceData> custom({
    Expression<String>? id,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? label,
    Expression<String>? groupLabel,
    Expression<String>? value,
    Expression<String>? groupValue,
    Expression<String>? referenceId,
    Expression<bool>? isHasNext,
    Expression<String>? nextReferenceDataId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (label != null) 'label': label,
      if (groupLabel != null) 'group_label': groupLabel,
      if (value != null) 'value': value,
      if (groupValue != null) 'group_value': groupValue,
      if (referenceId != null) 'reference_id': referenceId,
      if (isHasNext != null) 'is_has_next': isHasNext,
      if (nextReferenceDataId != null)
        'next_reference_data_id': nextReferenceDataId,
    });
  }

  ReferenceDataTableCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? dateCreated,
      Value<DateTime>? dateUpdated,
      Value<String>? label,
      Value<String>? groupLabel,
      Value<String>? value,
      Value<String>? groupValue,
      Value<String?>? referenceId,
      Value<bool>? isHasNext,
      Value<String?>? nextReferenceDataId}) {
    return ReferenceDataTableCompanion(
      id: id ?? this.id,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      label: label ?? this.label,
      groupLabel: groupLabel ?? this.groupLabel,
      value: value ?? this.value,
      groupValue: groupValue ?? this.groupValue,
      referenceId: referenceId ?? this.referenceId,
      isHasNext: isHasNext ?? this.isHasNext,
      nextReferenceDataId: nextReferenceDataId ?? this.nextReferenceDataId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (groupLabel.present) {
      map['group_label'] = Variable<String>(groupLabel.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (groupValue.present) {
      map['group_value'] = Variable<String>(groupValue.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (isHasNext.present) {
      map['is_has_next'] = Variable<bool>(isHasNext.value);
    }
    if (nextReferenceDataId.present) {
      map['next_reference_data_id'] =
          Variable<String>(nextReferenceDataId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceDataTableCompanion(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('label: $label, ')
          ..write('groupLabel: $groupLabel, ')
          ..write('value: $value, ')
          ..write('groupValue: $groupValue, ')
          ..write('referenceId: $referenceId, ')
          ..write('isHasNext: $isHasNext, ')
          ..write('nextReferenceDataId: $nextReferenceDataId')
          ..write(')'))
        .toString();
  }
}

class $ExpenseTableTable extends ExpenseTable
    with TableInfo<$ExpenseTableTable, ExpenseTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => UuidGenerator().v4());
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
      'date_created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _dateUpdatedMeta =
      const VerificationMeta('dateUpdated');
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
      'date_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _expenseDateMeta =
      const VerificationMeta('expenseDate');
  @override
  late final GeneratedColumn<DateTime> expenseDate = GeneratedColumn<DateTime>(
      'expense_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _referenceDataIdMeta =
      const VerificationMeta('referenceDataId');
  @override
  late final GeneratedColumn<String> referenceDataId = GeneratedColumn<String>(
      'reference_data_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES reference_data_table (id)'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dateCreated,
        dateUpdated,
        amount,
        description,
        expenseDate,
        referenceDataId
      ];
  @override
  String get aliasedName => _alias ?? 'expense_table';
  @override
  String get actualTableName => 'expense_table';
  @override
  VerificationContext validateIntegrity(Insertable<ExpenseTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('date_updated')) {
      context.handle(
          _dateUpdatedMeta,
          dateUpdated.isAcceptableOrUnknown(
              data['date_updated']!, _dateUpdatedMeta));
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('expense_date')) {
      context.handle(
          _expenseDateMeta,
          expenseDate.isAcceptableOrUnknown(
              data['expense_date']!, _expenseDateMeta));
    } else if (isInserting) {
      context.missing(_expenseDateMeta);
    }
    if (data.containsKey('reference_data_id')) {
      context.handle(
          _referenceDataIdMeta,
          referenceDataId.isAcceptableOrUnknown(
              data['reference_data_id']!, _referenceDataIdMeta));
    } else if (isInserting) {
      context.missing(_referenceDataIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
      dateUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_updated'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      expenseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expense_date'])!,
      referenceDataId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reference_data_id'])!,
    );
  }

  @override
  $ExpenseTableTable createAlias(String alias) {
    return $ExpenseTableTable(attachedDatabase, alias);
  }
}

class ExpenseTableData extends DataClass
    implements Insertable<ExpenseTableData> {
  final String id;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final double amount;
  final String? description;
  final DateTime expenseDate;
  final String referenceDataId;
  const ExpenseTableData(
      {required this.id,
      required this.dateCreated,
      required this.dateUpdated,
      required this.amount,
      this.description,
      required this.expenseDate,
      required this.referenceDataId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['expense_date'] = Variable<DateTime>(expenseDate);
    map['reference_data_id'] = Variable<String>(referenceDataId);
    return map;
  }

  ExpenseTableCompanion toCompanion(bool nullToAbsent) {
    return ExpenseTableCompanion(
      id: Value(id),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      amount: Value(amount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      expenseDate: Value(expenseDate),
      referenceDataId: Value(referenceDataId),
    );
  }

  factory ExpenseTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseTableData(
      id: serializer.fromJson<String>(json['id']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String?>(json['description']),
      expenseDate: serializer.fromJson<DateTime>(json['expenseDate']),
      referenceDataId: serializer.fromJson<String>(json['referenceDataId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String?>(description),
      'expenseDate': serializer.toJson<DateTime>(expenseDate),
      'referenceDataId': serializer.toJson<String>(referenceDataId),
    };
  }

  ExpenseTableData copyWith(
          {String? id,
          DateTime? dateCreated,
          DateTime? dateUpdated,
          double? amount,
          Value<String?> description = const Value.absent(),
          DateTime? expenseDate,
          String? referenceDataId}) =>
      ExpenseTableData(
        id: id ?? this.id,
        dateCreated: dateCreated ?? this.dateCreated,
        dateUpdated: dateUpdated ?? this.dateUpdated,
        amount: amount ?? this.amount,
        description: description.present ? description.value : this.description,
        expenseDate: expenseDate ?? this.expenseDate,
        referenceDataId: referenceDataId ?? this.referenceDataId,
      );
  @override
  String toString() {
    return (StringBuffer('ExpenseTableData(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('referenceDataId: $referenceDataId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dateCreated, dateUpdated, amount,
      description, expenseDate, referenceDataId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseTableData &&
          other.id == this.id &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.expenseDate == this.expenseDate &&
          other.referenceDataId == this.referenceDataId);
}

class ExpenseTableCompanion extends UpdateCompanion<ExpenseTableData> {
  final Value<String> id;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<double> amount;
  final Value<String?> description;
  final Value<DateTime> expenseDate;
  final Value<String> referenceDataId;
  const ExpenseTableCompanion({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.expenseDate = const Value.absent(),
    this.referenceDataId = const Value.absent(),
  });
  ExpenseTableCompanion.insert({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required double amount,
    this.description = const Value.absent(),
    required DateTime expenseDate,
    required String referenceDataId,
  })  : dateUpdated = Value(dateUpdated),
        amount = Value(amount),
        expenseDate = Value(expenseDate),
        referenceDataId = Value(referenceDataId);
  static Insertable<ExpenseTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<DateTime>? expenseDate,
    Expression<String>? referenceDataId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (expenseDate != null) 'expense_date': expenseDate,
      if (referenceDataId != null) 'reference_data_id': referenceDataId,
    });
  }

  ExpenseTableCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? dateCreated,
      Value<DateTime>? dateUpdated,
      Value<double>? amount,
      Value<String?>? description,
      Value<DateTime>? expenseDate,
      Value<String>? referenceDataId}) {
    return ExpenseTableCompanion(
      id: id ?? this.id,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      expenseDate: expenseDate ?? this.expenseDate,
      referenceDataId: referenceDataId ?? this.referenceDataId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (expenseDate.present) {
      map['expense_date'] = Variable<DateTime>(expenseDate.value);
    }
    if (referenceDataId.present) {
      map['reference_data_id'] = Variable<String>(referenceDataId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseTableCompanion(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('referenceDataId: $referenceDataId')
          ..write(')'))
        .toString();
  }
}

class $ExpenseReferenceTableTable extends ExpenseReferenceTable
    with TableInfo<$ExpenseReferenceTableTable, MstrdtExpenseReference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseReferenceTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => UuidGenerator().v4());
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
      'date_created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _dateUpdatedMeta =
      const VerificationMeta('dateUpdated');
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
      'date_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _suggestedAmountMeta =
      const VerificationMeta('suggestedAmount');
  @override
  late final GeneratedColumn<double> suggestedAmount = GeneratedColumn<double>(
      'suggested_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(.0));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceIdMeta =
      const VerificationMeta('referenceId');
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
      'reference_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES reference_table (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, dateCreated, dateUpdated, suggestedAmount, description, referenceId];
  @override
  String get aliasedName => _alias ?? 'expense_reference_table';
  @override
  String get actualTableName => 'expense_reference_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<MstrdtExpenseReference> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('date_updated')) {
      context.handle(
          _dateUpdatedMeta,
          dateUpdated.isAcceptableOrUnknown(
              data['date_updated']!, _dateUpdatedMeta));
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('suggested_amount')) {
      context.handle(
          _suggestedAmountMeta,
          suggestedAmount.isAcceptableOrUnknown(
              data['suggested_amount']!, _suggestedAmountMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('reference_id')) {
      context.handle(
          _referenceIdMeta,
          referenceId.isAcceptableOrUnknown(
              data['reference_id']!, _referenceIdMeta));
    } else if (isInserting) {
      context.missing(_referenceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MstrdtExpenseReference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MstrdtExpenseReference(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
      dateUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_updated'])!,
      suggestedAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}suggested_amount'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      referenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_id'])!,
    );
  }

  @override
  $ExpenseReferenceTableTable createAlias(String alias) {
    return $ExpenseReferenceTableTable(attachedDatabase, alias);
  }
}

class MstrdtExpenseReference extends DataClass
    implements Insertable<MstrdtExpenseReference> {
  final String id;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final double suggestedAmount;
  final String? description;
  final String referenceId;
  const MstrdtExpenseReference(
      {required this.id,
      required this.dateCreated,
      required this.dateUpdated,
      required this.suggestedAmount,
      this.description,
      required this.referenceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['suggested_amount'] = Variable<double>(suggestedAmount);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['reference_id'] = Variable<String>(referenceId);
    return map;
  }

  ExpenseReferenceTableCompanion toCompanion(bool nullToAbsent) {
    return ExpenseReferenceTableCompanion(
      id: Value(id),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      suggestedAmount: Value(suggestedAmount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      referenceId: Value(referenceId),
    );
  }

  factory MstrdtExpenseReference.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MstrdtExpenseReference(
      id: serializer.fromJson<String>(json['id']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      suggestedAmount: serializer.fromJson<double>(json['suggestedAmount']),
      description: serializer.fromJson<String?>(json['description']),
      referenceId: serializer.fromJson<String>(json['referenceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'suggestedAmount': serializer.toJson<double>(suggestedAmount),
      'description': serializer.toJson<String?>(description),
      'referenceId': serializer.toJson<String>(referenceId),
    };
  }

  MstrdtExpenseReference copyWith(
          {String? id,
          DateTime? dateCreated,
          DateTime? dateUpdated,
          double? suggestedAmount,
          Value<String?> description = const Value.absent(),
          String? referenceId}) =>
      MstrdtExpenseReference(
        id: id ?? this.id,
        dateCreated: dateCreated ?? this.dateCreated,
        dateUpdated: dateUpdated ?? this.dateUpdated,
        suggestedAmount: suggestedAmount ?? this.suggestedAmount,
        description: description.present ? description.value : this.description,
        referenceId: referenceId ?? this.referenceId,
      );
  @override
  String toString() {
    return (StringBuffer('MstrdtExpenseReference(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('suggestedAmount: $suggestedAmount, ')
          ..write('description: $description, ')
          ..write('referenceId: $referenceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, dateCreated, dateUpdated, suggestedAmount, description, referenceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MstrdtExpenseReference &&
          other.id == this.id &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.suggestedAmount == this.suggestedAmount &&
          other.description == this.description &&
          other.referenceId == this.referenceId);
}

class ExpenseReferenceTableCompanion
    extends UpdateCompanion<MstrdtExpenseReference> {
  final Value<String> id;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<double> suggestedAmount;
  final Value<String?> description;
  final Value<String> referenceId;
  const ExpenseReferenceTableCompanion({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.suggestedAmount = const Value.absent(),
    this.description = const Value.absent(),
    this.referenceId = const Value.absent(),
  });
  ExpenseReferenceTableCompanion.insert({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    this.suggestedAmount = const Value.absent(),
    this.description = const Value.absent(),
    required String referenceId,
  })  : dateUpdated = Value(dateUpdated),
        referenceId = Value(referenceId);
  static Insertable<MstrdtExpenseReference> custom({
    Expression<String>? id,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<double>? suggestedAmount,
    Expression<String>? description,
    Expression<String>? referenceId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (suggestedAmount != null) 'suggested_amount': suggestedAmount,
      if (description != null) 'description': description,
      if (referenceId != null) 'reference_id': referenceId,
    });
  }

  ExpenseReferenceTableCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? dateCreated,
      Value<DateTime>? dateUpdated,
      Value<double>? suggestedAmount,
      Value<String?>? description,
      Value<String>? referenceId}) {
    return ExpenseReferenceTableCompanion(
      id: id ?? this.id,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      suggestedAmount: suggestedAmount ?? this.suggestedAmount,
      description: description ?? this.description,
      referenceId: referenceId ?? this.referenceId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (suggestedAmount.present) {
      map['suggested_amount'] = Variable<double>(suggestedAmount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseReferenceTableCompanion(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('suggestedAmount: $suggestedAmount, ')
          ..write('description: $description, ')
          ..write('referenceId: $referenceId')
          ..write(')'))
        .toString();
  }
}

class $SavingReminderTableTable extends SavingReminderTable
    with TableInfo<$SavingReminderTableTable, NtfctnSavingReminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingReminderTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive =
      GeneratedColumn<bool>('is_active', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("is_active" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }),
          defaultValue: const Constant(false));
  static const VerificationMeta _activeStartDateMeta =
      const VerificationMeta('activeStartDate');
  @override
  late final GeneratedColumn<DateTime> activeStartDate =
      GeneratedColumn<DateTime>('active_start_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notificationTypeMeta =
      const VerificationMeta('notificationType');
  @override
  late final GeneratedColumn<String> notificationType = GeneratedColumn<String>(
      'notification_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => UuidGenerator().v4());
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
      'date_created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _dateUpdatedMeta =
      const VerificationMeta('dateUpdated');
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
      'date_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _recurringTypeMeta =
      const VerificationMeta('recurringType');
  @override
  late final GeneratedColumn<String> recurringType = GeneratedColumn<String>(
      'recurring_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        title,
        description,
        isActive,
        activeStartDate,
        notificationType,
        id,
        dateCreated,
        dateUpdated,
        amount,
        recurringType
      ];
  @override
  String get aliasedName => _alias ?? 'saving_reminder_table';
  @override
  String get actualTableName => 'saving_reminder_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<NtfctnSavingReminder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('active_start_date')) {
      context.handle(
          _activeStartDateMeta,
          activeStartDate.isAcceptableOrUnknown(
              data['active_start_date']!, _activeStartDateMeta));
    } else if (isInserting) {
      context.missing(_activeStartDateMeta);
    }
    if (data.containsKey('notification_type')) {
      context.handle(
          _notificationTypeMeta,
          notificationType.isAcceptableOrUnknown(
              data['notification_type']!, _notificationTypeMeta));
    } else if (isInserting) {
      context.missing(_notificationTypeMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('date_updated')) {
      context.handle(
          _dateUpdatedMeta,
          dateUpdated.isAcceptableOrUnknown(
              data['date_updated']!, _dateUpdatedMeta));
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('recurring_type')) {
      context.handle(
          _recurringTypeMeta,
          recurringType.isAcceptableOrUnknown(
              data['recurring_type']!, _recurringTypeMeta));
    } else if (isInserting) {
      context.missing(_recurringTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NtfctnSavingReminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NtfctnSavingReminder(
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      activeStartDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}active_start_date'])!,
      notificationType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}notification_type'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
      dateUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_updated'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      recurringType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurring_type'])!,
    );
  }

  @override
  $SavingReminderTableTable createAlias(String alias) {
    return $SavingReminderTableTable(attachedDatabase, alias);
  }
}

class NtfctnSavingReminder extends DataClass
    implements Insertable<NtfctnSavingReminder> {
  final String title;
  final String description;
  final bool isActive;
  final DateTime activeStartDate;
  final String notificationType;
  final String id;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final double amount;
  final String recurringType;
  const NtfctnSavingReminder(
      {required this.title,
      required this.description,
      required this.isActive,
      required this.activeStartDate,
      required this.notificationType,
      required this.id,
      required this.dateCreated,
      required this.dateUpdated,
      required this.amount,
      required this.recurringType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['is_active'] = Variable<bool>(isActive);
    map['active_start_date'] = Variable<DateTime>(activeStartDate);
    map['notification_type'] = Variable<String>(notificationType);
    map['id'] = Variable<String>(id);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['amount'] = Variable<double>(amount);
    map['recurring_type'] = Variable<String>(recurringType);
    return map;
  }

  SavingReminderTableCompanion toCompanion(bool nullToAbsent) {
    return SavingReminderTableCompanion(
      title: Value(title),
      description: Value(description),
      isActive: Value(isActive),
      activeStartDate: Value(activeStartDate),
      notificationType: Value(notificationType),
      id: Value(id),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      amount: Value(amount),
      recurringType: Value(recurringType),
    );
  }

  factory NtfctnSavingReminder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NtfctnSavingReminder(
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      activeStartDate: serializer.fromJson<DateTime>(json['activeStartDate']),
      notificationType: serializer.fromJson<String>(json['notificationType']),
      id: serializer.fromJson<String>(json['id']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      amount: serializer.fromJson<double>(json['amount']),
      recurringType: serializer.fromJson<String>(json['recurringType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'isActive': serializer.toJson<bool>(isActive),
      'activeStartDate': serializer.toJson<DateTime>(activeStartDate),
      'notificationType': serializer.toJson<String>(notificationType),
      'id': serializer.toJson<String>(id),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'amount': serializer.toJson<double>(amount),
      'recurringType': serializer.toJson<String>(recurringType),
    };
  }

  NtfctnSavingReminder copyWith(
          {String? title,
          String? description,
          bool? isActive,
          DateTime? activeStartDate,
          String? notificationType,
          String? id,
          DateTime? dateCreated,
          DateTime? dateUpdated,
          double? amount,
          String? recurringType}) =>
      NtfctnSavingReminder(
        title: title ?? this.title,
        description: description ?? this.description,
        isActive: isActive ?? this.isActive,
        activeStartDate: activeStartDate ?? this.activeStartDate,
        notificationType: notificationType ?? this.notificationType,
        id: id ?? this.id,
        dateCreated: dateCreated ?? this.dateCreated,
        dateUpdated: dateUpdated ?? this.dateUpdated,
        amount: amount ?? this.amount,
        recurringType: recurringType ?? this.recurringType,
      );
  @override
  String toString() {
    return (StringBuffer('NtfctnSavingReminder(')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('activeStartDate: $activeStartDate, ')
          ..write('notificationType: $notificationType, ')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('amount: $amount, ')
          ..write('recurringType: $recurringType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(title, description, isActive, activeStartDate,
      notificationType, id, dateCreated, dateUpdated, amount, recurringType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NtfctnSavingReminder &&
          other.title == this.title &&
          other.description == this.description &&
          other.isActive == this.isActive &&
          other.activeStartDate == this.activeStartDate &&
          other.notificationType == this.notificationType &&
          other.id == this.id &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.amount == this.amount &&
          other.recurringType == this.recurringType);
}

class SavingReminderTableCompanion
    extends UpdateCompanion<NtfctnSavingReminder> {
  final Value<String> title;
  final Value<String> description;
  final Value<bool> isActive;
  final Value<DateTime> activeStartDate;
  final Value<String> notificationType;
  final Value<String> id;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<double> amount;
  final Value<String> recurringType;
  const SavingReminderTableCompanion({
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.activeStartDate = const Value.absent(),
    this.notificationType = const Value.absent(),
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.amount = const Value.absent(),
    this.recurringType = const Value.absent(),
  });
  SavingReminderTableCompanion.insert({
    required String title,
    required String description,
    this.isActive = const Value.absent(),
    required DateTime activeStartDate,
    required String notificationType,
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required double amount,
    required String recurringType,
  })  : title = Value(title),
        description = Value(description),
        activeStartDate = Value(activeStartDate),
        notificationType = Value(notificationType),
        dateUpdated = Value(dateUpdated),
        amount = Value(amount),
        recurringType = Value(recurringType);
  static Insertable<NtfctnSavingReminder> custom({
    Expression<String>? title,
    Expression<String>? description,
    Expression<bool>? isActive,
    Expression<DateTime>? activeStartDate,
    Expression<String>? notificationType,
    Expression<String>? id,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<double>? amount,
    Expression<String>? recurringType,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (activeStartDate != null) 'active_start_date': activeStartDate,
      if (notificationType != null) 'notification_type': notificationType,
      if (id != null) 'id': id,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (amount != null) 'amount': amount,
      if (recurringType != null) 'recurring_type': recurringType,
    });
  }

  SavingReminderTableCompanion copyWith(
      {Value<String>? title,
      Value<String>? description,
      Value<bool>? isActive,
      Value<DateTime>? activeStartDate,
      Value<String>? notificationType,
      Value<String>? id,
      Value<DateTime>? dateCreated,
      Value<DateTime>? dateUpdated,
      Value<double>? amount,
      Value<String>? recurringType}) {
    return SavingReminderTableCompanion(
      title: title ?? this.title,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      activeStartDate: activeStartDate ?? this.activeStartDate,
      notificationType: notificationType ?? this.notificationType,
      id: id ?? this.id,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      amount: amount ?? this.amount,
      recurringType: recurringType ?? this.recurringType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (activeStartDate.present) {
      map['active_start_date'] = Variable<DateTime>(activeStartDate.value);
    }
    if (notificationType.present) {
      map['notification_type'] = Variable<String>(notificationType.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (recurringType.present) {
      map['recurring_type'] = Variable<String>(recurringType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingReminderTableCompanion(')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('activeStartDate: $activeStartDate, ')
          ..write('notificationType: $notificationType, ')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('amount: $amount, ')
          ..write('recurringType: $recurringType')
          ..write(')'))
        .toString();
  }
}

class $MoneyStorageTableTable extends MoneyStorageTable
    with TableInfo<$MoneyStorageTableTable, SvngMoneyStorage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoneyStorageTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => UuidGenerator().v4());
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
      'date_created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _dateUpdatedMeta =
      const VerificationMeta('dateUpdated');
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
      'date_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _iconUrlMeta =
      const VerificationMeta('iconUrl');
  @override
  late final GeneratedColumn<String> iconUrl = GeneratedColumn<String>(
      'icon_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _longNameMeta =
      const VerificationMeta('longName');
  @override
  late final GeneratedColumn<String> longName = GeneratedColumn<String>(
      'long_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _shortNameMeta =
      const VerificationMeta('shortName');
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
      'short_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, dateCreated, dateUpdated, iconUrl, longName, shortName, type];
  @override
  String get aliasedName => _alias ?? 'money_storage_table';
  @override
  String get actualTableName => 'money_storage_table';
  @override
  VerificationContext validateIntegrity(Insertable<SvngMoneyStorage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('date_updated')) {
      context.handle(
          _dateUpdatedMeta,
          dateUpdated.isAcceptableOrUnknown(
              data['date_updated']!, _dateUpdatedMeta));
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('icon_url')) {
      context.handle(_iconUrlMeta,
          iconUrl.isAcceptableOrUnknown(data['icon_url']!, _iconUrlMeta));
    }
    if (data.containsKey('long_name')) {
      context.handle(_longNameMeta,
          longName.isAcceptableOrUnknown(data['long_name']!, _longNameMeta));
    } else if (isInserting) {
      context.missing(_longNameMeta);
    }
    if (data.containsKey('short_name')) {
      context.handle(_shortNameMeta,
          shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta));
    } else if (isInserting) {
      context.missing(_shortNameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SvngMoneyStorage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SvngMoneyStorage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
      dateUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_updated'])!,
      iconUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_url'])!,
      longName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}long_name'])!,
      shortName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}short_name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
    );
  }

  @override
  $MoneyStorageTableTable createAlias(String alias) {
    return $MoneyStorageTableTable(attachedDatabase, alias);
  }
}

class SvngMoneyStorage extends DataClass
    implements Insertable<SvngMoneyStorage> {
  final String id;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String iconUrl;
  final String longName;
  final String shortName;
  final String type;
  const SvngMoneyStorage(
      {required this.id,
      required this.dateCreated,
      required this.dateUpdated,
      required this.iconUrl,
      required this.longName,
      required this.shortName,
      required this.type});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['icon_url'] = Variable<String>(iconUrl);
    map['long_name'] = Variable<String>(longName);
    map['short_name'] = Variable<String>(shortName);
    map['type'] = Variable<String>(type);
    return map;
  }

  MoneyStorageTableCompanion toCompanion(bool nullToAbsent) {
    return MoneyStorageTableCompanion(
      id: Value(id),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      iconUrl: Value(iconUrl),
      longName: Value(longName),
      shortName: Value(shortName),
      type: Value(type),
    );
  }

  factory SvngMoneyStorage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SvngMoneyStorage(
      id: serializer.fromJson<String>(json['id']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      iconUrl: serializer.fromJson<String>(json['iconUrl']),
      longName: serializer.fromJson<String>(json['longName']),
      shortName: serializer.fromJson<String>(json['shortName']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'iconUrl': serializer.toJson<String>(iconUrl),
      'longName': serializer.toJson<String>(longName),
      'shortName': serializer.toJson<String>(shortName),
      'type': serializer.toJson<String>(type),
    };
  }

  SvngMoneyStorage copyWith(
          {String? id,
          DateTime? dateCreated,
          DateTime? dateUpdated,
          String? iconUrl,
          String? longName,
          String? shortName,
          String? type}) =>
      SvngMoneyStorage(
        id: id ?? this.id,
        dateCreated: dateCreated ?? this.dateCreated,
        dateUpdated: dateUpdated ?? this.dateUpdated,
        iconUrl: iconUrl ?? this.iconUrl,
        longName: longName ?? this.longName,
        shortName: shortName ?? this.shortName,
        type: type ?? this.type,
      );
  @override
  String toString() {
    return (StringBuffer('SvngMoneyStorage(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('longName: $longName, ')
          ..write('shortName: $shortName, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, dateCreated, dateUpdated, iconUrl, longName, shortName, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SvngMoneyStorage &&
          other.id == this.id &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.iconUrl == this.iconUrl &&
          other.longName == this.longName &&
          other.shortName == this.shortName &&
          other.type == this.type);
}

class MoneyStorageTableCompanion extends UpdateCompanion<SvngMoneyStorage> {
  final Value<String> id;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> iconUrl;
  final Value<String> longName;
  final Value<String> shortName;
  final Value<String> type;
  const MoneyStorageTableCompanion({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.iconUrl = const Value.absent(),
    this.longName = const Value.absent(),
    this.shortName = const Value.absent(),
    this.type = const Value.absent(),
  });
  MoneyStorageTableCompanion.insert({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    this.iconUrl = const Value.absent(),
    required String longName,
    required String shortName,
    required String type,
  })  : dateUpdated = Value(dateUpdated),
        longName = Value(longName),
        shortName = Value(shortName),
        type = Value(type);
  static Insertable<SvngMoneyStorage> custom({
    Expression<String>? id,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? iconUrl,
    Expression<String>? longName,
    Expression<String>? shortName,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (longName != null) 'long_name': longName,
      if (shortName != null) 'short_name': shortName,
      if (type != null) 'type': type,
    });
  }

  MoneyStorageTableCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? dateCreated,
      Value<DateTime>? dateUpdated,
      Value<String>? iconUrl,
      Value<String>? longName,
      Value<String>? shortName,
      Value<String>? type}) {
    return MoneyStorageTableCompanion(
      id: id ?? this.id,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      iconUrl: iconUrl ?? this.iconUrl,
      longName: longName ?? this.longName,
      shortName: shortName ?? this.shortName,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (iconUrl.present) {
      map['icon_url'] = Variable<String>(iconUrl.value);
    }
    if (longName.present) {
      map['long_name'] = Variable<String>(longName.value);
    }
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoneyStorageTableCompanion(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('longName: $longName, ')
          ..write('shortName: $shortName, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $SavingTableTable extends SavingTable
    with TableInfo<$SavingTableTable, SvngSaving> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => UuidGenerator().v4());
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
      'date_created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _dateUpdatedMeta =
      const VerificationMeta('dateUpdated');
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
      'date_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isPublicMeta =
      const VerificationMeta('isPublic');
  @override
  late final GeneratedColumn<bool> isPublic =
      GeneratedColumn<bool>('is_public', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("is_public" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }),
          defaultValue: const Constant(false));
  static const VerificationMeta _isHasGoalMeta =
      const VerificationMeta('isHasGoal');
  @override
  late final GeneratedColumn<bool> isHasGoal =
      GeneratedColumn<bool>('is_has_goal', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("is_has_goal" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }),
          defaultValue: const Constant(false));
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<double> goal = GeneratedColumn<double>(
      'goal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(.0));
  static const VerificationMeta _isHasStartDateMeta =
      const VerificationMeta('isHasStartDate');
  @override
  late final GeneratedColumn<bool> isHasStartDate =
      GeneratedColumn<bool>('is_has_start_date', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("is_has_start_date" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }),
          defaultValue: const Constant(false));
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isHasEndDateMeta =
      const VerificationMeta('isHasEndDate');
  @override
  late final GeneratedColumn<bool> isHasEndDate =
      GeneratedColumn<bool>('is_has_end_date', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("is_has_end_date" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }),
          defaultValue: const Constant(false));
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSaveDailyMeta =
      const VerificationMeta('isSaveDaily');
  @override
  late final GeneratedColumn<bool> isSaveDaily =
      GeneratedColumn<bool>('is_save_daily', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("is_save_daily" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }),
          defaultValue: const Constant(false));
  static const VerificationMeta _isSaveWeeklyMeta =
      const VerificationMeta('isSaveWeekly');
  @override
  late final GeneratedColumn<bool> isSaveWeekly =
      GeneratedColumn<bool>('is_save_weekly', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("is_save_weekly" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }),
          defaultValue: const Constant(false));
  static const VerificationMeta _isSaveMonthlyMeta =
      const VerificationMeta('isSaveMonthly');
  @override
  late final GeneratedColumn<bool> isSaveMonthly =
      GeneratedColumn<bool>('is_save_monthly', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("is_save_monthly" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }),
          defaultValue: const Constant(false));
  static const VerificationMeta _currentAmountMeta =
      const VerificationMeta('currentAmount');
  @override
  late final GeneratedColumn<double> currentAmount = GeneratedColumn<double>(
      'current_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(.0));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES user_table (id)'));
  static const VerificationMeta _moneyStorageIdMeta =
      const VerificationMeta('moneyStorageId');
  @override
  late final GeneratedColumn<String> moneyStorageId = GeneratedColumn<String>(
      'money_storage_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES money_storage_table (id)'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dateCreated,
        dateUpdated,
        name,
        isPublic,
        isHasGoal,
        goal,
        isHasStartDate,
        startDate,
        isHasEndDate,
        endDate,
        isSaveDaily,
        isSaveWeekly,
        isSaveMonthly,
        currentAmount,
        userId,
        moneyStorageId
      ];
  @override
  String get aliasedName => _alias ?? 'saving_table';
  @override
  String get actualTableName => 'saving_table';
  @override
  VerificationContext validateIntegrity(Insertable<SvngSaving> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('date_updated')) {
      context.handle(
          _dateUpdatedMeta,
          dateUpdated.isAcceptableOrUnknown(
              data['date_updated']!, _dateUpdatedMeta));
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('is_public')) {
      context.handle(_isPublicMeta,
          isPublic.isAcceptableOrUnknown(data['is_public']!, _isPublicMeta));
    }
    if (data.containsKey('is_has_goal')) {
      context.handle(
          _isHasGoalMeta,
          isHasGoal.isAcceptableOrUnknown(
              data['is_has_goal']!, _isHasGoalMeta));
    }
    if (data.containsKey('goal')) {
      context.handle(
          _goalMeta, goal.isAcceptableOrUnknown(data['goal']!, _goalMeta));
    }
    if (data.containsKey('is_has_start_date')) {
      context.handle(
          _isHasStartDateMeta,
          isHasStartDate.isAcceptableOrUnknown(
              data['is_has_start_date']!, _isHasStartDateMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('is_has_end_date')) {
      context.handle(
          _isHasEndDateMeta,
          isHasEndDate.isAcceptableOrUnknown(
              data['is_has_end_date']!, _isHasEndDateMeta));
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('is_save_daily')) {
      context.handle(
          _isSaveDailyMeta,
          isSaveDaily.isAcceptableOrUnknown(
              data['is_save_daily']!, _isSaveDailyMeta));
    }
    if (data.containsKey('is_save_weekly')) {
      context.handle(
          _isSaveWeeklyMeta,
          isSaveWeekly.isAcceptableOrUnknown(
              data['is_save_weekly']!, _isSaveWeeklyMeta));
    }
    if (data.containsKey('is_save_monthly')) {
      context.handle(
          _isSaveMonthlyMeta,
          isSaveMonthly.isAcceptableOrUnknown(
              data['is_save_monthly']!, _isSaveMonthlyMeta));
    }
    if (data.containsKey('current_amount')) {
      context.handle(
          _currentAmountMeta,
          currentAmount.isAcceptableOrUnknown(
              data['current_amount']!, _currentAmountMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('money_storage_id')) {
      context.handle(
          _moneyStorageIdMeta,
          moneyStorageId.isAcceptableOrUnknown(
              data['money_storage_id']!, _moneyStorageIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {name},
      ];
  @override
  SvngSaving map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SvngSaving(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
      dateUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_updated'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      isPublic: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_public'])!,
      isHasGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_has_goal'])!,
      goal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}goal'])!,
      isHasStartDate: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_has_start_date'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date']),
      isHasEndDate: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_has_end_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      isSaveDaily: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_save_daily'])!,
      isSaveWeekly: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_save_weekly'])!,
      isSaveMonthly: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_save_monthly'])!,
      currentAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_amount'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      moneyStorageId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}money_storage_id']),
    );
  }

  @override
  $SavingTableTable createAlias(String alias) {
    return $SavingTableTable(attachedDatabase, alias);
  }
}

class SvngSaving extends DataClass implements Insertable<SvngSaving> {
  final String id;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String? name;
  final bool isPublic;
  final bool isHasGoal;
  final double goal;
  final bool isHasStartDate;
  final DateTime? startDate;
  final bool isHasEndDate;
  final DateTime? endDate;
  final bool isSaveDaily;
  final bool isSaveWeekly;
  final bool isSaveMonthly;
  final double currentAmount;
  final String? userId;
  final String? moneyStorageId;
  const SvngSaving(
      {required this.id,
      required this.dateCreated,
      required this.dateUpdated,
      this.name,
      required this.isPublic,
      required this.isHasGoal,
      required this.goal,
      required this.isHasStartDate,
      this.startDate,
      required this.isHasEndDate,
      this.endDate,
      required this.isSaveDaily,
      required this.isSaveWeekly,
      required this.isSaveMonthly,
      required this.currentAmount,
      this.userId,
      this.moneyStorageId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['is_public'] = Variable<bool>(isPublic);
    map['is_has_goal'] = Variable<bool>(isHasGoal);
    map['goal'] = Variable<double>(goal);
    map['is_has_start_date'] = Variable<bool>(isHasStartDate);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    map['is_has_end_date'] = Variable<bool>(isHasEndDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['is_save_daily'] = Variable<bool>(isSaveDaily);
    map['is_save_weekly'] = Variable<bool>(isSaveWeekly);
    map['is_save_monthly'] = Variable<bool>(isSaveMonthly);
    map['current_amount'] = Variable<double>(currentAmount);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || moneyStorageId != null) {
      map['money_storage_id'] = Variable<String>(moneyStorageId);
    }
    return map;
  }

  SavingTableCompanion toCompanion(bool nullToAbsent) {
    return SavingTableCompanion(
      id: Value(id),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      isPublic: Value(isPublic),
      isHasGoal: Value(isHasGoal),
      goal: Value(goal),
      isHasStartDate: Value(isHasStartDate),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      isHasEndDate: Value(isHasEndDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      isSaveDaily: Value(isSaveDaily),
      isSaveWeekly: Value(isSaveWeekly),
      isSaveMonthly: Value(isSaveMonthly),
      currentAmount: Value(currentAmount),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      moneyStorageId: moneyStorageId == null && nullToAbsent
          ? const Value.absent()
          : Value(moneyStorageId),
    );
  }

  factory SvngSaving.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SvngSaving(
      id: serializer.fromJson<String>(json['id']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      name: serializer.fromJson<String?>(json['name']),
      isPublic: serializer.fromJson<bool>(json['isPublic']),
      isHasGoal: serializer.fromJson<bool>(json['isHasGoal']),
      goal: serializer.fromJson<double>(json['goal']),
      isHasStartDate: serializer.fromJson<bool>(json['isHasStartDate']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      isHasEndDate: serializer.fromJson<bool>(json['isHasEndDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      isSaveDaily: serializer.fromJson<bool>(json['isSaveDaily']),
      isSaveWeekly: serializer.fromJson<bool>(json['isSaveWeekly']),
      isSaveMonthly: serializer.fromJson<bool>(json['isSaveMonthly']),
      currentAmount: serializer.fromJson<double>(json['currentAmount']),
      userId: serializer.fromJson<String?>(json['userId']),
      moneyStorageId: serializer.fromJson<String?>(json['moneyStorageId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'name': serializer.toJson<String?>(name),
      'isPublic': serializer.toJson<bool>(isPublic),
      'isHasGoal': serializer.toJson<bool>(isHasGoal),
      'goal': serializer.toJson<double>(goal),
      'isHasStartDate': serializer.toJson<bool>(isHasStartDate),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'isHasEndDate': serializer.toJson<bool>(isHasEndDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'isSaveDaily': serializer.toJson<bool>(isSaveDaily),
      'isSaveWeekly': serializer.toJson<bool>(isSaveWeekly),
      'isSaveMonthly': serializer.toJson<bool>(isSaveMonthly),
      'currentAmount': serializer.toJson<double>(currentAmount),
      'userId': serializer.toJson<String?>(userId),
      'moneyStorageId': serializer.toJson<String?>(moneyStorageId),
    };
  }

  SvngSaving copyWith(
          {String? id,
          DateTime? dateCreated,
          DateTime? dateUpdated,
          Value<String?> name = const Value.absent(),
          bool? isPublic,
          bool? isHasGoal,
          double? goal,
          bool? isHasStartDate,
          Value<DateTime?> startDate = const Value.absent(),
          bool? isHasEndDate,
          Value<DateTime?> endDate = const Value.absent(),
          bool? isSaveDaily,
          bool? isSaveWeekly,
          bool? isSaveMonthly,
          double? currentAmount,
          Value<String?> userId = const Value.absent(),
          Value<String?> moneyStorageId = const Value.absent()}) =>
      SvngSaving(
        id: id ?? this.id,
        dateCreated: dateCreated ?? this.dateCreated,
        dateUpdated: dateUpdated ?? this.dateUpdated,
        name: name.present ? name.value : this.name,
        isPublic: isPublic ?? this.isPublic,
        isHasGoal: isHasGoal ?? this.isHasGoal,
        goal: goal ?? this.goal,
        isHasStartDate: isHasStartDate ?? this.isHasStartDate,
        startDate: startDate.present ? startDate.value : this.startDate,
        isHasEndDate: isHasEndDate ?? this.isHasEndDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        isSaveDaily: isSaveDaily ?? this.isSaveDaily,
        isSaveWeekly: isSaveWeekly ?? this.isSaveWeekly,
        isSaveMonthly: isSaveMonthly ?? this.isSaveMonthly,
        currentAmount: currentAmount ?? this.currentAmount,
        userId: userId.present ? userId.value : this.userId,
        moneyStorageId:
            moneyStorageId.present ? moneyStorageId.value : this.moneyStorageId,
      );
  @override
  String toString() {
    return (StringBuffer('SvngSaving(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('name: $name, ')
          ..write('isPublic: $isPublic, ')
          ..write('isHasGoal: $isHasGoal, ')
          ..write('goal: $goal, ')
          ..write('isHasStartDate: $isHasStartDate, ')
          ..write('startDate: $startDate, ')
          ..write('isHasEndDate: $isHasEndDate, ')
          ..write('endDate: $endDate, ')
          ..write('isSaveDaily: $isSaveDaily, ')
          ..write('isSaveWeekly: $isSaveWeekly, ')
          ..write('isSaveMonthly: $isSaveMonthly, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('userId: $userId, ')
          ..write('moneyStorageId: $moneyStorageId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      dateCreated,
      dateUpdated,
      name,
      isPublic,
      isHasGoal,
      goal,
      isHasStartDate,
      startDate,
      isHasEndDate,
      endDate,
      isSaveDaily,
      isSaveWeekly,
      isSaveMonthly,
      currentAmount,
      userId,
      moneyStorageId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SvngSaving &&
          other.id == this.id &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.name == this.name &&
          other.isPublic == this.isPublic &&
          other.isHasGoal == this.isHasGoal &&
          other.goal == this.goal &&
          other.isHasStartDate == this.isHasStartDate &&
          other.startDate == this.startDate &&
          other.isHasEndDate == this.isHasEndDate &&
          other.endDate == this.endDate &&
          other.isSaveDaily == this.isSaveDaily &&
          other.isSaveWeekly == this.isSaveWeekly &&
          other.isSaveMonthly == this.isSaveMonthly &&
          other.currentAmount == this.currentAmount &&
          other.userId == this.userId &&
          other.moneyStorageId == this.moneyStorageId);
}

class SavingTableCompanion extends UpdateCompanion<SvngSaving> {
  final Value<String> id;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String?> name;
  final Value<bool> isPublic;
  final Value<bool> isHasGoal;
  final Value<double> goal;
  final Value<bool> isHasStartDate;
  final Value<DateTime?> startDate;
  final Value<bool> isHasEndDate;
  final Value<DateTime?> endDate;
  final Value<bool> isSaveDaily;
  final Value<bool> isSaveWeekly;
  final Value<bool> isSaveMonthly;
  final Value<double> currentAmount;
  final Value<String?> userId;
  final Value<String?> moneyStorageId;
  const SavingTableCompanion({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.name = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.isHasGoal = const Value.absent(),
    this.goal = const Value.absent(),
    this.isHasStartDate = const Value.absent(),
    this.startDate = const Value.absent(),
    this.isHasEndDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isSaveDaily = const Value.absent(),
    this.isSaveWeekly = const Value.absent(),
    this.isSaveMonthly = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.userId = const Value.absent(),
    this.moneyStorageId = const Value.absent(),
  });
  SavingTableCompanion.insert({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    this.name = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.isHasGoal = const Value.absent(),
    this.goal = const Value.absent(),
    this.isHasStartDate = const Value.absent(),
    this.startDate = const Value.absent(),
    this.isHasEndDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isSaveDaily = const Value.absent(),
    this.isSaveWeekly = const Value.absent(),
    this.isSaveMonthly = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.userId = const Value.absent(),
    this.moneyStorageId = const Value.absent(),
  }) : dateUpdated = Value(dateUpdated);
  static Insertable<SvngSaving> custom({
    Expression<String>? id,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? name,
    Expression<bool>? isPublic,
    Expression<bool>? isHasGoal,
    Expression<double>? goal,
    Expression<bool>? isHasStartDate,
    Expression<DateTime>? startDate,
    Expression<bool>? isHasEndDate,
    Expression<DateTime>? endDate,
    Expression<bool>? isSaveDaily,
    Expression<bool>? isSaveWeekly,
    Expression<bool>? isSaveMonthly,
    Expression<double>? currentAmount,
    Expression<String>? userId,
    Expression<String>? moneyStorageId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (name != null) 'name': name,
      if (isPublic != null) 'is_public': isPublic,
      if (isHasGoal != null) 'is_has_goal': isHasGoal,
      if (goal != null) 'goal': goal,
      if (isHasStartDate != null) 'is_has_start_date': isHasStartDate,
      if (startDate != null) 'start_date': startDate,
      if (isHasEndDate != null) 'is_has_end_date': isHasEndDate,
      if (endDate != null) 'end_date': endDate,
      if (isSaveDaily != null) 'is_save_daily': isSaveDaily,
      if (isSaveWeekly != null) 'is_save_weekly': isSaveWeekly,
      if (isSaveMonthly != null) 'is_save_monthly': isSaveMonthly,
      if (currentAmount != null) 'current_amount': currentAmount,
      if (userId != null) 'user_id': userId,
      if (moneyStorageId != null) 'money_storage_id': moneyStorageId,
    });
  }

  SavingTableCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? dateCreated,
      Value<DateTime>? dateUpdated,
      Value<String?>? name,
      Value<bool>? isPublic,
      Value<bool>? isHasGoal,
      Value<double>? goal,
      Value<bool>? isHasStartDate,
      Value<DateTime?>? startDate,
      Value<bool>? isHasEndDate,
      Value<DateTime?>? endDate,
      Value<bool>? isSaveDaily,
      Value<bool>? isSaveWeekly,
      Value<bool>? isSaveMonthly,
      Value<double>? currentAmount,
      Value<String?>? userId,
      Value<String?>? moneyStorageId}) {
    return SavingTableCompanion(
      id: id ?? this.id,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      name: name ?? this.name,
      isPublic: isPublic ?? this.isPublic,
      isHasGoal: isHasGoal ?? this.isHasGoal,
      goal: goal ?? this.goal,
      isHasStartDate: isHasStartDate ?? this.isHasStartDate,
      startDate: startDate ?? this.startDate,
      isHasEndDate: isHasEndDate ?? this.isHasEndDate,
      endDate: endDate ?? this.endDate,
      isSaveDaily: isSaveDaily ?? this.isSaveDaily,
      isSaveWeekly: isSaveWeekly ?? this.isSaveWeekly,
      isSaveMonthly: isSaveMonthly ?? this.isSaveMonthly,
      currentAmount: currentAmount ?? this.currentAmount,
      userId: userId ?? this.userId,
      moneyStorageId: moneyStorageId ?? this.moneyStorageId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isPublic.present) {
      map['is_public'] = Variable<bool>(isPublic.value);
    }
    if (isHasGoal.present) {
      map['is_has_goal'] = Variable<bool>(isHasGoal.value);
    }
    if (goal.present) {
      map['goal'] = Variable<double>(goal.value);
    }
    if (isHasStartDate.present) {
      map['is_has_start_date'] = Variable<bool>(isHasStartDate.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (isHasEndDate.present) {
      map['is_has_end_date'] = Variable<bool>(isHasEndDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (isSaveDaily.present) {
      map['is_save_daily'] = Variable<bool>(isSaveDaily.value);
    }
    if (isSaveWeekly.present) {
      map['is_save_weekly'] = Variable<bool>(isSaveWeekly.value);
    }
    if (isSaveMonthly.present) {
      map['is_save_monthly'] = Variable<bool>(isSaveMonthly.value);
    }
    if (currentAmount.present) {
      map['current_amount'] = Variable<double>(currentAmount.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (moneyStorageId.present) {
      map['money_storage_id'] = Variable<String>(moneyStorageId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingTableCompanion(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('name: $name, ')
          ..write('isPublic: $isPublic, ')
          ..write('isHasGoal: $isHasGoal, ')
          ..write('goal: $goal, ')
          ..write('isHasStartDate: $isHasStartDate, ')
          ..write('startDate: $startDate, ')
          ..write('isHasEndDate: $isHasEndDate, ')
          ..write('endDate: $endDate, ')
          ..write('isSaveDaily: $isSaveDaily, ')
          ..write('isSaveWeekly: $isSaveWeekly, ')
          ..write('isSaveMonthly: $isSaveMonthly, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('userId: $userId, ')
          ..write('moneyStorageId: $moneyStorageId')
          ..write(')'))
        .toString();
  }
}

class $TransactionTableTable extends TransactionTable
    with TableInfo<$TransactionTableTable, TrnsctnTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => UuidGenerator().v4());
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
      'date_created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _dateUpdatedMeta =
      const VerificationMeta('dateUpdated');
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
      'date_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      check: () => amount.isBiggerThan(const Constant(0)),
      type: DriftSqlType.double,
      requiredDuringInsert: true);
  static const VerificationMeta _savingIdMeta =
      const VerificationMeta('savingId');
  @override
  late final GeneratedColumn<String> savingId = GeneratedColumn<String>(
      'saving_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES saving_table (id)'));
  static const VerificationMeta _isExpenseMeta =
      const VerificationMeta('isExpense');
  @override
  late final GeneratedColumn<bool> isExpense =
      GeneratedColumn<bool>('is_expense', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("is_expense" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }),
          defaultValue: const Constant(false));
  static const VerificationMeta _expenseIdMeta =
      const VerificationMeta('expenseId');
  @override
  late final GeneratedColumn<String> expenseId = GeneratedColumn<String>(
      'expense_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES expense_table (id)'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dateCreated,
        dateUpdated,
        type,
        description,
        amount,
        savingId,
        isExpense,
        expenseId
      ];
  @override
  String get aliasedName => _alias ?? 'transaction_table';
  @override
  String get actualTableName => 'transaction_table';
  @override
  VerificationContext validateIntegrity(Insertable<TrnsctnTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('date_updated')) {
      context.handle(
          _dateUpdatedMeta,
          dateUpdated.isAcceptableOrUnknown(
              data['date_updated']!, _dateUpdatedMeta));
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('saving_id')) {
      context.handle(_savingIdMeta,
          savingId.isAcceptableOrUnknown(data['saving_id']!, _savingIdMeta));
    } else if (isInserting) {
      context.missing(_savingIdMeta);
    }
    if (data.containsKey('is_expense')) {
      context.handle(_isExpenseMeta,
          isExpense.isAcceptableOrUnknown(data['is_expense']!, _isExpenseMeta));
    }
    if (data.containsKey('expense_id')) {
      context.handle(_expenseIdMeta,
          expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrnsctnTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrnsctnTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
      dateUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_updated'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      savingId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}saving_id'])!,
      isExpense: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_expense'])!,
      expenseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}expense_id']),
    );
  }

  @override
  $TransactionTableTable createAlias(String alias) {
    return $TransactionTableTable(attachedDatabase, alias);
  }
}

class TrnsctnTransaction extends DataClass
    implements Insertable<TrnsctnTransaction> {
  final String id;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String type;
  final String description;
  final double amount;
  final String savingId;
  final bool isExpense;
  final String? expenseId;
  const TrnsctnTransaction(
      {required this.id,
      required this.dateCreated,
      required this.dateUpdated,
      required this.type,
      required this.description,
      required this.amount,
      required this.savingId,
      required this.isExpense,
      this.expenseId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['type'] = Variable<String>(type);
    map['description'] = Variable<String>(description);
    map['amount'] = Variable<double>(amount);
    map['saving_id'] = Variable<String>(savingId);
    map['is_expense'] = Variable<bool>(isExpense);
    if (!nullToAbsent || expenseId != null) {
      map['expense_id'] = Variable<String>(expenseId);
    }
    return map;
  }

  TransactionTableCompanion toCompanion(bool nullToAbsent) {
    return TransactionTableCompanion(
      id: Value(id),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      type: Value(type),
      description: Value(description),
      amount: Value(amount),
      savingId: Value(savingId),
      isExpense: Value(isExpense),
      expenseId: expenseId == null && nullToAbsent
          ? const Value.absent()
          : Value(expenseId),
    );
  }

  factory TrnsctnTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrnsctnTransaction(
      id: serializer.fromJson<String>(json['id']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      type: serializer.fromJson<String>(json['type']),
      description: serializer.fromJson<String>(json['description']),
      amount: serializer.fromJson<double>(json['amount']),
      savingId: serializer.fromJson<String>(json['savingId']),
      isExpense: serializer.fromJson<bool>(json['isExpense']),
      expenseId: serializer.fromJson<String?>(json['expenseId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'type': serializer.toJson<String>(type),
      'description': serializer.toJson<String>(description),
      'amount': serializer.toJson<double>(amount),
      'savingId': serializer.toJson<String>(savingId),
      'isExpense': serializer.toJson<bool>(isExpense),
      'expenseId': serializer.toJson<String?>(expenseId),
    };
  }

  TrnsctnTransaction copyWith(
          {String? id,
          DateTime? dateCreated,
          DateTime? dateUpdated,
          String? type,
          String? description,
          double? amount,
          String? savingId,
          bool? isExpense,
          Value<String?> expenseId = const Value.absent()}) =>
      TrnsctnTransaction(
        id: id ?? this.id,
        dateCreated: dateCreated ?? this.dateCreated,
        dateUpdated: dateUpdated ?? this.dateUpdated,
        type: type ?? this.type,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        savingId: savingId ?? this.savingId,
        isExpense: isExpense ?? this.isExpense,
        expenseId: expenseId.present ? expenseId.value : this.expenseId,
      );
  @override
  String toString() {
    return (StringBuffer('TrnsctnTransaction(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('savingId: $savingId, ')
          ..write('isExpense: $isExpense, ')
          ..write('expenseId: $expenseId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dateCreated, dateUpdated, type,
      description, amount, savingId, isExpense, expenseId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrnsctnTransaction &&
          other.id == this.id &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.type == this.type &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.savingId == this.savingId &&
          other.isExpense == this.isExpense &&
          other.expenseId == this.expenseId);
}

class TransactionTableCompanion extends UpdateCompanion<TrnsctnTransaction> {
  final Value<String> id;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> type;
  final Value<String> description;
  final Value<double> amount;
  final Value<String> savingId;
  final Value<bool> isExpense;
  final Value<String?> expenseId;
  const TransactionTableCompanion({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.savingId = const Value.absent(),
    this.isExpense = const Value.absent(),
    this.expenseId = const Value.absent(),
  });
  TransactionTableCompanion.insert({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required String type,
    this.description = const Value.absent(),
    required double amount,
    required String savingId,
    this.isExpense = const Value.absent(),
    this.expenseId = const Value.absent(),
  })  : dateUpdated = Value(dateUpdated),
        type = Value(type),
        amount = Value(amount),
        savingId = Value(savingId);
  static Insertable<TrnsctnTransaction> custom({
    Expression<String>? id,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? type,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<String>? savingId,
    Expression<bool>? isExpense,
    Expression<String>? expenseId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (savingId != null) 'saving_id': savingId,
      if (isExpense != null) 'is_expense': isExpense,
      if (expenseId != null) 'expense_id': expenseId,
    });
  }

  TransactionTableCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? dateCreated,
      Value<DateTime>? dateUpdated,
      Value<String>? type,
      Value<String>? description,
      Value<double>? amount,
      Value<String>? savingId,
      Value<bool>? isExpense,
      Value<String?>? expenseId}) {
    return TransactionTableCompanion(
      id: id ?? this.id,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      type: type ?? this.type,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      savingId: savingId ?? this.savingId,
      isExpense: isExpense ?? this.isExpense,
      expenseId: expenseId ?? this.expenseId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (savingId.present) {
      map['saving_id'] = Variable<String>(savingId.value);
    }
    if (isExpense.present) {
      map['is_expense'] = Variable<bool>(isExpense.value);
    }
    if (expenseId.present) {
      map['expense_id'] = Variable<String>(expenseId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTableCompanion(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('savingId: $savingId, ')
          ..write('isExpense: $isExpense, ')
          ..write('expenseId: $expenseId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $UserTableTable userTable = $UserTableTable(this);
  late final $GroupReferenceTableTable groupReferenceTable =
      $GroupReferenceTableTable(this);
  late final $ReferenceTableTable referenceTable = $ReferenceTableTable(this);
  late final $ReferenceDataTableTable referenceDataTable =
      $ReferenceDataTableTable(this);
  late final $ExpenseTableTable expenseTable = $ExpenseTableTable(this);
  late final $ExpenseReferenceTableTable expenseReferenceTable =
      $ExpenseReferenceTableTable(this);
  late final $SavingReminderTableTable savingReminderTable =
      $SavingReminderTableTable(this);
  late final $MoneyStorageTableTable moneyStorageTable =
      $MoneyStorageTableTable(this);
  late final $SavingTableTable savingTable = $SavingTableTable(this);
  late final $TransactionTableTable transactionTable =
      $TransactionTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        userTable,
        groupReferenceTable,
        referenceTable,
        referenceDataTable,
        expenseTable,
        expenseReferenceTable,
        savingReminderTable,
        moneyStorageTable,
        savingTable,
        transactionTable
      ];
}
