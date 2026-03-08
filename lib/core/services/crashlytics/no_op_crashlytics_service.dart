import 'package:flutter/foundation.dart';
import 'package:flutter_skeleton/core/services/crashlytics/crashlytics_service.dart';
import 'package:flutter_skeleton/core/utils/log.dart';

class NoOpCrashlyticsService implements CrashlyticsService {
  @override
  Future<void> init({required bool enabled}) async {}

  @override
  Future<void> recordException(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      logError('CrashlyticsStub: $reason – $exception');
    }
  }

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails flutterErrorDetails,
  ) async {
    if (kDebugMode) {
      logError('CrashlyticsStub: ${flutterErrorDetails.exceptionAsString()}');
    }
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {}

  @override
  Future<void> setCustomKey(String key, dynamic value) async {}

  @override
  Future<void> log(String message) async {
    if (kDebugMode) {
      logInfo('CrashlyticsStub log: $message');
    }
  }
}
