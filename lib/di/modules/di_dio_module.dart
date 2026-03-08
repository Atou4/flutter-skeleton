import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_skeleton/core/configs/app_config.dart';
import 'package:flutter_skeleton/core/network/auth_interceptor.dart';
import 'package:flutter_skeleton/di/di_initializer.dart';
import 'package:flutter_skeleton/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_skeleton/features/auth/presentation/cubit/auth_cubit.dart';

class DioModule {
  DioModule._();

  static const String dioInstanceName = 'dioInstance';
  static final GetIt _injector = Injector.instance;

  static void setupBaseDio() {
    _injector.registerLazySingleton<Dio>(() {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
      if (!kReleaseMode) {
        dio.interceptors.add(
          PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseHeader: true,
            maxWidth: 120,
          ),
        );
      }
      return dio;
    }, instanceName: dioInstanceName);
  }

  static void setupAuthInterceptor() {
    final dio = _injector<Dio>(instanceName: dioInstanceName);
    final authRepository = _injector<AuthRepository>();
    final authCubit = _injector<AuthCubit>();
    dio.interceptors.add(
      AuthInterceptor(
        authRepository: authRepository,
        onAuthFailed: authCubit.signOut,
        dio: dio,
      ),
    );
  }
}
