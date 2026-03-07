import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/domain/entities/i_vo.dart';
import 'package:wise_spends/domain/entities/impl/saving/saving_vo.dart';
import 'package:wise_spends/domain/entities/impl/expense/payee_vo.dart';
import 'package:wise_spends/core/constants/constant/enum/expense/commitment_detail_type.dart';
import 'package:wise_spends/core/constants/constant/enum/expense/commitment_task_type.dart';

// ---------------------------------------------------------------------------
// CommitmentDetailVO
// ---------------------------------------------------------------------------

class CommitmentDetailVO extends IVO {
  // -- Identity --------------------------------------------------------------

  String? commitmentDetailId;

  // -- Core ------------------------------------------------------------------

  String? description;
  double? amount;

  /// Recurrence schedule (monthly, weekly, …).
  CommitmentDetailType? type;

  // -- Payment type ----------------------------------------------------------

  /// HOW tasks are paid when this detail is distributed.
  /// Defaults to internalTransfer so existing data is unaffected.
  CommitmentTaskType taskType;

  // -- Source saving ---------------------------------------------------------

  String? savingId;
  SavingVO? sourceSavingVO;

  // -- Internal transfer target ----------------------------------------------

  /// Populated when taskType == CommitmentTaskType.internalTransfer.
  String? targetSavingId;
  SavingVO? targetSavingVO;

  // -- Third-party payee -----------------------------------------------------

  /// Populated when taskType == CommitmentTaskType.thirdPartyPayment.
  String? payeeId;
  PayeeVO? payeeVO;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  CommitmentDetailVO({this.taskType = CommitmentTaskType.internalTransfer});

  CommitmentDetailVO.fromExpnsCommitmentDetail(
    ExpnsCommitmentDetail commitmentDetail, {
    SvngSaving? saving,
    SvngSaving? targetSaving,
    ExpnsPayee? payee,
  }) : taskType = commitmentDetail.taskType {
    commitmentDetailId = commitmentDetail.id;
    description = commitmentDetail.description;
    amount = commitmentDetail.amount;
    type = commitmentDetail.type;

    savingId = commitmentDetail.savingId;
    if (saving != null) {
      sourceSavingVO = SavingVO.fromSvngSaving(saving);
    }

    targetSavingId = commitmentDetail.targetSavingId;
    if (targetSaving != null) {
      targetSavingVO = SavingVO.fromSvngSaving(targetSaving);
    }

    payeeId = commitmentDetail.payeeId;
    if (payee != null) {
      payeeVO = PayeeVO.fromExpnsPayee(payee);
    }
  }

  CommitmentDetailVO.fromJson(Map<String, dynamic> json)
    : taskType = _parseTaskType(json['taskType'] as String?) {
    commitmentDetailId = json['commitmentDetailId'];
    description = json['description'];
    amount = json['amount'] as double?;

    final typeString = json['type'] as String?;
    type = typeString != null
        ? CommitmentDetailType.values.firstWhere(
            (e) => e.name == typeString,
            orElse: () => CommitmentDetailType.monthly,
          )
        : null;

    savingId = json['savingId'];
    sourceSavingVO = json['sourceSavingVO'] != null
        ? SavingVO.fromJson(json['sourceSavingVO'] as Map<String, dynamic>)
        : null;

    targetSavingId = json['targetSavingId'];
    targetSavingVO = json['targetSavingVO'] != null
        ? SavingVO.fromJson(json['targetSavingVO'] as Map<String, dynamic>)
        : null;

    payeeId = json['payeeId'];
    payeeVO = json['payeeVO'] != null
        ? PayeeVO.fromJson(json['payeeVO'] as Map<String, dynamic>)
        : null;
  }

  // ---------------------------------------------------------------------------
  // Backwards-compat alias — existing code that reads `referredSavingVO`
  // continues to work without changes.
  // ---------------------------------------------------------------------------

  SavingVO? get referredSavingVO => sourceSavingVO;

  set referredSavingVO(SavingVO? value) => sourceSavingVO = value;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  bool get isInternalTransfer =>
      taskType == CommitmentTaskType.internalTransfer;
  bool get isThirdPartyPayment =>
      taskType == CommitmentTaskType.thirdPartyPayment;
  bool get isCash => taskType == CommitmentTaskType.cash;

  /// Display name for source saving — safe to call in UI without null checks.
  String get sourceSavingName => sourceSavingVO?.savingName ?? savingId ?? '—';

  /// Display name for target saving.
  String get targetSavingName =>
      targetSavingVO?.savingName ?? targetSavingId ?? '—';

  /// Display name for payee.
  String get payeeName => payeeVO?.name ?? payeeId ?? '—';

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  @override
  Map<String, dynamic> toJson() => {
    'commitmentDetailId': commitmentDetailId,
    'description': description,
    'amount': amount,
    'type': type?.name,
    'taskType': taskType.name,
    'savingId': savingId,
    'sourceSavingVO': sourceSavingVO?.toJson(),
    'targetSavingId': targetSavingId,
    'targetSavingVO': targetSavingVO?.toJson(),
    'payeeId': payeeId,
    'payeeVO': payeeVO?.toJson(),
  };

  static CommitmentTaskType _parseTaskType(String? value) {
    if (value == null) return CommitmentTaskType.internalTransfer;
    return CommitmentTaskType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CommitmentTaskType.internalTransfer,
    );
  }
}
