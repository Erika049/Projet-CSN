/// Données fictives + modèles du parcours Agent d'accueil.
///
/// Dart pur, sans dépendance Flutter, pour pouvoir être remplacé directement
/// par les modèles de l'API plus tard.

// ---------------------------------------------------------------------------
// Profil agent
// ---------------------------------------------------------------------------

class AgentProfile {
  final String prenom;
  final String nom;
  final String poste;
  final String lieu;

  const AgentProfile({
    required this.prenom,
    required this.nom,
    required this.poste,
    required this.lieu,
  });

  String get fullName => '$prenom $nom';
  String get initials =>
      '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}';
}

const mockAgent = AgentProfile(
  prenom: 'Brice',
  nom: 'Ngono',
  poste: "Agent d'accueil",
  lieu: 'Accueil · Hôp. Général',
);

// ---------------------------------------------------------------------------
// Admissions du jour (dashboard)
// ---------------------------------------------------------------------------

enum AdmissionStatut { ok, urgence }

class Admission {
  final String initials;
  final String nom;
  final String service;
  final String heure;
  final AdmissionStatut statut;

  const Admission({
    required this.initials,
    required this.nom,
    required this.service,
    required this.heure,
    required this.statut,
  });
}

const mockAdmissions = <Admission>[
  Admission(
    initials: 'TJ',
    nom: 'TCHAMENI Jean',
    service: 'Cardiologie',
    heure: '09:34',
    statut: AdmissionStatut.ok,
  ),
  Admission(
    initials: 'NB',
    nom: 'NGO BIDIAS Léa',
    service: 'Diabéto',
    heure: '10:00',
    statut: AdmissionStatut.ok,
  ),
  Admission(
    initials: 'EY',
    nom: 'EBALE Yolande',
    service: 'Cardiologie',
    heure: '10:30',
    statut: AdmissionStatut.ok,
  ),
  Admission(
    initials: 'MH',
    nom: 'MBALLA Henri',
    service: 'Urgence trauma',
    heure: '11:15',
    statut: AdmissionStatut.urgence,
  ),
];

// ---------------------------------------------------------------------------
// Patient identifié après un scan (écran de confirmation)
// ---------------------------------------------------------------------------

class IdentifiedPatient {
  final String id; // UUID réel du patient (requis pour créer un passage)
  final String nom;
  final String idShort;
  final String dateNaissance;
  final String age;
  final String groupe;
  final String telephone;
  final String dernierPassage;
  final String initials;

  const IdentifiedPatient({
    required this.id,
    required this.nom,
    required this.idShort,
    required this.dateNaissance,
    required this.age,
    required this.groupe,
    required this.telephone,
    required this.dernierPassage,
    required this.initials,
  });
}

const mockIdentifiedPatient = IdentifiedPatient(
  id: '8f3b9c2a-1234-4bc3-a716-446655440000',
  nom: 'TCHAMENI Jean',
  idShort: '8f3b9c2a···440000',
  dateNaissance: '14/05/88',
  age: '37 ans',
  groupe: 'B+',
  telephone: '+237 691 23 45 67',
  dernierPassage: 'il y a 11 sem.',
  initials: 'JT',
);

// ---------------------------------------------------------------------------
// Mon activité (journal des actions)
// ---------------------------------------------------------------------------

enum ActivityKind { scan, creation, urgence }

class ActivityEntry {
  final String heure;
  final ActivityKind kind;
  final String titre;
  final String patient;
  final String details;

  const ActivityEntry({
    required this.heure,
    required this.kind,
    required this.titre,
    required this.patient,
    required this.details,
  });
}

const mockActivities = <ActivityEntry>[
  ActivityEntry(
    heure: '09:34',
    kind: ActivityKind.scan,
    titre: 'Scan QR validé',
    patient: 'TCHAMENI Jean',
    details: 'Admission Cardiologie',
  ),
  ActivityEntry(
    heure: '10:05',
    kind: ActivityKind.scan,
    titre: 'Scan QR validé',
    patient: 'NGO BIDIAS Léa',
    details: 'Admission Diabéto',
  ),
  ActivityEntry(
    heure: '10:32',
    kind: ActivityKind.creation,
    titre: 'Passage créé',
    patient: 'EBALE Yolande',
    details: 'Consultation Cardio',
  ),
  ActivityEntry(
    heure: '11:15',
    kind: ActivityKind.urgence,
    titre: 'Admission urgence',
    patient: 'MBALLA Henri',
    details: 'Trauma · prio. 1',
  ),
  ActivityEntry(
    heure: '11:40',
    kind: ActivityKind.creation,
    titre: 'Nouveau patient',
    patient: 'NDJOMO Carine',
    details: 'Première inscription',
  ),
];