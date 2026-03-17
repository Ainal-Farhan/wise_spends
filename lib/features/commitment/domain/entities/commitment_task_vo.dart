import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/domain/entities/i_vo.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';
import 'package:wise_spends/features/saving/domain/entities/saving_vo.dart';
import 'package:wise_spends/features/commitment/data/constants/commitment_task_type.dart';

// ---------------------------------------------------------------------------
// CommitmentTaskVO
// ---------------------------------------------------------------------------

/// VO for a single commitment task — the actionable, completable payment unit
/// generated when a commitment is distributed.
///
/// Three payment scenarios are supported via [type]:
///   - [CommitmentTaskType.internalTransfer]  : sourceSaving → targetSaving
///   - [CommitmentTaskType.thirdPartyPayment] : sourceSaving → external payee
///   - [CommitmentTaskType.cash]              : no digital account movement
class CommitmentTaskVO extends IVO {
  // -- Identity --------------------------------------------------------------

  String? commitmentTaskId;

  // -- Core ------------------------------------------------------------------

  String? name;

  /// Always positive. Direction is determined by [type].
  double? amount;

  bool? isDone;

  // -- Commitment hierarchy --------------------------------------------------

  String? commitmentId;
  String? commitmentDetailId;

  // -- Payment type ----------------------------------------------------------

  CommitmentTaskType? type;

  // -- Source saving ---------------------------------------------------------

  /// Account funds are drawn from.
  /// Null for [CommitmentTaskType.cash] — no digital debit occurs.
  String? sourceSavingId;
  SavingVO? sourceSavingVO;

  // -- Target saving ---------------------------------------------------------

  /// Destination account. Only set for [CommitmentTaskType.internalTransfer].
  String? targetSavingId;
  SavingVO? targetSavingVO;

  // -- Third-party payee -----------------------------------------------------

  /// Only set for [CommitmentTaskType.thirdPartyPayment].
  /// Stored as a nested [PayeeVO] — not as flat fields — to mirror the
  /// normalised [PayeeTable] schema and avoid duplication.
  String? payeeId;
  PayeeVO? payeeVO;

  // -- Metadata --------------------------------------------------------------

  String? note;

  /// Receipt / FPX ref — populated after completion.
  String? paymentReference;

  /// FK to the Transaction record created when [isDone] becomes true.
  String? transactionId;

  DateTime? updatedDate;

  // ---------------------------------------------------------------------------
  // Constructors
  // ---------------------------------------------------------------------------

  CommitmentTaskVO();

  /// Constructs from the Drift-generated data class plus optional joined rows.
  /// Pass [sourceSaving], [targetSaving], and [payee] from a JOIN or separate
  /// lookups; all are optional so partial loads are safe.
  CommitmentTaskVO.fromExpnsCommitmentTask(
    ExpnsCommitmentTask task, {
    SvngSaving? sourceSaving,
    SvngSaving? targetSaving,
    ExpnsPayee? payee,
  }) {
    commitmentTaskId = task.id;
    name = task.name;
    amount = task.amount;
    isDone = task.isDone;
    updatedDate = task.dateUpdated;
    commitmentId = task.commitmentId;
    commitmentDetailId = task.commitmentDetailId;
    type = task.type;
    sourceSavingId = task.sourceSavingId;
    targetSavingId = task.targetSavingId;
    payeeId = task.payeeId;
    note = task.note;
    paymentReference = task.paymentReference;
    transactionId = task.transactionId;

    if (sourceSaving != null) {
      sourceSavingVO = SavingVO.fromSvngSaving(sourceSaving);
    }
    if (targetSaving != null) {
      targetSavingVO = SavingVO.fromSvngSaving(targetSaving);
    }
    if (payee != null) {
      payeeVO = PayeeVO.fromExpnsPayee(payee);
    }
  }

  CommitmentTaskVO.fromJson(Map<String, dynamic> json) {
    commitmentTaskId = json['commitmentTaskId'] as String?;
    name = json['name'] as String?;
    amount = json['amount'] as double?;
    isDone = json['isDone'] as bool?;
    updatedDate = json['updatedDate'] as DateTime?;
    commitmentId = json['commitmentId'] as String?;
    commitmentDetailId = json['commitmentDetailId'] as String?;

    final typeString = json['type'] as String?;
    type = typeString != null
        ? CommitmentTaskType.values.firstWhere(
            (e) => e.name == typeString,
            orElse: () => CommitmentTaskType.internalTransfer,
          )
        : null;

    sourceSavingId = json['sourceSavingId'] as String?;
    targetSavingId = json['targetSavingId'] as String?;
    payeeId = json['payeeId'] as String?;
    note = json['note'] as String?;
    paymentReference = json['paymentReference'] as String?;
    transactionId = json['transactionId'] as String?;

    sourceSavingVO = json['sourceSavingVO'] != null
        ? SavingVO.fromJson(json['sourceSavingVO'] as Map<String, dynamic>)
        : null;
    targetSavingVO = json['targetSavingVO'] != null
        ? SavingVO.fromJson(json['targetSavingVO'] as Map<String, dynamic>)
        : null;
    payeeVO = json['payeeVO'] != null
        ? PayeeVO.fromJson(json['payeeVO'] as Map<String, dynamic>)
        : null;
  }

  @override
  Map<String, dynamic> toJson() => {
    'commitmentTaskId': commitmentTaskId,
    'name': name,
    'amount': amount,
    'isDone': isDone,
    'updatedDate': updatedDate,
    'commitmentId': commitmentId,
    'commitmentDetailId': commitmentDetailId,
    'type': type?.name,
    'sourceSavingId': sourceSavingId,
    'targetSavingId': targetSavingId,
    'payeeId': payeeId,
    'note': note,
    'paymentReference': paymentReference,
    'transactionId': transactionId,
    // Nested VOs serialised as maps — allows full round-trip via fromJson
    'sourceSavingVO': sourceSavingVO?.toJson(),
    'targetSavingVO': targetSavingVO?.toJson(),
    'payeeVO': payeeVO?.toJson(),
  };

  // ---------------------------------------------------------------------------
  // Type helpers
  // ---------------------------------------------------------------------------

  bool get isInternalTransfer => type == CommitmentTaskType.internalTransfer;
  bool get isThirdPartyPayment => type == CommitmentTaskType.thirdPartyPayment;
  bool get isCash => type == CommitmentTaskType.cash;

  // ---------------------------------------------------------------------------
  // Display getters — used by the screen so it never needs to null-check inline
  // ---------------------------------------------------------------------------

  /// Display-ready source saving name. Falls back to raw ID, then '—'.
  String get sourceSavingName =>
      sourceSavingVO?.savingName ?? sourceSavingId ?? '—';

  /// Display-ready target saving name. Falls back to raw ID, then '—'.
  String get targetSavingName =>
      targetSavingVO?.savingName ?? targetSavingId ?? '—';

  /// Display-ready payee name. Falls back to raw ID, then '—'.
  /// Named as a getter (not a field) so it can never accidentally shadow
  /// the nested [payeeVO?.name] with a stale flat string.
  String get payeeName => payeeVO?.name ?? payeeId ?? '—';
}
