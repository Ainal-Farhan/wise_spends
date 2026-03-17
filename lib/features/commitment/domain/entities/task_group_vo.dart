import 'package:wise_spends/domain/entities/i_vo.dart';
import 'package:wise_spends/features/commitment/data/constants/commitment_task_type.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';

/// VO representing a group of commitment tasks that share the same
/// source money storage AND target (either money storage for internal transfers,
/// or payee for third-party payments).
///
/// This allows users to complete multiple related tasks in one go,
/// making manual transaction tracking more convenient.
///
/// Two grouping scenarios:
/// 1. Internal Transfer: Group by source money storage + target money storage
///    - Task 1: From Saving A (Bank X) → Saving B (Bank Y)
///    - Task 2: From Saving C (Bank X) → Saving D (Bank Y)
///    Grouped as: Bank X → Bank Y
///
/// 2. Third-Party Payment: Group by source money storage + payee
///    - Task 1: From Saving A (Bank X) → Payee John
///    - Task 2: From Saving C (Bank X) → Payee John
///    Grouped as: Bank X → John
class TaskGroupVO implements IVO {
  /// Unique identifier for this group
  String groupId;

  /// The type of tasks in this group
  CommitmentTaskType? groupType;

  /// The source money storage ID all tasks in this group share
  String? sourceMoneyStorageId;

  /// Source money storage name (cached for display convenience)
  String? sourceMoneyStorageName;

  /// The target money storage ID (for internal transfers only)
  String? targetMoneyStorageId;

  /// Target money storage name (cached for display convenience)
  String? targetMoneyStorageName;

  /// The target payee ID (for third-party payments only)
  String? payeeId;

  /// Target payee name (cached for display convenience)
  String? payeeName;

  /// List of incomplete tasks in this group
  List<CommitmentTaskVO> tasks;

  /// Total amount across all tasks in the group
  double get totalAmount {
    return tasks.fold(0.0, (sum, task) => sum + (task.amount ?? 0.0));
  }

  /// Number of tasks in the group
  int get taskCount => tasks.length;

  TaskGroupVO({
    required this.groupId,
    this.groupType,
    this.sourceMoneyStorageId,
    this.sourceMoneyStorageName,
    this.targetMoneyStorageId,
    this.targetMoneyStorageName,
    this.payeeId,
    this.payeeName,
    required this.tasks,
  });

  TaskGroupVO.fromJson(Map<String, dynamic> json)
      : groupId = json['groupId'] as String,
        groupType = json['groupType'] != null
            ? CommitmentTaskType.values.firstWhere(
                (e) => e.name == json['groupType'],
                orElse: () => CommitmentTaskType.internalTransfer,
              )
            : null,
        sourceMoneyStorageId = json['sourceMoneyStorageId'] as String?,
        sourceMoneyStorageName = json['sourceMoneyStorageName'] as String?,
        targetMoneyStorageId = json['targetMoneyStorageId'] as String?,
        targetMoneyStorageName = json['targetMoneyStorageName'] as String?,
        payeeId = json['payeeId'] as String?,
        payeeName = json['payeeName'] as String?,
        tasks = (json['tasks'] as List<dynamic>)
            .map((t) => CommitmentTaskVO.fromJson(t as Map<String, dynamic>))
            .toList();

  @override
  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupType': groupType?.name,
      'sourceMoneyStorageId': sourceMoneyStorageId,
      'sourceMoneyStorageName': sourceMoneyStorageName,
      'targetMoneyStorageId': targetMoneyStorageId,
      'targetMoneyStorageName': targetMoneyStorageName,
      'payeeId': payeeId,
      'payeeName': payeeName,
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
  }

  /// Creates a group ID for internal transfers
  static String createInternalTransferGroupId(
    String? sourceMoneyStorageId,
    String? targetMoneyStorageId,
  ) {
    return 'internal_${sourceMoneyStorageId ?? 'no_source'}_${targetMoneyStorageId ?? 'no_target'}';
  }

  /// Creates a group ID for third-party payments
  static String createThirdPartyPaymentGroupId(
    String? sourceMoneyStorageId,
    String? payeeId,
  ) {
    return 'payment_${sourceMoneyStorageId ?? 'no_source'}_${payeeId ?? 'no_payee'}';
  }

  /// Display target name (either money storage name or payee name)
  String get targetName {
    if (groupType == CommitmentTaskType.thirdPartyPayment) {
      return payeeName ?? 'Unknown Payee';
    }
    return targetMoneyStorageName ?? 'Unknown';
  }
}
