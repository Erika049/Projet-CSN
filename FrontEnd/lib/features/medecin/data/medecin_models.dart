class PatientDuJour {
  final String idPassage;
  final String idPatient;
  final String nom;
  final String prenom;
  final String motifVisite;
  final String heure;
  final String statut;
  final String groupeSanguin;
  final int age;

  PatientDuJour({
    required this.idPassage,
    required this.idPatient,
    required this.nom,
    required this.prenom,
    required this.motifVisite,
    required this.heure,
    required this.statut,
    required this.groupeSanguin,
    required this.age,
  });

  String get nomComplet => '$prenom $nom';
  String get initiales =>
      '${prenom.isNotEmpty ? prenom[0] : ''}'
          '${nom.isNotEmpty ? nom[0] : ''}'.toUpperCase();

  factory PatientDuJour.fromJson(Map<String, dynamic> json) {
    return PatientDuJour(
      idPassage:     json['idPassage']?.toString()     ?? '',
      idPatient:     json['idPatient']?.toString()     ?? '',
      nom:           json['nom']?.toString()           ?? '',
      prenom:        json['prenom']?.toString()        ?? '',
      motifVisite:   json['motifVisite']?.toString()   ?? '',
      heure:         json['heure']?.toString()         ?? '',
      statut:        json['statut']?.toString()        ?? '',
      groupeSanguin: json['groupeSanguin']?.toString() ?? '',
      age:           (json['age'] as num?)?.toInt()    ?? 0,
    );
  }
}

class StatsDuJour {
  final int total;
  final int enCours;
  final int urgences;

  StatsDuJour({
    required this.total,
    required this.enCours,
    required this.urgences,
  });

  factory StatsDuJour.fromJson(Map<String, dynamic> json) {
    return StatsDuJour(
      total:    (json['total']    as num?)?.toInt() ?? 0,
      enCours:  (json['en_cours'] as num?)?.toInt() ?? 0,
      urgences: (json['urgences'] as num?)?.toInt() ?? 0,
    );
  }
}

class PassageDetail {
  final String idPassage;
  final String nomPatient;
  final String prenomPatient;
  final String idPatient;
  final String hopital;
  final String motifVisite;
  final String dateAdmission;
  final String statut;
  final Map<String, dynamic>? constantesVitales;
  final String? diagnostic;
  final String? prescriptionOrdonnance;

  PassageDetail({
    required this.idPassage,
    required this.nomPatient,
    required this.prenomPatient,
    required this.idPatient,
    required this.hopital,
    required this.motifVisite,
    required this.dateAdmission,
    required this.statut,
    this.constantesVitales,
    this.diagnostic,
    this.prescriptionOrdonnance,
  });

  String get nomComplet => '$prenomPatient $nomPatient';
  bool get estEnCours => statut == 'en_cours';

  factory PassageDetail.fromJson(Map<String, dynamic> json) {
    return PassageDetail(
      idPassage:     json['idPassage']?.toString()     ?? '',
      nomPatient:    json['nomPatient']?.toString()    ?? '',
      prenomPatient: json['prenomPatient']?.toString() ?? '',
      idPatient:     json['idPatient']?.toString()     ?? '',
      hopital:       json['hopital']?.toString()       ?? '',
      motifVisite:   json['motifVisite']?.toString()   ?? '',
      dateAdmission: json['dateAdmission']?.toString() ?? '',
      statut:        json['statut']?.toString()        ?? '',
      constantesVitales:
      json['constantesVitales'] as Map<String, dynamic>?,
      diagnostic:            json['diagnostic']?.toString(),
      prescriptionOrdonnance:
      json['prescriptionOrdonnance']?.toString(),
    );
  }
}

class ActivitePro {
  final String idPassage;
  final String type;
  final String label;
  final String patient;
  final String detail;
  final String tone;
  final String date;

  ActivitePro({
    required this.idPassage,
    required this.type,
    required this.label,
    required this.patient,
    required this.detail,
    required this.tone,
    required this.date,
  });

  factory ActivitePro.fromJson(Map<String, dynamic> json) {
    return ActivitePro(
      idPassage: json['idPassage']?.toString() ?? '',
      type:      json['type']?.toString()      ?? '',
      label:     json['label']?.toString()     ?? '',
      patient:   json['patient']?.toString()   ?? '',
      detail:    json['detail']?.toString()    ?? '',
      tone:      json['tone']?.toString()      ?? 'primary',
      date:      json['date']?.toString()      ?? '',
    );
  }
}