/// Données fictives + modèles du parcours Patient.
///
/// Ces classes sont du Dart pur (aucune dépendance Flutter) afin de pouvoir
/// être remplacées plus tard par les modèles renvoyés par l'API (Dio).
/// Les écrans consomment uniquement les `mock*` ci-dessous : le jour où le
/// backend est branché, il suffira de remplacer ces constantes par des appels
/// réseau sans toucher à l'UI.

// ---------------------------------------------------------------------------
// Profil patient
// ---------------------------------------------------------------------------

class PatientProfile {
  final String prenom;
  final String nom;
  final String idFull;
  final String idShort;
  final String dateNaissance;
  final String genre; // "M" / "F"
  final String groupeSanguin;
  final String telephone;

  const PatientProfile({
    required this.prenom,
    required this.nom,
    required this.idFull,
    required this.idShort,
    required this.dateNaissance,
    required this.genre,
    required this.groupeSanguin,
    required this.telephone,
  });

  String get fullName => '$prenom $nom';
  String get fullNameUpper => '$prenom ${nom.toUpperCase()}';
  String get initials =>
      '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}';
}

const mockPatient = PatientProfile(
  prenom: 'Jean',
  nom: 'Tchameni',
  idFull: '8f3b9c2a-1234-4bc3-a716-446655440000',
  idShort: '8f3b···440000',
  dateNaissance: '14 Mai 1988',
  genre: 'M',
  groupeSanguin: 'B+',
  telephone: '+237 691 23 45 67',
);

// ---------------------------------------------------------------------------
// Passages (visites)
// ---------------------------------------------------------------------------

enum PassageStatut { enCours, urgence, consultation, controle, examen, termine }

class Constantes {
  final String tension; // "13/8"
  final String temperature; // "37.2"
  final String poids; // "74"
  final String pouls; // "72"
  final String? spo2; // "98"
  final String? freqResp; // "16"
  final String? prisPar; // "Infirmière · 09:42"

  const Constantes({
    required this.tension,
    required this.temperature,
    required this.poids,
    required this.pouls,
    this.spo2,
    this.freqResp,
    this.prisPar,
  });
}

class Medicament {
  final String nom; // "Amlodipine 5 mg"
  final String posologie; // "1 cp / jour · 30 jours"
  final int? prises; // 22
  final int? total; // 30
  final int? quantite; // 30 cp (vue pharmacien)

  const Medicament({
    required this.nom,
    required this.posologie,
    this.prises,
    this.total,
    this.quantite,
  });
}

class Examen {
  final String nom; // "Hémogramme (NFS)"
  final String statut; // "Publié" / "En attente"

  const Examen({required this.nom, required this.statut});
}

class Passage {
  final String id;
  final String motif; // "Consultation Cardiologie"
  final PassageStatut statut;
  final String typeLabel; // "Urgence", "Consultation Cardio", ...
  final String? resume; // "Hypertension légère"
  final String hopital;
  final String? service;
  final String date; // "19 Mai 2026"
  final String? heure; // "14:30"
  final String? medecin; // "Dr. Mballa"
  final String? diagnostic;
  final Constantes? constantes;
  final List<Medicament> prescription;
  final List<Examen> examens;

  const Passage({
    required this.id,
    required this.motif,
    required this.statut,
    required this.typeLabel,
    required this.hopital,
    required this.date,
    this.resume,
    this.service,
    this.heure,
    this.medecin,
    this.diagnostic,
    this.constantes,
    this.prescription = const [],
    this.examens = const [],
  });
}

/// Passage actuellement ouvert (affiché sur l'accueil + détail complet).
const mockPassageEnCours = Passage(
  id: '9e2a-5566',
  motif: 'Consultation Cardiologie',
  statut: PassageStatut.enCours,
  typeLabel: 'En cours',
  hopital: 'Hôpital Général',
  service: 'Cardiologie',
  date: "Aujourd'hui",
  heure: '09:34',
  medecin: 'Dr. Mballa',
  diagnostic:
  'Hypertension artérielle stade 1. Pas de signe de décompensation '
      'cardiaque. Recommandation : régime hyposodé et contrôle dans 2 semaines.',
  constantes: Constantes(
    tension: '13/8',
    temperature: '37.2',
    poids: '74',
    pouls: '72',
    spo2: '98',
    freqResp: '16',
    prisPar: 'Infirmière · 09:42',
  ),
  prescription: [
    Medicament(nom: 'Amlodipine 5 mg', posologie: '1 cp / jour · 30 jours'),
    Medicament(nom: 'Paracétamol 500 mg', posologie: 'Si douleur · Au besoin'),
  ],
  examens: [
    Examen(nom: 'Hémogramme (NFS)', statut: 'Publié'),
    Examen(nom: 'Bilan lipidique', statut: 'Publié'),
  ],
);

/// Historique médical (passages passés).
const mockHistorique = <Passage>[
  Passage(
    id: 'p-001',
    motif: 'Paludisme simple suspecté',
    statut: PassageStatut.urgence,
    typeLabel: 'Urgence',
    resume: 'Paludisme simple suspecté',
    hopital: 'Hôpital Général',
    date: '19 Mai 2026',
    heure: '14:30',
  ),
  Passage(
    id: 'p-002',
    motif: 'Hypertension légère',
    statut: PassageStatut.consultation,
    typeLabel: 'Consultation Cardio',
    resume: 'Hypertension légère',
    hopital: 'Clinique Pasteur',
    date: '02 Mars 2026',
    heure: '10:15',
  ),
  Passage(
    id: 'p-003',
    motif: 'Rien à signaler',
    statut: PassageStatut.controle,
    typeLabel: 'Contrôle annuel',
    resume: 'Rien à signaler',
    hopital: 'Hôpital Central',
    date: '12 Nov 2025',
    heure: '09:15',
  ),
  Passage(
    id: 'p-004',
    motif: 'Anémie modérée',
    statut: PassageStatut.examen,
    typeLabel: 'Examen sanguin',
    resume: 'Anémie modérée',
    hopital: 'Hôpital Général',
    date: '23 Jul 2025',
    heure: '16:45',
  ),
];

// ---------------------------------------------------------------------------
// Ordonnances
// ---------------------------------------------------------------------------

enum OrdonnanceStatut { active, expireBientot, terminee }

class Ordonnance {
  final String id;
  final String titre; // "Hypertension"
  final OrdonnanceStatut statut;
  final String badge; // "Expire dans 28 j", "Terminée"
  final String date; // "24 Mai 2026"
  final int nbMedicaments;
  final String medecin; // "Dr. Mballa"
  final String specialite; // "Cardio"
  final String? delivreLe;
  final String? expireLe;
  final String? delivreParInfo; // ligne de statut de délivrance
  final List<Medicament> medicaments;

  const Ordonnance({
    required this.id,
    required this.titre,
    required this.statut,
    required this.badge,
    required this.date,
    required this.nbMedicaments,
    required this.medecin,
    required this.specialite,
    this.delivreLe,
    this.expireLe,
    this.delivreParInfo,
    this.medicaments = const [],
  });

  bool get estArchivee => statut == OrdonnanceStatut.terminee;
}

const mockOrdonnances = <Ordonnance>[
  Ordonnance(
    id: 'OR-9F4A',
    titre: 'Hypertension',
    statut: OrdonnanceStatut.active,
    badge: 'Expire dans 28 j',
    date: '24 Mai 2026',
    nbMedicaments: 2,
    medecin: 'Dr. Mballa',
    specialite: 'Cardio',
    delivreLe: '24 Mai 2026',
    expireLe: '23 Juin 2026',
    delivreParInfo:
    'Délivrée par Pharm. F. Atangana le 24 Mai · 14:08. '
        'Pharmacie centrale · Hôpital Général.',
    medicaments: [
      Medicament(
        nom: 'Amlodipine 5 mg',
        posologie: '1 comprimé / jour · 30 jours',
        prises: 22,
        total: 30,
      ),
      Medicament(nom: 'Paracétamol 500 mg', posologie: 'Si douleur · Au besoin'),
    ],
  ),
  Ordonnance(
    id: 'OR-7B21',
    titre: 'Antalgiques · Migraine',
    statut: OrdonnanceStatut.expireBientot,
    badge: 'Expire dans 3 j',
    date: '19 Mai 2026',
    nbMedicaments: 1,
    medecin: 'Dr. Ngono',
    specialite: 'Généraliste',
    medicaments: [
      Medicament(nom: 'Ibuprofène 400 mg', posologie: '1 cp si douleur'),
    ],
  ),
  Ordonnance(
    id: 'OR-5C03',
    titre: 'Antipaludique',
    statut: OrdonnanceStatut.terminee,
    badge: 'Terminée',
    date: '02 Mai 2026',
    nbMedicaments: 3,
    medecin: 'Dr. Mballa',
    specialite: 'Cardio',
  ),
  Ordonnance(
    id: 'OR-4A88',
    titre: 'Antibiothérapie bronchite',
    statut: OrdonnanceStatut.terminee,
    badge: 'Terminée',
    date: '12 Nov 2025',
    nbMedicaments: 2,
    medecin: 'Dr. Tabi',
    specialite: 'Pneumo',
  ),
];

// ---------------------------------------------------------------------------
// Notifications
// ---------------------------------------------------------------------------

enum NotifType { examen, ordonnance, admission, dossier, securite }

class AppNotification {
  final NotifType type;
  final String titre;
  final String sousTitre;
  final String temps;
  final bool nonLu;
  final String groupe; // "Aujourd'hui", "Hier", "Cette semaine"

  const AppNotification({
    required this.type,
    required this.titre,
    required this.sousTitre,
    required this.temps,
    required this.groupe,
    this.nonLu = false,
  });
}

const mockNotifications = <AppNotification>[
  AppNotification(
    type: NotifType.examen,
    titre: "Nouveaux résultats d'examen",
    sousTitre: 'Hémogramme (NFS) publié par le laboratoire',
    temps: 'il y a 12 min',
    groupe: "Aujourd'hui",
    nonLu: true,
  ),
  AppNotification(
    type: NotifType.ordonnance,
    titre: 'Ordonnance bientôt expirée',
    sousTitre: 'Antalgiques · Migraine — expire dans 3 jours',
    temps: 'il y a 1 h',
    groupe: "Aujourd'hui",
    nonLu: true,
  ),
  AppNotification(
    type: NotifType.admission,
    titre: 'Admission enregistrée',
    sousTitre: 'Hôpital Général — Consultation Cardiologie',
    temps: '23 Mai · 09:30',
    groupe: 'Hier',
  ),
  AppNotification(
    type: NotifType.dossier,
    titre: 'Dossier consulté',
    sousTitre: 'Dr. Mballa a accédé à votre dossier',
    temps: '23 Mai · 09:34',
    groupe: 'Hier',
  ),
  AppNotification(
    type: NotifType.securite,
    titre: 'Connexion depuis un nouvel appareil',
    sousTitre: 'Samsung Galaxy A24 · Yaoundé',
    temps: '20 Mai · 18:42',
    groupe: 'Cette semaine',
  ),
];