import 'package:dartz/dartz.dart';
import 'package:flutter_skeleton/core/exceptions/error_failures.dart';
import 'package:flutter_skeleton/core/utils/log.dart';

class EnhancedFailureHandler {
  static Future<void> handleFailure<T>({
    required Failure failure,
    required Future<Either<Failure, T>> Function() retryRequest,
    required void Function(T) onSuccess,
    required void Function(String) onError,
    required void Function() setLoading,
    void Function(Map<String, String>)? onFieldErrors,
    int maxRetries = 1,
    Duration retryDelay = const Duration(milliseconds: 500),
  }) async {
    if (failure is ValidationFailure &&
        failure.fieldErrors != null &&
        onFieldErrors != null) {
      onFieldErrors(failure.fieldErrors!);
      onError(failure.message);
      return;
    }
    if (failure is NetworkFailure) {
      setLoading();
      var retryCount = 0;
      Either<Failure, T> retryResult;
      do {
        retryCount++;
        logWarning(
          'Retry attempt $retryCount of $maxRetries for ${failure.runtimeType}',
        );
        try {
          retryResult = await retryRequest();
          if (retryResult.isRight()) {
            retryResult.fold(
              // ignore: inference_failure_on_collection_literal
              (_) => {},
              (result) => onSuccess(result),
            );
            return;
          }
          await Future<void>.delayed(retryDelay * retryCount);
        } catch (e) {
          logError('Error during retry: $e');
          retryResult = Left(
            NetworkFailure(message: 'Error during retry: $e'),
          );
          break;
        }
      } while (retryCount < maxRetries);
      retryResult.fold(
        (retryFailure) => onError(retryFailure.message),
        (result) => onSuccess(result),
      );
    } else {
      onError(failure.message);
    }
  }

  static void handleFailureByType({
    required Failure failure,
    required void Function(Failure) onOtherFailure,
    void Function(NetworkFailure)? onNetworkFailure,
    void Function(ServerFailure)? onServerFailure,
    void Function(AuthFailure)? onAuthFailure,
    void Function(ValidationFailure)? onValidationFailure,
  }) {
    switch (failure) {
      case NetworkFailure():
        (onNetworkFailure ?? onOtherFailure)(failure);
      case ServerFailure():
        (onServerFailure ?? onOtherFailure)(failure);
      case AuthFailure():
        (onAuthFailure ?? onOtherFailure)(failure);
      case ValidationFailure():
        (onValidationFailure ?? onOtherFailure)(failure);
      default:
        onOtherFailure(failure);
    }
  }
}
