import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton/core/configs/app_config.dart';
import 'package:flutter_skeleton/core/services/crashlytics/crashlytics_service.dart';
import 'package:flutter_skeleton/core/services/secure_storage/secure_storage_service.dart';
import 'package:flutter_skeleton/core/utils/log.dart';
import 'package:flutter_skeleton/di/di_container.dart';
import 'package:flutter_skeleton/features/auth/domain/repositories/auth_repository.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.authRepository,
    required this.onAuthFailed,
    required this.dio,
  });

  final AuthRepository authRepository;
  final VoidCallback onAuthFailed;
  final Dio dio;

  CrashlyticsService? get _crashlytics {
    try {
      if (diContainer.isRegistered<CrashlyticsService>()) {
        return diContainer<CrashlyticsService>();
      }
    } catch (_) {}
    return null;
  }

  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  bool _isRefreshRequest(RequestOptions options) {
    final path = options.path;
    return path == AppConfig.refreshPath ||
        path.endsWith(AppConfig.refreshPath);
  }

  bool _hasInvalidRefreshTokenMessage(DioException err) {
    final data = err.response?.data;
    if (data is Map) {
      return data['message'] == 'Invalid refresh token';
    }
    return false;
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken =
          await SecureStorageService.getValue(AppConfig.refreshTokenKey);
      logInfo(
        'Attempting token refresh. Has refresh token: ${refreshToken != null}',
      );
      if (refreshToken == null) {
        logError('No refresh token found');
        _crashlytics?.log('auth:refresh_token_missing');
        return null;
      }
      final result = await authRepository.refreshToken(refreshToken);
      return result.fold(
        (failure) {
          logError('Token refresh failed: ${failure.message}');
          _crashlytics?.log('auth:refresh_failed:${failure.message}');
          return null;
        },
        (tokenResponse) async {
          await SecureStorageService.storeValue(
            AppConfig.accessTokenKey,
            tokenResponse.accessToken,
          );
          await SecureStorageService.storeValue(
            AppConfig.refreshTokenKey,
            tokenResponse.refreshToken,
          );
          logInfo('Token refresh successful!');
          _crashlytics?.log('auth:refresh_success');
          return tokenResponse.accessToken;
        },
      );
    } catch (e) {
      logError('Unexpected error during token refresh: $e');
      _crashlytics?.recordException(
        e,
        StackTrace.current,
        reason: 'auth:refresh_unexpected',
      );
      return null;
    }
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token =
        await SecureStorageService.getValue(AppConfig.accessTokenKey);
    if (token != null) {
      options.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return super.onError(err, handler);
    }
    if (_hasInvalidRefreshTokenMessage(err)) {
      _rejectAllPendingRequests(err);
      onAuthFailed();
      return handler.next(err);
    }
    if (_isRefreshRequest(err.requestOptions)) {
      return super.onError(err, handler);
    }
    if (_isRefreshing) {
      _pendingRequests.add(_PendingRequest(err.requestOptions, handler));
      return;
    }
    _isRefreshing = true;
    try {
      final newToken = await _refreshToken();
      if (newToken == null) {
        _rejectAllPendingRequests(err);
        onAuthFailed();
        return handler.next(err);
      }
      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      try {
        final response = await dio.fetch<dynamic>(err.requestOptions);
        handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
      await _retryAllPendingRequests(newToken);
    } catch (e) {
      logError('Error during token refresh: $e');
      _crashlytics?.recordException(
        e,
        StackTrace.current,
        reason: 'auth:refresh_error',
      );
      _rejectAllPendingRequests(err);
      onAuthFailed();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _retryAllPendingRequests(String newToken) async {
    final requests = List<_PendingRequest>.from(_pendingRequests);
    _pendingRequests.clear();
    for (final pending in requests) {
      pending.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      try {
        final response = await dio.fetch<dynamic>(pending.requestOptions);
        pending.handler.resolve(response);
      } catch (e) {
        if (e is DioException) {
          pending.handler.next(e);
        } else {
          pending.handler.reject(
            DioException(requestOptions: pending.requestOptions, error: e),
          );
        }
      }
    }
  }

  void _rejectAllPendingRequests(DioException originalError) {
    for (final pending in _pendingRequests) {
      pending.handler.next(
        DioException(
          requestOptions: pending.requestOptions,
          response: originalError.response,
          type: originalError.type,
          error: originalError.error,
        ),
      );
    }
    _pendingRequests.clear();
  }
}

class _PendingRequest {
  _PendingRequest(this.requestOptions, this.handler);

  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;
}
