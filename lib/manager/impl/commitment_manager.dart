import 'package:drift/drift.dart';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/locator/i_repository_locator.dart';
import 'package:wise_spends/locator/i_service_locator.dart';
import 'package:wise_spends/manager/i_commitment_manager.dart';
import 'package:wise_spends/manager/i_startup_manager.dart';
import 'package:wise_spends/repository/expense/i_commitment_detail_repository.dart';
import 'package:wise_spends/repository/expense/i_commitment_repository.dart';
import 'package:wise_spends/service/local/saving/i_saving_service.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_detail_vo.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_vo.dart';
import 'package:wise_spends/vo/impl/saving/saving_vo.dart';

class CommitmentManager extends ICommitmentManager {
  @override
  Future<List<CommitmentVO>> retrieveListOfCommitmentOfCurrentUser() async {
    List<CommitmentVO> commitmentList = [];

    IStartupManager startupManager =
        SingletonUtil.getSingleton<IManagerLocator>()!.getStartupManager();

    ICommitmentRepository commitmentRepo =
        SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getCommitmentRepository();

    List<ExpnsCommitment> commitmentTableDataList =
        await commitmentRepo.watchAllByUser(startupManager.currentUser).first;

    for (ExpnsCommitment commitment in commitmentTableDataList) {
      commitmentList
          .add((await retrieveCommitmentVOBasedOnCommitmentId(commitment.id))!);
    }

    return commitmentList;
  }

  @override
  Future<void> saveCommitmentVO(CommitmentVO commitmentVO) async {
    final IStartupManager startupManager =
        SingletonUtil.getSingleton<IManagerLocator>()!.getStartupManager();

    ICommitmentRepository commitmentRepo =
        SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getCommitmentRepository();

    CommitmentTableCompanion commitmentTableCompanion =
        CommitmentTableCompanion.insert(
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
      referredSavingId: commitmentVO.referredSavingVO!.savingId!,
      userId: startupManager.currentUser.id,
    );

    String commitmentId = '';
    if (commitmentVO.commitmentId != null) {
      commitmentId = commitmentVO.commitmentId!;
      await commitmentRepo.updatePart(
          tableCompanion: commitmentTableCompanion,
          id: commitmentVO.commitmentId!);
    } else {
      ExpnsCommitment commitment =
          await commitmentRepo.save(commitmentTableCompanion);
      commitmentId = commitment.id;
    }

    await saveCommitmentDetailVO(
        commitmentId, commitmentVO.commitmentDetailVOList);
  }

  @override
  Future<void> saveCommitmentDetailVO(String commitmentId,
      List<CommitmentDetailVO> commitmentDetailVOList) async {
    if (commitmentDetailVOList.isEmpty) {
      return;
    }

    final IStartupManager startupManager =
        SingletonUtil.getSingleton<IManagerLocator>()!.getStartupManager();

    ICommitmentDetailRepository commitmentDetailRepo =
        SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getCommitmentDetailRepository();

    for (CommitmentDetailVO vo in commitmentDetailVOList) {
      CommitmentDetailTableCompanion tableCompanion =
          CommitmentDetailTableCompanion.insert(
        id: vo.commitmentDetailId == null
            ? const Value.absent()
            : Value(vo.commitmentDetailId!),
        createdBy: startupManager.currentUser.name,
        dateUpdated: DateTime.now(),
        lastModifiedBy: startupManager.currentUser.name,
        amount: vo.amount ?? .0,
        description: vo.description ?? '-',
        type: vo.type ?? vo.referredSavingVO!.savingTableType!.value,
        savingId: vo.referredSavingVO!.savingId!,
        commitmentId: commitmentId,
      );

      if (vo.commitmentDetailId != null) {
        await commitmentDetailRepo.updatePart(
            tableCompanion: tableCompanion, id: vo.commitmentDetailId!);
      } else {
        commitmentDetailRepo.save(tableCompanion);
      }
    }
  }

  @override
  Future<void> deleteCommitmentVO(String commitmentId) async {
    ICommitmentRepository commitmentRepo =
        SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getCommitmentRepository();

    ExpnsCommitment? commitment =
        await commitmentRepo.findById(id: commitmentId);

    if (commitment == null) {
      return;
    }

    ICommitmentDetailRepository commitmentDetailRepo =
        SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getCommitmentDetailRepository();

    await commitmentDetailRepo.deleteByCommitmentId(commitment.id);
    await commitmentRepo.delete(commitment);
  }

  @override
  Future<void> deleteCommitmentDetailVO(String commitmentDetailId) async {
    ICommitmentDetailRepository commitmentDetailRepo =
        SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getCommitmentDetailRepository();

    await commitmentDetailRepo.deleteById(id: commitmentDetailId);
  }

  @override
  Future<CommitmentVO?> retrieveCommitmentVOBasedOnCommitmentId(
      String commitmentId) async {
    ICommitmentRepository commitmentRepo =
        SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getCommitmentRepository();
    ExpnsCommitment? commitment =
        await commitmentRepo.findById(id: commitmentId);

    if (commitment == null) {
      return null;
    }

    ICommitmentDetailRepository commitmentDetailRepo =
        SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getCommitmentDetailRepository();
    ISavingService savingService =
        SingletonUtil.getSingleton<IServiceLocator>()!.getSavingService();

    List<ExpnsCommitmentDetail> detailsList =
        await commitmentDetailRepo.watchAllByCommitment(commitment).first;
    Map<ExpnsCommitmentDetail, SvngSaving> commitmentDetailMap = {};
    for (ExpnsCommitmentDetail commitmentDetail in detailsList) {
      SvngSaving? saving =
          await savingService.watchSavingById(commitmentDetail.savingId).first;

      if (saving == null) {
        continue;
      }

      commitmentDetailMap[commitmentDetail] = saving;
    }

    CommitmentVO vo =
        CommitmentVO.fromExpnsCommitment(commitment, commitmentDetailMap);

    SvngSaving? saving =
        await savingService.watchSavingById(commitment.referredSavingId).first;

    if (saving != null) {
      SavingVO savingVO = SavingVO.fromSvngSaving(saving);
      vo.referredSavingVO = savingVO;
    }

    return vo;
  }
}
