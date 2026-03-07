import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/saving/saving_constant.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/di/i_service_locator.dart';
import 'package:wise_spends/core/constants/constant/enum/expense/commitment_detail_type.dart';
import 'package:wise_spends/core/constants/constant/enum/expense/commitment_task_type.dart';
import 'package:wise_spends/domain/usecases/i_commitment_manager.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_detail_vo.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_task_vo.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_vo.dart';
import 'package:wise_spends/domain/entities/impl/saving/saving_vo.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';

class CommitmentManager extends ICommitmentManager {
  // ---------------------------------------------------------------------------
  // Commitment CRUD
  // ---------------------------------------------------------------------------

  @override
  Future<List<CommitmentVO>> retrieveListOfCommitmentOfCurrentUser() async {
    final startupManager = SingletonUtil.getSingleton<IManagerLocator>()!
        .getStartupManager();
    final commitmentRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCommitmentRepository();

    final List<ExpnsCommitment> rows = await commitmentRepo
        .watchAllByUser(startupManager.currentUser)
        .first;

    final List<CommitmentVO> result = [];
    for (final row in rows) {
      final vo = await retrieveCommitmentVOBasedOnCommitmentId(row.id);
      if (vo != null) result.add(vo);
    }
    return result;
  }

  @override
  Future<void> saveCommitmentVO(CommitmentVO commitmentVO) async {
    final startupManager = SingletonUtil.getSingleton<IManagerLocator>()!
        .getStartupManager();
    final commitmentRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCommitmentRepository();
    final savingService = SingletonUtil.getSingleton<IServiceLocator>()!
        .getSavingService();

    // Resolve the referred saving ID — prefer explicit VO, fall back to first detail
    String? resolvedReferredSavingId = commitmentVO.referredSavingVO?.savingId;
    if (resolvedReferredSavingId == null &&
        commitmentVO.commitmentDetailVOList.isNotEmpty) {
      resolvedReferredSavingId =
          commitmentVO.commitmentDetailVOList.first.savingId;
    }

    if (resolvedReferredSavingId == null) {
      throw Exception(
        'Please select a savings account before creating a commitment.',
      );
    }

    // Ensure referredSavingVO is populated so downstream operations can use it
    if (commitmentVO.referredSavingVO == null) {
      final saving = await savingService
          .watchSavingById(resolvedReferredSavingId)
          .first;
      if (saving != null) {
        commitmentVO.referredSavingVO = SavingVO.fromSvngSaving(saving);
      }
    }

    final companion = CommitmentTableCompanion.insert(
      id: commitmentVO.commitmentId != null
          ? Value(commitmentVO.commitmentId!)
          : const Value.absent(),
      createdBy: startupManager.currentUser.name,
      dateUpdated: DateTime.now(),
      lastModifiedBy: startupManager.currentUser.name,
      name: commitmentVO.name!,
      description: commitmentVO.description != null
          ? Value(commitmentVO.description!)
          : const Value.absent(),
      referredSavingId: resolvedReferredSavingId,
      userId: startupManager.currentUser.id,
    );

    String commitmentId;
    if (commitmentVO.commitmentId != null) {
      commitmentId = commitmentVO.commitmentId!;
      await commitmentRepo.updatePart(
        tableCompanion: companion,
        id: commitmentId,
      );
    } else {
      final inserted = await commitmentRepo.insertOne(companion);
      commitmentId = inserted.id;
    }

    await saveCommitmentDetailVO(
      commitmentId,
      commitmentVO.commitmentDetailVOList,
    );
  }

  @override
  Future<void> saveCommitmentDetailVO(
    String commitmentId,
    List<CommitmentDetailVO> commitmentDetailVOList,
  ) async {
    if (commitmentDetailVOList.isEmpty) return;

    final startupManager = SingletonUtil.getSingleton<IManagerLocator>()!
        .getStartupManager();
    final commitmentDetailRepo =
        SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getCommitmentDetailRepository();
    final savingService = SingletonUtil.getSingleton<IServiceLocator>()!
        .getSavingService();

    for (final vo in commitmentDetailVOList) {
      final String? resolvedSavingId =
          vo.referredSavingVO?.savingId ?? vo.savingId;

      if (resolvedSavingId == null) {
        throw Exception('Commitment detail is missing a savings account.');
      }

      if (vo.referredSavingVO == null) {
        final saving = await savingService
            .watchSavingById(resolvedSavingId)
            .first;
        if (saving != null) {
          vo.referredSavingVO = SavingVO.fromSvngSaving(saving);
        }
      }

      // Resolve to CommitmentDetailType enum — companion expects the enum
      // directly since the column is now intEnum<CommitmentDetailType>().
      // Fall back to monthly if nothing is set.
      final CommitmentDetailType resolvedType =
          vo.type ??
          _commitmentDetailTypeFromSavingType(
            vo.referredSavingVO?.savingTableType?.value,
          );

      final companion = CommitmentDetailTableCompanion.insert(
        id: vo.commitmentDetailId == null
            ? const Value.absent()
            : Value(vo.commitmentDetailId!),
        createdBy: startupManager.currentUser.name,
        dateUpdated: DateTime.now(),
        lastModifiedBy: startupManager.currentUser.name,
        amount: vo.amount ?? 0.0,
        description: vo.description ?? '-',
        type: resolvedType,
        savingId: resolvedSavingId,
        commitmentId: commitmentId,
      );

      if (vo.commitmentDetailId != null) {
        await commitmentDetailRepo.updatePart(
          tableCompanion: companion,
          id: vo.commitmentDetailId!,
        );
      } else {
        await commitmentDetailRepo.insertOne(companion);
      }
    }
  }

  @override
  Future<void> deleteCommitmentVO(String commitmentId) async {
    final commitmentRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCommitmentRepository();
    final commitment = await commitmentRepo.findById(id: commitmentId);
    if (commitment == null) return;

    final commitmentDetailRepo =
        SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getCommitmentDetailRepository();

    // Delete tasks for this commitment, then details, then commitment itself
    final commitmentTaskRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCommitmentTaskRepository();

    await commitmentTaskRepo.deleteByCommitmentId(commitment.id);
    await commitmentDetailRepo.deleteByCommitmentId(commitment.id);
    await commitmentRepo.delete(commitment);
  }

  @override
  Future<void> deleteCommitmentDetailVO(String commitmentDetailId) async {
    final commitmentDetailRepo =
        SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getCommitmentDetailRepository();

    // Delete tasks linked to this detail, then the detail itself
    final commitmentTaskRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCommitmentTaskRepository();

    await commitmentTaskRepo.deleteByCommitmentDetailId(commitmentDetailId);
    await commitmentDetailRepo.deleteById(id: commitmentDetailId);
  }

  @override
  Future<CommitmentVO?> retrieveCommitmentVOBasedOnCommitmentId(
    String commitmentId,
  ) async {
    final commitmentRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCommitmentRepository();
    final commitment = await commitmentRepo.findById(id: commitmentId);
    if (commitment == null) return null;

    final commitmentDetailRepo =
        SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getCommitmentDetailRepository();
    final savingService = SingletonUtil.getSingleton<IServiceLocator>()!
        .getSavingService();

    final details = await commitmentDetailRepo
        .watchAllByCommitment(commitment)
        .first;

    final Map<ExpnsCommitmentDetail, SvngSaving> detailMap = {};
    for (final detail in details) {
      final saving = await savingService.watchSavingById(detail.savingId).first;
      if (saving == null) continue;
      detailMap[detail] = saving;
    }

    final vo = CommitmentVO.fromExpnsCommitment(commitment, detailMap);

    final saving = await savingService
        .watchSavingById(commitment.referredSavingId)
        .first;
    if (saving != null) {
      vo.referredSavingVO = SavingVO.fromSvngSaving(saving);
    }

    return vo;
  }

  // ---------------------------------------------------------------------------
  // Commitment task — count / list
  // ---------------------------------------------------------------------------

  @override
  Stream<int> retrieveTotalCommitmentTask() async* {
    yield 0;
    final commitmentTaskRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCommitmentTaskRepository();
    yield (await commitmentTaskRepo.watchAll(false).first).length;
  }

  @override
  Future<List<CommitmentTaskVO>> retrieveListOfCommitmentTask(
    bool isDone,
  ) async {
    final commitmentTaskRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCommitmentTaskRepository();
    final savingService = SingletonUtil.getSingleton<IServiceLocator>()!
        .getSavingService();

    final List<ExpnsCommitmentTask> tasks = await commitmentTaskRepo
        .watchAll(isDone)
        .first;

    final List<CommitmentTaskVO> result = [];
    for (final task in tasks) {
      // Resolve source saving
      SvngSaving? sourceSaving;
      if (task.sourceSavingId != null) {
        sourceSaving = await savingService
            .watchSavingById(task.sourceSavingId!)
            .first;
      }

      // Resolve target saving (internal transfers only)
      SvngSaving? targetSaving;
      if (task.targetSavingId != null) {
        targetSaving = await savingService
            .watchSavingById(task.targetSavingId!)
            .first;
      }

      // Resolve payee (third-party payments only)
      ExpnsPayee? payee;
      if (task.payeeId != null) {
        final payeeRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getPayeeRepository();
        payee = await payeeRepo.findById(id: task.payeeId!);
      }
      result.add(
        CommitmentTaskVO.fromExpnsCommitmentTask(
          task,
          sourceSaving: sourceSaving,
          targetSaving: targetSaving,
          payee: payee,
        ),
      );
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Distribute
  // ---------------------------------------------------------------------------

  @override
  Future<String> startDistributeCommitment(CommitmentVO vo) async {
    if (vo.commitmentDetailVOList.isEmpty) {
      return 'No commitment details found for this commitment.';
    }

    if (vo.referredSavingVO == null || vo.referredSavingVO!.savingId == null) {
      return 'No savings account found for this commitment.';
    }

    final savingService = SingletonUtil.getSingleton<IServiceLocator>()!
        .getSavingService();

    final SvngSaving? sourceSaving = await savingService
        .watchSavingById(vo.referredSavingVO!.savingId!)
        .first;

    if (sourceSaving == null) {
      return 'Savings account not found.';
    }

    if (sourceSaving.currentAmount < (vo.totalAmount ?? 0.0)) {
      return 'Insufficient balance in ${sourceSaving.name}.';
    }

    final startupManager = SingletonUtil.getSingleton<IManagerLocator>()!
        .getStartupManager();
    final commitmentTaskRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCommitmentTaskRepository();

    final List<CommitmentTaskTableCompanion> companions = [];

    for (final detail in vo.commitmentDetailVOList) {
      if (detail.commitmentDetailId == null) continue;

      final String? detailSavingId =
          detail.referredSavingVO?.savingId ?? detail.savingId;

      if (detailSavingId == null) continue;

      // Each detail generates one task:
      //   sourceSavingId = commitment's referred saving (money leaves here)
      //   targetSavingId = detail's saving (money arrives here)
      //   type           = internalTransfer
      // Amount is always positive — direction is implied by source → target.
      companions.add(
        CommitmentTaskTableCompanion.insert(
          createdBy: startupManager.currentUser.name,
          dateUpdated: DateTime.now(),
          lastModifiedBy: startupManager.currentUser.name,
          name: detail.description ?? 'Commitment Task',
          amount: detail.amount ?? 0.0,
          isDone: const Value(false),
          commitmentId: vo.commitmentId!,
          commitmentDetailId: detail.commitmentDetailId!,
          type: CommitmentTaskType.internalTransfer,
          sourceSavingId: Value(sourceSaving.id),
          targetSavingId: Value(detailSavingId),
        ),
      );
    }

    if (companions.isEmpty) {
      return 'No valid commitment details to distribute.';
    }

    await commitmentTaskRepo.saveAllFromTableCompanion(companions);
    return 'Successfully distributed the commitment.';
  }

  // ---------------------------------------------------------------------------
  // Commitment task — status update
  // ---------------------------------------------------------------------------

  @override
  Future<void> updateStatusCommitmentTask(
    bool isDone,
    CommitmentTaskVO taskVO,
  ) async {
    if (taskVO.commitmentTaskId == null) return;

    if (isDone) {
      // Save transaction record before processing
      await _saveTransactionForTask(taskVO);

      final savingManager = SingletonUtil.getSingleton<IManagerLocator>()!
          .getSavingManager();

      switch (taskVO.type) {
        case CommitmentTaskType.internalTransfer:
          // Debit source, credit target
          if (taskVO.sourceSavingId != null) {
            await savingManager.updateSavingCurrentAmount(
              savingId: taskVO.sourceSavingId!,
              transactionType: SavingConstant.savingTransactionOut,
              transactionAmount: taskVO.amount!.abs(),
            );
          }
          if (taskVO.targetSavingId != null) {
            await savingManager.updateSavingCurrentAmount(
              savingId: taskVO.targetSavingId!,
              transactionType: SavingConstant.savingTransactionIn,
              transactionAmount: taskVO.amount!.abs(),
            );
          }
          break;

        case CommitmentTaskType.thirdPartyPayment:
          // Debit source only — money goes out
          if (taskVO.sourceSavingId != null) {
            await savingManager.updateSavingCurrentAmount(
              savingId: taskVO.sourceSavingId!,
              transactionType: SavingConstant.savingTransactionOut,
              transactionAmount: taskVO.amount!.abs(),
            );
          }
          break;

        case CommitmentTaskType.cash:
          // No digital account movement
          break;

        case null:
          break;
      }
    }

    await SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCommitmentTaskRepository()
        .deleteById(id: taskVO.commitmentTaskId!);
  }

  // ---------------------------------------------------------------------------
  // Commitment task — add / edit / delete
  // ---------------------------------------------------------------------------

  @override
  Future<void> addCommitmentTask(CommitmentTaskVO taskVO) async {
    final startupManager = SingletonUtil.getSingleton<IManagerLocator>()!
        .getStartupManager();
    final commitmentTaskRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCommitmentTaskRepository();

    _validateTaskVO(taskVO);

    final companion = CommitmentTaskTableCompanion.insert(
      id: taskVO.commitmentTaskId != null
          ? Value(taskVO.commitmentTaskId!)
          : const Value.absent(),
      createdBy: startupManager.currentUser.name,
      dateUpdated: DateTime.now(),
      lastModifiedBy: startupManager.currentUser.name,
      name: taskVO.name ?? 'Commitment Task',
      amount: taskVO.amount ?? 0.0,
      isDone: Value(taskVO.isDone ?? false),
      commitmentId: taskVO.commitmentId ?? '',
      commitmentDetailId: taskVO.commitmentDetailId ?? '',
      type: taskVO.type ?? CommitmentTaskType.internalTransfer,
      sourceSavingId: Value(taskVO.sourceSavingId),
      targetSavingId: Value(taskVO.targetSavingId),
      payeeId: Value(taskVO.payeeId),
      note: Value(taskVO.note),
      paymentReference: Value(taskVO.paymentReference),
    );

    await commitmentTaskRepo.insertOne(companion);
  }

  @override
  Future<void> editCommitmentTask(CommitmentTaskVO taskVO) async {
    if (taskVO.commitmentTaskId == null) return;

    final startupManager = SingletonUtil.getSingleton<IManagerLocator>()!
        .getStartupManager();
    final commitmentTaskRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCommitmentTaskRepository();

    _validateTaskVO(taskVO);

    final companion = CommitmentTaskTableCompanion.insert(
      id: Value(taskVO.commitmentTaskId!),
      createdBy: startupManager.currentUser.name,
      dateUpdated: DateTime.now(),
      lastModifiedBy: startupManager.currentUser.name,
      name: taskVO.name ?? 'Commitment Task',
      amount: taskVO.amount ?? 0.0,
      isDone: Value(taskVO.isDone ?? false),
      commitmentId: taskVO.commitmentId ?? '',
      commitmentDetailId: taskVO.commitmentDetailId ?? '',
      type: taskVO.type ?? CommitmentTaskType.internalTransfer,
      sourceSavingId: Value(taskVO.sourceSavingId),
      targetSavingId: Value(taskVO.targetSavingId),
      payeeId: Value(taskVO.payeeId),
      note: Value(taskVO.note),
      paymentReference: Value(taskVO.paymentReference),
    );

    await commitmentTaskRepo.updatePart(
      tableCompanion: companion,
      id: taskVO.commitmentTaskId!,
    );
  }

  @override
  Future<void> deleteCommitmentTask(CommitmentTaskVO taskVO) async {
    if (taskVO.commitmentTaskId == null) return;

    await SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCommitmentTaskRepository()
        .deleteById(id: taskVO.commitmentTaskId!);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Maps a saving table type string to a [CommitmentDetailType].
  /// Falls back to [CommitmentDetailType.monthly] when unrecognised.
  CommitmentDetailType _commitmentDetailTypeFromSavingType(String? value) {
    if (value == null) return CommitmentDetailType.monthly;
    return CommitmentDetailType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CommitmentDetailType.monthly,
    );
  }

  /// Validates type-specific field requirements before any DB write.
  /// Mirrors the rules documented in the schema design doc.
  void _validateTaskVO(CommitmentTaskVO taskVO) {
    switch (taskVO.type) {
      case CommitmentTaskType.internalTransfer:
        if (taskVO.sourceSavingId == null) {
          throw Exception(
            'sourceSavingId is required for an internal transfer.',
          );
        }
        if (taskVO.targetSavingId == null) {
          throw Exception(
            'targetSavingId is required for an internal transfer.',
          );
        }
        if (taskVO.sourceSavingId == taskVO.targetSavingId) {
          throw Exception('Source and target savings must be different.');
        }
        break;

      case CommitmentTaskType.thirdPartyPayment:
        if (taskVO.sourceSavingId == null) {
          throw Exception(
            'sourceSavingId is required for a third-party payment.',
          );
        }
        if (taskVO.payeeId == null) {
          throw Exception('payeeId is required for a third-party payment.');
        }
        break;

      case CommitmentTaskType.cash:
        // No savings required for cash
        break;

      case null:
        throw Exception('Payment type must be set before saving a task.');
    }
  }

  /// Saves a transaction record for a completed commitment task.
  /// Creates debit/credit entries in TransactionTable based on task type.
  Future<void> _saveTransactionForTask(CommitmentTaskVO taskVO) async {
    if (taskVO.amount == null || taskVO.amount! <= 0) return;

    final transactionRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getTransactionRepository();
    final savingService = SingletonUtil.getSingleton<IServiceLocator>()!
        .getSavingService();
    final now = DateTime.now();
    final baseId = 'txn_${now.millisecondsSinceEpoch}';

    // Resolve saving names for display in note
    String? sourceSavingName;
    String? targetSavingName;

    if (taskVO.sourceSavingId != null) {
      final s = await savingService
          .watchSavingById(taskVO.sourceSavingId!)
          .first;
      sourceSavingName = s?.name ?? 'Unknown Account';
    }

    if (taskVO.targetSavingId != null) {
      final s = await savingService
          .watchSavingById(taskVO.targetSavingId!)
          .first;
      targetSavingName = s?.name ?? 'Unknown Account';
    }

    switch (taskVO.type) {
      case CommitmentTaskType.internalTransfer:
        if (taskVO.sourceSavingId == null) return;
        await transactionRepo.saveTransaction(
          TransactionEntity(
            id: baseId,
            title: taskVO.name ?? 'Commitment Transfer',
            amount: taskVO.amount!,
            type: TransactionType.commitment,
            commitmentTaskId: taskVO.commitmentTaskId,
            date: now,
            note:
                taskVO.note ??
                'Transfer from $sourceSavingName to $targetSavingName',
            savingId: taskVO.sourceSavingId!,
            destinationSavingId: taskVO.targetSavingId,
            createdAt: now,
            updatedAt: now,
          ),
        );
        break;

      case CommitmentTaskType.thirdPartyPayment:
        if (taskVO.sourceSavingId == null) return;
        await transactionRepo.saveTransaction(
          TransactionEntity(
            id: baseId,
            title: taskVO.name ?? 'Commitment Payment',
            amount: taskVO.amount!,
            type: TransactionType.commitment,
            commitmentTaskId: taskVO.commitmentTaskId,
            payeeId: taskVO.payeeId,
            date: now,
            note: taskVO.note ?? 'Payment from $sourceSavingName',
            savingId: taskVO.sourceSavingId!,
            destinationSavingId: taskVO.targetSavingId,
            createdAt: now,
            updatedAt: now,
          ),
        );
        break;

      case CommitmentTaskType.cash:
      case null:
        // No transaction record needed
        break;
    }
  }
}
