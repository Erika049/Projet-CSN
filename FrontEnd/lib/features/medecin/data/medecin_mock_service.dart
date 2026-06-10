import 'medecin_models.dart';

class MedecinMockService {
  static final MedecinMockService _instance = MedecinMockService._();
  factory MedecinMockService() => _instance;
  MedecinMockService._();

  static const _delay = Duration(milliseconds: 500);

  // ── Données médecin connecté ──
  static const Map<String, String> _medecinInfo = {
    'nom': 'Mballa',
    'prenom': 'Alphonse',
    'role': 'Médecin',
    'service': 'Cardiologie · Hôpital Général',
    'initiales': 'AM',
  };

  Map<String, String> getMedecinInfo() => _medecinInfo;

  // ── Patients du jour ──
  static const List<PatientDuJour> _patients = [
    PatientDuJour(
      id: '8f3b9c2a-1234-4bc3-a716-446655440000',
      nom: 'TCHAMENI', prenom: 'Jean',
      motif: 'Consultation Cardiologie',
      heure: '09:30', statut: 'en_cours',
      idPassage: '9e2a4b8c-5678-4df1-bc23-112233445566',
    ),
    PatientDuJour(
      id: '2b3c4d5e-2222-3333-4444-555566667777',
      nom: 'NGO BIDIAS', prenom: 'Léa',
      motif: 'Suivi diabète',
      heure: '10:00', statut: 'en_attente',
      idPassage: '2a3b4c5d-1111-2222-3333-444455556666',
    ),
    PatientDuJour(
      id: '3c4d5e6f-3333-4444-5555-666677778888',
      nom: 'KAMGA', prenom: 'Patrick',
      motif: 'Bronchite aiguë',
      heure: '10:45', statut: 'termine',
      idPassage: '3b4c5d6e-2222-3333-4444-555566667777',
    ),
    PatientDuJour(
      id: '4d5e6f7a-4444-5555-6666-777788889999',
      nom: 'EBALE', prenom: 'Yolande',
      motif: 'Hypertension',
      heure: '11:15', statut: 'a_venir',
    ),
    PatientDuJour(
      id: '5e6f7a8b-5555-6666-7777-888899990000',
      nom: 'MBALLA', prenom: 'Henri',
      motif: 'Urgence trauma',
      heure: '11:30', statut: 'urgence',
    ),
  ];

  Future<List<PatientDuJour>> getPatientsduJour() async {
    await Future.delayed(_delay);
    return _patients;
  }

  Future<Map<String, int>> getStatsJour() async {
    await Future.delayed(_delay);
    return {
      'total': 12,
      'en_cours': 4,
      'urgences': 2,
    };
  }

  Future<DossierPatient> getDossierPatient(String idPatient) async {
    await Future.delayed(_delay);
    return const DossierPatient(
      id: '8f3b9c2a-1234-4bc3-a716-446655440000',
      nom: 'TCHAMENI', prenom: 'Jean',
      dateNaissance: '14 Mai 1988',
      genre: 'M', groupeSanguin: 'B+',
      telephone: '+237 691 23 45 67',
      age: 37,
      nbHopitaux: 3, nbPassages: 6, nbOrdonnancesActives: 2,
      passageActif: PassageActif(
        id: '9e2a4b8c-5678-4df1-bc23-112233445566',
        motif: 'Consultation Cardiologie',
        heure: '09:34',
        tension: '13/8', temperature: '37.2°',
        poids: '74 kg', pouls: '72',
        diagnostic: 'Hypertension artérielle stade 1.',
        prescription: 'Amlodipine 5 mg · Paracétamol 500 mg',
      ),
      antecedents: [
        Antecedent(
          titre: 'Allergie pénicilline',
          date: 'Signalé en Nov. 2024',
          type: 'allergie', tone: 'danger',
        ),
        Antecedent(
          titre: 'Hypertension légère',
          date: 'Dépistée en Mars 2026',
          type: 'maladie', tone: 'warning',
        ),
        Antecedent(
          titre: 'Hémogramme · GB élevés',
          date: '19 Mai 2026',
          type: 'examen', tone: 'primary',
        ),
      ],
      derniersPassages: [
        DernierPassage(
          titre: 'Urgence · Paludisme suspecté',
          hopital: 'Hôpital Général',
          date: '19 Mai 2026',
        ),
        DernierPassage(
          titre: 'Consultation Cardio',
          hopital: 'Clinique Pasteur',
          date: '02 Mars 2026',
        ),
        DernierPassage(
          titre: 'Contrôle annuel · RAS',
          hopital: 'Hôpital Central',
          date: '12 Nov 2025',
        ),
      ],
    );
  }

  Future<List<ActivitePro>> getActivites({int jours = 0}) async {
    await Future.delayed(_delay);
    final now = DateTime.now();
    return [
      ActivitePro(type: 'consult', label: 'Consultation Cardiologie',
          patient: 'TCHAMENI Jean', detail: 'Hypertension stade 1',
          tone: 'primary', date: now.subtract(const Duration(hours: 3))),
      ActivitePro(type: 'consult', label: 'Suivi diabéto',
          patient: 'NGO BIDIAS Léa', detail: 'Glycémie stable',
          tone: 'primary', date: now.subtract(const Duration(hours: 4))),
      ActivitePro(type: 'ord', label: 'Ordonnance rédigée',
          patient: 'KAMGA Patrick', detail: 'Amoxicilline 1g · 5j',
          tone: 'success', date: now.subtract(const Duration(hours: 5))),
      ActivitePro(type: 'exam', label: 'Examens prescrits',
          patient: 'TCHAMENI Jean', detail: 'ECG repos · bilan lipidique',
          tone: 'warning', date: now.subtract(const Duration(hours: 5, minutes: 30))),
      ActivitePro(type: 'diag', label: 'Diagnostic saisi',
          patient: 'EBALE Yolande', detail: 'Migraine ophtalmique',
          tone: 'primary', date: now.subtract(const Duration(hours: 6))),
      ActivitePro(type: 'consult', label: 'Consultation Cardio',
          patient: 'MBALLA Henri', detail: 'Suivi post-AVC',
          tone: 'primary', date: now.subtract(const Duration(days: 1, hours: 8))),
      ActivitePro(type: 'ord', label: 'Ordonnance rédigée',
          patient: 'NGO BIDIAS Léa', detail: 'Metformine 850 mg',
          tone: 'success', date: now.subtract(const Duration(days: 1, hours: 9))),
      ActivitePro(type: 'consult', label: 'Consultation',
          patient: 'OBAMA Marie', detail: 'Bilan annuel',
          tone: 'primary', date: now.subtract(const Duration(days: 2, hours: 13))),
    ].where((a) {
      if (jours == 0) {
        return a.date.day == now.day &&
            a.date.month == now.month &&
            a.date.year == now.year;
      }
      return a.date.isAfter(now.subtract(Duration(days: jours)));
    }).toList();
  }
}