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

      if (vo.taskType == CommitmentTaskType.creditCardCharge &&
          vo.linkedCreditCardId == null) {
        throw Exception(
          'Detail "${vo.description}" is a credit card charge but has no card selected.',
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
        taskType: Value(vo.taskType),
        // Source saving — null only for cash
        savingId: Value(
          vo.taskType == CommitmentTaskType.cash ? null : resolvedSourceSavingId,
        ),
        targetSavingId: Value(
          vo.taskType == CommitmentTaskType.internalTransfer
              ? vo.targetSavingId
              : null,
        ),
        payeeId: Value(
          vo.taskType == CommitmentTaskType.thirdPartyPayment
              ? vo.payeeId
              : null,
        ),
        // CC / EPP fields
        linkedCreditCardId: Value(
          vo.taskType == CommitmentTaskType.creditCardCharge
              ? vo.linkedCreditCardId
              : null,
        ),
        eppTotalInstallments: Value(
          vo.taskType == CommitmentTaskType.creditCardCharge
              ? vo.eppTotalInstallments
              : null,
        ),
        eppCompletedInstallments: Value(vo.eppCompletedInstallments),
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
    final cardRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCreditCardRepository();
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

      final vo = CommitmentDetailVO.fromExpnsCommitmentDetail(
        detail,
        saving: sourceSaving,
        targetSaving: targetSaving,
        payee: payee,
      );

      // Hydrate CC name for display
      if (detail.linkedCreditCardId != null) {
        final card = await cardRepo.getCardById(detail.linkedCreditCardId!);
        if (card != null) {
          vo.linkedCreditCardName = card.lastFourDigits != null
              ? '${card.name} •••• ${card.lastFourDigits}'
              : card.name;
        }
      }

      detailVOs.add(vo);
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
    bool isDone, {
    int? limit,
    int? offset,
  }) async {
    final commitmentTaskRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCommitmentTaskRepository();
    final savingService = SingletonUtil.getSingleton<IServiceLocator>()!
        .getSavingService();

    // Get paginated tasks from repository
    final List<ExpnsCommitmentTask> tasks;
    if (limit != null && offset != null) {
      // Use watchAll with pagination - need to implement in repository
      // For now, fetch all and apply pagination in memory
      final allTasks = await commitmentTaskRepo.watchAll(isDone).first;
      final endIndex = offset + limit > allTasks.length 
          ? allTasks.length 
          : offset + limit;
      tasks = offset >= allTasks.length 
          ? [] 
          : allTasks.sublist(offset, endIndex);
    } else {
      tasks = await commitmentTaskRepo.watchAll(isDone).first;
    }

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
    // Only cash has no savings impact. CC charges deduct from source saving.
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
            ),
          );
          break;

        // ── Credit card charge (EPP / infinite) ────────────────────────────
        case CommitmentTaskType.creditCardCharge:
          final String? cardId = detail.linkedCreditCardId;
          if (cardId == null) continue;

          // EPP limit: skip if all installments are already done.
          if (detail.isEppComplete) continue;

          final String? sourceSavingId =
              detail.savingId ?? vo.referredSavingVO?.savingId;

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
              type: CommitmentTaskType.creditCardCharge,
              sourceSavingId: Value(sourceSavingId),
              // note carries the credit card ID for lookup at completion time.
              note: Value(cardId),
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
      final now = DateTime.now();
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

        case CommitmentTaskType.creditCardCharge:
          // The credit card ID was stored in the task's note field at distribute time.
          final cardId = taskVO.note;
          if (cardId != null && cardId.isNotEmpty) {
            final chargeRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
                .getCreditCardChargeRepository();
            // Post the charge and link the source saving as the reserved saving.
            // This means the amount stays reserved in the saving account until
            // the CC bill is paid — it is NOT immediately deducted.
            await chargeRepo.addCharge(
              creditCardId: cardId,
              description: taskVO.name ?? 'Commitment Charge',
              amount: taskVO.amount ?? 0.0,
              chargeDate: now,
              status: 'posted',
              reservedSavingId: taskVO.sourceSavingId,
            );
          }
          // Do NOT call updateSavingCurrentAmount here.
          // The saving is already shown as "reserved" (via pending commitment task).
          // Once the charge is posted above, _loadCreditCardChargeReservations
          // picks it up as a reservation instead, keeping the reserved amount
          // intact until the CC bill is paid.
          //
          // Increment eppCompletedInstallments on the detail.
          if (taskVO.commitmentDetailId != null) {
            await _incrementEppInstallment(taskVO.commitmentDetailId!);
          }
          break;

        case null:
          break;
      }

      ExpnsCommitmentTask expnsCommitmentTask =
          (await SingletonUtil.getSingleton<IRepositoryLocator>()!
              .getCommitmentTaskRepository()
              .findById(id: taskVO.commitmentTaskId!))!;

      expnsCommitmentTask = expnsCommitmentTask.copyWith(
        dateUpdated: DateTime.now(),
        isDone: true,
      );

      await SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getCommitmentTaskRepository()
          .update(expnsCommitmentTask);
    }
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

  /// Increments [eppCompletedInstallments] on the commitment detail row.
  Future<void> _incrementEppInstallment(String commitmentDetailId) async {
    final repo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCommitmentDetailRepository();
    final detail = await repo.findById(id: commitmentDetailId);
    if (detail == null) return;
    final updated = detail.copyWith(
      eppCompletedInstallments: detail.eppCompletedInstallments + 1,
      dateUpdated: DateTime.now(),
    );
    await repo.update(updated);
  }

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

      case CommitmentTaskType.creditCardCharge:
        // Validation handled separately; note carries the card ID.
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
      case CommitmentTaskType.creditCardCharge:
      case null:
        break;
    }
  }
}
