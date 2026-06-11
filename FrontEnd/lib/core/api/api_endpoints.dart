import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // ─────────────────────────────────────────────────────────────────────────
  // URL de base — sélection automatique selon la plateforme
  //
  // WEB       → localhost (navigateur sur la même machine que le backend)
  //
  // TÉLÉPHONE (même réseau Wi-Fi que le PC) :
  //   Option A — USB + ADB (recommandé, pas besoin de connaître l'IP) :
  //     $ adb reverse tcp:8080 tcp:8080
  //     puis lancer l'app normalement → localhost fonctionne sur le téléphone
  //
  //   Option B — Wi-Fi direct (si ADB non disponible) :
  //     Trouver l'IP Wi-Fi du PC (ipconfig / ip addr), puis :
  //     $ flutter run --dart-define=API_HOST=192.168.X.X
  //
  // ÉMULATEUR Android → 10.0.2.2 (valeur par défaut si API_HOST absent)
  // ─────────────────────────────────────────────────────────────────────────

  // ── Adresse du backend ────────────────────────────────────────────────────
  // Web                 → localhost automatique
  // Téléphone via USB   → adb reverse tcp:8080 tcp:8080  puis lancer normalement
  // Téléphone via Wi-Fi → flutter run --dart-define=API_HOST=<IP_PC>
  //                       (ex: flutter run --dart-define=API_HOST=10.26.75.160)
  static const String _mobileHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: 'localhost',
  );

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api/v1';
    return 'http://$_mobileHost:8080/api/v1';
  }

  // Vérification réseau
  static const String networkCheck = '/network/check';

  // Auth
  static const String loginProfessionnel    = '/auth/login-professionnel';
  static const String loginPatient          = '/auth/login-patient';
  static const String loginBiometrique      = '/auth/login-biometrique';
  static const String enregistrerBiometrie  = '/auth/enregistrer-biometrie';

  // Personnel médical
  static String personnelProfil(String id)    => '/personnel/$id/profil';
  static String dashboardAccueil(String id)   => '/admission/dashboard/$id';
  static String dashboardInfirmier(String id) => '/infirmier/dashboard/$id';
  static String activiteAgent(String id)      => '/admission/activite/$id';
  static String activiteInfirmier(String id)  => '/infirmier/activite/$id';

  // Patients
  static const String enregistrerPatient = '/patients/enregistrer';
  static String profil(String id)          => '/patients/$id/profil';
  static String historique(String id)      => '/patients/$id/historique';
  static String passageEnCours(String id)  => '/patients/$id/passage-en-cours';
  static String qrCode(String id)          => '/patients/$id/qr-code';

  // Ordonnances
  static String ordonnances(String id)        => '/ordonnances/patient/$id';
  static String ordonnancesActives(String id)  => '/ordonnances/patient/$id/actives';
  static String ordonnanceDetail(String id)   => '/ordonnances/$id';
  static const String creerOrdonnance         = '/ordonnances';

  // Notifications
  static String notifications(String id) => '/notifications/patient/$id';
  static String nonLues(String id)        => '/notifications/patient/$id/non-lues';
  static String toutLire(String id)       => '/notifications/patient/$id/tout-lire';
  static String marquerLue(String id)     => '/notifications/$id/lire';

  // Admission
  static const String scanCarte    = '/admission/scan-carte';
  static const String creerPassage = '/admission/creer-passage';

  // Passages
  static String constantes(String id)  => '/passages/$id/constantes';
  static String consultation(String id) => '/passages/$id/consultation';
  static String soin(String id)        => '/passages/$id/soin';
  static String injection(String id)   => '/passages/$id/injection';

  // Laboratoire
  static const String ajouterExamen = '/laboratoire/ajouter-examen';
}
