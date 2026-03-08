import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton/core/exceptions/app_exception.dart';
import 'package:flutter_skeleton/core/utils/log.dart';

abstract class BaseCubit<T> extends Cubit<T> {
  BaseCubit(super.initialState);

  String get tag => runtimeType.toString();

  @override
  void emit(T state) {
    if (!isClosed) {
      logInfo('$tag: emitting state: ${state.runtimeType}');
      super.emit(state);
    }
  }

  Future<void> safeEmit(Future<void> Function() call) async {
    try {
      await call();
    } catch (e) {
      logError('$tag: error: $e');
      handleError(e);
    }
  }

  void handleError(Object error) {
    final message =
        error is AppException ? error.message : error.toString();
    final errorState = createErrorState(message);
    if (errorState != null) {
      emit(errorState);
    }
  }

  T? createErrorState(String message) => null;

  Future<void> handleRepositoryCall<R>({
    required Future<R> Function() call,
    required void Function(R result) onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      logInfo('$tag: making repository call');
      final result = await call();
      logInfo('$tag: repository call successful');
      onSuccess(result);
    } catch (e) {
      final message = e is AppException ? e.message : e.toString();
      logError('$tag: repository call failed: $message');
      if (onError != null) {
        onError(message);
      } else {
        handleError(e);
      }
    }
  }

  void handleEither<L extends AppException, R>({
    required Either<L, R> either,
    required void Function(R result) onSuccess,
    void Function(String message)? onError,
  }) {
    either.fold(
      (failure) {
        final message = failure.message;
        logError('$tag: failure: $message');
        if (onError != null) {
          onError(message);
        } else {
          handleError(failure);
        }
      },
      (success) {
        logSuccess('$tag: success');
        onSuccess(success);
      },
    );
  }
}
