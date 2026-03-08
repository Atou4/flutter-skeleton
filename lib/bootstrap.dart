import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_skeleton/core/utils/log.dart';
import 'package:flutter_skeleton/di/di_container.dart';
import 'package:flutter_skeleton/di/di_initializer.dart';
import 'package:flutter_skeleton/core/services/crashlytics/crashlytics_service.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    logInfo(
      '[BLOC_OBSERVER] onChange(${bloc.runtimeType}): '
      '${change.currentState.runtimeType} -> ${change.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    logError(
      '[BLOC_OBSERVER] onError(${bloc.runtimeType}): $error\n$stackTrace',
    );
    try {
      if (diContainer.isRegistered<CrashlyticsService>()) {
        diContainer<CrashlyticsService>().recordException(
          error,
          stackTrace,
          reason: 'BLoC:${bloc.runtimeType}',
          fatal: false,
        );
      }
    } catch (_) {}
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(
  FutureOr<Widget> Function() builder,
  AsyncCallback? flavorConfiguration,
) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await flavorConfiguration?.call();

      Bloc.observer = const AppBlocObserver();
      await Injector.init();
      await Injector.instance.allReady();

      final crashlyticsService = diContainer<CrashlyticsService>();
      await crashlyticsService.init(enabled: !kDebugMode);

      FlutterError.onError = (details) {
        logError(
          'Flutter error: ${details.exceptionAsString()}, ${details.stack}',
        );
        crashlyticsService.recordFlutterError(details);
        if (kDebugMode) {
          FlutterError.presentError(details);
        }
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        logError('PlatformDispatcher error: $error\n$stack');
        crashlyticsService.recordException(error, stack, fatal: true);
        return true;
      };

      runApp(await builder());
    },
    (exception, stackTrace) async {
      logError('Zone error: $exception, $stackTrace');
      final crashlyticsService = diContainer<CrashlyticsService>();
      await crashlyticsService.recordException(
        exception,
        stackTrace,
        fatal: true,
      );
    },
  );
}
