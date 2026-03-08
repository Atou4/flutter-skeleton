import 'package:dartz/dartz.dart';
import 'package:flutter_skeleton/core/exceptions/error_failures.dart';

class TokenResponse {
  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;
}

abstract class AuthRepository {
  Future<Either<Failure, TokenResponse>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, TokenResponse>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, TokenResponse>> refreshToken(String refreshToken);

  Future<void> signOut();
}
