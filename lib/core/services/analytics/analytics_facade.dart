import 'package:flutter_skeleton/core/services/analytics/analytics_client.dart';

class AnalyticsFacade implements AnalyticsClient {
  const AnalyticsFacade(this._clients);

  final List<AnalyticsClient> _clients;

  @override
  Future<void> trackScreenView(String screenName) =>
      _fanOut((client) => client.trackScreenView(screenName));

  @override
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? params,
  }) =>
      _fanOut((client) => client.trackEvent(eventName, params: params));

  Future<void> _fanOut(
    Future<void> Function(AnalyticsClient client) action,
  ) async {
    for (final client in _clients) {
      try {
        await action(client);
      } catch (_) {}
    }
  }
}
