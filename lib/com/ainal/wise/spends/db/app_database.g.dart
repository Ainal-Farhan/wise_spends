// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: type=lint
class CmnUser extends DataClass implements Insertable<CmnUser> {
  final String id;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String name;
  CmnUser(
      {required this.id,
      required this.dateCreated,
      required this.dateUpdated,
      required this.name});
  factory CmnUser.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return CmnUser(
      id: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      dateCreated: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}date_created'])!,
      dateUpdated: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}date_updated'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
    );
  }
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

  factory CmnUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CmnUser(
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

  CmnUser copyWith(
          {String? id,
          DateTime? dateCreated,
          DateTime? dateUpdated,
          String? name}) =>
      CmnUser(
        id: id ?? this.id,
        dateCreated: dateCreated ?? this.dateCreated,
        dateUpdated: dateUpdated ?? this.dateUpdated,
        name: name ?? this.name,
      );
  @override
  String toString() {
    return (StringBuffer('CmnUser(')
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
      (other is CmnUser &&
          other.id == this.id &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.name == this.name);
}

class UserTableCompanion extends UpdateCompanion<CmnUser> {
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
    this.dateUpdated = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<CmnUser> custom({
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

class $UserTableTable extends UserTable
    with TableInfo<$UserTableTable, CmnUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserTableTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      type: const StringType(),
      requiredDuringInsert: false,
      clientDefault: () => UuidGenerator().v4());
  final VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime?> dateCreated =
      GeneratedColumn<DateTime?>('date_created', aliasedName, false,
          type: const IntType(),
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  final VerificationMeta _dateUpdatedMeta =
      const VerificationMeta('dateUpdated');
  @override
  late final GeneratedColumn<DateTime?> dateUpdated =
      GeneratedColumn<DateTime?>('date_updated', aliasedName, false,
          type: const IntType(),
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, dateCreated, dateUpdated, name];
  @override
  String get aliasedName => _alias ?? 'user_table';
  @override
  String get actualTableName => 'user_table';
  @override
  VerificationContext validateIntegrity(Insertable<CmnUser> instance,
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
  CmnUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    return CmnUser.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $UserTableTable createAlias(String alias) {
    return $UserTableTable(attachedDatabase, alias);
  }
}

class CmnSaving extends DataClass implements Insertable<CmnSaving> {
  final String id;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String name;
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
  CmnSaving(
      {required this.id,
      required this.dateCreated,
      required this.dateUpdated,
      required this.name,
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
      required this.currentAmount});
  factory CmnSaving.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return CmnSaving(
      id: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      dateCreated: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}date_created'])!,
      dateUpdated: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}date_updated'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      isPublic: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_public'])!,
      isHasGoal: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_has_goal'])!,
      goal: const RealType()
          .mapFromDatabaseResponse(data['${effectivePrefix}goal'])!,
      isHasStartDate: const BoolType().mapFromDatabaseResponse(
          data['${effectivePrefix}is_has_start_date'])!,
      startDate: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}start_date']),
      isHasEndDate: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_has_end_date'])!,
      endDate: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}end_date']),
      isSaveDaily: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_save_daily'])!,
      isSaveWeekly: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_save_weekly'])!,
      isSaveMonthly: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_save_monthly'])!,
      currentAmount: const RealType()
          .mapFromDatabaseResponse(data['${effectivePrefix}current_amount'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['name'] = Variable<String>(name);
    map['is_public'] = Variable<bool>(isPublic);
    map['is_has_goal'] = Variable<bool>(isHasGoal);
    map['goal'] = Variable<double>(goal);
    map['is_has_start_date'] = Variable<bool>(isHasStartDate);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime?>(startDate);
    }
    map['is_has_end_date'] = Variable<bool>(isHasEndDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime?>(endDate);
    }
    map['is_save_daily'] = Variable<bool>(isSaveDaily);
    map['is_save_weekly'] = Variable<bool>(isSaveWeekly);
    map['is_save_monthly'] = Variable<bool>(isSaveMonthly);
    map['current_amount'] = Variable<double>(currentAmount);
    return map;
  }

  SavingTableCompanion toCompanion(bool nullToAbsent) {
    return SavingTableCompanion(
      id: Value(id),
      dateCreated: Value(dateCreated),
      dateUpdated: Value(dateUpdated),
      name: Value(name),
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
    );
  }

  factory CmnSaving.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CmnSaving(
      id: serializer.fromJson<String>(json['id']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      name: serializer.fromJson<String>(json['name']),
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
    };
  }

  CmnSaving copyWith(
          {String? id,
          DateTime? dateCreated,
          DateTime? dateUpdated,
          String? name,
          bool? isPublic,
          bool? isHasGoal,
          double? goal,
          bool? isHasStartDate,
          DateTime? startDate,
          bool? isHasEndDate,
          DateTime? endDate,
          bool? isSaveDaily,
          bool? isSaveWeekly,
          bool? isSaveMonthly,
          double? currentAmount}) =>
      CmnSaving(
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
      );
  @override
  String toString() {
    return (StringBuffer('CmnSaving(')
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
          ..write('currentAmount: $currentAmount')
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
      currentAmount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CmnSaving &&
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
          other.currentAmount == this.currentAmount);
}

class SavingTableCompanion extends UpdateCompanion<CmnSaving> {
  final Value<String> id;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> name;
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
  });
  SavingTableCompanion.insert({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    required String name,
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
  }) : name = Value(name);
  static Insertable<CmnSaving> custom({
    Expression<String>? id,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? name,
    Expression<bool>? isPublic,
    Expression<bool>? isHasGoal,
    Expression<double>? goal,
    Expression<bool>? isHasStartDate,
    Expression<DateTime?>? startDate,
    Expression<bool>? isHasEndDate,
    Expression<DateTime?>? endDate,
    Expression<bool>? isSaveDaily,
    Expression<bool>? isSaveWeekly,
    Expression<bool>? isSaveMonthly,
    Expression<double>? currentAmount,
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
    });
  }

  SavingTableCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? dateCreated,
      Value<DateTime>? dateUpdated,
      Value<String>? name,
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
      Value<double>? currentAmount}) {
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
      map['start_date'] = Variable<DateTime?>(startDate.value);
    }
    if (isHasEndDate.present) {
      map['is_has_end_date'] = Variable<bool>(isHasEndDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime?>(endDate.value);
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
          ..write('currentAmount: $currentAmount')
          ..write(')'))
        .toString();
  }
}

class $SavingTableTable extends SavingTable
    with TableInfo<$SavingTableTable, CmnSaving> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingTableTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      type: const StringType(),
      requiredDuringInsert: false,
      clientDefault: () => UuidGenerator().v4());
  final VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime?> dateCreated =
      GeneratedColumn<DateTime?>('date_created', aliasedName, false,
          type: const IntType(),
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  final VerificationMeta _dateUpdatedMeta =
      const VerificationMeta('dateUpdated');
  @override
  late final GeneratedColumn<DateTime?> dateUpdated =
      GeneratedColumn<DateTime?>('date_updated', aliasedName, false,
          type: const IntType(),
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _isPublicMeta = const VerificationMeta('isPublic');
  @override
  late final GeneratedColumn<bool?> isPublic = GeneratedColumn<bool?>(
      'is_public', aliasedName, false,
      type: const BoolType(),
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (is_public IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _isHasGoalMeta = const VerificationMeta('isHasGoal');
  @override
  late final GeneratedColumn<bool?> isHasGoal = GeneratedColumn<bool?>(
      'is_has_goal', aliasedName, false,
      type: const BoolType(),
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (is_has_goal IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<double?> goal = GeneratedColumn<double?>(
      'goal', aliasedName, false,
      type: const RealType(),
      requiredDuringInsert: false,
      defaultValue: const Constant(.0));
  final VerificationMeta _isHasStartDateMeta =
      const VerificationMeta('isHasStartDate');
  @override
  late final GeneratedColumn<bool?> isHasStartDate = GeneratedColumn<bool?>(
      'is_has_start_date', aliasedName, false,
      type: const BoolType(),
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (is_has_start_date IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _startDateMeta = const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime?> startDate = GeneratedColumn<DateTime?>(
      'start_date', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _isHasEndDateMeta =
      const VerificationMeta('isHasEndDate');
  @override
  late final GeneratedColumn<bool?> isHasEndDate = GeneratedColumn<bool?>(
      'is_has_end_date', aliasedName, false,
      type: const BoolType(),
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (is_has_end_date IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _endDateMeta = const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime?> endDate = GeneratedColumn<DateTime?>(
      'end_date', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _isSaveDailyMeta =
      const VerificationMeta('isSaveDaily');
  @override
  late final GeneratedColumn<bool?> isSaveDaily = GeneratedColumn<bool?>(
      'is_save_daily', aliasedName, false,
      type: const BoolType(),
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (is_save_daily IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _isSaveWeeklyMeta =
      const VerificationMeta('isSaveWeekly');
  @override
  late final GeneratedColumn<bool?> isSaveWeekly = GeneratedColumn<bool?>(
      'is_save_weekly', aliasedName, false,
      type: const BoolType(),
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (is_save_weekly IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _isSaveMonthlyMeta =
      const VerificationMeta('isSaveMonthly');
  @override
  late final GeneratedColumn<bool?> isSaveMonthly = GeneratedColumn<bool?>(
      'is_save_monthly', aliasedName, false,
      type: const BoolType(),
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (is_save_monthly IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _currentAmountMeta =
      const VerificationMeta('currentAmount');
  @override
  late final GeneratedColumn<double?> currentAmount = GeneratedColumn<double?>(
      'current_amount', aliasedName, false,
      type: const RealType(),
      requiredDuringInsert: false,
      defaultValue: const Constant(.0));
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
        currentAmount
      ];
  @override
  String get aliasedName => _alias ?? 'saving_table';
  @override
  String get actualTableName => 'saving_table';
  @override
  VerificationContext validateIntegrity(Insertable<CmnSaving> instance,
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
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {name},
      ];
  @override
  CmnSaving map(Map<String, dynamic> data, {String? tablePrefix}) {
    return CmnSaving.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $SavingTableTable createAlias(String alias) {
    return $SavingTableTable(attachedDatabase, alias);
  }
}

class CmnTransaction extends DataClass implements Insertable<CmnTransaction> {
  final String id;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String type;
  final String description;
  final double amount;
  final String saving;
  CmnTransaction(
      {required this.id,
      required this.dateCreated,
      required this.dateUpdated,
      required this.type,
      required this.description,
      required this.amount,
      required this.saving});
  factory CmnTransaction.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return CmnTransaction(
      id: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      dateCreated: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}date_created'])!,
      dateUpdated: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}date_updated'])!,
      type: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}type'])!,
      description: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}description'])!,
      amount: const RealType()
          .mapFromDatabaseResponse(data['${effectivePrefix}amount'])!,
      saving: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}saving'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    map['type'] = Variable<String>(type);
    map['description'] = Variable<String>(description);
    map['amount'] = Variable<double>(amount);
    map['saving'] = Variable<String>(saving);
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
      saving: Value(saving),
    );
  }

  factory CmnTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CmnTransaction(
      id: serializer.fromJson<String>(json['id']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
      type: serializer.fromJson<String>(json['type']),
      description: serializer.fromJson<String>(json['description']),
      amount: serializer.fromJson<double>(json['amount']),
      saving: serializer.fromJson<String>(json['saving']),
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
      'saving': serializer.toJson<String>(saving),
    };
  }

  CmnTransaction copyWith(
          {String? id,
          DateTime? dateCreated,
          DateTime? dateUpdated,
          String? type,
          String? description,
          double? amount,
          String? saving}) =>
      CmnTransaction(
        id: id ?? this.id,
        dateCreated: dateCreated ?? this.dateCreated,
        dateUpdated: dateUpdated ?? this.dateUpdated,
        type: type ?? this.type,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        saving: saving ?? this.saving,
      );
  @override
  String toString() {
    return (StringBuffer('CmnTransaction(')
          ..write('id: $id, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('saving: $saving')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, dateCreated, dateUpdated, type, description, amount, saving);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CmnTransaction &&
          other.id == this.id &&
          other.dateCreated == this.dateCreated &&
          other.dateUpdated == this.dateUpdated &&
          other.type == this.type &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.saving == this.saving);
}

class TransactionTableCompanion extends UpdateCompanion<CmnTransaction> {
  final Value<String> id;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateUpdated;
  final Value<String> type;
  final Value<String> description;
  final Value<double> amount;
  final Value<String> saving;
  const TransactionTableCompanion({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.saving = const Value.absent(),
  });
  TransactionTableCompanion.insert({
    this.id = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    required String type,
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    required String saving,
  })  : type = Value(type),
        saving = Value(saving);
  static Insertable<CmnTransaction> custom({
    Expression<String>? id,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateUpdated,
    Expression<String>? type,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<String>? saving,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (saving != null) 'saving': saving,
    });
  }

  TransactionTableCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? dateCreated,
      Value<DateTime>? dateUpdated,
      Value<String>? type,
      Value<String>? description,
      Value<double>? amount,
      Value<String>? saving}) {
    return TransactionTableCompanion(
      id: id ?? this.id,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      type: type ?? this.type,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      saving: saving ?? this.saving,
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
    if (saving.present) {
      map['saving'] = Variable<String>(saving.value);
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
          ..write('saving: $saving')
          ..write(')'))
        .toString();
  }
}

class $TransactionTableTable extends TransactionTable
    with TableInfo<$TransactionTableTable, CmnTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionTableTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>(
      'id', aliasedName, false,
      type: const StringType(),
      requiredDuringInsert: false,
      clientDefault: () => UuidGenerator().v4());
  final VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime?> dateCreated =
      GeneratedColumn<DateTime?>('date_created', aliasedName, false,
          type: const IntType(),
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  final VerificationMeta _dateUpdatedMeta =
      const VerificationMeta('dateUpdated');
  @override
  late final GeneratedColumn<DateTime?> dateUpdated =
      GeneratedColumn<DateTime?>('date_updated', aliasedName, false,
          type: const IntType(),
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  final VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String?> type = GeneratedColumn<String?>(
      'type', aliasedName, false,
      check: () => type.isIn(DomainTableConstant.transactionTableTypeList),
      type: const StringType(),
      requiredDuringInsert: true);
  final VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String?> description = GeneratedColumn<String?>(
      'description', aliasedName, false,
      type: const StringType(),
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  final VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double?> amount = GeneratedColumn<double?>(
      'amount', aliasedName, false,
      type: const RealType(),
      requiredDuringInsert: false,
      defaultValue: const Constant(.0));
  final VerificationMeta _savingMeta = const VerificationMeta('saving');
  @override
  late final GeneratedColumn<String?> saving = GeneratedColumn<String?>(
      'saving', aliasedName, false,
      type: const StringType(),
      requiredDuringInsert: true,
      defaultConstraints: 'REFERENCES saving_table (id)');
  @override
  List<GeneratedColumn> get $columns =>
      [id, dateCreated, dateUpdated, type, description, amount, saving];
  @override
  String get aliasedName => _alias ?? 'transaction_table';
  @override
  String get actualTableName => 'transaction_table';
  @override
  VerificationContext validateIntegrity(Insertable<CmnTransaction> instance,
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
    }
    if (data.containsKey('saving')) {
      context.handle(_savingMeta,
          saving.isAcceptableOrUnknown(data['saving']!, _savingMeta));
    } else if (isInserting) {
      context.missing(_savingMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CmnTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    return CmnTransaction.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $TransactionTableTable createAlias(String alias) {
    return $TransactionTableTable(attachedDatabase, alias);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $UserTableTable userTable = $UserTableTable(this);
  late final $SavingTableTable savingTable = $SavingTableTable(this);
  late final $TransactionTableTable transactionTable =
      $TransactionTableTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [userTable, savingTable, transactionTable];
}
