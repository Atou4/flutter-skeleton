import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_skeleton/core/exceptions/error_failures.dart';
import 'package:flutter_skeleton/core/network/error_handler.dart';
import 'package:flutter_skeleton/core/services/crashlytics/crashlytics_service.dart';
import 'package:flutter_skeleton/core/utils/log.dart';

class RepositoryHelper {
  static Future<Either<Failure, T>> executeRequest<T>({
    required Future<T> Function() request,
    required CrashlyticsService crashlyticsService,
    String? context,
    Failure Function(ErrorHandler error)? errorMapper,
  }) async {
    try {
      final result = await request();
      return Right(result);
    } on DioException catch (dioError) {
      final error = ErrorHandler.fromDioException(dioError);
      final operation = context ?? 'unknown_operation';
      logError('$operation error: ${error.message}');
      final statusCode = dioError.response?.statusCode;
      if (statusCode != 401 && statusCode != 404) {
        unawaited(_setErrorContext(crashlyticsService, dioError, operation));
        unawaited(
          crashlyticsService.recordException(
            dioError,
            dioError.stackTrace,
            reason: 'RepositoryRequest-$operation',
          ),
        );
      }
      return Left(
        errorMapper?.call(error) ?? _mapErrorHandlerToFailure(error),
      );
    } catch (e, st) {
      final error = ErrorHandler(e);
      final operation = context ?? 'unknown_operation';
      logError('$operation unexpected error: ${error.message}');
      await crashlyticsService.recordException(
        e,
        st,
        reason: 'Unexpected error in $operation',
      );
      return Left(_mapErrorHandlerToFailure(error));
    }
  }

  static Future<void> _setErrorContext(
    CrashlyticsService crashlyticsService,
    DioException dioError,
    String operation,
  ) async {
    final error = ErrorHandler.fromDioException(dioError);
    await Future.wait([
      crashlyticsService.setCustomKey('operation', operation),
      crashlyticsService.setCustomKey('error_type', error.type.toString()),
      crashlyticsService.setCustomKey(
        'request_params',
        dioError.requestOptions.data?.toString() ?? 'null',
      ),
      crashlyticsService.setCustomKey(
        'status_code',
        dioError.response?.statusCode?.toString() ?? 'unknown',
      ),
      crashlyticsService.setCustomKey(
        'request_url',
        dioError.requestOptions.uri.toString(),
      ),
      crashlyticsService.setCustomKey(
        'response_body',
        dioError.response?.data?.toString() ?? 'null',
      ),
    ]);
  }

  static Failure _mapErrorHandlerToFailure(ErrorHandler error) {
    return switch (error.type) {
      AppErrorType.networkError || AppErrorType.connectionTimeout => NetworkFailure(
          message: error.message,
          errorType: error.type,
          errorCode: error.type.toString(),
          originalError: error.originalError,
        ),
      AppErrorType.invalidCredentials ||
      AppErrorType.invalidOtp ||
      AppErrorType.invalidRefreshToken ||
      AppErrorType.forbidden =>
        AuthFailure(
          message: error.message,
          type: error.type,
          errorCode: error.type.toString(),
          originalError: error.originalError,
        ),
      AppErrorType.validationError => ValidationFailure(
          message: error.message,
          fieldErrors: error.fieldErrors,
          errorType: error.type,
          errorCode: error.type.toString(),
          originalError: error.originalError,
        ),
      AppErrorType.notFound || AppErrorType.serverError => ServerFailure(
          message: error.message,
          errorType: error.type,
          errorCode: error.type.toString(),
          originalError: error.originalError,
        ),
      _ => ServerFailure(
          message: error.message,
          errorType: error.type,
          errorCode: error.type.toString(),
          originalError: error.originalError,
        ),
    };
  }

  static Future<Either<Failure, T>> executeRequestWithTimeout<T>({
    required Future<T> Function() request,
    required CrashlyticsService crashlyticsService,
    String? context,
    Duration timeout = const Duration(seconds: 30),
    Failure Function(ErrorHandler error)? errorMapper,
  }) async {
    try {
      final result = await request().timeout(
        timeout,
        onTimeout: () => throw TimeoutException(timeout.inMilliseconds),
      );
      return Right(result);
    } catch (e) {
      final contextMsg = context != null ? '[$context]' : '';
      logError('$contextMsg Request timed out: $e');
      if (e is TimeoutException) {
        return Left(
          NetworkFailure(
            message: 'Request timed out after ${e.timeoutMilliseconds}ms',
            errorType: AppErrorType.connectionTimeout,
            errorCode: 'REQUEST_TIMEOUT',
            originalError: e,
          ),
        );
      }
      return executeRequest(
        // ignore: only_throw_errors
        request: () async => throw e,
        context: context,
        errorMapper: errorMapper,
        crashlyticsService: crashlyticsService,
      );
    }
  }
}

class TimeoutException implements Exception {
  TimeoutException(this.timeoutMilliseconds);
  final int timeoutMilliseconds;

  @override
  String toString() =>
      'TimeoutException: Request timed out after $timeoutMilliseconds milliseconds';
}
