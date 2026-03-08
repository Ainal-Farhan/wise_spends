import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_table.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_deposit_table.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_spending_table.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_linked_account_table.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_milestone_table.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_item_table.dart';
import 'package:wise_spends/data/db/domain/savings_plan/savings_plan_item_tag_table.dart';

export './savings_plan_table.dart';
export './savings_plan_deposit_table.dart';
export './savings_plan_spending_table.dart';
export './savings_plan_linked_account_table.dart';
export './savings_plan_milestone_table.dart';
export './savings_plan_item_table.dart';
export './savings_plan_item_tag_table.dart';

abstract class SavingsPlan {
  static const List<dynamic> tableList = [
    SavingsPlanTable,
    SavingsPlanDepositTable,
    SavingsPlanSpendingTable,
    SavingsPlanLinkedAccountTable,
    SavingsPlanMilestoneTable,
    SavingsPlanItemTable,
    SavingsPlanItemTagTable,
  ];
}
