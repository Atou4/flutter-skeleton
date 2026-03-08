abstract class AnalyticsClient {
  Future<void> trackScreenView(String screenName);

  Future<void> trackEvent(String eventName, {Map<String, dynamic>? params});
}
