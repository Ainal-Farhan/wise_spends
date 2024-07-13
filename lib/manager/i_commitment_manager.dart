import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/locator/i_repository_locator.dart';
import 'package:wise_spends/locator/i_service_locator.dart';
import 'package:wise_spends/manager/i_manager.dart';
import 'package:wise_spends/manager/i_startup_manager.dart';
import 'package:wise_spends/repository/expense/i_commitment_detail_repository.dart';
import 'package:wise_spends/repository/expense/i_commitment_repository.dart';
import 'package:wise_spends/service/local/saving/i_saving_service.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_details_vo.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_vo.dart';
import 'package:wise_spends/vo/impl/saving/saving_vo.dart';

abstract class ICommitmentManager extends IManager {
  Future<List<CommitmentVO>> retrieveListOfCommitmentOfCurrentUser() async {
    List<CommitmentVO> commitmentList = [];

    IStartupManager startupManager =
        SingletonUtil.getSingleton<IManagerLocator>()!.getStartupManager();

    ICommitmentRepository commitmentRepo =
        SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getCommitmentRepository();
    ICommitmentDetailRepository commitmentDetailRepo =
        SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getCommitmentDetailRepository();
    ISavingService savingService =
        SingletonUtil.getSingleton<IServiceLocator>()!.getSavingService();

    List<ExpnsCommitment> commitmentTableDataList =
        await commitmentRepo.watchAllByUser(startupManager.currentUser).first;

    for (ExpnsCommitment commitment in commitmentTableDataList) {
      List<ExpnsCommitmentDetail> detailsList =
          await commitmentDetailRepo.watchAllByCommitment(commitment).first;
      CommitmentVO vo = CommitmentVO();
      vo.name = commitment.name;
      vo.description = commitment.description;

      double totalAmount = .0;
      for (ExpnsCommitmentDetail commitmentDetail in detailsList) {
        totalAmount += commitmentDetail.amount;

        SvngSaving? saving = await savingService
            .watchSavingById(commitment.referredSavingId)
            .first;

        CommitmentDetailVO commitmentDetailVO =
            CommitmentDetailVO.fromExpnsCommitmentDetail(
                commitmentDetail, saving);

        vo.commitmentDetailVOList.add(commitmentDetailVO);
      }
      vo.totalAmount = totalAmount;

      SvngSaving? saving = await savingService
          .watchSavingById(commitment.referredSavingId)
          .first;

      if (saving != null) {
        SavingVO savingVO = SavingVO.fromSvngSaving(saving);
        vo.referredSavingVO = savingVO;
      }

      commitmentList.add(vo);
    }

    return commitmentList;
  }
}
