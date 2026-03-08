import 'dart:async';
import 'dart:developer' as dev show log;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

enum NetworkState { offline, online }

class NetworkAdapter {
  NetworkAdapter({required Connectivity connectivity})
      : _connectivity = connectivity {
    _streamSubscription =
        _connectivity.onConnectivityChanged.listen(_updateState);
    checkConnectivity();
  }

  final Connectivity _connectivity;

  final BehaviorSubject<NetworkState> _connectivityBehaviorSubject =
      BehaviorSubject.seeded(NetworkState.online);

  late final StreamSubscription<List<ConnectivityResult>> _streamSubscription;

  Stream<NetworkState> get connectivityStream =>
      _connectivityBehaviorSubject.stream;

  NetworkState get currentState => _connectivityBehaviorSubject.value;

  void _updateState(List<ConnectivityResult> result) {
    final newState = result.contains(ConnectivityResult.none)
        ? NetworkState.offline
        : NetworkState.online;
    if (newState != _connectivityBehaviorSubject.value) {
      if (kDebugMode) {
        dev.log(
          'Network state changed: $newState (from result: $result)',
          name: 'NetworkAdapter',
        );
      }
      _connectivityBehaviorSubject.add(newState);
    }
  }

  Future<void> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateState(result);
    } catch (e) {
      if (kDebugMode) {
        dev.log(
          'Error checking connectivity: $e',
          name: 'NetworkAdapter',
          error: e,
        );
      }
    }
  }

  void dispose() {
    _streamSubscription.cancel();
    _connectivityBehaviorSubject.close();
  }
}
