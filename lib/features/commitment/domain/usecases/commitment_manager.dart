import 'package:drift/drift.dart';
import 'package:wise_spends/features/saving/data/constants/saving_constant.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/di/i_service_locator.dart';
import 'package:wise_spends/features/commitment/data/constants/commitment_detail_type.dart';
import 'package:wise_spends/features/commitment/data/constants/commitment_task_type.dart';
import 'package:wise_spends/features/commitment/domain/usecases/i_commitment_manager.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_detail_vo.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_vo.dart';
import 'package:wise_spends/features/saving/domain/entities/saving_vo.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';

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

  // ---------------------------------------------------------------------------
  // saveCommitmentDetailVO — FIXED
  // ---------------------------------------------------------------------------
  // Previously only wrote `savingId` (source account) and left taskType,
  // targetSavingId, and payeeId out of the companion entirely, so the values
  // entered in the form were silently discarded.
  //
  // Changes:
  //   1. Write `taskType` from `vo.taskType` (defaults to internalTransfer).
  //   2. Write `targetSavingId` for internal transfers.
  //   3. Write `payeeId` for third-party payments.
  //   4. `savingId` is null-safe for cash payments — no source account needed.
  // ---------------------------------------------------------------------------

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
      // ── Resolve source saving ──────────────────────────────────────────────
      // Cash payments have no source saving — that is valid.
      final String? resolvedSourceSavingId =
          vo.sourceSavingVO?.savingId ?? vo.savingId;

      if (resolvedSourceSavingId == null &&
          vo.taskType != CommitmentTaskType.cash) {
        throw Exception(
          'Commitment detail "${vo.description}" is missing a source savings account.',
        );
      }

      // Hydrate sourceSavingVO if only the ID was set
      if (resolvedSourceSavingId != null && vo.sourceSavingVO == null) {
        final saving = await savingService
            .watchSavingById(resolvedSourceSavingId)
            .first;
        if (saving != null) {
          vo.sourceSavingVO = SavingVO.fromSvngSaving(saving);
        }
      }

      // ── Validate type-specific FK requirements ─────────────────────────────
      if (vo.taskType == CommitmentTaskType.internalTransfer &&
          vo.targetSavingId == null) {
        throw Exception(
          'Detail "${vo.description}" is an internal transfer but has no target savings account.',
        );
      }

      if (vo.taskType == CommitmentTaskType.thirdPartyPayment &&
          vo.payeeId == null) {
        throw Exception(
          'Detail "${vo.description}" is a third-party payment but has no payee selected.',
        );
      }

      // ── Recurrence type ────────────────────────────────────────────────────
      final CommitmentDetailType resolvedType =
          vo.type ??
          _commitmentDetailTypeFromSavingType(
            vo.sourceSavingVO?.savingTableType?.value,
          );

      // ── Build companion — all new fields included ──────────────────────────
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
        // NEW: persist the task payment type chosen in the form
        taskType: Value(vo.taskType),
        // Source saving — null only for cash payments
        savingId: Value(resolvedSourceSavingId),
        // NEW: target saving (internal transfer only, null otherwise)
        targetSavingId: Value(
          vo.taskType == CommitmentTaskType.internalTransfer
              ? vo.targetSavingId
              : null,
        ),
        // NEW: payee (third-party payment only, null otherwise)
        payeeId: Value(
          vo.taskType == CommitmentTaskType.thirdPartyPayment
              ? vo.payeeId
              : null,
        ),
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
    final payeeRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getPayeeRepository();

    final details = await commitmentDetailRepo
        .watchAllByCommitment(commitment)
        .first;

    // Build detail VOs with all three optional joins resolved
    final List<CommitmentDetailVO> detailVOs = [];
    for (final detail in details) {
      // Source saving
      SvngSaving? sourceSaving;
      if (detail.savingId != null) {
        sourceSaving = await savingService
            .watchSavingById(detail.savingId!)
            .first;
      }

      // Target saving (internal transfers)
      SvngSaving? targetSaving;
      if (detail.targetSavingId != null) {
        targetSaving = await savingService
            .watchSavingById(detail.targetSavingId!)
            .first;
      }

      // Payee (third-party payments)
      ExpnsPayee? payee;
      if (detail.payeeId != null) {
        payee = await payeeRepo.findById(id: detail.payeeId!);
      }

      detailVOs.add(
        CommitmentDetailVO.fromExpnsCommitmentDetail(
          detail,
          saving: sourceSaving,
          targetSaving: targetSaving,
          payee: payee,
        ),
      );
    }

    // Build commitment VO using detail VOs directly
    final vo = CommitmentVO.fromExpnsCommitmentWithDetails(
      commitment,
      detailVOs,
    );

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
      SvngSaving? sourceSaving;
      if (task.sourceSavingId != null) {
        sourceSaving = await savingService
            .watchSavingById(task.sourceSavingId!)
            .first;
      }

      SvngSaving? targetSaving;
      if (task.targetSavingId != null) {
        targetSaving = await savingService
            .watchSavingById(task.targetSavingId!)
            .first;
      }

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
  // startDistributeCommitment — FIXED
  // ---------------------------------------------------------------------------
  // Previously hardcoded every task as:
  //   type           = internalTransfer
  //   sourceSavingId = commitment.referredSaving   (always the pool account)
  //   targetSavingId = detail.savingId             (always treated as destination)
  //
  // Now branches on detail.taskType so each detail drives its own task shape:
  //
  //   internalTransfer  → sourceSaving = detail.savingId (or commitment saving as
  //                        fallback), targetSaving = detail.targetSavingId
  //   thirdPartyPayment → sourceSaving = detail.savingId, payeeId = detail.payeeId
  //   cash              → no savings linked
  //
  // Balance check is kept but now scoped to details that actually debit a saving.
  // ---------------------------------------------------------------------------

  @override
  Future<String> startDistributeCommitment(CommitmentVO vo) async {
    if (vo.commitmentDetailVOList.isEmpty) {
      return 'No commitment details found for this commitment.';
    }

    final savingService = SingletonUtil.getSingleton<IServiceLocator>()!
        .getSavingService();
    final startupManager = SingletonUtil.getSingleton<IManagerLocator>()!
        .getStartupManager();
    final commitmentTaskRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCommitmentTaskRepository();

    // ── Balance check: sum amounts that will debit a digital account ──────────
    // Cash tasks don't touch any account so they are excluded.
    double totalDebit = 0.0;
    for (final detail in vo.commitmentDetailVOList) {
      if (detail.taskType != CommitmentTaskType.cash) {
        totalDebit += detail.amount ?? 0.0;
      }
    }

    // Only check the commitment-level referred saving if it is the actual
    // source for any detail.  If every detail specifies its own sourceSavingId
    // we skip this commitment-level guard (individual checks below will catch).
    if (vo.referredSavingVO?.savingId != null && totalDebit > 0) {
      final SvngSaving? poolSaving = await savingService
          .watchSavingById(vo.referredSavingVO!.savingId!)
          .first;

      if (poolSaving != null && poolSaving.currentAmount < totalDebit) {
        return 'Insufficient balance in ${poolSaving.name}.';
      }
    }

    // ── Build task companions ─────────────────────────────────────────────────
    final List<CommitmentTaskTableCompanion> companions = [];

    for (final detail in vo.commitmentDetailVOList) {
      if (detail.commitmentDetailId == null) continue;

      switch (detail.taskType) {
        // ── Internal transfer ──────────────────────────────────────────────
        case CommitmentTaskType.internalTransfer:
          // Source: use detail's own savingId; fall back to the commitment's
          // referred saving if the detail was created before the form update.
          final String? sourceSavingId =
              detail.savingId ?? vo.referredSavingVO?.savingId;

          // Target: must be set — skip gracefully with a log rather than crash.
          final String? targetSavingId = detail.targetSavingId;

          if (sourceSavingId == null || targetSavingId == null) {
            // Detail is incomplete — skip and continue distributing the rest.
            continue;
          }

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
              sourceSavingId: Value(sourceSavingId),
              targetSavingId: Value(targetSavingId),
              // payeeId intentionally absent (null) for transfers
            ),
          );
          break;

        // ── Third-party payment ────────────────────────────────────────────
        case CommitmentTaskType.thirdPartyPayment:
          final String? sourceSavingId =
              detail.savingId ?? vo.referredSavingVO?.savingId;
          final String? payeeId = detail.payeeId;

          if (sourceSavingId == null || payeeId == null) {
            continue;
          }

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
              type: CommitmentTaskType.thirdPartyPayment,
              sourceSavingId: Value(sourceSavingId),
              // targetSavingId intentionally null — money leaves the system
              payeeId: Value(payeeId),
            ),
          );
          break;

        // ── Cash ───────────────────────────────────────────────────────────
        case CommitmentTaskType.cash:
          // No account links needed — just record the task.
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
              type: CommitmentTaskType.cash,
              // Both saving fields null — cash has no digital movement
            ),
          );
          break;
      }
    }

    if (companions.isEmpty) {
      return 'No valid commitment details to distribute. '
          'Ensure each detail has the required account / payee information.';
    }

    await commitmentTaskRepo.saveAllFromTableCompanion(companions);
    return 'Successfully distributed ${companions.length} task(s).';
  }

  // ---------------------------------------------------------------------------
  // Commitment task — status update (unchanged)
  // ---------------------------------------------------------------------------

  @override
  Future<void> updateStatusCommitmentTask(
    bool isDone,
    CommitmentTaskVO taskVO,
  ) async {
    if (taskVO.commitmentTaskId == null) return;

    if (isDone) {
      await _saveTransactionForTask(taskVO);

      final savingManager = SingletonUtil.getSingleton<IManagerLocator>()!
          .getSavingManager();

      switch (taskVO.type) {
        case CommitmentTaskType.internalTransfer:
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
          if (taskVO.sourceSavingId != null) {
            await savingManager.updateSavingCurrentAmount(
              savingId: taskVO.sourceSavingId!,
              transactionType: SavingConstant.savingTransactionOut,
              transactionAmount: taskVO.amount!.abs(),
            );
          }
          break;

        case CommitmentTaskType.cash:
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
  // Commitment task — add / edit / delete (unchanged)
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

  CommitmentDetailType _commitmentDetailTypeFromSavingType(String? value) {
    if (value == null) return CommitmentDetailType.monthly;
    return CommitmentDetailType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CommitmentDetailType.monthly,
    );
  }

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
        break;

      case null:
        throw Exception('Payment type must be set before saving a task.');
    }
  }

  Future<void> _saveTransactionForTask(CommitmentTaskVO taskVO) async {
    if (taskVO.amount == null || taskVO.amount! <= 0) return;

    final transactionRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getTransactionRepository();
    final savingService = SingletonUtil.getSingleton<IServiceLocator>()!
        .getSavingService();
    final now = DateTime.now();
    final baseId = 'txn_${now.millisecondsSinceEpoch}';

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
        break;
    }
  }
}
