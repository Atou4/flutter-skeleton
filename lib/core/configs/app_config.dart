import 'package:flutter_skeleton/core/configs/environment.dart';

class AppConfig {
  static const String appName = 'FlutterSkeleton';
  static const String appVersion = '1.0.0';

  static String baseUrl = '';

  static const String defaultLocale = 'en';

  static void configDev() {
    baseUrl = Environment.restApiUrl;
  }

  static void configStaging() {
    baseUrl = Environment.restApiUrl;
  }

  static void configProduction() {
    baseUrl = Environment.restApiUrl;
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';

  static const String signupPath = '/auth/signup';
  static const String loginPath = '/auth/login';
  static const String refreshPath = '/auth/refresh';
  static const String requestOtpPath = '/auth/otp/request';
  static const String verifyOtpPath = '/auth/otp/verify';
  static const String resetPasswordPath = '/auth/reset-password';

  Flavor getFlavor() {
    const flavorStr = String.fromEnvironment('FLUTTER_APP_FLAVOR');
    return switch (flavorStr) {
      'development' => Flavor.dev,
      'staging' => Flavor.stg,
      'production' => Flavor.prod,
      _ => throw UnsupportedError('Unsupported flavor: $flavorStr'),
    };
  }
}

enum Flavor { dev, stg, prod }
