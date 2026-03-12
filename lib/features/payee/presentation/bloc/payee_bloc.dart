import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart';
import 'package:wise_spends/features/commitment/data/repositories/i_payee_repository.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';
import 'payee_event.dart';
import 'payee_state.dart';

/// Payee BLoC
class PayeeBloc extends Bloc<PayeeEvent, PayeeState> {
  final IPayeeRepository _repository;

  PayeeBloc(this._repository) : super(const PayeeInitial()) {
    on<LoadPayees>(_onLoadPayees);
    on<LoadPayee>(_onLoadPayee);
    on<SavePayee>(_onSavePayee);
    on<DeletePayee>(_onDeletePayee);
  }

  Future<void> _onLoadPayees(LoadPayees event, Emitter<PayeeState> emit) async {
    emit(const PayeeLoading());
    try {
      final payees = await _repository.findAll();
      emit(PayeesLoaded(payees.map((p) => PayeeVO.fromExpnsPayee(p)).toList()));
    } catch (e) {
      emit(PayeeError(e.toString()));
    }
  }

  Future<void> _onLoadPayee(LoadPayee event, Emitter<PayeeState> emit) async {
    emit(const PayeeLoading());
    try {
      final payee = await _repository.findById(id: event.payeeId);
      if (payee == null) {
        emit(const PayeeError('Payee not found'));
      } else {
        emit(PayeeLoaded(PayeeVO.fromExpnsPayee(payee)));
      }
    } catch (e) {
      emit(PayeeError(e.toString()));
    }
  }

  Future<void> _onSavePayee(SavePayee event, Emitter<PayeeState> emit) async {
    emit(const PayeeLoading());
    try {
      final startupManager = SingletonUtil.getSingleton<IManagerLocator>()!
          .getStartupManager();

      final companion = PayeeTableCompanion.insert(
        id: event.payee.id != null
            ? Value(event.payee.id!)
            : const Value.absent(),
        createdBy: startupManager.currentUser.name,
        dateUpdated: DateTime.now(),
        lastModifiedBy: startupManager.currentUser.name,
        name: event.payee.name ?? '',
        accountNumber: event.payee.accountNumber != null
            ? Value(event.payee.accountNumber!)
            : const Value.absent(),
        bankName: event.payee.bankName != null
            ? Value(event.payee.bankName!)
            : const Value.absent(),
        note: event.payee.note != null
            ? Value(event.payee.note!)
            : const Value.absent(),
      );

      if (event.payee.id != null) {
        await _repository.updatePart(
          tableCompanion: companion,
          id: event.payee.id!,
        );
      } else {
        await _repository.insertOne(companion);
      }

      emit(const PayeeSaved('Payee saved successfully'));
    } catch (e) {
      emit(PayeeError(e.toString()));
    }
  }

  Future<void> _onDeletePayee(
    DeletePayee event,
    Emitter<PayeeState> emit,
  ) async {
    emit(const PayeeLoading());
    try {
      await _repository.deleteById(id: event.payeeId);
      emit(const PayeeDeleted('Payee deleted successfully'));
    } catch (e) {
      emit(PayeeError(e.toString()));
    }
  }
}
