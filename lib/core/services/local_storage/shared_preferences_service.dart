import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_skeleton/core/services/local_storage/local_storage_service.dart';
import 'package:flutter_skeleton/core/utils/log.dart';
import 'package:flutter_skeleton/di/di_initializer.dart';

class SharedPreferencesService implements LocalStorageService {
  SharedPreferencesService() {
    init();
  }

  late final SharedPreferences _pref;

  @override
  FutureOr<void> init() async {
    _pref = await SharedPreferences.getInstance();
    Injector.instance.signalReady(this);
  }

  @override
  Object? getValue({required String key}) => _pref.get(key);

  @override
  FutureOr<void> setValue({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) {
      await _pref.setString(key, value);
    } else if (value is int) {
      await _pref.setInt(key, value);
    } else if (value is double) {
      await _pref.setDouble(key, value);
    } else if (value is bool) {
      await _pref.setBool(key, value);
    } else if (value is List<String>) {
      await _pref.setStringList(key, value);
    } else {
      await _pref.setString(key, value.toString());
      logWarning(
        'SharedPreferences does not support this type – saved as String',
      );
    }
  }

  @override
  bool? getBool({required String key}) => _pref.getBool(key);

  @override
  double? getDouble({required String key}) => _pref.getDouble(key);

  @override
  int? getInt({required String key}) => _pref.getInt(key);

  @override
  String? getString({required String key}) => _pref.getString(key);

  @override
  List<String>? getStringList({required String key}) =>
      _pref.getStringList(key);

  @override
  FutureOr<bool> removeEntry({required String key}) => _pref.remove(key);
}
