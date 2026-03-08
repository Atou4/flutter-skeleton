import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton/core/configs/app_config.dart';
import 'package:flutter_skeleton/core/services/crashlytics/crashlytics_service.dart';
import 'package:flutter_skeleton/core/services/secure_storage/secure_storage_service.dart';
import 'package:flutter_skeleton/di/di_container.dart';
import 'package:flutter_skeleton/features/auth/domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.authRepository}) : super(AuthInitial());

  final AuthRepository authRepository;

  CrashlyticsService? get _crashlytics {
    try {
      if (diContainer.isRegistered<CrashlyticsService>()) {
        return diContainer<CrashlyticsService>();
      }
    } catch (_) {}
    return null;
  }

  Future<void> checkAuthStatus() async {
    final accessToken =
        await SecureStorageService.getValue(AppConfig.accessTokenKey);
    if (accessToken != null) {
      await _crashlytics?.setCustomKey('auth', 'authenticated');
      emit(const UserAuthenticated());
    } else {
      await _crashlytics?.setCustomKey('auth', 'unauthenticated');
      emit(UserUnAuthenticated());
    }
  }

  Future<void> signOut() async {
    await authRepository.signOut();
    await _crashlytics?.setUserIdentifier('');
    await _crashlytics?.setCustomKey('auth', 'signed_out');
    emit(UserUnAuthenticated());
  }
}
