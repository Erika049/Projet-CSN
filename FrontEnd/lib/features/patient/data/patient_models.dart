// Modèles de données Patient — utilisés par l'UI et appels API

class Patient {
  final String  id;
  final String  nom;
  final String  prenom;
  final String  dateNaissance;
  final String  genre;
  final String  groupeSanguin;
  final String  telephone;
  final String? email;
  final String? photoUrl;
  final String? urgenceNom;
  final String? urgenceTelephone;
  final CarteNumerique carte;

  const Patient({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.genre,
    required this.groupeSanguin,
    required this.telephone,
    this.email,
    this.photoUrl,
    this.urgenceNom,
    this.urgenceTelephone,
    required this.carte,
  });

  String get nomComplet => '$prenom $nom';
  String get initiales =>
      '${prenom.isNotEmpty ? prenom[0] : ''}'
          '${nom.isNotEmpty ? nom[0] : ''}'.toUpperCase();
}

class CarteNumerique {
  final String qrCodeToken;
  final String statut;
  final String expireAnnee;
  final String expireMois;

  const CarteNumerique({
    required this.qrCodeToken,
    required this.statut,
    required this.expireAnnee,
    required this.expireMois,
  });

  bool   get estActive  => statut == 'actif';
  String get expiration => '$expireMois/$expireAnnee';
}

class PassageMedical {
  final String id;
  final String hopital;
  final String service;
  final String dateAdmission;
  final String heureAdmission;
  final String motifVisite;
  final String statut;
  final String? medecin;
  final ConstantesVitales? constantes;
  final String? diagnostic;
  final String? prescription;
  final List<ExamenLabo> examens;

  const PassageMedical({
    required this.id,
    required this.hopital,
    required this.service,
    required this.dateAdmission,
    required this.heureAdmission,
    required this.motifVisite,
    required this.statut,
    this.medecin,
    this.constantes,
    this.diagnostic,
    this.prescription,
    this.examens = const [],
  });

  bool get estEnCours => statut == 'en_cours';
}

class ConstantesVitales {
  final String? tension;
  final String? temperature;
  final String? poids;
  final String? pouls;
  final String? spo2;
  final String? freqRespi;

  const ConstantesVitales({
    this.tension,
    this.temperature,
    this.poids,
    this.pouls,
    this.spo2,
    this.freqRespi,
  });
}

class ExamenLabo {
  final String id;
  final String type;
  final String resultats;
  final String dateResultat;

  const ExamenLabo({
    required this.id,
    required this.type,
    required this.resultats,
    required this.dateResultat,
  });
}

class Ordonnance {
  final String id;
  final String titre;
  final String medecin;
  final String specialite;
  final String dateDelivrance;
  final String dateExpiration;
  final String statut;
  final int    joursRestants;
  final List<Medicament> medicaments;

  const Ordonnance({
    required this.id,
    required this.titre,
    required this.medecin,
    required this.specialite,
    required this.dateDelivrance,
    required this.dateExpiration,
    required this.statut,
    required this.joursRestants,
    required this.medicaments,
  });

  bool get estActive => statut == 'active';
}

class Medicament {
  final String nom;
  final String posologie;
  final int?   comprimesRestants;
  final int?   comprimesTotaux;

  const Medicament({
    required this.nom,
    required this.posologie,
    this.comprimesRestants,
    this.comprimesTotaux,
  });
}

class Notification {
  final String id;
  final String titre;
  final String message;
  final String temps;
  final String type;
  final bool   lue;

  const Notification({
    required this.id,
    required this.titre,
    required this.message,
    required this.temps,
    required this.type,
    this.lue = false,
  });
}