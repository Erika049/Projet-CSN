/// Données fictives + modèles du parcours Infirmier.
///
/// Dart pur, sans dépendance Flutter.

// ---------------------------------------------------------------------------
// Profil infirmier
// ---------------------------------------------------------------------------

class InfirmierProfile {
  final String prenom;
  final String nom;
  final String service;
  final String bloc;

  const InfirmierProfile({
    required this.prenom,
    required this.nom,
    required this.service,
    required this.bloc,
  });

  String get fullName => '$prenom $nom';
  String get displayName => 'Inf. $prenom $nom';
  String get initials =>
      '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}';
  String get lieu => '$service · $bloc';
}

const mockInfirmier = InfirmierProfile(
  prenom: 'Marie',
  nom: 'Onana',
  service: 'Cardiologie',
  bloc: 'Bloc B',
);

// ---------------------------------------------------------------------------
// Passage à constanter
// ---------------------------------------------------------------------------

enum PassageUrgence { normal, urgence }

class PassageAConstanter {
  final String initials;
  final String nom;
  final String service;
  final String lit;
  final String heure;
  final PassageUrgence urgence;

  const PassageAConstanter({
    required this.initials,
    required this.nom,
    required this.service,
    required this.lit,
    required this.heure,
    this.urgence = PassageUrgence.normal,
  });

  bool get isUrgence => urgence == PassageUrgence.urgence;
}

const mockPassages = <PassageAConstanter>[
  PassageAConstanter(
    initials: 'TJ',
    nom: 'TCHAMENI Jean',
    service: 'Cardiologie',
    lit: 'Lit B-14',
    heure: '09:34',
  ),
  PassageAConstanter(
    initials: 'MH',
    nom: 'MBALLA Henri',
    service: 'Urgence trauma',
    lit: 'Lit URG-3',
    heure: '11:15',
    urgence: PassageUrgence.urgence,
  ),
  PassageAConstanter(
    initials: 'NB',
    nom: 'NGO BIDIAS Léa',
    service: 'Diabéto',
    lit: 'Lit D-08',
    heure: '10:00',
  ),
];

// ---------------------------------------------------------------------------
// Constantes vitales du patient courant (pré-remplies pour la démo)
// ---------------------------------------------------------------------------

class ConstantesVitales {
  final String tension;
  final String temperature;
  final String poids;
  final String freqCardiaque;
  final String spo2;
  final String freqRespi;
  final String noteInfirmiere;

  const ConstantesVitales({
    required this.tension,
    required this.temperature,
    required this.poids,
    required this.freqCardiaque,
    required this.spo2,
    required this.freqRespi,
    required this.noteInfirmiere,
  });
}

const mockConstantes = ConstantesVitales(
  tension: '13/8',
  temperature: '37.2',
  poids: '74',
  freqCardiaque: '72',
  spo2: '98',
  freqRespi: '16',
  noteInfirmiere:
      'Patient calme, légère fatigue. Pas de douleur thoracique signalée...',
);

// ---------------------------------------------------------------------------
// Mon activité (journal des soins)
// ---------------------------------------------------------------------------

enum InfirmierActivityKind { constantes, urgence, soin, injection }

class InfirmierActivity {
  final String heure;
  final InfirmierActivityKind kind;
  final String titre;
  final String patient;
  final String details;

  const InfirmierActivity({
    required this.heure,
    required this.kind,
    required this.titre,
    required this.patient,
    required this.details,
  });
}

const mockInfirmierActivities = <InfirmierActivity>[
  InfirmierActivity(
    heure: '11:50',
    kind: InfirmierActivityKind.constantes,
    titre: 'Constantes prises',
    patient: 'TCHAMENI Jean',
    details: 'Tension 13/8 · 37.2°',
  ),
  InfirmierActivity(
    heure: '10:30',
    kind: InfirmierActivityKind.constantes,
    titre: 'Constantes prises',
    patient: 'NGO BIDIAS Léa',
    details: 'Pouls 76 · SpO₂ 98%',
  ),
  InfirmierActivity(
    heure: '09:45',
    kind: InfirmierActivityKind.soin,
    titre: 'Pansement réalisé',
    patient: 'KAMGA Patrick',
    details: 'Plaie post-op',
  ),
  InfirmierActivity(
    heure: '09:10',
    kind: InfirmierActivityKind.urgence,
    titre: 'Constantes urgence',
    patient: 'MBALLA Henri',
    details: 'TA basse · 9/5',
  ),
  InfirmierActivity(
    heure: '08:25',
    kind: InfirmierActivityKind.injection,
    titre: 'Injection IV',
    patient: 'OBAMA Marie',
    details: '',
  ),
];