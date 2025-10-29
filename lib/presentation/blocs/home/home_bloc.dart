import 'package:bloc/bloc.dart';
import 'package:wise_spends/data/repositories/saving/i_saving_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ISavingRepository _repository;

  HomeBloc(this._repository) : super(HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<LoadTransactionFormEvent>(_onLoadTransactionForm);
    on<MakeTransactionEvent>(_onMakeTransaction);
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final dailyUsageSavings = await _repository.getDailyUsageSavings();
      final creditSavings = await _repository.getCreditSavings();
      emit(
        HomeLoaded(
          dailyUsageSavings: dailyUsageSavings,
          creditSavings: creditSavings,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onLoadTransactionForm(
    LoadTransactionFormEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final allSavings = await _repository.getAllSavings();
      emit(TransactionFormLoaded(allSavings: allSavings));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onMakeTransaction(
    MakeTransactionEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      await _repository.makeTransaction(
        sourceSavingId: event.sourceSavingId,
        destinationSavingId: event.destinationSavingId,
        amount: event.amount,
        transactionType: event.transactionType,
        reference: event.reference,
      );
      emit(TransactionSuccess('Transaction completed successfully'));
      // Reload data after transaction
      add(LoadHomeDataEvent());
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
