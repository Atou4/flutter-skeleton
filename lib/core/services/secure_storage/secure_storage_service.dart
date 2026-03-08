import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();

  static const _storage = FlutterSecureStorage();

  static Future<void> storeValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getValue(String key) {
    return _storage.read(key: key);
  }

  static Future<void> deleteValue(String key) async {
    await _storage.delete(key: key);
  }
}
