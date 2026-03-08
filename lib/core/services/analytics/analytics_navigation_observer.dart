import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_skeleton/core/services/analytics/analytics_client.dart';

class AnalyticsNavigationObserver extends NavigatorObserver {
  AnalyticsNavigationObserver({required AnalyticsClient analyticsClient})
      : _analyticsClient = analyticsClient;

  final AnalyticsClient _analyticsClient;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackRoute(newRoute);
    }
  }

  void _trackRoute(Route<dynamic> route) {
    final routeName = route.settings.name;
    if (routeName != null) {
      unawaited(_analyticsClient.trackScreenView(routeName));
    }
  }
}
