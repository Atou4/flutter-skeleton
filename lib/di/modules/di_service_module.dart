import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_skeleton/core/services/analytics/analytics_client.dart';
import 'package:flutter_skeleton/core/services/analytics/analytics_facade.dart';
import 'package:flutter_skeleton/core/services/analytics/logger_analytics_client.dart';
import 'package:flutter_skeleton/core/services/crashlytics/crashlytics_service.dart';
import 'package:flutter_skeleton/core/services/crashlytics/no_op_crashlytics_service.dart';
import 'package:flutter_skeleton/core/services/local_storage/local_storage_service.dart';
import 'package:flutter_skeleton/core/services/local_storage/shared_preferences_service.dart';
import 'package:flutter_skeleton/core/services/network/network_adapter.dart';
import 'package:flutter_skeleton/di/di_container.dart';
import 'package:flutter_skeleton/di/di_initializer.dart';
import 'package:flutter_skeleton/navigation/app_router.dart';

class ServiceModule {
  ServiceModule._();

  static void init() {
    Injector.instance
      ..registerLazySingleton<AnalyticsClient>(() {
        final clients = <AnalyticsClient>[const LoggerAnalyticsClient()];
        return AnalyticsFacade(clients);
      })
      ..registerSingleton(AppRouter())
      ..registerLazySingleton<CrashlyticsService>(NoOpCrashlyticsService.new)
      ..registerSingleton<Connectivity>(Connectivity())
      ..registerFactory<NetworkAdapter>(
        () => NetworkAdapter(connectivity: diContainer()),
      )
      ..registerSingleton<LocalStorageService>(
        SharedPreferencesService(),
        signalsReady: true,
      );
  }
}
