import 'package:flutter/foundation.dart';

abstract class CrashlyticsService {
  Future<void> init({required bool enabled});

  Future<void> recordException(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    bool fatal = false,
  });

  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails);

  Future<void> setUserIdentifier(String identifier);

  Future<void> setCustomKey(String key, dynamic value);

  Future<void> log(String message);
}
