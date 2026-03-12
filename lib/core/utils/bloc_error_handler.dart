import 'package:wise_spends/core/logger/wise_logger.dart';

/// Typedef for emit function in BLoCs
typedef EmitFunction<S> = void Function(S state);

/// Generic error handler for BLoC operations
///
/// Wraps async operations with standardized try/catch logic:
/// - Logs errors with context for debugging
/// - Emits error state to update UI
/// - Prevents duplicate error handling code across BLoCs
///
/// Example usage:
/// ```dart
/// Future<void> _onLoadData(LoadDataEvent event, Emitter<State> emit) async {
///   emit(const StateLoading());
///   await handleBlocError(
///     context: 'LoadData',
///     operation: () async {
///       final result = await _repository.getData();
///       emit(StateLoaded(data: result));
///     },
///     emit: emit,
///     onError: (msg) => StateError(msg),
///   );
/// }
/// ```
Future<void> handleBlocError<S>({
  required Future<void> Function() operation,
  required EmitFunction<S> emit,
  required S Function(String message) onError,
  String context = '',
}) async {
  try {
    await operation();
  } catch (e, stackTrace) {
    WiseLogger().debug(
      '[BLoC Error][$context] $e',
      tag: 'BlocErrorHandler',
      error: e,
      stackTrace: stackTrace,
    );
    emit(onError(e.toString()));
  }
}
