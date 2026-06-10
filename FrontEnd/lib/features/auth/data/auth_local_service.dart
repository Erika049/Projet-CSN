import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalService {
  static const _keyToken = 'auth_token';
  static const _keyRole = 'user_role';
  static const _keyName = 'user_name';
  static const _keyBiometric = 'biometric_enabled';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveSession({
    required String token,
    required String role,
    required String userName,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyRole, value: role);
    await _storage.write(key: _keyName, value: userName);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<String?> getRole() async {
    return await _storage.read(key: _keyRole);
  }

  Future<String?> getUserName() async {
    return await _storage.read(key: _keyName);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> enableBiometric() async {
    await _storage.write(key: _keyBiometric, value: 'true');
  }

  Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _keyBiometric);
    return val == 'true';
  }

  Future<bool> hasSession() async {
    final token = await _storage.read(key: _keyToken);
    return token != null && token.isNotEmpty;
  }

  Future<void> saveUserId(String id) async {
    await _storage.write(key: 'auth_user_id', value: id);
  }

  Future<String?> getUserId() async =>
      _storage.read(key: 'auth_user_id');

  Future<void> logout() async {
    await _storage.deleteAll();
  }
}