import 'package:bloc/bloc.dart';
import 'package:wise_spends/features/lending/data/repositories/i_lending_repository.dart';
import 'lending_list_event.dart';
import 'lending_list_state.dart';

class LendingListBloc extends Bloc<LendingListEvent, LendingListState> {
  final ILendingRepository _repository;

  LendingListBloc(this._repository) : super(LendingListLoading()) {
    on<LoadLendingsEvent>(_onLoad);
    on<AddLendingEvent>(_onAdd);
    on<DeleteLendingEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadLendingsEvent event,
    Emitter<LendingListState> emit,
  ) async {
    emit(LendingListLoading());
    try {
      final lendings = await _repository.getAllLendings();
      final summaries = await Future.wait(
        lendings.map((l) async {
          final outstanding = await _repository.getOutstandingAmount(l.id);
          return LendingSummary(lending: l, outstanding: outstanding);
        }),
      );
      emit(LendingListLoaded(summaries));
    } catch (e) {
      emit(LendingError(e.toString()));
    }
  }

  Future<void> _onAdd(
    AddLendingEvent event,
    Emitter<LendingListState> emit,
  ) async {
    try {
      await _repository.addLending(
        borrowerName: event.borrowerName,
        principalAmount: event.principalAmount,
        lendingDate: event.lendingDate,
        dueDate: event.dueDate,
        sourceSavingId: event.sourceSavingId,
        note: event.note,
        noAutoDeduct: event.noAutoDeduct,
      );
      add(LoadLendingsEvent());
    } catch (e) {
      emit(LendingError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteLendingEvent event,
    Emitter<LendingListState> emit,
  ) async {
    try {
      await _repository.deleteLending(event.id);
      add(LoadLendingsEvent());
    } catch (e) {
      emit(LendingError(e.toString()));
    }
  }
}
