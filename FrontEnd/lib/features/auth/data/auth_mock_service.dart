/// Service d'authentification local pour les tests sans backend.
///
/// Désactiver [enabled] avant la mise en production.

import 'auth_local_service.dart';

class AuthMockService {
  // ── Basculer ici pour activer / désactiver le mock ─────────────────────────
  static const bool enabled = true;

  // ── Comptes de test ────────────────────────────────────────────────────────
  static const _users = <String, Map<String, String>>{
    'jean.tchameni': {
      'password': 'Test@1234',
      'role': 'patient',
      'prenom': 'Jean',
      'nom': 'Tchameni',
      'id': '1',
    },
    'inf.onana': {
      'password': 'Test@1234',
      'role': 'infirmier',
      'prenom': 'Marie',
      'nom': 'Onana',
      'id': '2',
    },
    'brice.ngono': {
      'password': 'Test@1234',
      'role': 'accueil',
      'prenom': 'Brice',
      'nom': 'Ngono',
      'id': '3',
    },
    'dr.mballa': {
      'password': 'Test@1234',
      'role': 'medecin',
      'prenom': 'Alphonse',
      'nom': 'Mballa',
      'id': '4',
    },
  };

  final _local = AuthLocalService();

  /// Connecte l'utilisateur localement. Lance une [Exception] si ko.
  Future<Map<String, String>> login({
    required String identifiant,
    required String motDePasse,
  }) async {
    final user = _users[identifiant.trim().toLowerCase()];
    if (user == null || user['password'] != motDePasse) {
      throw Exception('Identifiant ou mot de passe incorrect.');
    }
    await _local.saveSession(
      token: 'mock-token-${user['id']}',
      role: user['role']!,
      userName: '${user['prenom']} ${user['nom']}',
    );
    await _local.saveUserId(user['id']!);
    return Map<String, String>.from(user);
  }
}