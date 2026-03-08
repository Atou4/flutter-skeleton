import 'package:equatable/equatable.dart';

abstract class AppException extends Equatable implements Exception {
  const AppException(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class CacheException extends AppException {
  const CacheException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}
