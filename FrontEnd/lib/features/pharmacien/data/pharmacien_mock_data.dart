// Données fictives + modèles du parcours Pharmacien.
// Dart pur, sans dépendance Flutter.

// ---------------------------------------------------------------------------
// Profil pharmacien
// ---------------------------------------------------------------------------

class PharmacienProfile {
  final String prenom;
  final String nom;
  final String service;

  const PharmacienProfile({
    required this.prenom,
    required this.nom,
    required this.service,
  });

  factory PharmacienProfile.fromJson(Map<String, dynamic> json) {
    return PharmacienProfile(
      prenom: json['prenom'] ?? '',
      nom: json['nom'] ?? '',
      service: json['role'] ?? 'Pharmacien',
    );
  }

  String get fullName => '$prenom $nom';
  String get displayName => '$prenom $nom';
  String get initials =>
      '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}';
  // Initiales de "Florence Atangana" → FA
  String get shortName =>
      '${prenom.isNotEmpty ? prenom[0] : ''}. ${nom.split(' ').last}';
}

const mockPharmacien = PharmacienProfile(
  prenom: 'Florence',
  nom: 'Atangana',
  service: 'Pharmacie centrale',
);

// ---------------------------------------------------------------------------
// Médicament dans une ordonnance
// ---------------------------------------------------------------------------

class MedicamentItem {
  final String nom;
  final String quantite;
  final String posologie;
  final bool stockOk;

  const MedicamentItem({
    required this.nom,
    required this.quantite,
    required this.posologie,
    this.stockOk = true,
  });
}

// ---------------------------------------------------------------------------
// Ordonnances en attente
// ---------------------------------------------------------------------------

class OrdonnanceItem {
  final String initials;
  final String patient;
  final String diagnostic;
  final int nbMedicaments;
  final String tempsEcoule;
  final bool isUrgent;
  // Champs détail
  final String ordonnanceId;
  final String allergies;
  final String medecinInitials;
  final String medecinNom;
  final String medecinService;
  final String dateOrdonnance;
  final String diagnosticComplet;
  final List<MedicamentItem> medicaments;

  const OrdonnanceItem({
    required this.initials,
    required this.patient,
    required this.diagnostic,
    required this.nbMedicaments,
    required this.tempsEcoule,
    this.isUrgent = false,
    required this.ordonnanceId,
    this.allergies = '',
    required this.medecinInitials,
    required this.medecinNom,
    required this.medecinService,
    required this.dateOrdonnance,
    required this.diagnosticComplet,
    required this.medicaments,
  });

  factory OrdonnanceItem.fromJson(Map<String, dynamic> json) {
    return OrdonnanceItem(
      initials: (json['patientName'] ?? 'XX').split(' ').map((e) => e[0]).join(),
      patient: json['patientName'] ?? 'Inconnu',
      diagnostic: json['titre'] ?? 'Aucun',
      nbMedicaments: (json['medicaments'] as List).length,
      tempsEcoule: 'Maintenant',
      ordonnanceId: json['idOrdonnance'] ?? '',
      medecinInitials: 'Dr',
      medecinNom: json['medecinNom'] ?? 'Inconnu',
      medecinService: json['specialite'] ?? '',
      dateOrdonnance: json['dateDelivrance'] ?? '',
      diagnosticComplet: json['titre'] ?? '',
      medicaments: (json['medicaments'] as List)
          .map((m) => MedicamentItem(
                nom: m['nom'],
                quantite: '${m['comprimesTotaux']} cp',
                posologie: m['posologie'],
              ))
          .toList(),
    );
  }
}

const mockOrdonnances = <OrdonnanceItem>[
  OrdonnanceItem(
    initials: 'TJ',
    patient: 'TCHAMENI Jean',
    diagnostic: 'Hypertension',
    nbMedicaments: 2,
    tempsEcoule: 'il y a 5 min',
    ordonnanceId: 'OR-9F4A',
    allergies: 'Pénicilline',
    medecinInitials: 'AM',
    medecinNom: 'Dr. Mballa Alphonse',
    medecinService: 'Cardiologie · Hôpital Général',
    dateOrdonnance: '24/05 · 11:08',
    diagnosticComplet:
        'Hypertension artérielle stade 1. Contrôle dans 2 sem.',
    medicaments: [
      MedicamentItem(
        nom: 'Amlodipine 5 mg',
        quantite: '30 cp',
        posologie: '1 cp / jour · 30 jours',
      ),
      MedicamentItem(
        nom: 'Paracétamol 500 mg',
        quantite: '20 cp',
        posologie: 'Si douleur · Au besoin',
      ),
    ],
  ),
  OrdonnanceItem(
    initials: 'NB',
    patient: 'NGO BIDIAS Léa',
    diagnostic: 'Suivi diabète',
    nbMedicaments: 3,
    tempsEcoule: 'il y a 18 min',
    isUrgent: true,
    ordonnanceId: 'OR-2C1E',
    allergies: '',
    medecinInitials: 'FK',
    medecinNom: 'Dr. Fotso Kenfack',
    medecinService: 'Endocrinologie · Hôpital Central',
    dateOrdonnance: '24/05 · 11:25',
    diagnosticComplet: 'Diabète type 2. Contrôle glycémique insuffisant.',
    medicaments: [
      MedicamentItem(
        nom: 'Metformine 850 mg',
        quantite: '60 cp',
        posologie: '2 cp / jour · 30 jours',
      ),
      MedicamentItem(
        nom: 'Vitamine D3 1000 UI',
        quantite: '30 cp',
        posologie: '1 cp / jour',
      ),
      MedicamentItem(
        nom: 'Acide folique 5 mg',
        quantite: '30 cp',
        posologie: '1 cp / jour',
      ),
    ],
  ),
  OrdonnanceItem(
    initials: 'KP',
    patient: 'KAMGA Patrick',
    diagnostic: 'Bronchite aiguë',
    nbMedicaments: 4,
    tempsEcoule: 'il y a 32 min',
    ordonnanceId: 'OR-7B3D',
    allergies: '',
    medecinInitials: 'NS',
    medecinNom: 'Dr. Nkomo Simon',
    medecinService: 'Pneumologie · Clinique Pasteur',
    dateOrdonnance: '24/05 · 11:10',
    diagnosticComplet: 'Bronchite aiguë bactérienne. Pas d\'antécédents.',
    medicaments: [
      MedicamentItem(
        nom: 'Amoxicilline 500 mg',
        quantite: '21 cp',
        posologie: '3 cp / jour · 7 jours',
      ),
      MedicamentItem(
        nom: 'Ibuprofène 400 mg',
        quantite: '14 cp',
        posologie: '2 cp / jour · 7 jours',
      ),
      MedicamentItem(
        nom: 'Bromhexine 8 mg',
        quantite: '21 cp',
        posologie: '3 cp / jour · 7 jours',
      ),
      MedicamentItem(
        nom: 'Salbutamol spray',
        quantite: '1 fl',
        posologie: '2 bouffées / 6h si besoin',
      ),
    ],
  ),
  OrdonnanceItem(
    initials: 'EY',
    patient: 'EBALE Yolande',
    diagnostic: 'Antalgiques',
    nbMedicaments: 1,
    tempsEcoule: 'il y a 1 h',
    ordonnanceId: 'OR-4A8F',
    allergies: '',
    medecinInitials: 'MB',
    medecinNom: 'Dr. Mbarga Benoît',
    medecinService: 'Médecine générale · Hôpital Général',
    dateOrdonnance: '24/05 · 10:42',
    diagnosticComplet: 'Douleurs lombaires chroniques.',
    medicaments: [
      MedicamentItem(
        nom: 'Paracétamol 1 g',
        quantite: '30 cp',
        posologie: '1 cp / 6h · max 4/jour',
      ),
    ],
  ),
];

// ---------------------------------------------------------------------------
// Mon activité
// ---------------------------------------------------------------------------

enum PharmacienActivityKind { delivrance, refus }

class PharmacienActivity {
  final String heure;
  final PharmacienActivityKind kind;
  final String titre;
  final String patient;
  final String details;

  const PharmacienActivity({
    required this.heure,
    required this.kind,
    required this.titre,
    required this.patient,
    required this.details,
  });
}

const mockPharmacienActivities = <PharmacienActivity>[
  PharmacienActivity(
    heure: '14:08',
    kind: PharmacienActivityKind.delivrance,
    titre: 'Délivrance',
    patient: 'TCHAMENI Jean',
    details: 'Amlodipine + Paracétamol',
  ),
  PharmacienActivity(
    heure: '12:30',
    kind: PharmacienActivityKind.delivrance,
    titre: 'Délivrance',
    patient: 'NGO BIDIAS Léa',
    details: 'Metformine 850 mg',
  ),
  PharmacienActivity(
    heure: '11:15',
    kind: PharmacienActivityKind.refus,
    titre: 'Délivrance refusée',
    patient: 'KAMGA Patrick',
    details: 'Ordonnance non valide',
  ),
  PharmacienActivity(
    heure: '10:00',
    kind: PharmacienActivityKind.delivrance,
    titre: 'Délivrance',
    patient: 'EBALE Yolande',
    details: 'Ibuprofène 400 mg',
  ),
];
