import 'package:dartz/dartz.dart';
import 'package:flutter_skeleton/core/configs/app_config.dart';
import 'package:flutter_skeleton/core/exceptions/error_failures.dart';
import 'package:flutter_skeleton/core/services/crashlytics/crashlytics_service.dart';
import 'package:flutter_skeleton/core/services/secure_storage/secure_storage_service.dart';
import 'package:flutter_skeleton/core/network/repository_helper.dart';
import 'package:flutter_skeleton/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImplementation implements AuthRepository {
  AuthRepositoryImplementation({
    required this.crashlyticsService,
  });

  final CrashlyticsService crashlyticsService;

  @override
  Future<Either<Failure, TokenResponse>> signInWithEmail({
    required String email,
    required String password,
  }) {
    return RepositoryHelper.executeRequest(
      request: () async {
        throw UnimplementedError('signInWithEmail not implemented');
      },
      crashlyticsService: crashlyticsService,
      context: 'signInWithEmail',
    );
  }

  @override
  Future<Either<Failure, TokenResponse>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) {
    return RepositoryHelper.executeRequest(
      request: () async {
        throw UnimplementedError('signUpWithEmail not implemented');
      },
      crashlyticsService: crashlyticsService,
      context: 'signUpWithEmail',
    );
  }

  @override
  Future<Either<Failure, TokenResponse>> refreshToken(
    String refreshToken,
  ) {
    return RepositoryHelper.executeRequest(
      request: () async {
        throw UnimplementedError('refreshToken not implemented');
      },
      crashlyticsService: crashlyticsService,
      context: 'refreshToken',
    );
  }

  @override
  Future<void> signOut() async {
    await SecureStorageService.deleteValue(AppConfig.accessTokenKey);
    await SecureStorageService.deleteValue(AppConfig.refreshTokenKey);
  }
}
