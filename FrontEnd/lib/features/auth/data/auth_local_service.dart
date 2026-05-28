import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalService {
  static const _keyBiometricEnabled = 'biometric_enabled';
  static const _keyUserRole = 'user_role';
  static const _keyUserName = 'user_name';
  static const _keyAccessToken = 'access_token';

  final FlutterSecureStorage _storage;

  AuthLocalService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // --- Biométrie ---

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _keyBiometricEnabled);
    return value == 'true';
  }

  Future<void> enableBiometric() async {
    await _storage.write(key: _keyBiometricEnabled, value: 'true');
  }

  Future<void> disableBiometric() async {
    await _storage.delete(key: _keyBiometricEnabled);
  }

  // --- Session utilisateur ---

  Future<void> saveSession({
    required String token,
    required String role,
    required String userName,
  }) async {
    await _storage.write(key: _keyAccessToken, value: token);
    await _storage.write(key: _keyUserRole, value: role);
    await _storage.write(key: _keyUserName, value: userName);
  }

  Future<String?> getUserRole() async {
    return _storage.read(key: _keyUserRole);
  }

  Future<String?> getUserName() async {
    return _storage.read(key: _keyUserName);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  Future<bool> hasSession() async {
    final token = await _storage.read(key: _keyAccessToken);
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}
