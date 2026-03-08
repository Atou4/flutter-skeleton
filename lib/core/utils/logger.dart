import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class Logger {
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(message, name: tag ?? 'DEBUG', level: 500);
    }
  }

  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(message, name: tag ?? 'INFO', level: 800);
    }
  }

  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(message, name: tag ?? 'WARNING', level: 900);
    }
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? 'ERROR',
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
