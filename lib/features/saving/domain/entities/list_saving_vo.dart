import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/domain/entities/i_vo.dart';
import 'package:wise_spends/features/saving/domain/entities/reserve_vo.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';

class ListSavingVO implements IVO {
  final SvngSaving saving;
  SvngMoneyStorage? moneyStorage;

  /// Optional reservation summary - contains reserved amount and transferable amount
  /// If null, reservation data has not been computed yet
  SavingsReserveSummary? reserveSummary;

  /// Optional category entity - contains icon code point
  CategoryEntity? category;

  ListSavingVO({
    required this.saving,
    this.moneyStorage,
    this.reserveSummary,
    this.category,
  });

  /// Current amount from the saving
  double get currentAmount => saving.currentAmount;

  /// Total reserved amount (from commitments and budget plan allocations)
  double get reservedAmount => reserveSummary?.totalReserved ?? 0.0;

  /// Transferable amount (current amount - reserved amount)
  double get transferableAmount => reserveSummary?.transferableAmount ?? currentAmount;

  /// Whether this saving has any reservations
  bool get hasReservations => reserveSummary?.hasReservations ?? false;

  /// Reserved amount from commitment tasks only
  double get commitmentTaskReserved =>
      reserveSummary?.commitmentTaskReserved ?? 0.0;

  /// Reserved amount from budget plan allocations only
  double get budgetPlanAllocationReserved =>
      reserveSummary?.budgetPlanAllocationReserved ?? 0.0;

  ListSavingVO.fromJson(Map<String, dynamic> json)
      : saving = json['saving'],
        moneyStorage = json['moneyStorage'],
        reserveSummary = json['reserveSummary'] != null
            ? SavingsReserveSummary.fromJson(json['reserveSummary'])
            : null,
        category = null; // Category is loaded separately, not from JSON

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['moneyStorage'] = moneyStorage?.toJson() ?? '';
    data['saving'] = saving.toJson();
    if (reserveSummary != null) {
      data['reserveSummary'] = reserveSummary!.toJson();
    }
    // Category is not serialized
    return data;
  }
}
