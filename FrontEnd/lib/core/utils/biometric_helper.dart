import 'package:local_auth/local_auth.dart';

/// Wrapper autour de local_auth pour lancer la validation
/// d'empreinte digitale / reconnaissance faciale du système.
class BiometricHelper {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// `true` si l'appareil supporte la biométrie ET qu'au moins
  /// une empreinte / un visage est enregistré.
  static Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Lance le prompt biométrique natif (empreinte / Face ID).
  /// Retourne `true` si l'utilisateur s'est authentifié avec succès.
  static Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
