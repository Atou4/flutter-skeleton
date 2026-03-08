class ApiException implements Exception {
  ApiException({required this.message});
  final String message;

  @override
  String toString() => 'ApiException: $message';
}

class BadRequestException extends ApiException {
  BadRequestException({required super.message});
}

class InternalServerErrorException extends ApiException {
  InternalServerErrorException({required super.message});
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({required super.message});
}

class ForbiddenException extends ApiException {
  ForbiddenException({required super.message});
}

class NotFoundException extends ApiException {
  NotFoundException({required super.message});
}

class NoInternetException extends ApiException {
  NoInternetException({required super.message});
}
