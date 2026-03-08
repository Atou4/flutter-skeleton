import 'dart:developer' as developer;

import 'package:flutter_skeleton/core/services/crashlytics/crashlytics_service.dart';
import 'package:flutter_skeleton/di/di_container.dart';

bool showTime = true;

String get printTime {
  final date = DateTime.now();
  return showTime ? ':${date.minute}:${date.second}:${date.millisecond}' : '';
}

class Log {
  static void i(dynamic msg) {
    developer.log(
      '\x1B[34m$msg\x1B[0m',
      name: 'App$printTime',
    );
  }

  static void s(dynamic msg) {
    developer.log(
      '\x1B[32m$msg\x1B[0m',
      name: 'App$printTime',
    );
  }

  static void w(dynamic msg) {
    developer.log(
      '\x1B[33m$msg\x1B[0m',
      name: 'App$printTime',
    );
  }

  static void e(dynamic msg) {
    developer.log(
      '\x1B[31m$msg\x1B[0m',
      name: 'App$printTime',
    );
  }
}

void logInfo(dynamic msg) {
  Log.i(msg);
}

void logSuccess(dynamic msg) {
  Log.s(msg);
}

void logWarning(dynamic msg) {
  Log.w(msg);
}

void logError(dynamic msg) {
  Log.e(msg);
  try {
    if (diContainer.isRegistered<CrashlyticsService>()) {
      diContainer<CrashlyticsService>().log(msg.toString());
    }
  } catch (_) {}
}
