class ApiEndpoints {
  ApiEndpoints._();

  // ════════════════════════════════════════════
  // Ton IP Wi-Fi actuelle
  // Si tu changes de réseau → mets à jour ici
  // Émulateur Android → utilise 10.0.2.2
  // ════════════════════════════════════════════
  static const String baseUrl = 'https://projet-csn.onrender.com/api/v1';

  // Vérification réseau
  static const String networkCheck = '/network/check';

  // Auth
  static const String loginProfessionnel = '/auth/login-professionnel';
  static const String loginPatient       = '/auth/login-patient';
  static const String loginBiometrique   = '/auth/login-biometrique';
  static const String enregistrerBiometrie = '/auth/enregistrer-biometrie';

  // Patients
  static const String enregistrerPatient = '/patients/enregistrer';
  static String profil(String id)         => '/patients/$id/profil';
  static String historique(String id)     => '/patients/$id/historique';
  static String passageEnCours(String id) => '/patients/$id/passage-en-cours';
  static String qrCode(String id)         => '/patients/$id/qr-code';

  // ── Médecin ──────────────────────────────────────────
  static const String medecinPatientsDuJour =
      '/medecin/patients-du-jour';
  static const String medecinStatsDuJour =
      '/medecin/stats-du-jour';
  static const String medecinActivite =
      '/medecin/activite';
  static String medecinPassageDetail(String id) =>
      '/medecin/passages/$id';

  // Ordonnances
  static String ordonnances(String id)       => '/ordonnances/patient/$id';
  static String ordonnancesActives(String id) => '/ordonnances/patient/$id/actives';
  static String ordonnanceDetail(String id)  => '/ordonnances/$id';
  static const String creerOrdonnance        = '/ordonnances';

  // Notifications
  static String notifications(String id)    => '/notifications/patient/$id';
  static String nonLues(String id)          => '/notifications/patient/$id/non-lues';
  static String toutLire(String id)         => '/notifications/patient/$id/tout-lire';
  static String marquerLue(String id)       => '/notifications/$id/lire';

  // Admission (utilisé par le parcours agent d'accueil)
  static const String scanCarte    = '/admission/scan-carte';
  static const String creerPassage = '/admission/creer-passage';

  // Passages
  static String constantes(String id)   => '/passages/$id/constantes';
  static String consultation(String id) => '/passages/$id/consultation';

  // Laboratoire
  static const String ajouterExamen = '/laboratoire/ajouter-examen';
}