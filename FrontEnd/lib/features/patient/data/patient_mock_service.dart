import 'patient_models.dart';

/// Service de données fictives — remplacé par PatientApiService
/// quand l'API sera connectée.
/// Toutes les méthodes sont async pour que la migration
/// vers Dio soit transparente (même signature).
class PatientMockService {
  // ─── Singleton ───
  static final PatientMockService _instance = PatientMockService._();
  factory PatientMockService() => _instance;
  PatientMockService._();

  // ─── Délai simulé réseau ───
  static const _delay = Duration(milliseconds: 600);

  // ══════════════════════════════════════════
  // DONNÉES FICTIVES STATIQUES
  // ══════════════════════════════════════════

  static const Patient _patient = Patient(
    id: '8f3b9c2a-1234-4bc3-a716-446655440000',
    nom: 'TCHAMENI',
    prenom: 'Jean',
    dateNaissance: '14 Mai 1988',
    genre: 'M',
    groupeSanguin: 'B+',
    telephone: '+237 691 23 45 67',
    email: 'jean.tchameni@email.com',
    carte: CarteNumerique(
      qrCodeToken: 'QR-TKN-9F-A2-E1-K7',
      statut: 'actif',
      expireAnnee: '2028',
      expireMois: '12',
    ),
  );

  static const List<PassageMedical> _passages = [
    PassageMedical(
      id: '9e2a4b8c-5678-4df1-bc23-112233445566',
      hopital: 'Hôpital Général',
      service: 'Service Cardiologie',
      dateAdmission: "Aujourd'hui",
      heureAdmission: '09:34',
      motifVisite: 'Consultation Cardiologie',
      statut: 'en_cours',
      medecin: 'Dr. Mballa',
      constantes: ConstantesVitales(
        tension: '13/8',
        temperature: '37.2°',
        poids: '74 kg',
        pouls: '72',
      ),
      diagnostic: 'Hypertension artérielle stade 1.',
      prescription: 'Amlodipine 5 mg · Paracétamol 500 mg',
    ),
    PassageMedical(
      id: '1a2b3c4d-1111-2222-3333-444455556666',
      hopital: 'Clinique Pasteur',
      service: 'Cardiologie',
      dateAdmission: '02 Mars 2026',
      heureAdmission: '10:15',
      motifVisite: 'Consultation Cardio',
      statut: 'termine',
      medecin: 'Dr. Mballa',
      constantes: ConstantesVitales(
        tension: '12/7',
        temperature: '36.7°',
        poids: '73 kg',
        pouls: '68',
      ),
      diagnostic: 'Hypertension légère',
      examens: [
        ExamenLabo(
          id: 'ex-001',
          type: 'Hémogramme (NFS)',
          resultats: 'Globules blancs : 11 000 /mm³ (Élevés)',
          dateResultat: '02 Mars 2026 · 11:08',
        ),
      ],
    ),
    PassageMedical(
      id: '2b3c4d5e-2222-3333-4444-555566667777',
      hopital: 'Hôpital Central',
      service: 'Médecine générale',
      dateAdmission: '12 Nov 2025',
      heureAdmission: '09:15',
      motifVisite: 'Contrôle annuel',
      statut: 'termine',
      medecin: 'Dr. Ngono',
      constantes: ConstantesVitales(
        tension: '12/8',
        temperature: '36.8°',
        poids: '73 kg',
        pouls: '70',
      ),
      diagnostic: 'Rien à signaler',
    ),
    PassageMedical(
      id: '3c4d5e6f-3333-4444-5555-666677778888',
      hopital: 'Hôpital Général',
      service: 'Laboratoire',
      dateAdmission: '23 Jul 2025',
      heureAdmission: '16:45',
      motifVisite: 'Examen sanguin',
      statut: 'termine',
      medecin: 'Dr. Tabi',
      constantes: ConstantesVitales(
        tension: '11/7',
        temperature: '36.5°',
      ),
      diagnostic: 'Anémie modérée',
    ),
  ];

  static const List<Ordonnance> _ordonnances = [
    Ordonnance(
      id: 'ord-001',
      titre: 'Hypertension',
      medecin: 'Dr. Mballa Alphonse',
      specialite: 'Cardio',
      dateDelivrance: '24 Mai 2026',
      dateExpiration: '23 Juin 2026',
      statut: 'active',
      joursRestants: 28,
      medicaments: [
        Medicament(
          nom: 'Amlodipine 5 mg',
          posologie: '1 cp / jour · 30 jours',
          comprimesRestants: 22,
          comprimesTotaux: 30,
        ),
        Medicament(
          nom: 'Paracétamol 500 mg',
          posologie: 'Si douleur · Au besoin',
        ),
      ],
    ),
    Ordonnance(
      id: 'ord-002',
      titre: 'Antalgiques · Migraine',
      medecin: 'Dr. Ngono',
      specialite: 'Généraliste',
      dateDelivrance: '19 Mai 2026',
      dateExpiration: '22 Mai 2026',
      statut: 'active',
      joursRestants: 3,
      medicaments: [
        Medicament(
          nom: 'Ibuprofène 400 mg',
          posologie: '1 cp si crise · Max 3/j',
        ),
      ],
    ),
    Ordonnance(
      id: 'ord-003',
      titre: 'Antipaludique',
      medecin: 'Dr. Mballa Alphonse',
      specialite: 'Cardio',
      dateDelivrance: '02 Mai 2026',
      dateExpiration: '09 Mai 2026',
      statut: 'terminee',
      joursRestants: 0,
      medicaments: [
        Medicament(
          nom: 'Artesunate',
          posologie: '3 cp / jour · 3 jours',
        ),
      ],
    ),
  ];

  static const List<Notification> _notifications = [
    Notification(
      id: 'notif-001',
      titre: "Nouveaux résultats d'examen",
      message: 'Hémogramme (NFS) publié par le laboratoire',
      temps: 'il y a 12 min',
      type: 'examen',
    ),
    Notification(
      id: 'notif-002',
      titre: 'Ordonnance bientôt expirée',
      message: 'Antalgiques · Migraine — expire dans 3 jours',
      temps: 'il y a 1 h',
      type: 'ordonnance',
    ),
    Notification(
      id: 'notif-003',
      titre: 'Admission enregistrée',
      message: 'Hôpital Général — Consultation Cardiologie',
      temps: '23 Mai · 09:30',
      type: 'admission',
      lue: true,
    ),
    Notification(
      id: 'notif-004',
      titre: 'Dossier consulté',
      message: 'Dr. Mballa a accédé à votre dossier',
      temps: '23 Mai · 09:34',
      type: 'acces',
      lue: true,
    ),
    Notification(
      id: 'notif-005',
      titre: 'Connexion depuis un nouvel appareil',
      message: 'Samsung Galaxy A24 · Yaoundé',
      temps: '20 Mai · 18:42',
      type: 'securite',
      lue: true,
    ),
  ];

  // ══════════════════════════════════════════
  // MÉTHODES — même signature que le futur API service
  // ══════════════════════════════════════════

  Future<Patient> getPatient() async {
    await Future.delayed(_delay);
    return _patient;
  }

  Future<List<PassageMedical>> getHistorique() async {
    await Future.delayed(_delay);
    return _passages;
  }

  Future<PassageMedical?> getPassageEnCours() async {
    await Future.delayed(_delay);
    try {
      return _passages.firstWhere((p) => p.estEnCours);
    } catch (_) {
      return null;
    }
  }

  Future<List<Ordonnance>> getOrdonnances() async {
    await Future.delayed(_delay);
    return _ordonnances;
  }

  Future<List<Ordonnance>> getOrdonnancesActives() async {
    await Future.delayed(_delay);
    return _ordonnances.where((o) => o.estActive).toList();
  }

  Future<List<Notification>> getNotifications() async {
    await Future.delayed(_delay);
    return _notifications;
  }

  Future<int> getNombreNotificationsNonLues() async {
    await Future.delayed(_delay);
    return _notifications.where((n) => !n.lue).length;
  }
}