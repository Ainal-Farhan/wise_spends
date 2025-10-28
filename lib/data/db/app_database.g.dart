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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => UuidGenerator().v4(),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
    'date_created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dateUpdatedMeta = const VerificationMeta(
    'dateUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
    'date_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    name,
    email,
    phoneNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CmmnUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    }
    if (data.containsKey('date_updated')) {
      context.handle(
        _dateUpdatedMeta,
        dateUpdated.isAcceptableOrUnknown(
          data['date_updated']!,
          _dateUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedByMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
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
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_created'],
      )!,
      dateUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_updated'],
      )!,
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
    );
  }

  @override
  $UserTableTable createAlias(String alias) {
    return $UserTableTable(attachedDatabase, alias);
  }
}

class CmmnUser extends DataClass implements Insertable<CmmnUser> {
  final String id;
  final String createdBy;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String lastModifiedBy;
  final String name;
  final String? email;
  final String? phoneNumber;
  const CmmnUser({
    required this.id,
    required this.createdBy,
    required this.dateCreated,
    required this.dateUpdated,
    required this.lastModifiedBy,
    required this.name,
    this.email,
    this.phoneNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_by'] = Variable<String>(createdBy);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['last_modified_by'] = Variable<String>(lastModifiedBy);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    return map;
  }

  UserTableCompanion toCompanion(bool nullToAbsent) {
    return UserTableCompanion(
      id: Value(id),
      createdBy: Value(createdBy),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      lastModifiedBy: Value(lastModifiedBy),
      name: Value(name),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
    );
  }

  factory CmmnUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CmmnUser(
      id: serializer.fromJson<String>(json['id']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      lastModifiedBy: serializer.fromJson<String>(json['lastModifiedBy']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdBy': serializer.toJson<String>(createdBy),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'lastModifiedBy': serializer.toJson<String>(lastModifiedBy),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String?>(email),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
    };
  }

  CmmnUser copyWith({
    String? id,
    String? createdBy,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    String? lastModifiedBy,
    String? name,
    Value<String?> email = const Value.absent(),
    Value<String?> phoneNumber = const Value.absent(),
  }) => CmmnUser(
    id: id ?? this.id,
    createdBy: createdBy ?? this.createdBy,
    dateCreated: dateCreated ?? this.dateCreated,
    dateUpdated: dateUpdated ?? this.dateUpdated,
    lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    name: name ?? this.name,
    email: email.present ? email.value : this.email,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
  );
  CmmnUser copyWithCompanion(UserTableCompanion data) {
    return CmmnUser(
      id: data.id.present ? data.id.value : this.id,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
      dateUpdated: data.dateUpdated.present
          ? data.dateUpdated.value
          : this.dateUpdated,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CmmnUser(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phoneNumber: $phoneNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    name,
    email,
    phoneNumber,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CmmnUser &&
          other.id == this.id &&
          other.createdBy == this.createdBy &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.lastModifiedBy == this.lastModifiedBy &&
          other.name == this.name &&
          other.email == this.email &&
          other.phoneNumber == this.phoneNumber);
}

class UserTableCompanion extends UpdateCompanion<CmmnUser> {
  final Value<String> id;
  final Value<String> createdBy;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> lastModifiedBy;
  final Value<String> name;
  final Value<String?> email;
  final Value<String?> phoneNumber;
  final Value<int> rowid;
  const UserTableCompanion({
    this.id = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserTableCompanion.insert({
    this.id = const Value.absent(),
    required String createdBy,
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required String lastModifiedBy,
    required String name,
    this.email = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdBy = Value(createdBy),
       dateUpdated = Value(dateUpdated),
       lastModifiedBy = Value(lastModifiedBy),
       name = Value(name);
  static Insertable<CmmnUser> custom({
    Expression<String>? id,
    Expression<String>? createdBy,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? lastModifiedBy,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? phoneNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdBy != null) 'created_by': createdBy,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserTableCompanion copyWith({
    Value<String>? id,
    Value<String>? createdBy,
    Value<DateTime>? dateCreated,
    Value<DateTime>? dateUpdated,
    Value<String>? lastModifiedBy,
    Value<String>? name,
    Value<String?>? email,
    Value<String?>? phoneNumber,
    Value<int>? rowid,
  }) {
    return UserTableCompanion(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserTableCompanion(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('rowid: $rowid')
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => UuidGenerator().v4(),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
    'date_created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dateUpdatedMeta = const VerificationMeta(
    'dateUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
    'date_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    label,
    value,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_reference_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MstrdtGroupReference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    }
    if (data.containsKey('date_updated')) {
      context.handle(
        _dateUpdatedMeta,
        dateUpdated.isAcceptableOrUnknown(
          data['date_updated']!,
          _dateUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedByMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
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
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_created'],
      )!,
      dateUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_updated'],
      )!,
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
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
  final String createdBy;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String lastModifiedBy;
  final String label;
  final String value;
  const MstrdtGroupReference({
    required this.id,
    required this.createdBy,
    required this.dateCreated,
    required this.dateUpdated,
    required this.lastModifiedBy,
    required this.label,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_by'] = Variable<String>(createdBy);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['last_modified_by'] = Variable<String>(lastModifiedBy);
    map['label'] = Variable<String>(label);
    map['value'] = Variable<String>(value);
    return map;
  }

  GroupReferenceTableCompanion toCompanion(bool nullToAbsent) {
    return GroupReferenceTableCompanion(
      id: Value(id),
      createdBy: Value(createdBy),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      lastModifiedBy: Value(lastModifiedBy),
      label: Value(label),
      value: Value(value),
    );
  }

  factory MstrdtGroupReference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MstrdtGroupReference(
      id: serializer.fromJson<String>(json['id']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      lastModifiedBy: serializer.fromJson<String>(json['lastModifiedBy']),
      label: serializer.fromJson<String>(json['label']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdBy': serializer.toJson<String>(createdBy),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'lastModifiedBy': serializer.toJson<String>(lastModifiedBy),
      'label': serializer.toJson<String>(label),
      'value': serializer.toJson<String>(value),
    };
  }

  MstrdtGroupReference copyWith({
    String? id,
    String? createdBy,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    String? lastModifiedBy,
    String? label,
    String? value,
  }) => MstrdtGroupReference(
    id: id ?? this.id,
    createdBy: createdBy ?? this.createdBy,
    dateCreated: dateCreated ?? this.dateCreated,
    dateUpdated: dateUpdated ?? this.dateUpdated,
    lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    label: label ?? this.label,
    value: value ?? this.value,
  );
  MstrdtGroupReference copyWithCompanion(GroupReferenceTableCompanion data) {
    return MstrdtGroupReference(
      id: data.id.present ? data.id.value : this.id,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
      dateUpdated: data.dateUpdated.present
          ? data.dateUpdated.value
          : this.dateUpdated,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      label: data.label.present ? data.label.value : this.label,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MstrdtGroupReference(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('label: $label, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    label,
    value,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MstrdtGroupReference &&
          other.id == this.id &&
          other.createdBy == this.createdBy &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.lastModifiedBy == this.lastModifiedBy &&
          other.label == this.label &&
          other.value == this.value);
}

class GroupReferenceTableCompanion
    extends UpdateCompanion<MstrdtGroupReference> {
  final Value<String> id;
  final Value<String> createdBy;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> lastModifiedBy;
  final Value<String> label;
  final Value<String> value;
  final Value<int> rowid;
  const GroupReferenceTableCompanion({
    this.id = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    this.label = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupReferenceTableCompanion.insert({
    this.id = const Value.absent(),
    required String createdBy,
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required String lastModifiedBy,
    required String label,
    required String value,
    this.rowid = const Value.absent(),
  }) : createdBy = Value(createdBy),
       dateUpdated = Value(dateUpdated),
       lastModifiedBy = Value(lastModifiedBy),
       label = Value(label),
       value = Value(value);
  static Insertable<MstrdtGroupReference> custom({
    Expression<String>? id,
    Expression<String>? createdBy,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? lastModifiedBy,
    Expression<String>? label,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdBy != null) 'created_by': createdBy,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
      if (label != null) 'label': label,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupReferenceTableCompanion copyWith({
    Value<String>? id,
    Value<String>? createdBy,
    Value<DateTime>? dateCreated,
    Value<DateTime>? dateUpdated,
    Value<String>? lastModifiedBy,
    Value<String>? label,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return GroupReferenceTableCompanion(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      label: label ?? this.label,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupReferenceTableCompanion(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('label: $label, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => UuidGenerator().v4(),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
    'date_created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dateUpdatedMeta = const VerificationMeta(
    'dateUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
    'date_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _belongToMeta = const VerificationMeta(
    'belongTo',
  );
  @override
  late final GeneratedColumn<String> belongTo = GeneratedColumn<String>(
    'belong_to',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reference_table (id)',
    ),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES group_reference_table (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    label,
    value,
    isActive,
    belongTo,
    groupId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reference_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MstrdtReference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    }
    if (data.containsKey('date_updated')) {
      context.handle(
        _dateUpdatedMeta,
        dateUpdated.isAcceptableOrUnknown(
          data['date_updated']!,
          _dateUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedByMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('belong_to')) {
      context.handle(
        _belongToMeta,
        belongTo.isAcceptableOrUnknown(data['belong_to']!, _belongToMeta),
      );
    } else if (isInserting) {
      context.missing(_belongToMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
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
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_created'],
      )!,
      dateUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_updated'],
      )!,
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      belongTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}belong_to'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
    );
  }

  @override
  $ReferenceTableTable createAlias(String alias) {
    return $ReferenceTableTable(attachedDatabase, alias);
  }
}

class MstrdtReference extends DataClass implements Insertable<MstrdtReference> {
  final String id;
  final String createdBy;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String lastModifiedBy;
  final String label;
  final String value;
  final bool isActive;
  final String belongTo;
  final String groupId;
  const MstrdtReference({
    required this.id,
    required this.createdBy,
    required this.dateCreated,
    required this.dateUpdated,
    required this.lastModifiedBy,
    required this.label,
    required this.value,
    required this.isActive,
    required this.belongTo,
    required this.groupId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_by'] = Variable<String>(createdBy);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['last_modified_by'] = Variable<String>(lastModifiedBy);
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
      createdBy: Value(createdBy),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      lastModifiedBy: Value(lastModifiedBy),
      label: Value(label),
      value: Value(value),
      isActive: Value(isActive),
      belongTo: Value(belongTo),
      groupId: Value(groupId),
    );
  }

  factory MstrdtReference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MstrdtReference(
      id: serializer.fromJson<String>(json['id']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      lastModifiedBy: serializer.fromJson<String>(json['lastModifiedBy']),
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
      'createdBy': serializer.toJson<String>(createdBy),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'lastModifiedBy': serializer.toJson<String>(lastModifiedBy),
      'label': serializer.toJson<String>(label),
      'value': serializer.toJson<String>(value),
      'isActive': serializer.toJson<bool>(isActive),
      'belongTo': serializer.toJson<String>(belongTo),
      'groupId': serializer.toJson<String>(groupId),
    };
  }

  MstrdtReference copyWith({
    String? id,
    String? createdBy,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    String? lastModifiedBy,
    String? label,
    String? value,
    bool? isActive,
    String? belongTo,
    String? groupId,
  }) => MstrdtReference(
    id: id ?? this.id,
    createdBy: createdBy ?? this.createdBy,
    dateCreated: dateCreated ?? this.dateCreated,
    dateUpdated: dateUpdated ?? this.dateUpdated,
    lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    label: label ?? this.label,
    value: value ?? this.value,
    isActive: isActive ?? this.isActive,
    belongTo: belongTo ?? this.belongTo,
    groupId: groupId ?? this.groupId,
  );
  MstrdtReference copyWithCompanion(ReferenceTableCompanion data) {
    return MstrdtReference(
      id: data.id.present ? data.id.value : this.id,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
      dateUpdated: data.dateUpdated.present
          ? data.dateUpdated.value
          : this.dateUpdated,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      label: data.label.present ? data.label.value : this.label,
      value: data.value.present ? data.value.value : this.value,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      belongTo: data.belongTo.present ? data.belongTo.value : this.belongTo,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MstrdtReference(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
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
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    label,
    value,
    isActive,
    belongTo,
    groupId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MstrdtReference &&
          other.id == this.id &&
          other.createdBy == this.createdBy &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.lastModifiedBy == this.lastModifiedBy &&
          other.label == this.label &&
          other.value == this.value &&
          other.isActive == this.isActive &&
          other.belongTo == this.belongTo &&
          other.groupId == this.groupId);
}

class ReferenceTableCompanion extends UpdateCompanion<MstrdtReference> {
  final Value<String> id;
  final Value<String> createdBy;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> lastModifiedBy;
  final Value<String> label;
  final Value<String> value;
  final Value<bool> isActive;
  final Value<String> belongTo;
  final Value<String> groupId;
  final Value<int> rowid;
  const ReferenceTableCompanion({
    this.id = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    this.label = const Value.absent(),
    this.value = const Value.absent(),
    this.isActive = const Value.absent(),
    this.belongTo = const Value.absent(),
    this.groupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReferenceTableCompanion.insert({
    this.id = const Value.absent(),
    required String createdBy,
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required String lastModifiedBy,
    required String label,
    required String value,
    this.isActive = const Value.absent(),
    required String belongTo,
    required String groupId,
    this.rowid = const Value.absent(),
  }) : createdBy = Value(createdBy),
       dateUpdated = Value(dateUpdated),
       lastModifiedBy = Value(lastModifiedBy),
       label = Value(label),
       value = Value(value),
       belongTo = Value(belongTo),
       groupId = Value(groupId);
  static Insertable<MstrdtReference> custom({
    Expression<String>? id,
    Expression<String>? createdBy,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? lastModifiedBy,
    Expression<String>? label,
    Expression<String>? value,
    Expression<bool>? isActive,
    Expression<String>? belongTo,
    Expression<String>? groupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdBy != null) 'created_by': createdBy,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
      if (label != null) 'label': label,
      if (value != null) 'value': value,
      if (isActive != null) 'is_active': isActive,
      if (belongTo != null) 'belong_to': belongTo,
      if (groupId != null) 'group_id': groupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReferenceTableCompanion copyWith({
    Value<String>? id,
    Value<String>? createdBy,
    Value<DateTime>? dateCreated,
    Value<DateTime>? dateUpdated,
    Value<String>? lastModifiedBy,
    Value<String>? label,
    Value<String>? value,
    Value<bool>? isActive,
    Value<String>? belongTo,
    Value<String>? groupId,
    Value<int>? rowid,
  }) {
    return ReferenceTableCompanion(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      label: label ?? this.label,
      value: value ?? this.value,
      isActive: isActive ?? this.isActive,
      belongTo: belongTo ?? this.belongTo,
      groupId: groupId ?? this.groupId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceTableCompanion(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('label: $label, ')
          ..write('value: $value, ')
          ..write('isActive: $isActive, ')
          ..write('belongTo: $belongTo, ')
          ..write('groupId: $groupId, ')
          ..write('rowid: $rowid')
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => UuidGenerator().v4(),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
    'date_created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dateUpdatedMeta = const VerificationMeta(
    'dateUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
    'date_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupLabelMeta = const VerificationMeta(
    'groupLabel',
  );
  @override
  late final GeneratedColumn<String> groupLabel = GeneratedColumn<String>(
    'group_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupValueMeta = const VerificationMeta(
    'groupValue',
  );
  @override
  late final GeneratedColumn<String> groupValue = GeneratedColumn<String>(
    'group_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceIdMeta = const VerificationMeta(
    'referenceId',
  );
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
    'reference_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reference_table (id)',
    ),
  );
  static const VerificationMeta _isHasNextMeta = const VerificationMeta(
    'isHasNext',
  );
  @override
  late final GeneratedColumn<bool> isHasNext = GeneratedColumn<bool>(
    'is_has_next',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_has_next" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nextReferenceDataIdMeta =
      const VerificationMeta('nextReferenceDataId');
  @override
  late final GeneratedColumn<String> nextReferenceDataId =
      GeneratedColumn<String>(
        'next_reference_data_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES reference_data_table (id)',
        ),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    label,
    groupLabel,
    value,
    groupValue,
    referenceId,
    isHasNext,
    nextReferenceDataId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reference_data_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MstrdtReferenceData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    }
    if (data.containsKey('date_updated')) {
      context.handle(
        _dateUpdatedMeta,
        dateUpdated.isAcceptableOrUnknown(
          data['date_updated']!,
          _dateUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedByMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('group_label')) {
      context.handle(
        _groupLabelMeta,
        groupLabel.isAcceptableOrUnknown(data['group_label']!, _groupLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_groupLabelMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('group_value')) {
      context.handle(
        _groupValueMeta,
        groupValue.isAcceptableOrUnknown(data['group_value']!, _groupValueMeta),
      );
    } else if (isInserting) {
      context.missing(_groupValueMeta);
    }
    if (data.containsKey('reference_id')) {
      context.handle(
        _referenceIdMeta,
        referenceId.isAcceptableOrUnknown(
          data['reference_id']!,
          _referenceIdMeta,
        ),
      );
    }
    if (data.containsKey('is_has_next')) {
      context.handle(
        _isHasNextMeta,
        isHasNext.isAcceptableOrUnknown(data['is_has_next']!, _isHasNextMeta),
      );
    }
    if (data.containsKey('next_reference_data_id')) {
      context.handle(
        _nextReferenceDataIdMeta,
        nextReferenceDataId.isAcceptableOrUnknown(
          data['next_reference_data_id']!,
          _nextReferenceDataIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MstrdtReferenceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MstrdtReferenceData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_created'],
      )!,
      dateUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_updated'],
      )!,
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      groupLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_label'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      groupValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_value'],
      )!,
      referenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_id'],
      ),
      isHasNext: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_has_next'],
      )!,
      nextReferenceDataId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_reference_data_id'],
      ),
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
  final String createdBy;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String lastModifiedBy;
  final String label;
  final String groupLabel;
  final String value;
  final String groupValue;
  final String? referenceId;
  final bool isHasNext;
  final String? nextReferenceDataId;
  const MstrdtReferenceData({
    required this.id,
    required this.createdBy,
    required this.dateCreated,
    required this.dateUpdated,
    required this.lastModifiedBy,
    required this.label,
    required this.groupLabel,
    required this.value,
    required this.groupValue,
    this.referenceId,
    required this.isHasNext,
    this.nextReferenceDataId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_by'] = Variable<String>(createdBy);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['last_modified_by'] = Variable<String>(lastModifiedBy);
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
      createdBy: Value(createdBy),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      lastModifiedBy: Value(lastModifiedBy),
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

  factory MstrdtReferenceData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MstrdtReferenceData(
      id: serializer.fromJson<String>(json['id']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      lastModifiedBy: serializer.fromJson<String>(json['lastModifiedBy']),
      label: serializer.fromJson<String>(json['label']),
      groupLabel: serializer.fromJson<String>(json['groupLabel']),
      value: serializer.fromJson<String>(json['value']),
      groupValue: serializer.fromJson<String>(json['groupValue']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      isHasNext: serializer.fromJson<bool>(json['isHasNext']),
      nextReferenceDataId: serializer.fromJson<String?>(
        json['nextReferenceDataId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdBy': serializer.toJson<String>(createdBy),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'lastModifiedBy': serializer.toJson<String>(lastModifiedBy),
      'label': serializer.toJson<String>(label),
      'groupLabel': serializer.toJson<String>(groupLabel),
      'value': serializer.toJson<String>(value),
      'groupValue': serializer.toJson<String>(groupValue),
      'referenceId': serializer.toJson<String?>(referenceId),
      'isHasNext': serializer.toJson<bool>(isHasNext),
      'nextReferenceDataId': serializer.toJson<String?>(nextReferenceDataId),
    };
  }

  MstrdtReferenceData copyWith({
    String? id,
    String? createdBy,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    String? lastModifiedBy,
    String? label,
    String? groupLabel,
    String? value,
    String? groupValue,
    Value<String?> referenceId = const Value.absent(),
    bool? isHasNext,
    Value<String?> nextReferenceDataId = const Value.absent(),
  }) => MstrdtReferenceData(
    id: id ?? this.id,
    createdBy: createdBy ?? this.createdBy,
    dateCreated: dateCreated ?? this.dateCreated,
    dateUpdated: dateUpdated ?? this.dateUpdated,
    lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
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
  MstrdtReferenceData copyWithCompanion(ReferenceDataTableCompanion data) {
    return MstrdtReferenceData(
      id: data.id.present ? data.id.value : this.id,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
      dateUpdated: data.dateUpdated.present
          ? data.dateUpdated.value
          : this.dateUpdated,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      label: data.label.present ? data.label.value : this.label,
      groupLabel: data.groupLabel.present
          ? data.groupLabel.value
          : this.groupLabel,
      value: data.value.present ? data.value.value : this.value,
      groupValue: data.groupValue.present
          ? data.groupValue.value
          : this.groupValue,
      referenceId: data.referenceId.present
          ? data.referenceId.value
          : this.referenceId,
      isHasNext: data.isHasNext.present ? data.isHasNext.value : this.isHasNext,
      nextReferenceDataId: data.nextReferenceDataId.present
          ? data.nextReferenceDataId.value
          : this.nextReferenceDataId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MstrdtReferenceData(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
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
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    label,
    groupLabel,
    value,
    groupValue,
    referenceId,
    isHasNext,
    nextReferenceDataId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MstrdtReferenceData &&
          other.id == this.id &&
          other.createdBy == this.createdBy &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.lastModifiedBy == this.lastModifiedBy &&
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
  final Value<String> createdBy;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> lastModifiedBy;
  final Value<String> label;
  final Value<String> groupLabel;
  final Value<String> value;
  final Value<String> groupValue;
  final Value<String?> referenceId;
  final Value<bool> isHasNext;
  final Value<String?> nextReferenceDataId;
  final Value<int> rowid;
  const ReferenceDataTableCompanion({
    this.id = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    this.label = const Value.absent(),
    this.groupLabel = const Value.absent(),
    this.value = const Value.absent(),
    this.groupValue = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.isHasNext = const Value.absent(),
    this.nextReferenceDataId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReferenceDataTableCompanion.insert({
    this.id = const Value.absent(),
    required String createdBy,
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required String lastModifiedBy,
    required String label,
    required String groupLabel,
    required String value,
    required String groupValue,
    this.referenceId = const Value.absent(),
    this.isHasNext = const Value.absent(),
    this.nextReferenceDataId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdBy = Value(createdBy),
       dateUpdated = Value(dateUpdated),
       lastModifiedBy = Value(lastModifiedBy),
       label = Value(label),
       groupLabel = Value(groupLabel),
       value = Value(value),
       groupValue = Value(groupValue);
  static Insertable<MstrdtReferenceData> custom({
    Expression<String>? id,
    Expression<String>? createdBy,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? lastModifiedBy,
    Expression<String>? label,
    Expression<String>? groupLabel,
    Expression<String>? value,
    Expression<String>? groupValue,
    Expression<String>? referenceId,
    Expression<bool>? isHasNext,
    Expression<String>? nextReferenceDataId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdBy != null) 'created_by': createdBy,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
      if (label != null) 'label': label,
      if (groupLabel != null) 'group_label': groupLabel,
      if (value != null) 'value': value,
      if (groupValue != null) 'group_value': groupValue,
      if (referenceId != null) 'reference_id': referenceId,
      if (isHasNext != null) 'is_has_next': isHasNext,
      if (nextReferenceDataId != null)
        'next_reference_data_id': nextReferenceDataId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReferenceDataTableCompanion copyWith({
    Value<String>? id,
    Value<String>? createdBy,
    Value<DateTime>? dateCreated,
    Value<DateTime>? dateUpdated,
    Value<String>? lastModifiedBy,
    Value<String>? label,
    Value<String>? groupLabel,
    Value<String>? value,
    Value<String>? groupValue,
    Value<String?>? referenceId,
    Value<bool>? isHasNext,
    Value<String?>? nextReferenceDataId,
    Value<int>? rowid,
  }) {
    return ReferenceDataTableCompanion(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      label: label ?? this.label,
      groupLabel: groupLabel ?? this.groupLabel,
      value: value ?? this.value,
      groupValue: groupValue ?? this.groupValue,
      referenceId: referenceId ?? this.referenceId,
      isHasNext: isHasNext ?? this.isHasNext,
      nextReferenceDataId: nextReferenceDataId ?? this.nextReferenceDataId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
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
      map['next_reference_data_id'] = Variable<String>(
        nextReferenceDataId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceDataTableCompanion(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('label: $label, ')
          ..write('groupLabel: $groupLabel, ')
          ..write('value: $value, ')
          ..write('groupValue: $groupValue, ')
          ..write('referenceId: $referenceId, ')
          ..write('isHasNext: $isHasNext, ')
          ..write('nextReferenceDataId: $nextReferenceDataId, ')
          ..write('rowid: $rowid')
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => UuidGenerator().v4(),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
    'date_created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dateUpdatedMeta = const VerificationMeta(
    'dateUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
    'date_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _suggestedAmountMeta = const VerificationMeta(
    'suggestedAmount',
  );
  @override
  late final GeneratedColumn<double> suggestedAmount = GeneratedColumn<double>(
    'suggested_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(.0),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceIdMeta = const VerificationMeta(
    'referenceId',
  );
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
    'reference_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reference_table (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    suggestedAmount,
    description,
    referenceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_reference_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MstrdtExpenseReference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    }
    if (data.containsKey('date_updated')) {
      context.handle(
        _dateUpdatedMeta,
        dateUpdated.isAcceptableOrUnknown(
          data['date_updated']!,
          _dateUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedByMeta);
    }
    if (data.containsKey('suggested_amount')) {
      context.handle(
        _suggestedAmountMeta,
        suggestedAmount.isAcceptableOrUnknown(
          data['suggested_amount']!,
          _suggestedAmountMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('reference_id')) {
      context.handle(
        _referenceIdMeta,
        referenceId.isAcceptableOrUnknown(
          data['reference_id']!,
          _referenceIdMeta,
        ),
      );
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
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_created'],
      )!,
      dateUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_updated'],
      )!,
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      )!,
      suggestedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}suggested_amount'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      referenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_id'],
      )!,
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
  final String createdBy;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String lastModifiedBy;
  final double suggestedAmount;
  final String? description;
  final String referenceId;
  const MstrdtExpenseReference({
    required this.id,
    required this.createdBy,
    required this.dateCreated,
    required this.dateUpdated,
    required this.lastModifiedBy,
    required this.suggestedAmount,
    this.description,
    required this.referenceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_by'] = Variable<String>(createdBy);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['last_modified_by'] = Variable<String>(lastModifiedBy);
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
      createdBy: Value(createdBy),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      lastModifiedBy: Value(lastModifiedBy),
      suggestedAmount: Value(suggestedAmount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      referenceId: Value(referenceId),
    );
  }

  factory MstrdtExpenseReference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MstrdtExpenseReference(
      id: serializer.fromJson<String>(json['id']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      lastModifiedBy: serializer.fromJson<String>(json['lastModifiedBy']),
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
      'createdBy': serializer.toJson<String>(createdBy),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'lastModifiedBy': serializer.toJson<String>(lastModifiedBy),
      'suggestedAmount': serializer.toJson<double>(suggestedAmount),
      'description': serializer.toJson<String?>(description),
      'referenceId': serializer.toJson<String>(referenceId),
    };
  }

  MstrdtExpenseReference copyWith({
    String? id,
    String? createdBy,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    String? lastModifiedBy,
    double? suggestedAmount,
    Value<String?> description = const Value.absent(),
    String? referenceId,
  }) => MstrdtExpenseReference(
    id: id ?? this.id,
    createdBy: createdBy ?? this.createdBy,
    dateCreated: dateCreated ?? this.dateCreated,
    dateUpdated: dateUpdated ?? this.dateUpdated,
    lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    suggestedAmount: suggestedAmount ?? this.suggestedAmount,
    description: description.present ? description.value : this.description,
    referenceId: referenceId ?? this.referenceId,
  );
  MstrdtExpenseReference copyWithCompanion(
    ExpenseReferenceTableCompanion data,
  ) {
    return MstrdtExpenseReference(
      id: data.id.present ? data.id.value : this.id,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
      dateUpdated: data.dateUpdated.present
          ? data.dateUpdated.value
          : this.dateUpdated,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      suggestedAmount: data.suggestedAmount.present
          ? data.suggestedAmount.value
          : this.suggestedAmount,
      description: data.description.present
          ? data.description.value
          : this.description,
      referenceId: data.referenceId.present
          ? data.referenceId.value
          : this.referenceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MstrdtExpenseReference(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('suggestedAmount: $suggestedAmount, ')
          ..write('description: $description, ')
          ..write('referenceId: $referenceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    suggestedAmount,
    description,
    referenceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MstrdtExpenseReference &&
          other.id == this.id &&
          other.createdBy == this.createdBy &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.lastModifiedBy == this.lastModifiedBy &&
          other.suggestedAmount == this.suggestedAmount &&
          other.description == this.description &&
          other.referenceId == this.referenceId);
}

class ExpenseReferenceTableCompanion
    extends UpdateCompanion<MstrdtExpenseReference> {
  final Value<String> id;
  final Value<String> createdBy;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> lastModifiedBy;
  final Value<double> suggestedAmount;
  final Value<String?> description;
  final Value<String> referenceId;
  final Value<int> rowid;
  const ExpenseReferenceTableCompanion({
    this.id = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    this.suggestedAmount = const Value.absent(),
    this.description = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseReferenceTableCompanion.insert({
    this.id = const Value.absent(),
    required String createdBy,
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required String lastModifiedBy,
    this.suggestedAmount = const Value.absent(),
    this.description = const Value.absent(),
    required String referenceId,
    this.rowid = const Value.absent(),
  }) : createdBy = Value(createdBy),
       dateUpdated = Value(dateUpdated),
       lastModifiedBy = Value(lastModifiedBy),
       referenceId = Value(referenceId);
  static Insertable<MstrdtExpenseReference> custom({
    Expression<String>? id,
    Expression<String>? createdBy,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? lastModifiedBy,
    Expression<double>? suggestedAmount,
    Expression<String>? description,
    Expression<String>? referenceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdBy != null) 'created_by': createdBy,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
      if (suggestedAmount != null) 'suggested_amount': suggestedAmount,
      if (description != null) 'description': description,
      if (referenceId != null) 'reference_id': referenceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseReferenceTableCompanion copyWith({
    Value<String>? id,
    Value<String>? createdBy,
    Value<DateTime>? dateCreated,
    Value<DateTime>? dateUpdated,
    Value<String>? lastModifiedBy,
    Value<double>? suggestedAmount,
    Value<String?>? description,
    Value<String>? referenceId,
    Value<int>? rowid,
  }) {
    return ExpenseReferenceTableCompanion(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      suggestedAmount: suggestedAmount ?? this.suggestedAmount,
      description: description ?? this.description,
      referenceId: referenceId ?? this.referenceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseReferenceTableCompanion(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('suggestedAmount: $suggestedAmount, ')
          ..write('description: $description, ')
          ..write('referenceId: $referenceId, ')
          ..write('rowid: $rowid')
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => UuidGenerator().v4(),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
    'date_created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dateUpdatedMeta = const VerificationMeta(
    'dateUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
    'date_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconUrlMeta = const VerificationMeta(
    'iconUrl',
  );
  @override
  late final GeneratedColumn<String> iconUrl = GeneratedColumn<String>(
    'icon_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _longNameMeta = const VerificationMeta(
    'longName',
  );
  @override
  late final GeneratedColumn<String> longName = GeneratedColumn<String>(
    'long_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _shortNameMeta = const VerificationMeta(
    'shortName',
  );
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
    'short_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_table (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    iconUrl,
    longName,
    shortName,
    type,
    userId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'money_storage_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SvngMoneyStorage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    }
    if (data.containsKey('date_updated')) {
      context.handle(
        _dateUpdatedMeta,
        dateUpdated.isAcceptableOrUnknown(
          data['date_updated']!,
          _dateUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedByMeta);
    }
    if (data.containsKey('icon_url')) {
      context.handle(
        _iconUrlMeta,
        iconUrl.isAcceptableOrUnknown(data['icon_url']!, _iconUrlMeta),
      );
    }
    if (data.containsKey('long_name')) {
      context.handle(
        _longNameMeta,
        longName.isAcceptableOrUnknown(data['long_name']!, _longNameMeta),
      );
    } else if (isInserting) {
      context.missing(_longNameMeta);
    }
    if (data.containsKey('short_name')) {
      context.handle(
        _shortNameMeta,
        shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta),
      );
    } else if (isInserting) {
      context.missing(_shortNameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SvngMoneyStorage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SvngMoneyStorage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_created'],
      )!,
      dateUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_updated'],
      )!,
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      )!,
      iconUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_url'],
      )!,
      longName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}long_name'],
      )!,
      shortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
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
  final String createdBy;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String lastModifiedBy;
  final String iconUrl;
  final String longName;
  final String shortName;
  final String type;
  final String? userId;
  const SvngMoneyStorage({
    required this.id,
    required this.createdBy,
    required this.dateCreated,
    required this.dateUpdated,
    required this.lastModifiedBy,
    required this.iconUrl,
    required this.longName,
    required this.shortName,
    required this.type,
    this.userId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_by'] = Variable<String>(createdBy);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['last_modified_by'] = Variable<String>(lastModifiedBy);
    map['icon_url'] = Variable<String>(iconUrl);
    map['long_name'] = Variable<String>(longName);
    map['short_name'] = Variable<String>(shortName);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    return map;
  }

  MoneyStorageTableCompanion toCompanion(bool nullToAbsent) {
    return MoneyStorageTableCompanion(
      id: Value(id),
      createdBy: Value(createdBy),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      lastModifiedBy: Value(lastModifiedBy),
      iconUrl: Value(iconUrl),
      longName: Value(longName),
      shortName: Value(shortName),
      type: Value(type),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
    );
  }

  factory SvngMoneyStorage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SvngMoneyStorage(
      id: serializer.fromJson<String>(json['id']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      lastModifiedBy: serializer.fromJson<String>(json['lastModifiedBy']),
      iconUrl: serializer.fromJson<String>(json['iconUrl']),
      longName: serializer.fromJson<String>(json['longName']),
      shortName: serializer.fromJson<String>(json['shortName']),
      type: serializer.fromJson<String>(json['type']),
      userId: serializer.fromJson<String?>(json['userId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdBy': serializer.toJson<String>(createdBy),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'lastModifiedBy': serializer.toJson<String>(lastModifiedBy),
      'iconUrl': serializer.toJson<String>(iconUrl),
      'longName': serializer.toJson<String>(longName),
      'shortName': serializer.toJson<String>(shortName),
      'type': serializer.toJson<String>(type),
      'userId': serializer.toJson<String?>(userId),
    };
  }

  SvngMoneyStorage copyWith({
    String? id,
    String? createdBy,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    String? lastModifiedBy,
    String? iconUrl,
    String? longName,
    String? shortName,
    String? type,
    Value<String?> userId = const Value.absent(),
  }) => SvngMoneyStorage(
    id: id ?? this.id,
    createdBy: createdBy ?? this.createdBy,
    dateCreated: dateCreated ?? this.dateCreated,
    dateUpdated: dateUpdated ?? this.dateUpdated,
    lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    iconUrl: iconUrl ?? this.iconUrl,
    longName: longName ?? this.longName,
    shortName: shortName ?? this.shortName,
    type: type ?? this.type,
    userId: userId.present ? userId.value : this.userId,
  );
  SvngMoneyStorage copyWithCompanion(MoneyStorageTableCompanion data) {
    return SvngMoneyStorage(
      id: data.id.present ? data.id.value : this.id,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
      dateUpdated: data.dateUpdated.present
          ? data.dateUpdated.value
          : this.dateUpdated,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      iconUrl: data.iconUrl.present ? data.iconUrl.value : this.iconUrl,
      longName: data.longName.present ? data.longName.value : this.longName,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      type: data.type.present ? data.type.value : this.type,
      userId: data.userId.present ? data.userId.value : this.userId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SvngMoneyStorage(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('longName: $longName, ')
          ..write('shortName: $shortName, ')
          ..write('type: $type, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    iconUrl,
    longName,
    shortName,
    type,
    userId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SvngMoneyStorage &&
          other.id == this.id &&
          other.createdBy == this.createdBy &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.lastModifiedBy == this.lastModifiedBy &&
          other.iconUrl == this.iconUrl &&
          other.longName == this.longName &&
          other.shortName == this.shortName &&
          other.type == this.type &&
          other.userId == this.userId);
}

class MoneyStorageTableCompanion extends UpdateCompanion<SvngMoneyStorage> {
  final Value<String> id;
  final Value<String> createdBy;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> lastModifiedBy;
  final Value<String> iconUrl;
  final Value<String> longName;
  final Value<String> shortName;
  final Value<String> type;
  final Value<String?> userId;
  final Value<int> rowid;
  const MoneyStorageTableCompanion({
    this.id = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    this.iconUrl = const Value.absent(),
    this.longName = const Value.absent(),
    this.shortName = const Value.absent(),
    this.type = const Value.absent(),
    this.userId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoneyStorageTableCompanion.insert({
    this.id = const Value.absent(),
    required String createdBy,
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required String lastModifiedBy,
    this.iconUrl = const Value.absent(),
    required String longName,
    required String shortName,
    required String type,
    this.userId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdBy = Value(createdBy),
       dateUpdated = Value(dateUpdated),
       lastModifiedBy = Value(lastModifiedBy),
       longName = Value(longName),
       shortName = Value(shortName),
       type = Value(type);
  static Insertable<SvngMoneyStorage> custom({
    Expression<String>? id,
    Expression<String>? createdBy,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? lastModifiedBy,
    Expression<String>? iconUrl,
    Expression<String>? longName,
    Expression<String>? shortName,
    Expression<String>? type,
    Expression<String>? userId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdBy != null) 'created_by': createdBy,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (longName != null) 'long_name': longName,
      if (shortName != null) 'short_name': shortName,
      if (type != null) 'type': type,
      if (userId != null) 'user_id': userId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoneyStorageTableCompanion copyWith({
    Value<String>? id,
    Value<String>? createdBy,
    Value<DateTime>? dateCreated,
    Value<DateTime>? dateUpdated,
    Value<String>? lastModifiedBy,
    Value<String>? iconUrl,
    Value<String>? longName,
    Value<String>? shortName,
    Value<String>? type,
    Value<String?>? userId,
    Value<int>? rowid,
  }) {
    return MoneyStorageTableCompanion(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      iconUrl: iconUrl ?? this.iconUrl,
      longName: longName ?? this.longName,
      shortName: shortName ?? this.shortName,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoneyStorageTableCompanion(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('longName: $longName, ')
          ..write('shortName: $shortName, ')
          ..write('type: $type, ')
          ..write('userId: $userId, ')
          ..write('rowid: $rowid')
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => UuidGenerator().v4(),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
    'date_created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dateUpdatedMeta = const VerificationMeta(
    'dateUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
    'date_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPublicMeta = const VerificationMeta(
    'isPublic',
  );
  @override
  late final GeneratedColumn<bool> isPublic = GeneratedColumn<bool>(
    'is_public',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_public" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isHasGoalMeta = const VerificationMeta(
    'isHasGoal',
  );
  @override
  late final GeneratedColumn<bool> isHasGoal = GeneratedColumn<bool>(
    'is_has_goal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_has_goal" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<double> goal = GeneratedColumn<double>(
    'goal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(.0),
  );
  static const VerificationMeta _isHasStartDateMeta = const VerificationMeta(
    'isHasStartDate',
  );
  @override
  late final GeneratedColumn<bool> isHasStartDate = GeneratedColumn<bool>(
    'is_has_start_date',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_has_start_date" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isHasEndDateMeta = const VerificationMeta(
    'isHasEndDate',
  );
  @override
  late final GeneratedColumn<bool> isHasEndDate = GeneratedColumn<bool>(
    'is_has_end_date',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_has_end_date" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSaveDailyMeta = const VerificationMeta(
    'isSaveDaily',
  );
  @override
  late final GeneratedColumn<bool> isSaveDaily = GeneratedColumn<bool>(
    'is_save_daily',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_save_daily" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSaveWeeklyMeta = const VerificationMeta(
    'isSaveWeekly',
  );
  @override
  late final GeneratedColumn<bool> isSaveWeekly = GeneratedColumn<bool>(
    'is_save_weekly',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_save_weekly" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSaveMonthlyMeta = const VerificationMeta(
    'isSaveMonthly',
  );
  @override
  late final GeneratedColumn<bool> isSaveMonthly = GeneratedColumn<bool>(
    'is_save_monthly',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_save_monthly" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentAmountMeta = const VerificationMeta(
    'currentAmount',
  );
  @override
  late final GeneratedColumn<double> currentAmount = GeneratedColumn<double>(
    'current_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(.0),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_table (id)',
    ),
  );
  static const VerificationMeta _moneyStorageIdMeta = const VerificationMeta(
    'moneyStorageId',
  );
  @override
  late final GeneratedColumn<String> moneyStorageId = GeneratedColumn<String>(
    'money_storage_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES money_storage_table (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
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
    type,
    currentAmount,
    userId,
    moneyStorageId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saving_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SvngSaving> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    }
    if (data.containsKey('date_updated')) {
      context.handle(
        _dateUpdatedMeta,
        dateUpdated.isAcceptableOrUnknown(
          data['date_updated']!,
          _dateUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedByMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('is_public')) {
      context.handle(
        _isPublicMeta,
        isPublic.isAcceptableOrUnknown(data['is_public']!, _isPublicMeta),
      );
    }
    if (data.containsKey('is_has_goal')) {
      context.handle(
        _isHasGoalMeta,
        isHasGoal.isAcceptableOrUnknown(data['is_has_goal']!, _isHasGoalMeta),
      );
    }
    if (data.containsKey('goal')) {
      context.handle(
        _goalMeta,
        goal.isAcceptableOrUnknown(data['goal']!, _goalMeta),
      );
    }
    if (data.containsKey('is_has_start_date')) {
      context.handle(
        _isHasStartDateMeta,
        isHasStartDate.isAcceptableOrUnknown(
          data['is_has_start_date']!,
          _isHasStartDateMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('is_has_end_date')) {
      context.handle(
        _isHasEndDateMeta,
        isHasEndDate.isAcceptableOrUnknown(
          data['is_has_end_date']!,
          _isHasEndDateMeta,
        ),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('is_save_daily')) {
      context.handle(
        _isSaveDailyMeta,
        isSaveDaily.isAcceptableOrUnknown(
          data['is_save_daily']!,
          _isSaveDailyMeta,
        ),
      );
    }
    if (data.containsKey('is_save_weekly')) {
      context.handle(
        _isSaveWeeklyMeta,
        isSaveWeekly.isAcceptableOrUnknown(
          data['is_save_weekly']!,
          _isSaveWeeklyMeta,
        ),
      );
    }
    if (data.containsKey('is_save_monthly')) {
      context.handle(
        _isSaveMonthlyMeta,
        isSaveMonthly.isAcceptableOrUnknown(
          data['is_save_monthly']!,
          _isSaveMonthlyMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('current_amount')) {
      context.handle(
        _currentAmountMeta,
        currentAmount.isAcceptableOrUnknown(
          data['current_amount']!,
          _currentAmountMeta,
        ),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('money_storage_id')) {
      context.handle(
        _moneyStorageIdMeta,
        moneyStorageId.isAcceptableOrUnknown(
          data['money_storage_id']!,
          _moneyStorageIdMeta,
        ),
      );
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
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_created'],
      )!,
      dateUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_updated'],
      )!,
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      isPublic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_public'],
      )!,
      isHasGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_has_goal'],
      )!,
      goal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}goal'],
      )!,
      isHasStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_has_start_date'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      isHasEndDate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_has_end_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      isSaveDaily: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_save_daily'],
      )!,
      isSaveWeekly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_save_weekly'],
      )!,
      isSaveMonthly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_save_monthly'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      currentAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_amount'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      moneyStorageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}money_storage_id'],
      ),
    );
  }

  @override
  $SavingTableTable createAlias(String alias) {
    return $SavingTableTable(attachedDatabase, alias);
  }
}

class SvngSaving extends DataClass implements Insertable<SvngSaving> {
  final String id;
  final String createdBy;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String lastModifiedBy;
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
  final String type;
  final double currentAmount;
  final String? userId;
  final String? moneyStorageId;
  const SvngSaving({
    required this.id,
    required this.createdBy,
    required this.dateCreated,
    required this.dateUpdated,
    required this.lastModifiedBy,
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
    required this.type,
    required this.currentAmount,
    this.userId,
    this.moneyStorageId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_by'] = Variable<String>(createdBy);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['last_modified_by'] = Variable<String>(lastModifiedBy);
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
    map['type'] = Variable<String>(type);
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
      createdBy: Value(createdBy),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      lastModifiedBy: Value(lastModifiedBy),
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
      type: Value(type),
      currentAmount: Value(currentAmount),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      moneyStorageId: moneyStorageId == null && nullToAbsent
          ? const Value.absent()
          : Value(moneyStorageId),
    );
  }

  factory SvngSaving.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SvngSaving(
      id: serializer.fromJson<String>(json['id']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      lastModifiedBy: serializer.fromJson<String>(json['lastModifiedBy']),
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
      type: serializer.fromJson<String>(json['type']),
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
      'createdBy': serializer.toJson<String>(createdBy),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'lastModifiedBy': serializer.toJson<String>(lastModifiedBy),
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
      'type': serializer.toJson<String>(type),
      'currentAmount': serializer.toJson<double>(currentAmount),
      'userId': serializer.toJson<String?>(userId),
      'moneyStorageId': serializer.toJson<String?>(moneyStorageId),
    };
  }

  SvngSaving copyWith({
    String? id,
    String? createdBy,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    String? lastModifiedBy,
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
    String? type,
    double? currentAmount,
    Value<String?> userId = const Value.absent(),
    Value<String?> moneyStorageId = const Value.absent(),
  }) => SvngSaving(
    id: id ?? this.id,
    createdBy: createdBy ?? this.createdBy,
    dateCreated: dateCreated ?? this.dateCreated,
    dateUpdated: dateUpdated ?? this.dateUpdated,
    lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
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
    type: type ?? this.type,
    currentAmount: currentAmount ?? this.currentAmount,
    userId: userId.present ? userId.value : this.userId,
    moneyStorageId: moneyStorageId.present
        ? moneyStorageId.value
        : this.moneyStorageId,
  );
  SvngSaving copyWithCompanion(SavingTableCompanion data) {
    return SvngSaving(
      id: data.id.present ? data.id.value : this.id,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
      dateUpdated: data.dateUpdated.present
          ? data.dateUpdated.value
          : this.dateUpdated,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      name: data.name.present ? data.name.value : this.name,
      isPublic: data.isPublic.present ? data.isPublic.value : this.isPublic,
      isHasGoal: data.isHasGoal.present ? data.isHasGoal.value : this.isHasGoal,
      goal: data.goal.present ? data.goal.value : this.goal,
      isHasStartDate: data.isHasStartDate.present
          ? data.isHasStartDate.value
          : this.isHasStartDate,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      isHasEndDate: data.isHasEndDate.present
          ? data.isHasEndDate.value
          : this.isHasEndDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isSaveDaily: data.isSaveDaily.present
          ? data.isSaveDaily.value
          : this.isSaveDaily,
      isSaveWeekly: data.isSaveWeekly.present
          ? data.isSaveWeekly.value
          : this.isSaveWeekly,
      isSaveMonthly: data.isSaveMonthly.present
          ? data.isSaveMonthly.value
          : this.isSaveMonthly,
      type: data.type.present ? data.type.value : this.type,
      currentAmount: data.currentAmount.present
          ? data.currentAmount.value
          : this.currentAmount,
      userId: data.userId.present ? data.userId.value : this.userId,
      moneyStorageId: data.moneyStorageId.present
          ? data.moneyStorageId.value
          : this.moneyStorageId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SvngSaving(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
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
          ..write('type: $type, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('userId: $userId, ')
          ..write('moneyStorageId: $moneyStorageId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
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
    type,
    currentAmount,
    userId,
    moneyStorageId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SvngSaving &&
          other.id == this.id &&
          other.createdBy == this.createdBy &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.lastModifiedBy == this.lastModifiedBy &&
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
          other.type == this.type &&
          other.currentAmount == this.currentAmount &&
          other.userId == this.userId &&
          other.moneyStorageId == this.moneyStorageId);
}

class SavingTableCompanion extends UpdateCompanion<SvngSaving> {
  final Value<String> id;
  final Value<String> createdBy;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> lastModifiedBy;
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
  final Value<String> type;
  final Value<double> currentAmount;
  final Value<String?> userId;
  final Value<String?> moneyStorageId;
  final Value<int> rowid;
  const SavingTableCompanion({
    this.id = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
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
    this.type = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.userId = const Value.absent(),
    this.moneyStorageId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingTableCompanion.insert({
    this.id = const Value.absent(),
    required String createdBy,
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required String lastModifiedBy,
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
    required String type,
    this.currentAmount = const Value.absent(),
    this.userId = const Value.absent(),
    this.moneyStorageId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdBy = Value(createdBy),
       dateUpdated = Value(dateUpdated),
       lastModifiedBy = Value(lastModifiedBy),
       type = Value(type);
  static Insertable<SvngSaving> custom({
    Expression<String>? id,
    Expression<String>? createdBy,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? lastModifiedBy,
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
    Expression<String>? type,
    Expression<double>? currentAmount,
    Expression<String>? userId,
    Expression<String>? moneyStorageId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdBy != null) 'created_by': createdBy,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
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
      if (type != null) 'type': type,
      if (currentAmount != null) 'current_amount': currentAmount,
      if (userId != null) 'user_id': userId,
      if (moneyStorageId != null) 'money_storage_id': moneyStorageId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingTableCompanion copyWith({
    Value<String>? id,
    Value<String>? createdBy,
    Value<DateTime>? dateCreated,
    Value<DateTime>? dateUpdated,
    Value<String>? lastModifiedBy,
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
    Value<String>? type,
    Value<double>? currentAmount,
    Value<String?>? userId,
    Value<String?>? moneyStorageId,
    Value<int>? rowid,
  }) {
    return SavingTableCompanion(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
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
      type: type ?? this.type,
      currentAmount: currentAmount ?? this.currentAmount,
      userId: userId ?? this.userId,
      moneyStorageId: moneyStorageId ?? this.moneyStorageId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingTableCompanion(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
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
          ..write('type: $type, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('userId: $userId, ')
          ..write('moneyStorageId: $moneyStorageId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseTableTable extends ExpenseTable
    with TableInfo<$ExpenseTableTable, ExpnsExpense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => UuidGenerator().v4(),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
    'date_created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dateUpdatedMeta = const VerificationMeta(
    'dateUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
    'date_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expenseDateMeta = const VerificationMeta(
    'expenseDate',
  );
  @override
  late final GeneratedColumn<DateTime> expenseDate = GeneratedColumn<DateTime>(
    'expense_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceDataIdMeta = const VerificationMeta(
    'referenceDataId',
  );
  @override
  late final GeneratedColumn<String> referenceDataId = GeneratedColumn<String>(
    'reference_data_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reference_data_table (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    amount,
    description,
    expenseDate,
    referenceDataId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpnsExpense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    }
    if (data.containsKey('date_updated')) {
      context.handle(
        _dateUpdatedMeta,
        dateUpdated.isAcceptableOrUnknown(
          data['date_updated']!,
          _dateUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedByMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('expense_date')) {
      context.handle(
        _expenseDateMeta,
        expenseDate.isAcceptableOrUnknown(
          data['expense_date']!,
          _expenseDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expenseDateMeta);
    }
    if (data.containsKey('reference_data_id')) {
      context.handle(
        _referenceDataIdMeta,
        referenceDataId.isAcceptableOrUnknown(
          data['reference_data_id']!,
          _referenceDataIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_referenceDataIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpnsExpense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpnsExpense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_created'],
      )!,
      dateUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_updated'],
      )!,
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      expenseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expense_date'],
      )!,
      referenceDataId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_data_id'],
      )!,
    );
  }

  @override
  $ExpenseTableTable createAlias(String alias) {
    return $ExpenseTableTable(attachedDatabase, alias);
  }
}

class ExpnsExpense extends DataClass implements Insertable<ExpnsExpense> {
  final String id;
  final String createdBy;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String lastModifiedBy;
  final double amount;
  final String? description;
  final DateTime expenseDate;
  final String referenceDataId;
  const ExpnsExpense({
    required this.id,
    required this.createdBy,
    required this.dateCreated,
    required this.dateUpdated,
    required this.lastModifiedBy,
    required this.amount,
    this.description,
    required this.expenseDate,
    required this.referenceDataId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_by'] = Variable<String>(createdBy);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['last_modified_by'] = Variable<String>(lastModifiedBy);
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
      createdBy: Value(createdBy),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      lastModifiedBy: Value(lastModifiedBy),
      amount: Value(amount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      expenseDate: Value(expenseDate),
      referenceDataId: Value(referenceDataId),
    );
  }

  factory ExpnsExpense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpnsExpense(
      id: serializer.fromJson<String>(json['id']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      lastModifiedBy: serializer.fromJson<String>(json['lastModifiedBy']),
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
      'createdBy': serializer.toJson<String>(createdBy),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'lastModifiedBy': serializer.toJson<String>(lastModifiedBy),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String?>(description),
      'expenseDate': serializer.toJson<DateTime>(expenseDate),
      'referenceDataId': serializer.toJson<String>(referenceDataId),
    };
  }

  ExpnsExpense copyWith({
    String? id,
    String? createdBy,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    String? lastModifiedBy,
    double? amount,
    Value<String?> description = const Value.absent(),
    DateTime? expenseDate,
    String? referenceDataId,
  }) => ExpnsExpense(
    id: id ?? this.id,
    createdBy: createdBy ?? this.createdBy,
    dateCreated: dateCreated ?? this.dateCreated,
    dateUpdated: dateUpdated ?? this.dateUpdated,
    lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    amount: amount ?? this.amount,
    description: description.present ? description.value : this.description,
    expenseDate: expenseDate ?? this.expenseDate,
    referenceDataId: referenceDataId ?? this.referenceDataId,
  );
  ExpnsExpense copyWithCompanion(ExpenseTableCompanion data) {
    return ExpnsExpense(
      id: data.id.present ? data.id.value : this.id,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
      dateUpdated: data.dateUpdated.present
          ? data.dateUpdated.value
          : this.dateUpdated,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      amount: data.amount.present ? data.amount.value : this.amount,
      description: data.description.present
          ? data.description.value
          : this.description,
      expenseDate: data.expenseDate.present
          ? data.expenseDate.value
          : this.expenseDate,
      referenceDataId: data.referenceDataId.present
          ? data.referenceDataId.value
          : this.referenceDataId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpnsExpense(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('referenceDataId: $referenceDataId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    amount,
    description,
    expenseDate,
    referenceDataId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpnsExpense &&
          other.id == this.id &&
          other.createdBy == this.createdBy &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.lastModifiedBy == this.lastModifiedBy &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.expenseDate == this.expenseDate &&
          other.referenceDataId == this.referenceDataId);
}

class ExpenseTableCompanion extends UpdateCompanion<ExpnsExpense> {
  final Value<String> id;
  final Value<String> createdBy;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> lastModifiedBy;
  final Value<double> amount;
  final Value<String?> description;
  final Value<DateTime> expenseDate;
  final Value<String> referenceDataId;
  final Value<int> rowid;
  const ExpenseTableCompanion({
    this.id = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.expenseDate = const Value.absent(),
    this.referenceDataId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseTableCompanion.insert({
    this.id = const Value.absent(),
    required String createdBy,
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required String lastModifiedBy,
    required double amount,
    this.description = const Value.absent(),
    required DateTime expenseDate,
    required String referenceDataId,
    this.rowid = const Value.absent(),
  }) : createdBy = Value(createdBy),
       dateUpdated = Value(dateUpdated),
       lastModifiedBy = Value(lastModifiedBy),
       amount = Value(amount),
       expenseDate = Value(expenseDate),
       referenceDataId = Value(referenceDataId);
  static Insertable<ExpnsExpense> custom({
    Expression<String>? id,
    Expression<String>? createdBy,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? lastModifiedBy,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<DateTime>? expenseDate,
    Expression<String>? referenceDataId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdBy != null) 'created_by': createdBy,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (expenseDate != null) 'expense_date': expenseDate,
      if (referenceDataId != null) 'reference_data_id': referenceDataId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseTableCompanion copyWith({
    Value<String>? id,
    Value<String>? createdBy,
    Value<DateTime>? dateCreated,
    Value<DateTime>? dateUpdated,
    Value<String>? lastModifiedBy,
    Value<double>? amount,
    Value<String?>? description,
    Value<DateTime>? expenseDate,
    Value<String>? referenceDataId,
    Value<int>? rowid,
  }) {
    return ExpenseTableCompanion(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      expenseDate: expenseDate ?? this.expenseDate,
      referenceDataId: referenceDataId ?? this.referenceDataId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseTableCompanion(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('referenceDataId: $referenceDataId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommitmentTableTable extends CommitmentTable
    with TableInfo<$CommitmentTableTable, ExpnsCommitment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommitmentTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => UuidGenerator().v4(),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
    'date_created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dateUpdatedMeta = const VerificationMeta(
    'dateUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
    'date_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referredSavingIdMeta = const VerificationMeta(
    'referredSavingId',
  );
  @override
  late final GeneratedColumn<String> referredSavingId = GeneratedColumn<String>(
    'referred_saving_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES saving_table (id)',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_table (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    name,
    description,
    referredSavingId,
    userId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'commitment_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpnsCommitment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    }
    if (data.containsKey('date_updated')) {
      context.handle(
        _dateUpdatedMeta,
        dateUpdated.isAcceptableOrUnknown(
          data['date_updated']!,
          _dateUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedByMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('referred_saving_id')) {
      context.handle(
        _referredSavingIdMeta,
        referredSavingId.isAcceptableOrUnknown(
          data['referred_saving_id']!,
          _referredSavingIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_referredSavingIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpnsCommitment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpnsCommitment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_created'],
      )!,
      dateUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_updated'],
      )!,
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      referredSavingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referred_saving_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
    );
  }

  @override
  $CommitmentTableTable createAlias(String alias) {
    return $CommitmentTableTable(attachedDatabase, alias);
  }
}

class ExpnsCommitment extends DataClass implements Insertable<ExpnsCommitment> {
  final String id;
  final String createdBy;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String lastModifiedBy;
  final String name;
  final String? description;
  final String referredSavingId;
  final String userId;
  const ExpnsCommitment({
    required this.id,
    required this.createdBy,
    required this.dateCreated,
    required this.dateUpdated,
    required this.lastModifiedBy,
    required this.name,
    this.description,
    required this.referredSavingId,
    required this.userId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_by'] = Variable<String>(createdBy);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['last_modified_by'] = Variable<String>(lastModifiedBy);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['referred_saving_id'] = Variable<String>(referredSavingId);
    map['user_id'] = Variable<String>(userId);
    return map;
  }

  CommitmentTableCompanion toCompanion(bool nullToAbsent) {
    return CommitmentTableCompanion(
      id: Value(id),
      createdBy: Value(createdBy),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      lastModifiedBy: Value(lastModifiedBy),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      referredSavingId: Value(referredSavingId),
      userId: Value(userId),
    );
  }

  factory ExpnsCommitment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpnsCommitment(
      id: serializer.fromJson<String>(json['id']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      lastModifiedBy: serializer.fromJson<String>(json['lastModifiedBy']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      referredSavingId: serializer.fromJson<String>(json['referredSavingId']),
      userId: serializer.fromJson<String>(json['userId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdBy': serializer.toJson<String>(createdBy),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'lastModifiedBy': serializer.toJson<String>(lastModifiedBy),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'referredSavingId': serializer.toJson<String>(referredSavingId),
      'userId': serializer.toJson<String>(userId),
    };
  }

  ExpnsCommitment copyWith({
    String? id,
    String? createdBy,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    String? lastModifiedBy,
    String? name,
    Value<String?> description = const Value.absent(),
    String? referredSavingId,
    String? userId,
  }) => ExpnsCommitment(
    id: id ?? this.id,
    createdBy: createdBy ?? this.createdBy,
    dateCreated: dateCreated ?? this.dateCreated,
    dateUpdated: dateUpdated ?? this.dateUpdated,
    lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    referredSavingId: referredSavingId ?? this.referredSavingId,
    userId: userId ?? this.userId,
  );
  ExpnsCommitment copyWithCompanion(CommitmentTableCompanion data) {
    return ExpnsCommitment(
      id: data.id.present ? data.id.value : this.id,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
      dateUpdated: data.dateUpdated.present
          ? data.dateUpdated.value
          : this.dateUpdated,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      referredSavingId: data.referredSavingId.present
          ? data.referredSavingId.value
          : this.referredSavingId,
      userId: data.userId.present ? data.userId.value : this.userId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpnsCommitment(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('referredSavingId: $referredSavingId, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    name,
    description,
    referredSavingId,
    userId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpnsCommitment &&
          other.id == this.id &&
          other.createdBy == this.createdBy &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.lastModifiedBy == this.lastModifiedBy &&
          other.name == this.name &&
          other.description == this.description &&
          other.referredSavingId == this.referredSavingId &&
          other.userId == this.userId);
}

class CommitmentTableCompanion extends UpdateCompanion<ExpnsCommitment> {
  final Value<String> id;
  final Value<String> createdBy;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> lastModifiedBy;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> referredSavingId;
  final Value<String> userId;
  final Value<int> rowid;
  const CommitmentTableCompanion({
    this.id = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.referredSavingId = const Value.absent(),
    this.userId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommitmentTableCompanion.insert({
    this.id = const Value.absent(),
    required String createdBy,
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required String lastModifiedBy,
    required String name,
    this.description = const Value.absent(),
    required String referredSavingId,
    required String userId,
    this.rowid = const Value.absent(),
  }) : createdBy = Value(createdBy),
       dateUpdated = Value(dateUpdated),
       lastModifiedBy = Value(lastModifiedBy),
       name = Value(name),
       referredSavingId = Value(referredSavingId),
       userId = Value(userId);
  static Insertable<ExpnsCommitment> custom({
    Expression<String>? id,
    Expression<String>? createdBy,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? lastModifiedBy,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? referredSavingId,
    Expression<String>? userId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdBy != null) 'created_by': createdBy,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (referredSavingId != null) 'referred_saving_id': referredSavingId,
      if (userId != null) 'user_id': userId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommitmentTableCompanion copyWith({
    Value<String>? id,
    Value<String>? createdBy,
    Value<DateTime>? dateCreated,
    Value<DateTime>? dateUpdated,
    Value<String>? lastModifiedBy,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? referredSavingId,
    Value<String>? userId,
    Value<int>? rowid,
  }) {
    return CommitmentTableCompanion(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      name: name ?? this.name,
      description: description ?? this.description,
      referredSavingId: referredSavingId ?? this.referredSavingId,
      userId: userId ?? this.userId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (referredSavingId.present) {
      map['referred_saving_id'] = Variable<String>(referredSavingId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommitmentTableCompanion(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('referredSavingId: $referredSavingId, ')
          ..write('userId: $userId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommitmentDetailTableTable extends CommitmentDetailTable
    with TableInfo<$CommitmentDetailTableTable, ExpnsCommitmentDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommitmentDetailTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => UuidGenerator().v4(),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
    'date_created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dateUpdatedMeta = const VerificationMeta(
    'dateUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
    'date_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savingIdMeta = const VerificationMeta(
    'savingId',
  );
  @override
  late final GeneratedColumn<String> savingId = GeneratedColumn<String>(
    'saving_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES saving_table (id)',
    ),
  );
  static const VerificationMeta _commitmentIdMeta = const VerificationMeta(
    'commitmentId',
  );
  @override
  late final GeneratedColumn<String> commitmentId = GeneratedColumn<String>(
    'commitment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES commitment_table (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    amount,
    description,
    type,
    savingId,
    commitmentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'commitment_detail_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpnsCommitmentDetail> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    }
    if (data.containsKey('date_updated')) {
      context.handle(
        _dateUpdatedMeta,
        dateUpdated.isAcceptableOrUnknown(
          data['date_updated']!,
          _dateUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedByMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('saving_id')) {
      context.handle(
        _savingIdMeta,
        savingId.isAcceptableOrUnknown(data['saving_id']!, _savingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_savingIdMeta);
    }
    if (data.containsKey('commitment_id')) {
      context.handle(
        _commitmentIdMeta,
        commitmentId.isAcceptableOrUnknown(
          data['commitment_id']!,
          _commitmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_commitmentIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpnsCommitmentDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpnsCommitmentDetail(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_created'],
      )!,
      dateUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_updated'],
      )!,
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      savingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}saving_id'],
      )!,
      commitmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commitment_id'],
      )!,
    );
  }

  @override
  $CommitmentDetailTableTable createAlias(String alias) {
    return $CommitmentDetailTableTable(attachedDatabase, alias);
  }
}

class ExpnsCommitmentDetail extends DataClass
    implements Insertable<ExpnsCommitmentDetail> {
  final String id;
  final String createdBy;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String lastModifiedBy;
  final double amount;
  final String description;
  final String type;
  final String savingId;
  final String commitmentId;
  const ExpnsCommitmentDetail({
    required this.id,
    required this.createdBy,
    required this.dateCreated,
    required this.dateUpdated,
    required this.lastModifiedBy,
    required this.amount,
    required this.description,
    required this.type,
    required this.savingId,
    required this.commitmentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_by'] = Variable<String>(createdBy);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['last_modified_by'] = Variable<String>(lastModifiedBy);
    map['amount'] = Variable<double>(amount);
    map['description'] = Variable<String>(description);
    map['type'] = Variable<String>(type);
    map['saving_id'] = Variable<String>(savingId);
    map['commitment_id'] = Variable<String>(commitmentId);
    return map;
  }

  CommitmentDetailTableCompanion toCompanion(bool nullToAbsent) {
    return CommitmentDetailTableCompanion(
      id: Value(id),
      createdBy: Value(createdBy),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      lastModifiedBy: Value(lastModifiedBy),
      amount: Value(amount),
      description: Value(description),
      type: Value(type),
      savingId: Value(savingId),
      commitmentId: Value(commitmentId),
    );
  }

  factory ExpnsCommitmentDetail.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpnsCommitmentDetail(
      id: serializer.fromJson<String>(json['id']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      lastModifiedBy: serializer.fromJson<String>(json['lastModifiedBy']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String>(json['description']),
      type: serializer.fromJson<String>(json['type']),
      savingId: serializer.fromJson<String>(json['savingId']),
      commitmentId: serializer.fromJson<String>(json['commitmentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdBy': serializer.toJson<String>(createdBy),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'lastModifiedBy': serializer.toJson<String>(lastModifiedBy),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String>(description),
      'type': serializer.toJson<String>(type),
      'savingId': serializer.toJson<String>(savingId),
      'commitmentId': serializer.toJson<String>(commitmentId),
    };
  }

  ExpnsCommitmentDetail copyWith({
    String? id,
    String? createdBy,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    String? lastModifiedBy,
    double? amount,
    String? description,
    String? type,
    String? savingId,
    String? commitmentId,
  }) => ExpnsCommitmentDetail(
    id: id ?? this.id,
    createdBy: createdBy ?? this.createdBy,
    dateCreated: dateCreated ?? this.dateCreated,
    dateUpdated: dateUpdated ?? this.dateUpdated,
    lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    amount: amount ?? this.amount,
    description: description ?? this.description,
    type: type ?? this.type,
    savingId: savingId ?? this.savingId,
    commitmentId: commitmentId ?? this.commitmentId,
  );
  ExpnsCommitmentDetail copyWithCompanion(CommitmentDetailTableCompanion data) {
    return ExpnsCommitmentDetail(
      id: data.id.present ? data.id.value : this.id,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
      dateUpdated: data.dateUpdated.present
          ? data.dateUpdated.value
          : this.dateUpdated,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      amount: data.amount.present ? data.amount.value : this.amount,
      description: data.description.present
          ? data.description.value
          : this.description,
      type: data.type.present ? data.type.value : this.type,
      savingId: data.savingId.present ? data.savingId.value : this.savingId,
      commitmentId: data.commitmentId.present
          ? data.commitmentId.value
          : this.commitmentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpnsCommitmentDetail(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('savingId: $savingId, ')
          ..write('commitmentId: $commitmentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    amount,
    description,
    type,
    savingId,
    commitmentId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpnsCommitmentDetail &&
          other.id == this.id &&
          other.createdBy == this.createdBy &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.lastModifiedBy == this.lastModifiedBy &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.type == this.type &&
          other.savingId == this.savingId &&
          other.commitmentId == this.commitmentId);
}

class CommitmentDetailTableCompanion
    extends UpdateCompanion<ExpnsCommitmentDetail> {
  final Value<String> id;
  final Value<String> createdBy;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> lastModifiedBy;
  final Value<double> amount;
  final Value<String> description;
  final Value<String> type;
  final Value<String> savingId;
  final Value<String> commitmentId;
  final Value<int> rowid;
  const CommitmentDetailTableCompanion({
    this.id = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.savingId = const Value.absent(),
    this.commitmentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommitmentDetailTableCompanion.insert({
    this.id = const Value.absent(),
    required String createdBy,
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required String lastModifiedBy,
    required double amount,
    required String description,
    required String type,
    required String savingId,
    required String commitmentId,
    this.rowid = const Value.absent(),
  }) : createdBy = Value(createdBy),
       dateUpdated = Value(dateUpdated),
       lastModifiedBy = Value(lastModifiedBy),
       amount = Value(amount),
       description = Value(description),
       type = Value(type),
       savingId = Value(savingId),
       commitmentId = Value(commitmentId);
  static Insertable<ExpnsCommitmentDetail> custom({
    Expression<String>? id,
    Expression<String>? createdBy,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? lastModifiedBy,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<String>? type,
    Expression<String>? savingId,
    Expression<String>? commitmentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdBy != null) 'created_by': createdBy,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (savingId != null) 'saving_id': savingId,
      if (commitmentId != null) 'commitment_id': commitmentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommitmentDetailTableCompanion copyWith({
    Value<String>? id,
    Value<String>? createdBy,
    Value<DateTime>? dateCreated,
    Value<DateTime>? dateUpdated,
    Value<String>? lastModifiedBy,
    Value<double>? amount,
    Value<String>? description,
    Value<String>? type,
    Value<String>? savingId,
    Value<String>? commitmentId,
    Value<int>? rowid,
  }) {
    return CommitmentDetailTableCompanion(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      savingId: savingId ?? this.savingId,
      commitmentId: commitmentId ?? this.commitmentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (savingId.present) {
      map['saving_id'] = Variable<String>(savingId.value);
    }
    if (commitmentId.present) {
      map['commitment_id'] = Variable<String>(commitmentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommitmentDetailTableCompanion(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('savingId: $savingId, ')
          ..write('commitmentId: $commitmentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommitmentTaskTableTable extends CommitmentTaskTable
    with TableInfo<$CommitmentTaskTableTable, ExpnsCommitmentTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommitmentTaskTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => UuidGenerator().v4(),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
    'date_created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dateUpdatedMeta = const VerificationMeta(
    'dateUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
    'date_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _referredSavingIdMeta = const VerificationMeta(
    'referredSavingId',
  );
  @override
  late final GeneratedColumn<String> referredSavingId = GeneratedColumn<String>(
    'referred_saving_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES saving_table (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    name,
    amount,
    isDone,
    referredSavingId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'commitment_task_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpnsCommitmentTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    }
    if (data.containsKey('date_updated')) {
      context.handle(
        _dateUpdatedMeta,
        dateUpdated.isAcceptableOrUnknown(
          data['date_updated']!,
          _dateUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedByMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('is_done')) {
      context.handle(
        _isDoneMeta,
        isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta),
      );
    }
    if (data.containsKey('referred_saving_id')) {
      context.handle(
        _referredSavingIdMeta,
        referredSavingId.isAcceptableOrUnknown(
          data['referred_saving_id']!,
          _referredSavingIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_referredSavingIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpnsCommitmentTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpnsCommitmentTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_created'],
      )!,
      dateUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_updated'],
      )!,
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      isDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_done'],
      )!,
      referredSavingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referred_saving_id'],
      )!,
    );
  }

  @override
  $CommitmentTaskTableTable createAlias(String alias) {
    return $CommitmentTaskTableTable(attachedDatabase, alias);
  }
}

class ExpnsCommitmentTask extends DataClass
    implements Insertable<ExpnsCommitmentTask> {
  final String id;
  final String createdBy;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String lastModifiedBy;
  final String name;
  final double amount;
  final bool isDone;
  final String referredSavingId;
  const ExpnsCommitmentTask({
    required this.id,
    required this.createdBy,
    required this.dateCreated,
    required this.dateUpdated,
    required this.lastModifiedBy,
    required this.name,
    required this.amount,
    required this.isDone,
    required this.referredSavingId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_by'] = Variable<String>(createdBy);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['last_modified_by'] = Variable<String>(lastModifiedBy);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['is_done'] = Variable<bool>(isDone);
    map['referred_saving_id'] = Variable<String>(referredSavingId);
    return map;
  }

  CommitmentTaskTableCompanion toCompanion(bool nullToAbsent) {
    return CommitmentTaskTableCompanion(
      id: Value(id),
      createdBy: Value(createdBy),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      lastModifiedBy: Value(lastModifiedBy),
      name: Value(name),
      amount: Value(amount),
      isDone: Value(isDone),
      referredSavingId: Value(referredSavingId),
    );
  }

  factory ExpnsCommitmentTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpnsCommitmentTask(
      id: serializer.fromJson<String>(json['id']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      lastModifiedBy: serializer.fromJson<String>(json['lastModifiedBy']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      referredSavingId: serializer.fromJson<String>(json['referredSavingId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdBy': serializer.toJson<String>(createdBy),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'lastModifiedBy': serializer.toJson<String>(lastModifiedBy),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'isDone': serializer.toJson<bool>(isDone),
      'referredSavingId': serializer.toJson<String>(referredSavingId),
    };
  }

  ExpnsCommitmentTask copyWith({
    String? id,
    String? createdBy,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    String? lastModifiedBy,
    String? name,
    double? amount,
    bool? isDone,
    String? referredSavingId,
  }) => ExpnsCommitmentTask(
    id: id ?? this.id,
    createdBy: createdBy ?? this.createdBy,
    dateCreated: dateCreated ?? this.dateCreated,
    dateUpdated: dateUpdated ?? this.dateUpdated,
    lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    isDone: isDone ?? this.isDone,
    referredSavingId: referredSavingId ?? this.referredSavingId,
  );
  ExpnsCommitmentTask copyWithCompanion(CommitmentTaskTableCompanion data) {
    return ExpnsCommitmentTask(
      id: data.id.present ? data.id.value : this.id,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
      dateUpdated: data.dateUpdated.present
          ? data.dateUpdated.value
          : this.dateUpdated,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      referredSavingId: data.referredSavingId.present
          ? data.referredSavingId.value
          : this.referredSavingId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpnsCommitmentTask(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('isDone: $isDone, ')
          ..write('referredSavingId: $referredSavingId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    name,
    amount,
    isDone,
    referredSavingId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpnsCommitmentTask &&
          other.id == this.id &&
          other.createdBy == this.createdBy &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.lastModifiedBy == this.lastModifiedBy &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.isDone == this.isDone &&
          other.referredSavingId == this.referredSavingId);
}

class CommitmentTaskTableCompanion
    extends UpdateCompanion<ExpnsCommitmentTask> {
  final Value<String> id;
  final Value<String> createdBy;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> lastModifiedBy;
  final Value<String> name;
  final Value<double> amount;
  final Value<bool> isDone;
  final Value<String> referredSavingId;
  final Value<int> rowid;
  const CommitmentTaskTableCompanion({
    this.id = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.isDone = const Value.absent(),
    this.referredSavingId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommitmentTaskTableCompanion.insert({
    this.id = const Value.absent(),
    required String createdBy,
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required String lastModifiedBy,
    required String name,
    required double amount,
    this.isDone = const Value.absent(),
    required String referredSavingId,
    this.rowid = const Value.absent(),
  }) : createdBy = Value(createdBy),
       dateUpdated = Value(dateUpdated),
       lastModifiedBy = Value(lastModifiedBy),
       name = Value(name),
       amount = Value(amount),
       referredSavingId = Value(referredSavingId);
  static Insertable<ExpnsCommitmentTask> custom({
    Expression<String>? id,
    Expression<String>? createdBy,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? lastModifiedBy,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<bool>? isDone,
    Expression<String>? referredSavingId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdBy != null) 'created_by': createdBy,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (isDone != null) 'is_done': isDone,
      if (referredSavingId != null) 'referred_saving_id': referredSavingId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommitmentTaskTableCompanion copyWith({
    Value<String>? id,
    Value<String>? createdBy,
    Value<DateTime>? dateCreated,
    Value<DateTime>? dateUpdated,
    Value<String>? lastModifiedBy,
    Value<String>? name,
    Value<double>? amount,
    Value<bool>? isDone,
    Value<String>? referredSavingId,
    Value<int>? rowid,
  }) {
    return CommitmentTaskTableCompanion(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      isDone: isDone ?? this.isDone,
      referredSavingId: referredSavingId ?? this.referredSavingId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (referredSavingId.present) {
      map['referred_saving_id'] = Variable<String>(referredSavingId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommitmentTaskTableCompanion(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('isDone: $isDone, ')
          ..write('referredSavingId: $referredSavingId, ')
          ..write('rowid: $rowid')
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => UuidGenerator().v4(),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
    'date_created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dateUpdatedMeta = const VerificationMeta(
    'dateUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
    'date_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedByMeta = const VerificationMeta(
    'lastModifiedBy',
  );
  @override
  late final GeneratedColumn<String> lastModifiedBy = GeneratedColumn<String>(
    'last_modified_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'CHECK (amount > 0) NOT NULL',
  );
  static const VerificationMeta _savingIdMeta = const VerificationMeta(
    'savingId',
  );
  @override
  late final GeneratedColumn<String> savingId = GeneratedColumn<String>(
    'saving_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES saving_table (id)',
    ),
  );
  static const VerificationMeta _isExpenseMeta = const VerificationMeta(
    'isExpense',
  );
  @override
  late final GeneratedColumn<bool> isExpense = GeneratedColumn<bool>(
    'is_expense',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_expense" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _expenseIdMeta = const VerificationMeta(
    'expenseId',
  );
  @override
  late final GeneratedColumn<String> expenseId = GeneratedColumn<String>(
    'expense_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES expense_table (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    type,
    description,
    amount,
    savingId,
    isExpense,
    expenseId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrnsctnTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    }
    if (data.containsKey('date_updated')) {
      context.handle(
        _dateUpdatedMeta,
        dateUpdated.isAcceptableOrUnknown(
          data['date_updated']!,
          _dateUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateUpdatedMeta);
    }
    if (data.containsKey('last_modified_by')) {
      context.handle(
        _lastModifiedByMeta,
        lastModifiedBy.isAcceptableOrUnknown(
          data['last_modified_by']!,
          _lastModifiedByMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedByMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('saving_id')) {
      context.handle(
        _savingIdMeta,
        savingId.isAcceptableOrUnknown(data['saving_id']!, _savingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_savingIdMeta);
    }
    if (data.containsKey('is_expense')) {
      context.handle(
        _isExpenseMeta,
        isExpense.isAcceptableOrUnknown(data['is_expense']!, _isExpenseMeta),
      );
    }
    if (data.containsKey('expense_id')) {
      context.handle(
        _expenseIdMeta,
        expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrnsctnTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrnsctnTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_created'],
      )!,
      dateUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_updated'],
      )!,
      lastModifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified_by'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      savingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}saving_id'],
      )!,
      isExpense: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_expense'],
      )!,
      expenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_id'],
      ),
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
  final String createdBy;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String lastModifiedBy;
  final String type;
  final String description;
  final double amount;
  final String savingId;
  final bool isExpense;
  final String? expenseId;
  const TrnsctnTransaction({
    required this.id,
    required this.createdBy,
    required this.dateCreated,
    required this.dateUpdated,
    required this.lastModifiedBy,
    required this.type,
    required this.description,
    required this.amount,
    required this.savingId,
    required this.isExpense,
    this.expenseId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_by'] = Variable<String>(createdBy);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['last_modified_by'] = Variable<String>(lastModifiedBy);
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
      createdBy: Value(createdBy),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      lastModifiedBy: Value(lastModifiedBy),
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

  factory TrnsctnTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrnsctnTransaction(
      id: serializer.fromJson<String>(json['id']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      lastModifiedBy: serializer.fromJson<String>(json['lastModifiedBy']),
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
      'createdBy': serializer.toJson<String>(createdBy),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
      'lastModifiedBy': serializer.toJson<String>(lastModifiedBy),
      'type': serializer.toJson<String>(type),
      'description': serializer.toJson<String>(description),
      'amount': serializer.toJson<double>(amount),
      'savingId': serializer.toJson<String>(savingId),
      'isExpense': serializer.toJson<bool>(isExpense),
      'expenseId': serializer.toJson<String?>(expenseId),
    };
  }

  TrnsctnTransaction copyWith({
    String? id,
    String? createdBy,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    String? lastModifiedBy,
    String? type,
    String? description,
    double? amount,
    String? savingId,
    bool? isExpense,
    Value<String?> expenseId = const Value.absent(),
  }) => TrnsctnTransaction(
    id: id ?? this.id,
    createdBy: createdBy ?? this.createdBy,
    dateCreated: dateCreated ?? this.dateCreated,
    dateUpdated: dateUpdated ?? this.dateUpdated,
    lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    type: type ?? this.type,
    description: description ?? this.description,
    amount: amount ?? this.amount,
    savingId: savingId ?? this.savingId,
    isExpense: isExpense ?? this.isExpense,
    expenseId: expenseId.present ? expenseId.value : this.expenseId,
  );
  TrnsctnTransaction copyWithCompanion(TransactionTableCompanion data) {
    return TrnsctnTransaction(
      id: data.id.present ? data.id.value : this.id,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
      dateUpdated: data.dateUpdated.present
          ? data.dateUpdated.value
          : this.dateUpdated,
      lastModifiedBy: data.lastModifiedBy.present
          ? data.lastModifiedBy.value
          : this.lastModifiedBy,
      type: data.type.present ? data.type.value : this.type,
      description: data.description.present
          ? data.description.value
          : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      savingId: data.savingId.present ? data.savingId.value : this.savingId,
      isExpense: data.isExpense.present ? data.isExpense.value : this.isExpense,
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrnsctnTransaction(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
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
  int get hashCode => Object.hash(
    id,
    createdBy,
    dateCreated,
    dateUpdated,
    lastModifiedBy,
    type,
    description,
    amount,
    savingId,
    isExpense,
    expenseId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrnsctnTransaction &&
          other.id == this.id &&
          other.createdBy == this.createdBy &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.lastModifiedBy == this.lastModifiedBy &&
          other.type == this.type &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.savingId == this.savingId &&
          other.isExpense == this.isExpense &&
          other.expenseId == this.expenseId);
}

class TransactionTableCompanion extends UpdateCompanion<TrnsctnTransaction> {
  final Value<String> id;
  final Value<String> createdBy;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> lastModifiedBy;
  final Value<String> type;
  final Value<String> description;
  final Value<double> amount;
  final Value<String> savingId;
  final Value<bool> isExpense;
  final Value<String?> expenseId;
  final Value<int> rowid;
  const TransactionTableCompanion({
    this.id = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.lastModifiedBy = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.savingId = const Value.absent(),
    this.isExpense = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionTableCompanion.insert({
    this.id = const Value.absent(),
    required String createdBy,
    this.dateCreated = const Value.absent(),
    required DateTime dateUpdated,
    required String lastModifiedBy,
    required String type,
    this.description = const Value.absent(),
    required double amount,
    required String savingId,
    this.isExpense = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdBy = Value(createdBy),
       dateUpdated = Value(dateUpdated),
       lastModifiedBy = Value(lastModifiedBy),
       type = Value(type),
       amount = Value(amount),
       savingId = Value(savingId);
  static Insertable<TrnsctnTransaction> custom({
    Expression<String>? id,
    Expression<String>? createdBy,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? lastModifiedBy,
    Expression<String>? type,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<String>? savingId,
    Expression<bool>? isExpense,
    Expression<String>? expenseId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdBy != null) 'created_by': createdBy,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (lastModifiedBy != null) 'last_modified_by': lastModifiedBy,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (savingId != null) 'saving_id': savingId,
      if (isExpense != null) 'is_expense': isExpense,
      if (expenseId != null) 'expense_id': expenseId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionTableCompanion copyWith({
    Value<String>? id,
    Value<String>? createdBy,
    Value<DateTime>? dateCreated,
    Value<DateTime>? dateUpdated,
    Value<String>? lastModifiedBy,
    Value<String>? type,
    Value<String>? description,
    Value<double>? amount,
    Value<String>? savingId,
    Value<bool>? isExpense,
    Value<String?>? expenseId,
    Value<int>? rowid,
  }) {
    return TransactionTableCompanion(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      type: type ?? this.type,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      savingId: savingId ?? this.savingId,
      isExpense: isExpense ?? this.isExpense,
      expenseId: expenseId ?? this.expenseId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    if (lastModifiedBy.present) {
      map['last_modified_by'] = Variable<String>(lastModifiedBy.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTableCompanion(')
          ..write('id: $id, ')
          ..write('createdBy: $createdBy, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('lastModifiedBy: $lastModifiedBy, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('savingId: $savingId, ')
          ..write('isExpense: $isExpense, ')
          ..write('expenseId: $expenseId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserTableTable userTable = $UserTableTable(this);
  late final $GroupReferenceTableTable groupReferenceTable =
      $GroupReferenceTableTable(this);
  late final $ReferenceTableTable referenceTable = $ReferenceTableTable(this);
  late final $ReferenceDataTableTable referenceDataTable =
      $ReferenceDataTableTable(this);
  late final $ExpenseReferenceTableTable expenseReferenceTable =
      $ExpenseReferenceTableTable(this);
  late final $MoneyStorageTableTable moneyStorageTable =
      $MoneyStorageTableTable(this);
  late final $SavingTableTable savingTable = $SavingTableTable(this);
  late final $ExpenseTableTable expenseTable = $ExpenseTableTable(this);
  late final $CommitmentTableTable commitmentTable = $CommitmentTableTable(
    this,
  );
  late final $CommitmentDetailTableTable commitmentDetailTable =
      $CommitmentDetailTableTable(this);
  late final $CommitmentTaskTableTable commitmentTaskTable =
      $CommitmentTaskTableTable(this);
  late final $TransactionTableTable transactionTable = $TransactionTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userTable,
    groupReferenceTable,
    referenceTable,
    referenceDataTable,
    expenseReferenceTable,
    moneyStorageTable,
    savingTable,
    expenseTable,
    commitmentTable,
    commitmentDetailTable,
    commitmentTaskTable,
    transactionTable,
  ];
}

typedef $$UserTableTableCreateCompanionBuilder =
    UserTableCompanion Function({
      Value<String> id,
      required String createdBy,
      Value<DateTime> dateCreated,
      required DateTime dateUpdated,
      required String lastModifiedBy,
      required String name,
      Value<String?> email,
      Value<String?> phoneNumber,
      Value<int> rowid,
    });
typedef $$UserTableTableUpdateCompanionBuilder =
    UserTableCompanion Function({
      Value<String> id,
      Value<String> createdBy,
      Value<DateTime> dateCreated,
      Value<DateTime> dateUpdated,
      Value<String> lastModifiedBy,
      Value<String> name,
      Value<String?> email,
      Value<String?> phoneNumber,
      Value<int> rowid,
    });

final class $$UserTableTableReferences
    extends BaseReferences<_$AppDatabase, $UserTableTable, CmmnUser> {
  $$UserTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MoneyStorageTableTable, List<SvngMoneyStorage>>
  _moneyStorageTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.moneyStorageTable,
        aliasName: $_aliasNameGenerator(
          db.userTable.id,
          db.moneyStorageTable.userId,
        ),
      );

  $$MoneyStorageTableTableProcessedTableManager get moneyStorageTableRefs {
    final manager = $$MoneyStorageTableTableTableManager(
      $_db,
      $_db.moneyStorageTable,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _moneyStorageTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SavingTableTable, List<SvngSaving>>
  _savingTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.savingTable,
    aliasName: $_aliasNameGenerator(db.userTable.id, db.savingTable.userId),
  );

  $$SavingTableTableProcessedTableManager get savingTableRefs {
    final manager = $$SavingTableTableTableManager(
      $_db,
      $_db.savingTable,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_savingTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CommitmentTableTable, List<ExpnsCommitment>>
  _commitmentTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.commitmentTable,
    aliasName: $_aliasNameGenerator(db.userTable.id, db.commitmentTable.userId),
  );

  $$CommitmentTableTableProcessedTableManager get commitmentTableRefs {
    final manager = $$CommitmentTableTableTableManager(
      $_db,
      $_db.commitmentTable,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _commitmentTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserTableTable> {
  $$UserTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> moneyStorageTableRefs(
    Expression<bool> Function($$MoneyStorageTableTableFilterComposer f) f,
  ) {
    final $$MoneyStorageTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyStorageTable,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyStorageTableTableFilterComposer(
            $db: $db,
            $table: $db.moneyStorageTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> savingTableRefs(
    Expression<bool> Function($$SavingTableTableFilterComposer f) f,
  ) {
    final $$SavingTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savingTable,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingTableTableFilterComposer(
            $db: $db,
            $table: $db.savingTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> commitmentTableRefs(
    Expression<bool> Function($$CommitmentTableTableFilterComposer f) f,
  ) {
    final $$CommitmentTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commitmentTable,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentTableTableFilterComposer(
            $db: $db,
            $table: $db.commitmentTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserTableTable> {
  $$UserTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserTableTable> {
  $$UserTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  Expression<T> moneyStorageTableRefs<T extends Object>(
    Expression<T> Function($$MoneyStorageTableTableAnnotationComposer a) f,
  ) {
    final $$MoneyStorageTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.moneyStorageTable,
          getReferencedColumn: (t) => t.userId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MoneyStorageTableTableAnnotationComposer(
                $db: $db,
                $table: $db.moneyStorageTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> savingTableRefs<T extends Object>(
    Expression<T> Function($$SavingTableTableAnnotationComposer a) f,
  ) {
    final $$SavingTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savingTable,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingTableTableAnnotationComposer(
            $db: $db,
            $table: $db.savingTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> commitmentTableRefs<T extends Object>(
    Expression<T> Function($$CommitmentTableTableAnnotationComposer a) f,
  ) {
    final $$CommitmentTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commitmentTable,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentTableTableAnnotationComposer(
            $db: $db,
            $table: $db.commitmentTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserTableTable,
          CmmnUser,
          $$UserTableTableFilterComposer,
          $$UserTableTableOrderingComposer,
          $$UserTableTableAnnotationComposer,
          $$UserTableTableCreateCompanionBuilder,
          $$UserTableTableUpdateCompanionBuilder,
          (CmmnUser, $$UserTableTableReferences),
          CmmnUser,
          PrefetchHooks Function({
            bool moneyStorageTableRefs,
            bool savingTableRefs,
            bool commitmentTableRefs,
          })
        > {
  $$UserTableTableTableManager(_$AppDatabase db, $UserTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<DateTime> dateUpdated = const Value.absent(),
                Value<String> lastModifiedBy = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserTableCompanion(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                name: name,
                email: email,
                phoneNumber: phoneNumber,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String createdBy,
                Value<DateTime> dateCreated = const Value.absent(),
                required DateTime dateUpdated,
                required String lastModifiedBy,
                required String name,
                Value<String?> email = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserTableCompanion.insert(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                name: name,
                email: email,
                phoneNumber: phoneNumber,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                moneyStorageTableRefs = false,
                savingTableRefs = false,
                commitmentTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (moneyStorageTableRefs) db.moneyStorageTable,
                    if (savingTableRefs) db.savingTable,
                    if (commitmentTableRefs) db.commitmentTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (moneyStorageTableRefs)
                        await $_getPrefetchedData<
                          CmmnUser,
                          $UserTableTable,
                          SvngMoneyStorage
                        >(
                          currentTable: table,
                          referencedTable: $$UserTableTableReferences
                              ._moneyStorageTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserTableTableReferences(
                                db,
                                table,
                                p0,
                              ).moneyStorageTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (savingTableRefs)
                        await $_getPrefetchedData<
                          CmmnUser,
                          $UserTableTable,
                          SvngSaving
                        >(
                          currentTable: table,
                          referencedTable: $$UserTableTableReferences
                              ._savingTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserTableTableReferences(
                                db,
                                table,
                                p0,
                              ).savingTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (commitmentTableRefs)
                        await $_getPrefetchedData<
                          CmmnUser,
                          $UserTableTable,
                          ExpnsCommitment
                        >(
                          currentTable: table,
                          referencedTable: $$UserTableTableReferences
                              ._commitmentTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserTableTableReferences(
                                db,
                                table,
                                p0,
                              ).commitmentTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UserTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserTableTable,
      CmmnUser,
      $$UserTableTableFilterComposer,
      $$UserTableTableOrderingComposer,
      $$UserTableTableAnnotationComposer,
      $$UserTableTableCreateCompanionBuilder,
      $$UserTableTableUpdateCompanionBuilder,
      (CmmnUser, $$UserTableTableReferences),
      CmmnUser,
      PrefetchHooks Function({
        bool moneyStorageTableRefs,
        bool savingTableRefs,
        bool commitmentTableRefs,
      })
    >;
typedef $$GroupReferenceTableTableCreateCompanionBuilder =
    GroupReferenceTableCompanion Function({
      Value<String> id,
      required String createdBy,
      Value<DateTime> dateCreated,
      required DateTime dateUpdated,
      required String lastModifiedBy,
      required String label,
      required String value,
      Value<int> rowid,
    });
typedef $$GroupReferenceTableTableUpdateCompanionBuilder =
    GroupReferenceTableCompanion Function({
      Value<String> id,
      Value<String> createdBy,
      Value<DateTime> dateCreated,
      Value<DateTime> dateUpdated,
      Value<String> lastModifiedBy,
      Value<String> label,
      Value<String> value,
      Value<int> rowid,
    });

final class $$GroupReferenceTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GroupReferenceTableTable,
          MstrdtGroupReference
        > {
  $$GroupReferenceTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ReferenceTableTable, List<MstrdtReference>>
  _referenceTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.referenceTable,
    aliasName: $_aliasNameGenerator(
      db.groupReferenceTable.id,
      db.referenceTable.groupId,
    ),
  );

  $$ReferenceTableTableProcessedTableManager get referenceTableRefs {
    final manager = $$ReferenceTableTableTableManager(
      $_db,
      $_db.referenceTable,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_referenceTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GroupReferenceTableTableFilterComposer
    extends Composer<_$AppDatabase, $GroupReferenceTableTable> {
  $$GroupReferenceTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> referenceTableRefs(
    Expression<bool> Function($$ReferenceTableTableFilterComposer f) f,
  ) {
    final $$ReferenceTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.referenceTable,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceTableTableFilterComposer(
            $db: $db,
            $table: $db.referenceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupReferenceTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupReferenceTableTable> {
  $$GroupReferenceTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroupReferenceTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupReferenceTableTable> {
  $$GroupReferenceTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  Expression<T> referenceTableRefs<T extends Object>(
    Expression<T> Function($$ReferenceTableTableAnnotationComposer a) f,
  ) {
    final $$ReferenceTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.referenceTable,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceTableTableAnnotationComposer(
            $db: $db,
            $table: $db.referenceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupReferenceTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupReferenceTableTable,
          MstrdtGroupReference,
          $$GroupReferenceTableTableFilterComposer,
          $$GroupReferenceTableTableOrderingComposer,
          $$GroupReferenceTableTableAnnotationComposer,
          $$GroupReferenceTableTableCreateCompanionBuilder,
          $$GroupReferenceTableTableUpdateCompanionBuilder,
          (MstrdtGroupReference, $$GroupReferenceTableTableReferences),
          MstrdtGroupReference,
          PrefetchHooks Function({bool referenceTableRefs})
        > {
  $$GroupReferenceTableTableTableManager(
    _$AppDatabase db,
    $GroupReferenceTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupReferenceTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupReferenceTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GroupReferenceTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<DateTime> dateUpdated = const Value.absent(),
                Value<String> lastModifiedBy = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupReferenceTableCompanion(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                label: label,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String createdBy,
                Value<DateTime> dateCreated = const Value.absent(),
                required DateTime dateUpdated,
                required String lastModifiedBy,
                required String label,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => GroupReferenceTableCompanion.insert(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                label: label,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GroupReferenceTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({referenceTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (referenceTableRefs) db.referenceTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (referenceTableRefs)
                    await $_getPrefetchedData<
                      MstrdtGroupReference,
                      $GroupReferenceTableTable,
                      MstrdtReference
                    >(
                      currentTable: table,
                      referencedTable: $$GroupReferenceTableTableReferences
                          ._referenceTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GroupReferenceTableTableReferences(
                            db,
                            table,
                            p0,
                          ).referenceTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.groupId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GroupReferenceTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupReferenceTableTable,
      MstrdtGroupReference,
      $$GroupReferenceTableTableFilterComposer,
      $$GroupReferenceTableTableOrderingComposer,
      $$GroupReferenceTableTableAnnotationComposer,
      $$GroupReferenceTableTableCreateCompanionBuilder,
      $$GroupReferenceTableTableUpdateCompanionBuilder,
      (MstrdtGroupReference, $$GroupReferenceTableTableReferences),
      MstrdtGroupReference,
      PrefetchHooks Function({bool referenceTableRefs})
    >;
typedef $$ReferenceTableTableCreateCompanionBuilder =
    ReferenceTableCompanion Function({
      Value<String> id,
      required String createdBy,
      Value<DateTime> dateCreated,
      required DateTime dateUpdated,
      required String lastModifiedBy,
      required String label,
      required String value,
      Value<bool> isActive,
      required String belongTo,
      required String groupId,
      Value<int> rowid,
    });
typedef $$ReferenceTableTableUpdateCompanionBuilder =
    ReferenceTableCompanion Function({
      Value<String> id,
      Value<String> createdBy,
      Value<DateTime> dateCreated,
      Value<DateTime> dateUpdated,
      Value<String> lastModifiedBy,
      Value<String> label,
      Value<String> value,
      Value<bool> isActive,
      Value<String> belongTo,
      Value<String> groupId,
      Value<int> rowid,
    });

final class $$ReferenceTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $ReferenceTableTable, MstrdtReference> {
  $$ReferenceTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ReferenceTableTable _belongToTable(_$AppDatabase db) =>
      db.referenceTable.createAlias(
        $_aliasNameGenerator(db.referenceTable.belongTo, db.referenceTable.id),
      );

  $$ReferenceTableTableProcessedTableManager get belongTo {
    final $_column = $_itemColumn<String>('belong_to')!;

    final manager = $$ReferenceTableTableTableManager(
      $_db,
      $_db.referenceTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_belongToTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GroupReferenceTableTable _groupIdTable(_$AppDatabase db) =>
      db.groupReferenceTable.createAlias(
        $_aliasNameGenerator(
          db.referenceTable.groupId,
          db.groupReferenceTable.id,
        ),
      );

  $$GroupReferenceTableTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$GroupReferenceTableTableTableManager(
      $_db,
      $_db.groupReferenceTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ReferenceDataTableTable,
    List<MstrdtReferenceData>
  >
  _referenceDataTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.referenceDataTable,
        aliasName: $_aliasNameGenerator(
          db.referenceTable.id,
          db.referenceDataTable.referenceId,
        ),
      );

  $$ReferenceDataTableTableProcessedTableManager get referenceDataTableRefs {
    final manager = $$ReferenceDataTableTableTableManager(
      $_db,
      $_db.referenceDataTable,
    ).filter((f) => f.referenceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _referenceDataTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ExpenseReferenceTableTable,
    List<MstrdtExpenseReference>
  >
  _expenseReferenceTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.expenseReferenceTable,
        aliasName: $_aliasNameGenerator(
          db.referenceTable.id,
          db.expenseReferenceTable.referenceId,
        ),
      );

  $$ExpenseReferenceTableTableProcessedTableManager
  get expenseReferenceTableRefs {
    final manager = $$ExpenseReferenceTableTableTableManager(
      $_db,
      $_db.expenseReferenceTable,
    ).filter((f) => f.referenceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _expenseReferenceTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReferenceTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReferenceTableTable> {
  $$ReferenceTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  $$ReferenceTableTableFilterComposer get belongTo {
    final $$ReferenceTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.belongTo,
      referencedTable: $db.referenceTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceTableTableFilterComposer(
            $db: $db,
            $table: $db.referenceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupReferenceTableTableFilterComposer get groupId {
    final $$GroupReferenceTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupReferenceTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupReferenceTableTableFilterComposer(
            $db: $db,
            $table: $db.groupReferenceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> referenceDataTableRefs(
    Expression<bool> Function($$ReferenceDataTableTableFilterComposer f) f,
  ) {
    final $$ReferenceDataTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.referenceDataTable,
      getReferencedColumn: (t) => t.referenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceDataTableTableFilterComposer(
            $db: $db,
            $table: $db.referenceDataTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expenseReferenceTableRefs(
    Expression<bool> Function($$ExpenseReferenceTableTableFilterComposer f) f,
  ) {
    final $$ExpenseReferenceTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.expenseReferenceTable,
          getReferencedColumn: (t) => t.referenceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExpenseReferenceTableTableFilterComposer(
                $db: $db,
                $table: $db.expenseReferenceTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ReferenceTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReferenceTableTable> {
  $$ReferenceTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReferenceTableTableOrderingComposer get belongTo {
    final $$ReferenceTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.belongTo,
      referencedTable: $db.referenceTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceTableTableOrderingComposer(
            $db: $db,
            $table: $db.referenceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupReferenceTableTableOrderingComposer get groupId {
    final $$GroupReferenceTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.groupId,
          referencedTable: $db.groupReferenceTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupReferenceTableTableOrderingComposer(
                $db: $db,
                $table: $db.groupReferenceTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ReferenceTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReferenceTableTable> {
  $$ReferenceTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$ReferenceTableTableAnnotationComposer get belongTo {
    final $$ReferenceTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.belongTo,
      referencedTable: $db.referenceTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceTableTableAnnotationComposer(
            $db: $db,
            $table: $db.referenceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupReferenceTableTableAnnotationComposer get groupId {
    final $$GroupReferenceTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.groupId,
          referencedTable: $db.groupReferenceTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroupReferenceTableTableAnnotationComposer(
                $db: $db,
                $table: $db.groupReferenceTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> referenceDataTableRefs<T extends Object>(
    Expression<T> Function($$ReferenceDataTableTableAnnotationComposer a) f,
  ) {
    final $$ReferenceDataTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.referenceDataTable,
          getReferencedColumn: (t) => t.referenceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReferenceDataTableTableAnnotationComposer(
                $db: $db,
                $table: $db.referenceDataTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> expenseReferenceTableRefs<T extends Object>(
    Expression<T> Function($$ExpenseReferenceTableTableAnnotationComposer a) f,
  ) {
    final $$ExpenseReferenceTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.expenseReferenceTable,
          getReferencedColumn: (t) => t.referenceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExpenseReferenceTableTableAnnotationComposer(
                $db: $db,
                $table: $db.expenseReferenceTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ReferenceTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReferenceTableTable,
          MstrdtReference,
          $$ReferenceTableTableFilterComposer,
          $$ReferenceTableTableOrderingComposer,
          $$ReferenceTableTableAnnotationComposer,
          $$ReferenceTableTableCreateCompanionBuilder,
          $$ReferenceTableTableUpdateCompanionBuilder,
          (MstrdtReference, $$ReferenceTableTableReferences),
          MstrdtReference,
          PrefetchHooks Function({
            bool belongTo,
            bool groupId,
            bool referenceDataTableRefs,
            bool expenseReferenceTableRefs,
          })
        > {
  $$ReferenceTableTableTableManager(
    _$AppDatabase db,
    $ReferenceTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReferenceTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReferenceTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReferenceTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<DateTime> dateUpdated = const Value.absent(),
                Value<String> lastModifiedBy = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> belongTo = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReferenceTableCompanion(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                label: label,
                value: value,
                isActive: isActive,
                belongTo: belongTo,
                groupId: groupId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String createdBy,
                Value<DateTime> dateCreated = const Value.absent(),
                required DateTime dateUpdated,
                required String lastModifiedBy,
                required String label,
                required String value,
                Value<bool> isActive = const Value.absent(),
                required String belongTo,
                required String groupId,
                Value<int> rowid = const Value.absent(),
              }) => ReferenceTableCompanion.insert(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                label: label,
                value: value,
                isActive: isActive,
                belongTo: belongTo,
                groupId: groupId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReferenceTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                belongTo = false,
                groupId = false,
                referenceDataTableRefs = false,
                expenseReferenceTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (referenceDataTableRefs) db.referenceDataTable,
                    if (expenseReferenceTableRefs) db.expenseReferenceTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (belongTo) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.belongTo,
                                    referencedTable:
                                        $$ReferenceTableTableReferences
                                            ._belongToTable(db),
                                    referencedColumn:
                                        $$ReferenceTableTableReferences
                                            ._belongToTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (groupId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.groupId,
                                    referencedTable:
                                        $$ReferenceTableTableReferences
                                            ._groupIdTable(db),
                                    referencedColumn:
                                        $$ReferenceTableTableReferences
                                            ._groupIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (referenceDataTableRefs)
                        await $_getPrefetchedData<
                          MstrdtReference,
                          $ReferenceTableTable,
                          MstrdtReferenceData
                        >(
                          currentTable: table,
                          referencedTable: $$ReferenceTableTableReferences
                              ._referenceDataTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ReferenceTableTableReferences(
                                db,
                                table,
                                p0,
                              ).referenceDataTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.referenceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (expenseReferenceTableRefs)
                        await $_getPrefetchedData<
                          MstrdtReference,
                          $ReferenceTableTable,
                          MstrdtExpenseReference
                        >(
                          currentTable: table,
                          referencedTable: $$ReferenceTableTableReferences
                              ._expenseReferenceTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ReferenceTableTableReferences(
                                db,
                                table,
                                p0,
                              ).expenseReferenceTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.referenceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ReferenceTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReferenceTableTable,
      MstrdtReference,
      $$ReferenceTableTableFilterComposer,
      $$ReferenceTableTableOrderingComposer,
      $$ReferenceTableTableAnnotationComposer,
      $$ReferenceTableTableCreateCompanionBuilder,
      $$ReferenceTableTableUpdateCompanionBuilder,
      (MstrdtReference, $$ReferenceTableTableReferences),
      MstrdtReference,
      PrefetchHooks Function({
        bool belongTo,
        bool groupId,
        bool referenceDataTableRefs,
        bool expenseReferenceTableRefs,
      })
    >;
typedef $$ReferenceDataTableTableCreateCompanionBuilder =
    ReferenceDataTableCompanion Function({
      Value<String> id,
      required String createdBy,
      Value<DateTime> dateCreated,
      required DateTime dateUpdated,
      required String lastModifiedBy,
      required String label,
      required String groupLabel,
      required String value,
      required String groupValue,
      Value<String?> referenceId,
      Value<bool> isHasNext,
      Value<String?> nextReferenceDataId,
      Value<int> rowid,
    });
typedef $$ReferenceDataTableTableUpdateCompanionBuilder =
    ReferenceDataTableCompanion Function({
      Value<String> id,
      Value<String> createdBy,
      Value<DateTime> dateCreated,
      Value<DateTime> dateUpdated,
      Value<String> lastModifiedBy,
      Value<String> label,
      Value<String> groupLabel,
      Value<String> value,
      Value<String> groupValue,
      Value<String?> referenceId,
      Value<bool> isHasNext,
      Value<String?> nextReferenceDataId,
      Value<int> rowid,
    });

final class $$ReferenceDataTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReferenceDataTableTable,
          MstrdtReferenceData
        > {
  $$ReferenceDataTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ReferenceTableTable _referenceIdTable(_$AppDatabase db) =>
      db.referenceTable.createAlias(
        $_aliasNameGenerator(
          db.referenceDataTable.referenceId,
          db.referenceTable.id,
        ),
      );

  $$ReferenceTableTableProcessedTableManager? get referenceId {
    final $_column = $_itemColumn<String>('reference_id');
    if ($_column == null) return null;
    final manager = $$ReferenceTableTableTableManager(
      $_db,
      $_db.referenceTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_referenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ReferenceDataTableTable _nextReferenceDataIdTable(_$AppDatabase db) =>
      db.referenceDataTable.createAlias(
        $_aliasNameGenerator(
          db.referenceDataTable.nextReferenceDataId,
          db.referenceDataTable.id,
        ),
      );

  $$ReferenceDataTableTableProcessedTableManager? get nextReferenceDataId {
    final $_column = $_itemColumn<String>('next_reference_data_id');
    if ($_column == null) return null;
    final manager = $$ReferenceDataTableTableTableManager(
      $_db,
      $_db.referenceDataTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_nextReferenceDataIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExpenseTableTable, List<ExpnsExpense>>
  _expenseTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenseTable,
    aliasName: $_aliasNameGenerator(
      db.referenceDataTable.id,
      db.expenseTable.referenceDataId,
    ),
  );

  $$ExpenseTableTableProcessedTableManager get expenseTableRefs {
    final manager = $$ExpenseTableTableTableManager($_db, $_db.expenseTable)
        .filter(
          (f) => f.referenceDataId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_expenseTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReferenceDataTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReferenceDataTableTable> {
  $$ReferenceDataTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupLabel => $composableBuilder(
    column: $table.groupLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupValue => $composableBuilder(
    column: $table.groupValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHasNext => $composableBuilder(
    column: $table.isHasNext,
    builder: (column) => ColumnFilters(column),
  );

  $$ReferenceTableTableFilterComposer get referenceId {
    final $$ReferenceTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.referenceId,
      referencedTable: $db.referenceTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceTableTableFilterComposer(
            $db: $db,
            $table: $db.referenceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReferenceDataTableTableFilterComposer get nextReferenceDataId {
    final $$ReferenceDataTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nextReferenceDataId,
      referencedTable: $db.referenceDataTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceDataTableTableFilterComposer(
            $db: $db,
            $table: $db.referenceDataTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> expenseTableRefs(
    Expression<bool> Function($$ExpenseTableTableFilterComposer f) f,
  ) {
    final $$ExpenseTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenseTable,
      getReferencedColumn: (t) => t.referenceDataId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseTableTableFilterComposer(
            $db: $db,
            $table: $db.expenseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReferenceDataTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReferenceDataTableTable> {
  $$ReferenceDataTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupLabel => $composableBuilder(
    column: $table.groupLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupValue => $composableBuilder(
    column: $table.groupValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHasNext => $composableBuilder(
    column: $table.isHasNext,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReferenceTableTableOrderingComposer get referenceId {
    final $$ReferenceTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.referenceId,
      referencedTable: $db.referenceTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceTableTableOrderingComposer(
            $db: $db,
            $table: $db.referenceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReferenceDataTableTableOrderingComposer get nextReferenceDataId {
    final $$ReferenceDataTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nextReferenceDataId,
      referencedTable: $db.referenceDataTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceDataTableTableOrderingComposer(
            $db: $db,
            $table: $db.referenceDataTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReferenceDataTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReferenceDataTableTable> {
  $$ReferenceDataTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get groupLabel => $composableBuilder(
    column: $table.groupLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get groupValue => $composableBuilder(
    column: $table.groupValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isHasNext =>
      $composableBuilder(column: $table.isHasNext, builder: (column) => column);

  $$ReferenceTableTableAnnotationComposer get referenceId {
    final $$ReferenceTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.referenceId,
      referencedTable: $db.referenceTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceTableTableAnnotationComposer(
            $db: $db,
            $table: $db.referenceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReferenceDataTableTableAnnotationComposer get nextReferenceDataId {
    final $$ReferenceDataTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.nextReferenceDataId,
          referencedTable: $db.referenceDataTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReferenceDataTableTableAnnotationComposer(
                $db: $db,
                $table: $db.referenceDataTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> expenseTableRefs<T extends Object>(
    Expression<T> Function($$ExpenseTableTableAnnotationComposer a) f,
  ) {
    final $$ExpenseTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenseTable,
      getReferencedColumn: (t) => t.referenceDataId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseTableTableAnnotationComposer(
            $db: $db,
            $table: $db.expenseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReferenceDataTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReferenceDataTableTable,
          MstrdtReferenceData,
          $$ReferenceDataTableTableFilterComposer,
          $$ReferenceDataTableTableOrderingComposer,
          $$ReferenceDataTableTableAnnotationComposer,
          $$ReferenceDataTableTableCreateCompanionBuilder,
          $$ReferenceDataTableTableUpdateCompanionBuilder,
          (MstrdtReferenceData, $$ReferenceDataTableTableReferences),
          MstrdtReferenceData,
          PrefetchHooks Function({
            bool referenceId,
            bool nextReferenceDataId,
            bool expenseTableRefs,
          })
        > {
  $$ReferenceDataTableTableTableManager(
    _$AppDatabase db,
    $ReferenceDataTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReferenceDataTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReferenceDataTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReferenceDataTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<DateTime> dateUpdated = const Value.absent(),
                Value<String> lastModifiedBy = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> groupLabel = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String> groupValue = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<bool> isHasNext = const Value.absent(),
                Value<String?> nextReferenceDataId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReferenceDataTableCompanion(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                label: label,
                groupLabel: groupLabel,
                value: value,
                groupValue: groupValue,
                referenceId: referenceId,
                isHasNext: isHasNext,
                nextReferenceDataId: nextReferenceDataId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String createdBy,
                Value<DateTime> dateCreated = const Value.absent(),
                required DateTime dateUpdated,
                required String lastModifiedBy,
                required String label,
                required String groupLabel,
                required String value,
                required String groupValue,
                Value<String?> referenceId = const Value.absent(),
                Value<bool> isHasNext = const Value.absent(),
                Value<String?> nextReferenceDataId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReferenceDataTableCompanion.insert(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                label: label,
                groupLabel: groupLabel,
                value: value,
                groupValue: groupValue,
                referenceId: referenceId,
                isHasNext: isHasNext,
                nextReferenceDataId: nextReferenceDataId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReferenceDataTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                referenceId = false,
                nextReferenceDataId = false,
                expenseTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (expenseTableRefs) db.expenseTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (referenceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.referenceId,
                                    referencedTable:
                                        $$ReferenceDataTableTableReferences
                                            ._referenceIdTable(db),
                                    referencedColumn:
                                        $$ReferenceDataTableTableReferences
                                            ._referenceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (nextReferenceDataId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.nextReferenceDataId,
                                    referencedTable:
                                        $$ReferenceDataTableTableReferences
                                            ._nextReferenceDataIdTable(db),
                                    referencedColumn:
                                        $$ReferenceDataTableTableReferences
                                            ._nextReferenceDataIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (expenseTableRefs)
                        await $_getPrefetchedData<
                          MstrdtReferenceData,
                          $ReferenceDataTableTable,
                          ExpnsExpense
                        >(
                          currentTable: table,
                          referencedTable: $$ReferenceDataTableTableReferences
                              ._expenseTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ReferenceDataTableTableReferences(
                                db,
                                table,
                                p0,
                              ).expenseTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.referenceDataId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ReferenceDataTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReferenceDataTableTable,
      MstrdtReferenceData,
      $$ReferenceDataTableTableFilterComposer,
      $$ReferenceDataTableTableOrderingComposer,
      $$ReferenceDataTableTableAnnotationComposer,
      $$ReferenceDataTableTableCreateCompanionBuilder,
      $$ReferenceDataTableTableUpdateCompanionBuilder,
      (MstrdtReferenceData, $$ReferenceDataTableTableReferences),
      MstrdtReferenceData,
      PrefetchHooks Function({
        bool referenceId,
        bool nextReferenceDataId,
        bool expenseTableRefs,
      })
    >;
typedef $$ExpenseReferenceTableTableCreateCompanionBuilder =
    ExpenseReferenceTableCompanion Function({
      Value<String> id,
      required String createdBy,
      Value<DateTime> dateCreated,
      required DateTime dateUpdated,
      required String lastModifiedBy,
      Value<double> suggestedAmount,
      Value<String?> description,
      required String referenceId,
      Value<int> rowid,
    });
typedef $$ExpenseReferenceTableTableUpdateCompanionBuilder =
    ExpenseReferenceTableCompanion Function({
      Value<String> id,
      Value<String> createdBy,
      Value<DateTime> dateCreated,
      Value<DateTime> dateUpdated,
      Value<String> lastModifiedBy,
      Value<double> suggestedAmount,
      Value<String?> description,
      Value<String> referenceId,
      Value<int> rowid,
    });

final class $$ExpenseReferenceTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExpenseReferenceTableTable,
          MstrdtExpenseReference
        > {
  $$ExpenseReferenceTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ReferenceTableTable _referenceIdTable(_$AppDatabase db) =>
      db.referenceTable.createAlias(
        $_aliasNameGenerator(
          db.expenseReferenceTable.referenceId,
          db.referenceTable.id,
        ),
      );

  $$ReferenceTableTableProcessedTableManager get referenceId {
    final $_column = $_itemColumn<String>('reference_id')!;

    final manager = $$ReferenceTableTableTableManager(
      $_db,
      $_db.referenceTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_referenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpenseReferenceTableTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseReferenceTableTable> {
  $$ExpenseReferenceTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get suggestedAmount => $composableBuilder(
    column: $table.suggestedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  $$ReferenceTableTableFilterComposer get referenceId {
    final $$ReferenceTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.referenceId,
      referencedTable: $db.referenceTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceTableTableFilterComposer(
            $db: $db,
            $table: $db.referenceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpenseReferenceTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseReferenceTableTable> {
  $$ExpenseReferenceTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get suggestedAmount => $composableBuilder(
    column: $table.suggestedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReferenceTableTableOrderingComposer get referenceId {
    final $$ReferenceTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.referenceId,
      referencedTable: $db.referenceTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceTableTableOrderingComposer(
            $db: $db,
            $table: $db.referenceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpenseReferenceTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseReferenceTableTable> {
  $$ExpenseReferenceTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<double> get suggestedAmount => $composableBuilder(
    column: $table.suggestedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  $$ReferenceTableTableAnnotationComposer get referenceId {
    final $$ReferenceTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.referenceId,
      referencedTable: $db.referenceTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceTableTableAnnotationComposer(
            $db: $db,
            $table: $db.referenceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpenseReferenceTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseReferenceTableTable,
          MstrdtExpenseReference,
          $$ExpenseReferenceTableTableFilterComposer,
          $$ExpenseReferenceTableTableOrderingComposer,
          $$ExpenseReferenceTableTableAnnotationComposer,
          $$ExpenseReferenceTableTableCreateCompanionBuilder,
          $$ExpenseReferenceTableTableUpdateCompanionBuilder,
          (MstrdtExpenseReference, $$ExpenseReferenceTableTableReferences),
          MstrdtExpenseReference,
          PrefetchHooks Function({bool referenceId})
        > {
  $$ExpenseReferenceTableTableTableManager(
    _$AppDatabase db,
    $ExpenseReferenceTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseReferenceTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ExpenseReferenceTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExpenseReferenceTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<DateTime> dateUpdated = const Value.absent(),
                Value<String> lastModifiedBy = const Value.absent(),
                Value<double> suggestedAmount = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> referenceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseReferenceTableCompanion(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                suggestedAmount: suggestedAmount,
                description: description,
                referenceId: referenceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String createdBy,
                Value<DateTime> dateCreated = const Value.absent(),
                required DateTime dateUpdated,
                required String lastModifiedBy,
                Value<double> suggestedAmount = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required String referenceId,
                Value<int> rowid = const Value.absent(),
              }) => ExpenseReferenceTableCompanion.insert(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                suggestedAmount: suggestedAmount,
                description: description,
                referenceId: referenceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpenseReferenceTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({referenceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (referenceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.referenceId,
                                referencedTable:
                                    $$ExpenseReferenceTableTableReferences
                                        ._referenceIdTable(db),
                                referencedColumn:
                                    $$ExpenseReferenceTableTableReferences
                                        ._referenceIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExpenseReferenceTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpenseReferenceTableTable,
      MstrdtExpenseReference,
      $$ExpenseReferenceTableTableFilterComposer,
      $$ExpenseReferenceTableTableOrderingComposer,
      $$ExpenseReferenceTableTableAnnotationComposer,
      $$ExpenseReferenceTableTableCreateCompanionBuilder,
      $$ExpenseReferenceTableTableUpdateCompanionBuilder,
      (MstrdtExpenseReference, $$ExpenseReferenceTableTableReferences),
      MstrdtExpenseReference,
      PrefetchHooks Function({bool referenceId})
    >;
typedef $$MoneyStorageTableTableCreateCompanionBuilder =
    MoneyStorageTableCompanion Function({
      Value<String> id,
      required String createdBy,
      Value<DateTime> dateCreated,
      required DateTime dateUpdated,
      required String lastModifiedBy,
      Value<String> iconUrl,
      required String longName,
      required String shortName,
      required String type,
      Value<String?> userId,
      Value<int> rowid,
    });
typedef $$MoneyStorageTableTableUpdateCompanionBuilder =
    MoneyStorageTableCompanion Function({
      Value<String> id,
      Value<String> createdBy,
      Value<DateTime> dateCreated,
      Value<DateTime> dateUpdated,
      Value<String> lastModifiedBy,
      Value<String> iconUrl,
      Value<String> longName,
      Value<String> shortName,
      Value<String> type,
      Value<String?> userId,
      Value<int> rowid,
    });

final class $$MoneyStorageTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MoneyStorageTableTable,
          SvngMoneyStorage
        > {
  $$MoneyStorageTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UserTableTable _userIdTable(_$AppDatabase db) =>
      db.userTable.createAlias(
        $_aliasNameGenerator(db.moneyStorageTable.userId, db.userTable.id),
      );

  $$UserTableTableProcessedTableManager? get userId {
    final $_column = $_itemColumn<String>('user_id');
    if ($_column == null) return null;
    final manager = $$UserTableTableTableManager(
      $_db,
      $_db.userTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SavingTableTable, List<SvngSaving>>
  _savingTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.savingTable,
    aliasName: $_aliasNameGenerator(
      db.moneyStorageTable.id,
      db.savingTable.moneyStorageId,
    ),
  );

  $$SavingTableTableProcessedTableManager get savingTableRefs {
    final manager = $$SavingTableTableTableManager(
      $_db,
      $_db.savingTable,
    ).filter((f) => f.moneyStorageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_savingTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MoneyStorageTableTableFilterComposer
    extends Composer<_$AppDatabase, $MoneyStorageTableTable> {
  $$MoneyStorageTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconUrl => $composableBuilder(
    column: $table.iconUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get longName => $composableBuilder(
    column: $table.longName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  $$UserTableTableFilterComposer get userId {
    final $$UserTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTableTableFilterComposer(
            $db: $db,
            $table: $db.userTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> savingTableRefs(
    Expression<bool> Function($$SavingTableTableFilterComposer f) f,
  ) {
    final $$SavingTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savingTable,
      getReferencedColumn: (t) => t.moneyStorageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingTableTableFilterComposer(
            $db: $db,
            $table: $db.savingTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MoneyStorageTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MoneyStorageTableTable> {
  $$MoneyStorageTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconUrl => $composableBuilder(
    column: $table.iconUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get longName => $composableBuilder(
    column: $table.longName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserTableTableOrderingComposer get userId {
    final $$UserTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTableTableOrderingComposer(
            $db: $db,
            $table: $db.userTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoneyStorageTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoneyStorageTableTable> {
  $$MoneyStorageTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconUrl =>
      $composableBuilder(column: $table.iconUrl, builder: (column) => column);

  GeneratedColumn<String> get longName =>
      $composableBuilder(column: $table.longName, builder: (column) => column);

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  $$UserTableTableAnnotationComposer get userId {
    final $$UserTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTableTableAnnotationComposer(
            $db: $db,
            $table: $db.userTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> savingTableRefs<T extends Object>(
    Expression<T> Function($$SavingTableTableAnnotationComposer a) f,
  ) {
    final $$SavingTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savingTable,
      getReferencedColumn: (t) => t.moneyStorageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingTableTableAnnotationComposer(
            $db: $db,
            $table: $db.savingTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MoneyStorageTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoneyStorageTableTable,
          SvngMoneyStorage,
          $$MoneyStorageTableTableFilterComposer,
          $$MoneyStorageTableTableOrderingComposer,
          $$MoneyStorageTableTableAnnotationComposer,
          $$MoneyStorageTableTableCreateCompanionBuilder,
          $$MoneyStorageTableTableUpdateCompanionBuilder,
          (SvngMoneyStorage, $$MoneyStorageTableTableReferences),
          SvngMoneyStorage,
          PrefetchHooks Function({bool userId, bool savingTableRefs})
        > {
  $$MoneyStorageTableTableTableManager(
    _$AppDatabase db,
    $MoneyStorageTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoneyStorageTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoneyStorageTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoneyStorageTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<DateTime> dateUpdated = const Value.absent(),
                Value<String> lastModifiedBy = const Value.absent(),
                Value<String> iconUrl = const Value.absent(),
                Value<String> longName = const Value.absent(),
                Value<String> shortName = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoneyStorageTableCompanion(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                iconUrl: iconUrl,
                longName: longName,
                shortName: shortName,
                type: type,
                userId: userId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String createdBy,
                Value<DateTime> dateCreated = const Value.absent(),
                required DateTime dateUpdated,
                required String lastModifiedBy,
                Value<String> iconUrl = const Value.absent(),
                required String longName,
                required String shortName,
                required String type,
                Value<String?> userId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoneyStorageTableCompanion.insert(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                iconUrl: iconUrl,
                longName: longName,
                shortName: shortName,
                type: type,
                userId: userId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MoneyStorageTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false, savingTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (savingTableRefs) db.savingTable],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$MoneyStorageTableTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$MoneyStorageTableTableReferences
                                        ._userIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (savingTableRefs)
                    await $_getPrefetchedData<
                      SvngMoneyStorage,
                      $MoneyStorageTableTable,
                      SvngSaving
                    >(
                      currentTable: table,
                      referencedTable: $$MoneyStorageTableTableReferences
                          ._savingTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MoneyStorageTableTableReferences(
                            db,
                            table,
                            p0,
                          ).savingTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.moneyStorageId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MoneyStorageTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoneyStorageTableTable,
      SvngMoneyStorage,
      $$MoneyStorageTableTableFilterComposer,
      $$MoneyStorageTableTableOrderingComposer,
      $$MoneyStorageTableTableAnnotationComposer,
      $$MoneyStorageTableTableCreateCompanionBuilder,
      $$MoneyStorageTableTableUpdateCompanionBuilder,
      (SvngMoneyStorage, $$MoneyStorageTableTableReferences),
      SvngMoneyStorage,
      PrefetchHooks Function({bool userId, bool savingTableRefs})
    >;
typedef $$SavingTableTableCreateCompanionBuilder =
    SavingTableCompanion Function({
      Value<String> id,
      required String createdBy,
      Value<DateTime> dateCreated,
      required DateTime dateUpdated,
      required String lastModifiedBy,
      Value<String?> name,
      Value<bool> isPublic,
      Value<bool> isHasGoal,
      Value<double> goal,
      Value<bool> isHasStartDate,
      Value<DateTime?> startDate,
      Value<bool> isHasEndDate,
      Value<DateTime?> endDate,
      Value<bool> isSaveDaily,
      Value<bool> isSaveWeekly,
      Value<bool> isSaveMonthly,
      required String type,
      Value<double> currentAmount,
      Value<String?> userId,
      Value<String?> moneyStorageId,
      Value<int> rowid,
    });
typedef $$SavingTableTableUpdateCompanionBuilder =
    SavingTableCompanion Function({
      Value<String> id,
      Value<String> createdBy,
      Value<DateTime> dateCreated,
      Value<DateTime> dateUpdated,
      Value<String> lastModifiedBy,
      Value<String?> name,
      Value<bool> isPublic,
      Value<bool> isHasGoal,
      Value<double> goal,
      Value<bool> isHasStartDate,
      Value<DateTime?> startDate,
      Value<bool> isHasEndDate,
      Value<DateTime?> endDate,
      Value<bool> isSaveDaily,
      Value<bool> isSaveWeekly,
      Value<bool> isSaveMonthly,
      Value<String> type,
      Value<double> currentAmount,
      Value<String?> userId,
      Value<String?> moneyStorageId,
      Value<int> rowid,
    });

final class $$SavingTableTableReferences
    extends BaseReferences<_$AppDatabase, $SavingTableTable, SvngSaving> {
  $$SavingTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserTableTable _userIdTable(_$AppDatabase db) =>
      db.userTable.createAlias(
        $_aliasNameGenerator(db.savingTable.userId, db.userTable.id),
      );

  $$UserTableTableProcessedTableManager? get userId {
    final $_column = $_itemColumn<String>('user_id');
    if ($_column == null) return null;
    final manager = $$UserTableTableTableManager(
      $_db,
      $_db.userTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MoneyStorageTableTable _moneyStorageIdTable(_$AppDatabase db) =>
      db.moneyStorageTable.createAlias(
        $_aliasNameGenerator(
          db.savingTable.moneyStorageId,
          db.moneyStorageTable.id,
        ),
      );

  $$MoneyStorageTableTableProcessedTableManager? get moneyStorageId {
    final $_column = $_itemColumn<String>('money_storage_id');
    if ($_column == null) return null;
    final manager = $$MoneyStorageTableTableTableManager(
      $_db,
      $_db.moneyStorageTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_moneyStorageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CommitmentTableTable, List<ExpnsCommitment>>
  _commitmentTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.commitmentTable,
    aliasName: $_aliasNameGenerator(
      db.savingTable.id,
      db.commitmentTable.referredSavingId,
    ),
  );

  $$CommitmentTableTableProcessedTableManager get commitmentTableRefs {
    final manager =
        $$CommitmentTableTableTableManager($_db, $_db.commitmentTable).filter(
          (f) => f.referredSavingId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _commitmentTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CommitmentDetailTableTable,
    List<ExpnsCommitmentDetail>
  >
  _commitmentDetailTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.commitmentDetailTable,
        aliasName: $_aliasNameGenerator(
          db.savingTable.id,
          db.commitmentDetailTable.savingId,
        ),
      );

  $$CommitmentDetailTableTableProcessedTableManager
  get commitmentDetailTableRefs {
    final manager = $$CommitmentDetailTableTableTableManager(
      $_db,
      $_db.commitmentDetailTable,
    ).filter((f) => f.savingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _commitmentDetailTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CommitmentTaskTableTable,
    List<ExpnsCommitmentTask>
  >
  _commitmentTaskTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.commitmentTaskTable,
        aliasName: $_aliasNameGenerator(
          db.savingTable.id,
          db.commitmentTaskTable.referredSavingId,
        ),
      );

  $$CommitmentTaskTableTableProcessedTableManager get commitmentTaskTableRefs {
    final manager =
        $$CommitmentTaskTableTableTableManager(
          $_db,
          $_db.commitmentTaskTable,
        ).filter(
          (f) => f.referredSavingId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _commitmentTaskTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionTableTable, List<TrnsctnTransaction>>
  _transactionTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactionTable,
    aliasName: $_aliasNameGenerator(
      db.savingTable.id,
      db.transactionTable.savingId,
    ),
  );

  $$TransactionTableTableProcessedTableManager get transactionTableRefs {
    final manager = $$TransactionTableTableTableManager(
      $_db,
      $_db.transactionTable,
    ).filter((f) => f.savingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SavingTableTableFilterComposer
    extends Composer<_$AppDatabase, $SavingTableTable> {
  $$SavingTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHasGoal => $composableBuilder(
    column: $table.isHasGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHasStartDate => $composableBuilder(
    column: $table.isHasStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHasEndDate => $composableBuilder(
    column: $table.isHasEndDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSaveDaily => $composableBuilder(
    column: $table.isSaveDaily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSaveWeekly => $composableBuilder(
    column: $table.isSaveWeekly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSaveMonthly => $composableBuilder(
    column: $table.isSaveMonthly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentAmount => $composableBuilder(
    column: $table.currentAmount,
    builder: (column) => ColumnFilters(column),
  );

  $$UserTableTableFilterComposer get userId {
    final $$UserTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTableTableFilterComposer(
            $db: $db,
            $table: $db.userTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MoneyStorageTableTableFilterComposer get moneyStorageId {
    final $$MoneyStorageTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moneyStorageId,
      referencedTable: $db.moneyStorageTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyStorageTableTableFilterComposer(
            $db: $db,
            $table: $db.moneyStorageTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> commitmentTableRefs(
    Expression<bool> Function($$CommitmentTableTableFilterComposer f) f,
  ) {
    final $$CommitmentTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commitmentTable,
      getReferencedColumn: (t) => t.referredSavingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentTableTableFilterComposer(
            $db: $db,
            $table: $db.commitmentTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> commitmentDetailTableRefs(
    Expression<bool> Function($$CommitmentDetailTableTableFilterComposer f) f,
  ) {
    final $$CommitmentDetailTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.commitmentDetailTable,
          getReferencedColumn: (t) => t.savingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CommitmentDetailTableTableFilterComposer(
                $db: $db,
                $table: $db.commitmentDetailTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> commitmentTaskTableRefs(
    Expression<bool> Function($$CommitmentTaskTableTableFilterComposer f) f,
  ) {
    final $$CommitmentTaskTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commitmentTaskTable,
      getReferencedColumn: (t) => t.referredSavingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentTaskTableTableFilterComposer(
            $db: $db,
            $table: $db.commitmentTaskTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionTableRefs(
    Expression<bool> Function($$TransactionTableTableFilterComposer f) f,
  ) {
    final $$TransactionTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionTable,
      getReferencedColumn: (t) => t.savingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionTableTableFilterComposer(
            $db: $db,
            $table: $db.transactionTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SavingTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingTableTable> {
  $$SavingTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHasGoal => $composableBuilder(
    column: $table.isHasGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHasStartDate => $composableBuilder(
    column: $table.isHasStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHasEndDate => $composableBuilder(
    column: $table.isHasEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSaveDaily => $composableBuilder(
    column: $table.isSaveDaily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSaveWeekly => $composableBuilder(
    column: $table.isSaveWeekly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSaveMonthly => $composableBuilder(
    column: $table.isSaveMonthly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentAmount => $composableBuilder(
    column: $table.currentAmount,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserTableTableOrderingComposer get userId {
    final $$UserTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTableTableOrderingComposer(
            $db: $db,
            $table: $db.userTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MoneyStorageTableTableOrderingComposer get moneyStorageId {
    final $$MoneyStorageTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moneyStorageId,
      referencedTable: $db.moneyStorageTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoneyStorageTableTableOrderingComposer(
            $db: $db,
            $table: $db.moneyStorageTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavingTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingTableTable> {
  $$SavingTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isPublic =>
      $composableBuilder(column: $table.isPublic, builder: (column) => column);

  GeneratedColumn<bool> get isHasGoal =>
      $composableBuilder(column: $table.isHasGoal, builder: (column) => column);

  GeneratedColumn<double> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<bool> get isHasStartDate => $composableBuilder(
    column: $table.isHasStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<bool> get isHasEndDate => $composableBuilder(
    column: $table.isHasEndDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isSaveDaily => $composableBuilder(
    column: $table.isSaveDaily,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSaveWeekly => $composableBuilder(
    column: $table.isSaveWeekly,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSaveMonthly => $composableBuilder(
    column: $table.isSaveMonthly,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get currentAmount => $composableBuilder(
    column: $table.currentAmount,
    builder: (column) => column,
  );

  $$UserTableTableAnnotationComposer get userId {
    final $$UserTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTableTableAnnotationComposer(
            $db: $db,
            $table: $db.userTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MoneyStorageTableTableAnnotationComposer get moneyStorageId {
    final $$MoneyStorageTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.moneyStorageId,
          referencedTable: $db.moneyStorageTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MoneyStorageTableTableAnnotationComposer(
                $db: $db,
                $table: $db.moneyStorageTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> commitmentTableRefs<T extends Object>(
    Expression<T> Function($$CommitmentTableTableAnnotationComposer a) f,
  ) {
    final $$CommitmentTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commitmentTable,
      getReferencedColumn: (t) => t.referredSavingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentTableTableAnnotationComposer(
            $db: $db,
            $table: $db.commitmentTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> commitmentDetailTableRefs<T extends Object>(
    Expression<T> Function($$CommitmentDetailTableTableAnnotationComposer a) f,
  ) {
    final $$CommitmentDetailTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.commitmentDetailTable,
          getReferencedColumn: (t) => t.savingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CommitmentDetailTableTableAnnotationComposer(
                $db: $db,
                $table: $db.commitmentDetailTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> commitmentTaskTableRefs<T extends Object>(
    Expression<T> Function($$CommitmentTaskTableTableAnnotationComposer a) f,
  ) {
    final $$CommitmentTaskTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.commitmentTaskTable,
          getReferencedColumn: (t) => t.referredSavingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CommitmentTaskTableTableAnnotationComposer(
                $db: $db,
                $table: $db.commitmentTaskTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> transactionTableRefs<T extends Object>(
    Expression<T> Function($$TransactionTableTableAnnotationComposer a) f,
  ) {
    final $$TransactionTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionTable,
      getReferencedColumn: (t) => t.savingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionTableTableAnnotationComposer(
            $db: $db,
            $table: $db.transactionTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SavingTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingTableTable,
          SvngSaving,
          $$SavingTableTableFilterComposer,
          $$SavingTableTableOrderingComposer,
          $$SavingTableTableAnnotationComposer,
          $$SavingTableTableCreateCompanionBuilder,
          $$SavingTableTableUpdateCompanionBuilder,
          (SvngSaving, $$SavingTableTableReferences),
          SvngSaving,
          PrefetchHooks Function({
            bool userId,
            bool moneyStorageId,
            bool commitmentTableRefs,
            bool commitmentDetailTableRefs,
            bool commitmentTaskTableRefs,
            bool transactionTableRefs,
          })
        > {
  $$SavingTableTableTableManager(_$AppDatabase db, $SavingTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<DateTime> dateUpdated = const Value.absent(),
                Value<String> lastModifiedBy = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                Value<bool> isHasGoal = const Value.absent(),
                Value<double> goal = const Value.absent(),
                Value<bool> isHasStartDate = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<bool> isHasEndDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isSaveDaily = const Value.absent(),
                Value<bool> isSaveWeekly = const Value.absent(),
                Value<bool> isSaveMonthly = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> currentAmount = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> moneyStorageId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingTableCompanion(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                name: name,
                isPublic: isPublic,
                isHasGoal: isHasGoal,
                goal: goal,
                isHasStartDate: isHasStartDate,
                startDate: startDate,
                isHasEndDate: isHasEndDate,
                endDate: endDate,
                isSaveDaily: isSaveDaily,
                isSaveWeekly: isSaveWeekly,
                isSaveMonthly: isSaveMonthly,
                type: type,
                currentAmount: currentAmount,
                userId: userId,
                moneyStorageId: moneyStorageId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String createdBy,
                Value<DateTime> dateCreated = const Value.absent(),
                required DateTime dateUpdated,
                required String lastModifiedBy,
                Value<String?> name = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                Value<bool> isHasGoal = const Value.absent(),
                Value<double> goal = const Value.absent(),
                Value<bool> isHasStartDate = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<bool> isHasEndDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isSaveDaily = const Value.absent(),
                Value<bool> isSaveWeekly = const Value.absent(),
                Value<bool> isSaveMonthly = const Value.absent(),
                required String type,
                Value<double> currentAmount = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> moneyStorageId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingTableCompanion.insert(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                name: name,
                isPublic: isPublic,
                isHasGoal: isHasGoal,
                goal: goal,
                isHasStartDate: isHasStartDate,
                startDate: startDate,
                isHasEndDate: isHasEndDate,
                endDate: endDate,
                isSaveDaily: isSaveDaily,
                isSaveWeekly: isSaveWeekly,
                isSaveMonthly: isSaveMonthly,
                type: type,
                currentAmount: currentAmount,
                userId: userId,
                moneyStorageId: moneyStorageId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavingTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                userId = false,
                moneyStorageId = false,
                commitmentTableRefs = false,
                commitmentDetailTableRefs = false,
                commitmentTaskTableRefs = false,
                transactionTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (commitmentTableRefs) db.commitmentTable,
                    if (commitmentDetailTableRefs) db.commitmentDetailTable,
                    if (commitmentTaskTableRefs) db.commitmentTaskTable,
                    if (transactionTableRefs) db.transactionTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (userId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.userId,
                                    referencedTable:
                                        $$SavingTableTableReferences
                                            ._userIdTable(db),
                                    referencedColumn:
                                        $$SavingTableTableReferences
                                            ._userIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (moneyStorageId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.moneyStorageId,
                                    referencedTable:
                                        $$SavingTableTableReferences
                                            ._moneyStorageIdTable(db),
                                    referencedColumn:
                                        $$SavingTableTableReferences
                                            ._moneyStorageIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (commitmentTableRefs)
                        await $_getPrefetchedData<
                          SvngSaving,
                          $SavingTableTable,
                          ExpnsCommitment
                        >(
                          currentTable: table,
                          referencedTable: $$SavingTableTableReferences
                              ._commitmentTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SavingTableTableReferences(
                                db,
                                table,
                                p0,
                              ).commitmentTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.referredSavingId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (commitmentDetailTableRefs)
                        await $_getPrefetchedData<
                          SvngSaving,
                          $SavingTableTable,
                          ExpnsCommitmentDetail
                        >(
                          currentTable: table,
                          referencedTable: $$SavingTableTableReferences
                              ._commitmentDetailTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SavingTableTableReferences(
                                db,
                                table,
                                p0,
                              ).commitmentDetailTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.savingId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (commitmentTaskTableRefs)
                        await $_getPrefetchedData<
                          SvngSaving,
                          $SavingTableTable,
                          ExpnsCommitmentTask
                        >(
                          currentTable: table,
                          referencedTable: $$SavingTableTableReferences
                              ._commitmentTaskTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SavingTableTableReferences(
                                db,
                                table,
                                p0,
                              ).commitmentTaskTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.referredSavingId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionTableRefs)
                        await $_getPrefetchedData<
                          SvngSaving,
                          $SavingTableTable,
                          TrnsctnTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$SavingTableTableReferences
                              ._transactionTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SavingTableTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.savingId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SavingTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingTableTable,
      SvngSaving,
      $$SavingTableTableFilterComposer,
      $$SavingTableTableOrderingComposer,
      $$SavingTableTableAnnotationComposer,
      $$SavingTableTableCreateCompanionBuilder,
      $$SavingTableTableUpdateCompanionBuilder,
      (SvngSaving, $$SavingTableTableReferences),
      SvngSaving,
      PrefetchHooks Function({
        bool userId,
        bool moneyStorageId,
        bool commitmentTableRefs,
        bool commitmentDetailTableRefs,
        bool commitmentTaskTableRefs,
        bool transactionTableRefs,
      })
    >;
typedef $$ExpenseTableTableCreateCompanionBuilder =
    ExpenseTableCompanion Function({
      Value<String> id,
      required String createdBy,
      Value<DateTime> dateCreated,
      required DateTime dateUpdated,
      required String lastModifiedBy,
      required double amount,
      Value<String?> description,
      required DateTime expenseDate,
      required String referenceDataId,
      Value<int> rowid,
    });
typedef $$ExpenseTableTableUpdateCompanionBuilder =
    ExpenseTableCompanion Function({
      Value<String> id,
      Value<String> createdBy,
      Value<DateTime> dateCreated,
      Value<DateTime> dateUpdated,
      Value<String> lastModifiedBy,
      Value<double> amount,
      Value<String?> description,
      Value<DateTime> expenseDate,
      Value<String> referenceDataId,
      Value<int> rowid,
    });

final class $$ExpenseTableTableReferences
    extends BaseReferences<_$AppDatabase, $ExpenseTableTable, ExpnsExpense> {
  $$ExpenseTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ReferenceDataTableTable _referenceDataIdTable(_$AppDatabase db) =>
      db.referenceDataTable.createAlias(
        $_aliasNameGenerator(
          db.expenseTable.referenceDataId,
          db.referenceDataTable.id,
        ),
      );

  $$ReferenceDataTableTableProcessedTableManager get referenceDataId {
    final $_column = $_itemColumn<String>('reference_data_id')!;

    final manager = $$ReferenceDataTableTableTableManager(
      $_db,
      $_db.referenceDataTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_referenceDataIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionTableTable, List<TrnsctnTransaction>>
  _transactionTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactionTable,
    aliasName: $_aliasNameGenerator(
      db.expenseTable.id,
      db.transactionTable.expenseId,
    ),
  );

  $$TransactionTableTableProcessedTableManager get transactionTableRefs {
    final manager = $$TransactionTableTableTableManager(
      $_db,
      $_db.transactionTable,
    ).filter((f) => f.expenseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExpenseTableTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseTableTable> {
  $$ExpenseTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => ColumnFilters(column),
  );

  $$ReferenceDataTableTableFilterComposer get referenceDataId {
    final $$ReferenceDataTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.referenceDataId,
      referencedTable: $db.referenceDataTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceDataTableTableFilterComposer(
            $db: $db,
            $table: $db.referenceDataTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionTableRefs(
    Expression<bool> Function($$TransactionTableTableFilterComposer f) f,
  ) {
    final $$TransactionTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionTable,
      getReferencedColumn: (t) => t.expenseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionTableTableFilterComposer(
            $db: $db,
            $table: $db.transactionTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpenseTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseTableTable> {
  $$ExpenseTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReferenceDataTableTableOrderingComposer get referenceDataId {
    final $$ReferenceDataTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.referenceDataId,
      referencedTable: $db.referenceDataTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenceDataTableTableOrderingComposer(
            $db: $db,
            $table: $db.referenceDataTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpenseTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseTableTable> {
  $$ExpenseTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => column,
  );

  $$ReferenceDataTableTableAnnotationComposer get referenceDataId {
    final $$ReferenceDataTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.referenceDataId,
          referencedTable: $db.referenceDataTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReferenceDataTableTableAnnotationComposer(
                $db: $db,
                $table: $db.referenceDataTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> transactionTableRefs<T extends Object>(
    Expression<T> Function($$TransactionTableTableAnnotationComposer a) f,
  ) {
    final $$TransactionTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionTable,
      getReferencedColumn: (t) => t.expenseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionTableTableAnnotationComposer(
            $db: $db,
            $table: $db.transactionTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpenseTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseTableTable,
          ExpnsExpense,
          $$ExpenseTableTableFilterComposer,
          $$ExpenseTableTableOrderingComposer,
          $$ExpenseTableTableAnnotationComposer,
          $$ExpenseTableTableCreateCompanionBuilder,
          $$ExpenseTableTableUpdateCompanionBuilder,
          (ExpnsExpense, $$ExpenseTableTableReferences),
          ExpnsExpense,
          PrefetchHooks Function({
            bool referenceDataId,
            bool transactionTableRefs,
          })
        > {
  $$ExpenseTableTableTableManager(_$AppDatabase db, $ExpenseTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<DateTime> dateUpdated = const Value.absent(),
                Value<String> lastModifiedBy = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> expenseDate = const Value.absent(),
                Value<String> referenceDataId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseTableCompanion(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                amount: amount,
                description: description,
                expenseDate: expenseDate,
                referenceDataId: referenceDataId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String createdBy,
                Value<DateTime> dateCreated = const Value.absent(),
                required DateTime dateUpdated,
                required String lastModifiedBy,
                required double amount,
                Value<String?> description = const Value.absent(),
                required DateTime expenseDate,
                required String referenceDataId,
                Value<int> rowid = const Value.absent(),
              }) => ExpenseTableCompanion.insert(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                amount: amount,
                description: description,
                expenseDate: expenseDate,
                referenceDataId: referenceDataId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpenseTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({referenceDataId = false, transactionTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionTableRefs) db.transactionTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (referenceDataId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.referenceDataId,
                                    referencedTable:
                                        $$ExpenseTableTableReferences
                                            ._referenceDataIdTable(db),
                                    referencedColumn:
                                        $$ExpenseTableTableReferences
                                            ._referenceDataIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionTableRefs)
                        await $_getPrefetchedData<
                          ExpnsExpense,
                          $ExpenseTableTable,
                          TrnsctnTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$ExpenseTableTableReferences
                              ._transactionTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExpenseTableTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.expenseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExpenseTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpenseTableTable,
      ExpnsExpense,
      $$ExpenseTableTableFilterComposer,
      $$ExpenseTableTableOrderingComposer,
      $$ExpenseTableTableAnnotationComposer,
      $$ExpenseTableTableCreateCompanionBuilder,
      $$ExpenseTableTableUpdateCompanionBuilder,
      (ExpnsExpense, $$ExpenseTableTableReferences),
      ExpnsExpense,
      PrefetchHooks Function({bool referenceDataId, bool transactionTableRefs})
    >;
typedef $$CommitmentTableTableCreateCompanionBuilder =
    CommitmentTableCompanion Function({
      Value<String> id,
      required String createdBy,
      Value<DateTime> dateCreated,
      required DateTime dateUpdated,
      required String lastModifiedBy,
      required String name,
      Value<String?> description,
      required String referredSavingId,
      required String userId,
      Value<int> rowid,
    });
typedef $$CommitmentTableTableUpdateCompanionBuilder =
    CommitmentTableCompanion Function({
      Value<String> id,
      Value<String> createdBy,
      Value<DateTime> dateCreated,
      Value<DateTime> dateUpdated,
      Value<String> lastModifiedBy,
      Value<String> name,
      Value<String?> description,
      Value<String> referredSavingId,
      Value<String> userId,
      Value<int> rowid,
    });

final class $$CommitmentTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $CommitmentTableTable, ExpnsCommitment> {
  $$CommitmentTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SavingTableTable _referredSavingIdTable(_$AppDatabase db) =>
      db.savingTable.createAlias(
        $_aliasNameGenerator(
          db.commitmentTable.referredSavingId,
          db.savingTable.id,
        ),
      );

  $$SavingTableTableProcessedTableManager get referredSavingId {
    final $_column = $_itemColumn<String>('referred_saving_id')!;

    final manager = $$SavingTableTableTableManager(
      $_db,
      $_db.savingTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_referredSavingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UserTableTable _userIdTable(_$AppDatabase db) =>
      db.userTable.createAlias(
        $_aliasNameGenerator(db.commitmentTable.userId, db.userTable.id),
      );

  $$UserTableTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UserTableTableTableManager(
      $_db,
      $_db.userTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $CommitmentDetailTableTable,
    List<ExpnsCommitmentDetail>
  >
  _commitmentDetailTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.commitmentDetailTable,
        aliasName: $_aliasNameGenerator(
          db.commitmentTable.id,
          db.commitmentDetailTable.commitmentId,
        ),
      );

  $$CommitmentDetailTableTableProcessedTableManager
  get commitmentDetailTableRefs {
    final manager = $$CommitmentDetailTableTableTableManager(
      $_db,
      $_db.commitmentDetailTable,
    ).filter((f) => f.commitmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _commitmentDetailTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CommitmentTableTableFilterComposer
    extends Composer<_$AppDatabase, $CommitmentTableTable> {
  $$CommitmentTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  $$SavingTableTableFilterComposer get referredSavingId {
    final $$SavingTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.referredSavingId,
      referencedTable: $db.savingTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingTableTableFilterComposer(
            $db: $db,
            $table: $db.savingTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UserTableTableFilterComposer get userId {
    final $$UserTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTableTableFilterComposer(
            $db: $db,
            $table: $db.userTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> commitmentDetailTableRefs(
    Expression<bool> Function($$CommitmentDetailTableTableFilterComposer f) f,
  ) {
    final $$CommitmentDetailTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.commitmentDetailTable,
          getReferencedColumn: (t) => t.commitmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CommitmentDetailTableTableFilterComposer(
                $db: $db,
                $table: $db.commitmentDetailTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CommitmentTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CommitmentTableTable> {
  $$CommitmentTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  $$SavingTableTableOrderingComposer get referredSavingId {
    final $$SavingTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.referredSavingId,
      referencedTable: $db.savingTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingTableTableOrderingComposer(
            $db: $db,
            $table: $db.savingTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UserTableTableOrderingComposer get userId {
    final $$UserTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTableTableOrderingComposer(
            $db: $db,
            $table: $db.userTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommitmentTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommitmentTableTable> {
  $$CommitmentTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  $$SavingTableTableAnnotationComposer get referredSavingId {
    final $$SavingTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.referredSavingId,
      referencedTable: $db.savingTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingTableTableAnnotationComposer(
            $db: $db,
            $table: $db.savingTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UserTableTableAnnotationComposer get userId {
    final $$UserTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserTableTableAnnotationComposer(
            $db: $db,
            $table: $db.userTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> commitmentDetailTableRefs<T extends Object>(
    Expression<T> Function($$CommitmentDetailTableTableAnnotationComposer a) f,
  ) {
    final $$CommitmentDetailTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.commitmentDetailTable,
          getReferencedColumn: (t) => t.commitmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CommitmentDetailTableTableAnnotationComposer(
                $db: $db,
                $table: $db.commitmentDetailTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CommitmentTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommitmentTableTable,
          ExpnsCommitment,
          $$CommitmentTableTableFilterComposer,
          $$CommitmentTableTableOrderingComposer,
          $$CommitmentTableTableAnnotationComposer,
          $$CommitmentTableTableCreateCompanionBuilder,
          $$CommitmentTableTableUpdateCompanionBuilder,
          (ExpnsCommitment, $$CommitmentTableTableReferences),
          ExpnsCommitment,
          PrefetchHooks Function({
            bool referredSavingId,
            bool userId,
            bool commitmentDetailTableRefs,
          })
        > {
  $$CommitmentTableTableTableManager(
    _$AppDatabase db,
    $CommitmentTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommitmentTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommitmentTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommitmentTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<DateTime> dateUpdated = const Value.absent(),
                Value<String> lastModifiedBy = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> referredSavingId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommitmentTableCompanion(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                name: name,
                description: description,
                referredSavingId: referredSavingId,
                userId: userId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String createdBy,
                Value<DateTime> dateCreated = const Value.absent(),
                required DateTime dateUpdated,
                required String lastModifiedBy,
                required String name,
                Value<String?> description = const Value.absent(),
                required String referredSavingId,
                required String userId,
                Value<int> rowid = const Value.absent(),
              }) => CommitmentTableCompanion.insert(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                name: name,
                description: description,
                referredSavingId: referredSavingId,
                userId: userId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CommitmentTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                referredSavingId = false,
                userId = false,
                commitmentDetailTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (commitmentDetailTableRefs) db.commitmentDetailTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (referredSavingId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.referredSavingId,
                                    referencedTable:
                                        $$CommitmentTableTableReferences
                                            ._referredSavingIdTable(db),
                                    referencedColumn:
                                        $$CommitmentTableTableReferences
                                            ._referredSavingIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (userId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.userId,
                                    referencedTable:
                                        $$CommitmentTableTableReferences
                                            ._userIdTable(db),
                                    referencedColumn:
                                        $$CommitmentTableTableReferences
                                            ._userIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (commitmentDetailTableRefs)
                        await $_getPrefetchedData<
                          ExpnsCommitment,
                          $CommitmentTableTable,
                          ExpnsCommitmentDetail
                        >(
                          currentTable: table,
                          referencedTable: $$CommitmentTableTableReferences
                              ._commitmentDetailTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CommitmentTableTableReferences(
                                db,
                                table,
                                p0,
                              ).commitmentDetailTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.commitmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CommitmentTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommitmentTableTable,
      ExpnsCommitment,
      $$CommitmentTableTableFilterComposer,
      $$CommitmentTableTableOrderingComposer,
      $$CommitmentTableTableAnnotationComposer,
      $$CommitmentTableTableCreateCompanionBuilder,
      $$CommitmentTableTableUpdateCompanionBuilder,
      (ExpnsCommitment, $$CommitmentTableTableReferences),
      ExpnsCommitment,
      PrefetchHooks Function({
        bool referredSavingId,
        bool userId,
        bool commitmentDetailTableRefs,
      })
    >;
typedef $$CommitmentDetailTableTableCreateCompanionBuilder =
    CommitmentDetailTableCompanion Function({
      Value<String> id,
      required String createdBy,
      Value<DateTime> dateCreated,
      required DateTime dateUpdated,
      required String lastModifiedBy,
      required double amount,
      required String description,
      required String type,
      required String savingId,
      required String commitmentId,
      Value<int> rowid,
    });
typedef $$CommitmentDetailTableTableUpdateCompanionBuilder =
    CommitmentDetailTableCompanion Function({
      Value<String> id,
      Value<String> createdBy,
      Value<DateTime> dateCreated,
      Value<DateTime> dateUpdated,
      Value<String> lastModifiedBy,
      Value<double> amount,
      Value<String> description,
      Value<String> type,
      Value<String> savingId,
      Value<String> commitmentId,
      Value<int> rowid,
    });

final class $$CommitmentDetailTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CommitmentDetailTableTable,
          ExpnsCommitmentDetail
        > {
  $$CommitmentDetailTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SavingTableTable _savingIdTable(_$AppDatabase db) =>
      db.savingTable.createAlias(
        $_aliasNameGenerator(
          db.commitmentDetailTable.savingId,
          db.savingTable.id,
        ),
      );

  $$SavingTableTableProcessedTableManager get savingId {
    final $_column = $_itemColumn<String>('saving_id')!;

    final manager = $$SavingTableTableTableManager(
      $_db,
      $_db.savingTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_savingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CommitmentTableTable _commitmentIdTable(_$AppDatabase db) =>
      db.commitmentTable.createAlias(
        $_aliasNameGenerator(
          db.commitmentDetailTable.commitmentId,
          db.commitmentTable.id,
        ),
      );

  $$CommitmentTableTableProcessedTableManager get commitmentId {
    final $_column = $_itemColumn<String>('commitment_id')!;

    final manager = $$CommitmentTableTableTableManager(
      $_db,
      $_db.commitmentTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_commitmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CommitmentDetailTableTableFilterComposer
    extends Composer<_$AppDatabase, $CommitmentDetailTableTable> {
  $$CommitmentDetailTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  $$SavingTableTableFilterComposer get savingId {
    final $$SavingTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savingId,
      referencedTable: $db.savingTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingTableTableFilterComposer(
            $db: $db,
            $table: $db.savingTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CommitmentTableTableFilterComposer get commitmentId {
    final $$CommitmentTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commitmentId,
      referencedTable: $db.commitmentTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentTableTableFilterComposer(
            $db: $db,
            $table: $db.commitmentTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommitmentDetailTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CommitmentDetailTableTable> {
  $$CommitmentDetailTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  $$SavingTableTableOrderingComposer get savingId {
    final $$SavingTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savingId,
      referencedTable: $db.savingTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingTableTableOrderingComposer(
            $db: $db,
            $table: $db.savingTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CommitmentTableTableOrderingComposer get commitmentId {
    final $$CommitmentTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commitmentId,
      referencedTable: $db.commitmentTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentTableTableOrderingComposer(
            $db: $db,
            $table: $db.commitmentTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommitmentDetailTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommitmentDetailTableTable> {
  $$CommitmentDetailTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  $$SavingTableTableAnnotationComposer get savingId {
    final $$SavingTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savingId,
      referencedTable: $db.savingTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingTableTableAnnotationComposer(
            $db: $db,
            $table: $db.savingTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CommitmentTableTableAnnotationComposer get commitmentId {
    final $$CommitmentTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commitmentId,
      referencedTable: $db.commitmentTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentTableTableAnnotationComposer(
            $db: $db,
            $table: $db.commitmentTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommitmentDetailTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommitmentDetailTableTable,
          ExpnsCommitmentDetail,
          $$CommitmentDetailTableTableFilterComposer,
          $$CommitmentDetailTableTableOrderingComposer,
          $$CommitmentDetailTableTableAnnotationComposer,
          $$CommitmentDetailTableTableCreateCompanionBuilder,
          $$CommitmentDetailTableTableUpdateCompanionBuilder,
          (ExpnsCommitmentDetail, $$CommitmentDetailTableTableReferences),
          ExpnsCommitmentDetail,
          PrefetchHooks Function({bool savingId, bool commitmentId})
        > {
  $$CommitmentDetailTableTableTableManager(
    _$AppDatabase db,
    $CommitmentDetailTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommitmentDetailTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CommitmentDetailTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CommitmentDetailTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<DateTime> dateUpdated = const Value.absent(),
                Value<String> lastModifiedBy = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> savingId = const Value.absent(),
                Value<String> commitmentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommitmentDetailTableCompanion(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                amount: amount,
                description: description,
                type: type,
                savingId: savingId,
                commitmentId: commitmentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String createdBy,
                Value<DateTime> dateCreated = const Value.absent(),
                required DateTime dateUpdated,
                required String lastModifiedBy,
                required double amount,
                required String description,
                required String type,
                required String savingId,
                required String commitmentId,
                Value<int> rowid = const Value.absent(),
              }) => CommitmentDetailTableCompanion.insert(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                amount: amount,
                description: description,
                type: type,
                savingId: savingId,
                commitmentId: commitmentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CommitmentDetailTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({savingId = false, commitmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (savingId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.savingId,
                                referencedTable:
                                    $$CommitmentDetailTableTableReferences
                                        ._savingIdTable(db),
                                referencedColumn:
                                    $$CommitmentDetailTableTableReferences
                                        ._savingIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (commitmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.commitmentId,
                                referencedTable:
                                    $$CommitmentDetailTableTableReferences
                                        ._commitmentIdTable(db),
                                referencedColumn:
                                    $$CommitmentDetailTableTableReferences
                                        ._commitmentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CommitmentDetailTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommitmentDetailTableTable,
      ExpnsCommitmentDetail,
      $$CommitmentDetailTableTableFilterComposer,
      $$CommitmentDetailTableTableOrderingComposer,
      $$CommitmentDetailTableTableAnnotationComposer,
      $$CommitmentDetailTableTableCreateCompanionBuilder,
      $$CommitmentDetailTableTableUpdateCompanionBuilder,
      (ExpnsCommitmentDetail, $$CommitmentDetailTableTableReferences),
      ExpnsCommitmentDetail,
      PrefetchHooks Function({bool savingId, bool commitmentId})
    >;
typedef $$CommitmentTaskTableTableCreateCompanionBuilder =
    CommitmentTaskTableCompanion Function({
      Value<String> id,
      required String createdBy,
      Value<DateTime> dateCreated,
      required DateTime dateUpdated,
      required String lastModifiedBy,
      required String name,
      required double amount,
      Value<bool> isDone,
      required String referredSavingId,
      Value<int> rowid,
    });
typedef $$CommitmentTaskTableTableUpdateCompanionBuilder =
    CommitmentTaskTableCompanion Function({
      Value<String> id,
      Value<String> createdBy,
      Value<DateTime> dateCreated,
      Value<DateTime> dateUpdated,
      Value<String> lastModifiedBy,
      Value<String> name,
      Value<double> amount,
      Value<bool> isDone,
      Value<String> referredSavingId,
      Value<int> rowid,
    });

final class $$CommitmentTaskTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CommitmentTaskTableTable,
          ExpnsCommitmentTask
        > {
  $$CommitmentTaskTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SavingTableTable _referredSavingIdTable(_$AppDatabase db) =>
      db.savingTable.createAlias(
        $_aliasNameGenerator(
          db.commitmentTaskTable.referredSavingId,
          db.savingTable.id,
        ),
      );

  $$SavingTableTableProcessedTableManager get referredSavingId {
    final $_column = $_itemColumn<String>('referred_saving_id')!;

    final manager = $$SavingTableTableTableManager(
      $_db,
      $_db.savingTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_referredSavingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CommitmentTaskTableTableFilterComposer
    extends Composer<_$AppDatabase, $CommitmentTaskTableTable> {
  $$CommitmentTaskTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );

  $$SavingTableTableFilterComposer get referredSavingId {
    final $$SavingTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.referredSavingId,
      referencedTable: $db.savingTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingTableTableFilterComposer(
            $db: $db,
            $table: $db.savingTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommitmentTaskTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CommitmentTaskTableTable> {
  $$CommitmentTaskTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );

  $$SavingTableTableOrderingComposer get referredSavingId {
    final $$SavingTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.referredSavingId,
      referencedTable: $db.savingTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingTableTableOrderingComposer(
            $db: $db,
            $table: $db.savingTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommitmentTaskTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommitmentTaskTableTable> {
  $$CommitmentTaskTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  $$SavingTableTableAnnotationComposer get referredSavingId {
    final $$SavingTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.referredSavingId,
      referencedTable: $db.savingTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingTableTableAnnotationComposer(
            $db: $db,
            $table: $db.savingTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommitmentTaskTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommitmentTaskTableTable,
          ExpnsCommitmentTask,
          $$CommitmentTaskTableTableFilterComposer,
          $$CommitmentTaskTableTableOrderingComposer,
          $$CommitmentTaskTableTableAnnotationComposer,
          $$CommitmentTaskTableTableCreateCompanionBuilder,
          $$CommitmentTaskTableTableUpdateCompanionBuilder,
          (ExpnsCommitmentTask, $$CommitmentTaskTableTableReferences),
          ExpnsCommitmentTask,
          PrefetchHooks Function({bool referredSavingId})
        > {
  $$CommitmentTaskTableTableTableManager(
    _$AppDatabase db,
    $CommitmentTaskTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommitmentTaskTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommitmentTaskTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CommitmentTaskTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<DateTime> dateUpdated = const Value.absent(),
                Value<String> lastModifiedBy = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<String> referredSavingId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommitmentTaskTableCompanion(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                name: name,
                amount: amount,
                isDone: isDone,
                referredSavingId: referredSavingId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String createdBy,
                Value<DateTime> dateCreated = const Value.absent(),
                required DateTime dateUpdated,
                required String lastModifiedBy,
                required String name,
                required double amount,
                Value<bool> isDone = const Value.absent(),
                required String referredSavingId,
                Value<int> rowid = const Value.absent(),
              }) => CommitmentTaskTableCompanion.insert(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                name: name,
                amount: amount,
                isDone: isDone,
                referredSavingId: referredSavingId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CommitmentTaskTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({referredSavingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (referredSavingId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.referredSavingId,
                                referencedTable:
                                    $$CommitmentTaskTableTableReferences
                                        ._referredSavingIdTable(db),
                                referencedColumn:
                                    $$CommitmentTaskTableTableReferences
                                        ._referredSavingIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CommitmentTaskTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommitmentTaskTableTable,
      ExpnsCommitmentTask,
      $$CommitmentTaskTableTableFilterComposer,
      $$CommitmentTaskTableTableOrderingComposer,
      $$CommitmentTaskTableTableAnnotationComposer,
      $$CommitmentTaskTableTableCreateCompanionBuilder,
      $$CommitmentTaskTableTableUpdateCompanionBuilder,
      (ExpnsCommitmentTask, $$CommitmentTaskTableTableReferences),
      ExpnsCommitmentTask,
      PrefetchHooks Function({bool referredSavingId})
    >;
typedef $$TransactionTableTableCreateCompanionBuilder =
    TransactionTableCompanion Function({
      Value<String> id,
      required String createdBy,
      Value<DateTime> dateCreated,
      required DateTime dateUpdated,
      required String lastModifiedBy,
      required String type,
      Value<String> description,
      required double amount,
      required String savingId,
      Value<bool> isExpense,
      Value<String?> expenseId,
      Value<int> rowid,
    });
typedef $$TransactionTableTableUpdateCompanionBuilder =
    TransactionTableCompanion Function({
      Value<String> id,
      Value<String> createdBy,
      Value<DateTime> dateCreated,
      Value<DateTime> dateUpdated,
      Value<String> lastModifiedBy,
      Value<String> type,
      Value<String> description,
      Value<double> amount,
      Value<String> savingId,
      Value<bool> isExpense,
      Value<String?> expenseId,
      Value<int> rowid,
    });

final class $$TransactionTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TransactionTableTable,
          TrnsctnTransaction
        > {
  $$TransactionTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SavingTableTable _savingIdTable(_$AppDatabase db) =>
      db.savingTable.createAlias(
        $_aliasNameGenerator(db.transactionTable.savingId, db.savingTable.id),
      );

  $$SavingTableTableProcessedTableManager get savingId {
    final $_column = $_itemColumn<String>('saving_id')!;

    final manager = $$SavingTableTableTableManager(
      $_db,
      $_db.savingTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_savingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExpenseTableTable _expenseIdTable(_$AppDatabase db) =>
      db.expenseTable.createAlias(
        $_aliasNameGenerator(db.transactionTable.expenseId, db.expenseTable.id),
      );

  $$ExpenseTableTableProcessedTableManager? get expenseId {
    final $_column = $_itemColumn<String>('expense_id');
    if ($_column == null) return null;
    final manager = $$ExpenseTableTableTableManager(
      $_db,
      $_db.expenseTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_expenseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionTableTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionTableTable> {
  $$TransactionTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isExpense => $composableBuilder(
    column: $table.isExpense,
    builder: (column) => ColumnFilters(column),
  );

  $$SavingTableTableFilterComposer get savingId {
    final $$SavingTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savingId,
      referencedTable: $db.savingTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingTableTableFilterComposer(
            $db: $db,
            $table: $db.savingTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpenseTableTableFilterComposer get expenseId {
    final $$ExpenseTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.expenseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseTableTableFilterComposer(
            $db: $db,
            $table: $db.expenseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionTableTable> {
  $$TransactionTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isExpense => $composableBuilder(
    column: $table.isExpense,
    builder: (column) => ColumnOrderings(column),
  );

  $$SavingTableTableOrderingComposer get savingId {
    final $$SavingTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savingId,
      referencedTable: $db.savingTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingTableTableOrderingComposer(
            $db: $db,
            $table: $db.savingTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpenseTableTableOrderingComposer get expenseId {
    final $$ExpenseTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.expenseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseTableTableOrderingComposer(
            $db: $db,
            $table: $db.expenseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionTableTable> {
  $$TransactionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastModifiedBy => $composableBuilder(
    column: $table.lastModifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<bool> get isExpense =>
      $composableBuilder(column: $table.isExpense, builder: (column) => column);

  $$SavingTableTableAnnotationComposer get savingId {
    final $$SavingTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savingId,
      referencedTable: $db.savingTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingTableTableAnnotationComposer(
            $db: $db,
            $table: $db.savingTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpenseTableTableAnnotationComposer get expenseId {
    final $$ExpenseTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.expenseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseTableTableAnnotationComposer(
            $db: $db,
            $table: $db.expenseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionTableTable,
          TrnsctnTransaction,
          $$TransactionTableTableFilterComposer,
          $$TransactionTableTableOrderingComposer,
          $$TransactionTableTableAnnotationComposer,
          $$TransactionTableTableCreateCompanionBuilder,
          $$TransactionTableTableUpdateCompanionBuilder,
          (TrnsctnTransaction, $$TransactionTableTableReferences),
          TrnsctnTransaction,
          PrefetchHooks Function({bool savingId, bool expenseId})
        > {
  $$TransactionTableTableTableManager(
    _$AppDatabase db,
    $TransactionTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<DateTime> dateUpdated = const Value.absent(),
                Value<String> lastModifiedBy = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> savingId = const Value.absent(),
                Value<bool> isExpense = const Value.absent(),
                Value<String?> expenseId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionTableCompanion(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                type: type,
                description: description,
                amount: amount,
                savingId: savingId,
                isExpense: isExpense,
                expenseId: expenseId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String createdBy,
                Value<DateTime> dateCreated = const Value.absent(),
                required DateTime dateUpdated,
                required String lastModifiedBy,
                required String type,
                Value<String> description = const Value.absent(),
                required double amount,
                required String savingId,
                Value<bool> isExpense = const Value.absent(),
                Value<String?> expenseId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionTableCompanion.insert(
                id: id,
                createdBy: createdBy,
                dateCreated: dateCreated,
                dateUpdated: dateUpdated,
                lastModifiedBy: lastModifiedBy,
                type: type,
                description: description,
                amount: amount,
                savingId: savingId,
                isExpense: isExpense,
                expenseId: expenseId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({savingId = false, expenseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (savingId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.savingId,
                                referencedTable:
                                    $$TransactionTableTableReferences
                                        ._savingIdTable(db),
                                referencedColumn:
                                    $$TransactionTableTableReferences
                                        ._savingIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (expenseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.expenseId,
                                referencedTable:
                                    $$TransactionTableTableReferences
                                        ._expenseIdTable(db),
                                referencedColumn:
                                    $$TransactionTableTableReferences
                                        ._expenseIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransactionTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionTableTable,
      TrnsctnTransaction,
      $$TransactionTableTableFilterComposer,
      $$TransactionTableTableOrderingComposer,
      $$TransactionTableTableAnnotationComposer,
      $$TransactionTableTableCreateCompanionBuilder,
      $$TransactionTableTableUpdateCompanionBuilder,
      (TrnsctnTransaction, $$TransactionTableTableReferences),
      TrnsctnTransaction,
      PrefetchHooks Function({bool savingId, bool expenseId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserTableTableTableManager get userTable =>
      $$UserTableTableTableManager(_db, _db.userTable);
  $$GroupReferenceTableTableTableManager get groupReferenceTable =>
      $$GroupReferenceTableTableTableManager(_db, _db.groupReferenceTable);
  $$ReferenceTableTableTableManager get referenceTable =>
      $$ReferenceTableTableTableManager(_db, _db.referenceTable);
  $$ReferenceDataTableTableTableManager get referenceDataTable =>
      $$ReferenceDataTableTableTableManager(_db, _db.referenceDataTable);
  $$ExpenseReferenceTableTableTableManager get expenseReferenceTable =>
      $$ExpenseReferenceTableTableTableManager(_db, _db.expenseReferenceTable);
  $$MoneyStorageTableTableTableManager get moneyStorageTable =>
      $$MoneyStorageTableTableTableManager(_db, _db.moneyStorageTable);
  $$SavingTableTableTableManager get savingTable =>
      $$SavingTableTableTableManager(_db, _db.savingTable);
  $$ExpenseTableTableTableManager get expenseTable =>
      $$ExpenseTableTableTableManager(_db, _db.expenseTable);
  $$CommitmentTableTableTableManager get commitmentTable =>
      $$CommitmentTableTableTableManager(_db, _db.commitmentTable);
  $$CommitmentDetailTableTableTableManager get commitmentDetailTable =>
      $$CommitmentDetailTableTableTableManager(_db, _db.commitmentDetailTable);
  $$CommitmentTaskTableTableTableManager get commitmentTaskTable =>
      $$CommitmentTaskTableTableTableManager(_db, _db.commitmentTaskTable);
  $$TransactionTableTableTableManager get transactionTable =>
      $$TransactionTableTableTableManager(_db, _db.transactionTable);
}
