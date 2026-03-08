import 'dart:developer';

import 'package:flutter_skeleton/core/services/analytics/analytics_client.dart';

class LoggerAnalyticsClient implements AnalyticsClient {
  const LoggerAnalyticsClient();

  @override
  Future<void> trackScreenView(String screenName) async {
    _log('screen_view: $screenName');
  }

  @override
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? params,
  }) async {
    _log('event: $eventName ${params ?? ''}');
  }

  void _log(String eventName) {
    log(eventName, name: 'AnalyticsEvent');
  }
}
