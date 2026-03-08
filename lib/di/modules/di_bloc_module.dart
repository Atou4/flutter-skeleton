import 'package:flutter_skeleton/core/services/local_storage/local_storage_service.dart';
import 'package:flutter_skeleton/di/di_container.dart';
import 'package:flutter_skeleton/di/di_initializer.dart';
import 'package:flutter_skeleton/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_skeleton/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_skeleton/features/shared/language/presentation/cubit/language_cubit.dart';

class BlocModule {
  BlocModule._();

  static void init() {
    Injector.instance
      ..registerLazySingleton<LanguageCubit>(
        () => LanguageCubit(diContainer<LocalStorageService>()),
      )
      ..registerLazySingleton<AuthCubit>(
        () => AuthCubit(authRepository: diContainer<AuthRepository>()),
      );
  }
}
