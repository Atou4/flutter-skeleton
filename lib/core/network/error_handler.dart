// ignore_for_file: cascade_invocations

import 'dart:io';
import 'package:dio/dio.dart';

enum AppErrorType {
  invalidCredentials,
  invalidOtp,
  phoneNotFound,
  emailNotFound,
  emailAlreadyExists,
  passwordMismatch,
  invalidRefreshToken,
  networkError,
  connectionTimeout,
  serverError,
  notFound,
  forbidden,
  validationError,
  unknown,
}

class ErrorHandler implements Exception {
  factory ErrorHandler(dynamic error) {
    if (error is DioException) {
      return ErrorHandler.fromDioException(error);
    } else if (error is SocketException) {
      return const ErrorHandler._(
        message: _networkErrorMessage,
        type: AppErrorType.networkError,
      );
    } else if (error is FormatException) {
      return const ErrorHandler._(
        message: 'Data format error',
        type: AppErrorType.unknown,
      );
    } else if (error is ErrorHandler) {
      return error;
    }
    return ErrorHandler._(
      message: error?.toString() ?? _defaultErrorMessage,
      type: AppErrorType.unknown,
    );
  }

  factory ErrorHandler.fromApiError(Map<String, dynamic>? errorData) {
    if (errorData == null) {
      return const ErrorHandler._(
        message: _defaultErrorMessage,
        type: AppErrorType.unknown,
      );
    }
    final message =
        (errorData['message'] ?? errorData['error'] ?? errorData['errorMessage'])
                ?.toString() ??
            _defaultErrorMessage;
    final errorType =
        _errorTypeMap[errorData['errorType']?.toString()] ?? AppErrorType.unknown;
    Map<String, String>? fieldErrors;
    if (errorData.containsKey('errors') && errorData['errors'] is Map) {
      fieldErrors = {};
      final errors = errorData['errors'] as Map;
      errors.forEach((key, value) {
        if (value is String) {
          fieldErrors![key.toString()] = value;
        } else if (value is List && value.isNotEmpty) {
          fieldErrors![key.toString()] = value.first.toString();
        }
      });
    }
    return ErrorHandler._(
      message: message,
      type: errorType,
      fieldErrors: fieldErrors,
      originalError: errorData,
    );
  }

  factory ErrorHandler.fromDioException(DioException error) {
    if (_networkErrorTypes.contains(error.type)) {
      return ErrorHandler._(
        message: _getNetworkErrorMessage(error.type),
        type: error.type == DioExceptionType.connectionTimeout
            ? AppErrorType.connectionTimeout
            : AppErrorType.networkError,
        originalError: error,
      );
    }
    if (error.type == DioExceptionType.badResponse) {
      return ErrorHandler.fromResponse(error.response, error);
    }
    if (error.type == DioExceptionType.cancel) {
      return ErrorHandler._(
        message: 'Request was cancelled',
        type: AppErrorType.unknown,
        originalError: error,
      );
    }
    return ErrorHandler._(
      message: error.message ?? _defaultErrorMessage,
      type: AppErrorType.unknown,
      originalError: error,
    );
  }

  factory ErrorHandler.fromResponse(
    Response<dynamic>? response, [
    dynamic originalError,
  ]) {
    if (response == null) {
      return ErrorHandler._(
        message: _serverErrorMessage,
        type: AppErrorType.serverError,
        originalError: originalError,
      );
    }
    final errorData = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : null;
    return switch (response.statusCode) {
      400 => ErrorHandler.fromApiError(errorData),
      401 => ErrorHandler._(
          message: _extractErrorMessage(errorData) ?? 'Authentication failed',
          type: AppErrorType.invalidCredentials,
          originalError: originalError,
        ),
      403 => ErrorHandler._(
          message: _extractErrorMessage(errorData) ?? 'Access denied',
          type: AppErrorType.forbidden,
          originalError: originalError,
        ),
      404 => ErrorHandler._(
          message: _extractErrorMessage(errorData) ?? 'Resource not found',
          type: AppErrorType.notFound,
          originalError: originalError,
        ),
      422 => ErrorHandler._(
          message: _extractErrorMessage(errorData) ?? 'Validation error',
          type: AppErrorType.validationError,
          fieldErrors: _extractFieldErrors(errorData),
          originalError: originalError,
        ),
      500 => ErrorHandler._(
          message: _extractErrorMessage(errorData) ?? _serverErrorMessage,
          type: AppErrorType.serverError,
          originalError: originalError,
        ),
      _ => ErrorHandler._(
          message: _extractErrorMessage(errorData) ?? _defaultErrorMessage,
          type: AppErrorType.unknown,
          originalError: originalError,
        ),
    };
  }

  const ErrorHandler._({
    required String message,
    required AppErrorType type,
    this.fieldErrors,
    this.originalError,
  })  : _errorMessage = message,
        _errorType = type;

  final String _errorMessage;
  final AppErrorType _errorType;
  final Map<String, String>? fieldErrors;
  final dynamic originalError;

  String get message => _errorMessage;
  AppErrorType get type => _errorType;
  bool get hasFieldErrors => fieldErrors != null && fieldErrors!.isNotEmpty;

  String getUserFriendlyMessage() {
    return switch (_errorType) {
      AppErrorType.invalidCredentials => 'Invalid email or password',
      AppErrorType.invalidOtp => 'Invalid verification code',
      AppErrorType.phoneNotFound => 'Phone number not found',
      AppErrorType.emailNotFound => 'Email not found',
      AppErrorType.emailAlreadyExists => 'Email is already in use',
      AppErrorType.passwordMismatch => 'Passwords do not match',
      AppErrorType.networkError => 'Please check your internet connection',
      AppErrorType.connectionTimeout => 'Connection timed out',
      AppErrorType.serverError => 'Server error, please try again later',
      AppErrorType.notFound => 'The requested information could not be found',
      AppErrorType.validationError => 'Please check your entries and try again',
      _ => _errorMessage,
    };
  }

  static const _defaultErrorMessage = 'An error occurred';
  static const _networkErrorMessage = 'Network error occurred';
  static const _serverErrorMessage = 'Server error occurred';

  static const Map<String, AppErrorType> _errorTypeMap = {
    'INVALID_OTP': AppErrorType.invalidOtp,
    'PHONE_NOT_FOUND': AppErrorType.phoneNotFound,
    'EMAIL_NOT_FOUND': AppErrorType.emailNotFound,
    'EMAIL_EXISTS': AppErrorType.emailAlreadyExists,
    'EMAIL_ALREADY_EXISTS': AppErrorType.emailAlreadyExists,
    'PASSWORD_MISMATCH': AppErrorType.passwordMismatch,
    'INVALID_REFRESH_TOKEN': AppErrorType.invalidRefreshToken,
    'VALIDATION_ERROR': AppErrorType.validationError,
  };

  static const _networkErrorTypes = {
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionError,
  };

  static String? _extractErrorMessage(Map<String, dynamic>? data) {
    if (data == null) return null;
    final possibleKeys = ['message', 'error', 'errorMessage', 'description'];
    for (final key in possibleKeys) {
      if (data.containsKey(key) && data[key] is String) {
        return data[key] as String?;
      }
    }
    return null;
  }

  static Map<String, String>? _extractFieldErrors(Map<String, dynamic>? data) {
    if (data == null) return null;
    Map<String, String>? fieldErrors;
    if (data.containsKey('errors') && data['errors'] is Map) {
      fieldErrors = {};
      final errors = data['errors'] as Map;
      errors.forEach((key, value) {
        if (value is String) {
          fieldErrors![key.toString()] = value;
        } else if (value is List && value.isNotEmpty) {
          fieldErrors![key.toString()] = value.first.toString();
        }
      });
    }
    return fieldErrors;
  }

  static String _getNetworkErrorMessage(DioExceptionType type) {
    return switch (type) {
      DioExceptionType.connectionTimeout => 'Connection timed out',
      DioExceptionType.sendTimeout => 'Request timed out',
      DioExceptionType.receiveTimeout => 'Response timed out',
      _ => _networkErrorMessage,
    };
  }

  @override
  String toString() =>
      'ErrorHandler(type: ${_errorType.name}, message: $_errorMessage)';
}
