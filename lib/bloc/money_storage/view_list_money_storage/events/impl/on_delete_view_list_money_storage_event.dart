import 'package:wise_spends/bloc/money_storage/view_list_money_storage/events/view_list_money_storage_event.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/state/impl/success_process_view_list_money_storage_state.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/state/impl/un_view_list_money_storage_state.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/view_list_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/state/view_list_money_storage_state.dart';
import 'package:wise_spends/router/app_router.dart';

class OnDeleteViewListMoneyStorageEvent extends ViewListMoneyStorageEvent {
  final String selectedMoneyStorageId;

  OnDeleteViewListMoneyStorageEvent(this.selectedMoneyStorageId);

  @override
  Stream<ViewListMoneyStorageState> applyAsync({
    ViewListMoneyStorageState? currentState,
    ViewListMoneyStorageBloc? bloc,
  }) async* {
    yield const UnViewListMoneyStorageState(version: 0);
    await savingManager.deleteSelectedMoneyStorage(selectedMoneyStorageId);
    yield const SuccessProcessViewListMoneyStorageState(
      version: 0,
      message: 'Successfully Delete Selected Money Storage',
      nextPageRoute: AppRouter.viewListMoneyStoragePageRoute,
    );
  }
}
