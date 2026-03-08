import 'package:equatable/equatable.dart';
import 'package:flutter_skeleton/core/network/error_handler.dart';

abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.errorType,
    this.errorCode,
    this.originalError,
  });

  final String message;
  final dynamic errorType;
  final String? errorCode;
  final dynamic originalError;

  @override
  List<Object?> get props => [message, errorType, errorCode];

  bool get shouldRetry => false;
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.errorType,
    super.errorCode,
    super.originalError,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network Error',
    super.errorType,
    super.errorCode,
    super.originalError,
  });

  @override
  bool get shouldRetry => true;
}

class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    required AppErrorType type,
    super.errorCode,
    super.originalError,
  }) : super(errorType: type);
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    this.fieldErrors,
    super.errorType,
    super.errorCode,
    super.originalError,
  });

  final Map<String, String>? fieldErrors;

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

class BusinessFailure extends Failure {
  const BusinessFailure({
    required super.message,
    super.errorType,
    super.errorCode,
    super.originalError,
  });
}

class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    this.permission,
    super.errorType,
    super.errorCode,
    super.originalError,
  });

  final String? permission;

  @override
  List<Object?> get props => [...super.props, permission];
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred',
    super.errorType,
    super.errorCode,
    super.originalError,
  });
}
