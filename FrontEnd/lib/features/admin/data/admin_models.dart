class AdminStats {
  final int nbPatients;
  final int nbPersonnel;
  final int nbHopitaux;
  final int nbPassagesAujourdhui;
  final int nbExamensAujourdhui;

  AdminStats({
    required this.nbPatients,
    required this.nbPersonnel,
    required this.nbHopitaux,
    required this.nbPassagesAujourdhui,
    required this.nbExamensAujourdhui,
  });

  factory AdminStats.fromJson(
      Map<String, dynamic> json) {
    return AdminStats(
      nbPatients: (json['nbPatients'] as num?)
          ?.toInt() ?? 0,
      nbPersonnel: (json['nbPersonnel'] as num?)
          ?.toInt() ?? 0,
      nbHopitaux: (json['nbHopitaux'] as num?)
          ?.toInt() ?? 0,
      nbPassagesAujourdhui:
      (json['nbPassagesAujourdhui'] as num?)
          ?.toInt() ?? 0,
      nbExamensAujourdhui:
      (json['nbExamensAujourdhui'] as num?)
          ?.toInt() ?? 0,
    );
  }
}

class PersonnelAdmin {
  final String  idPersonnel;
  final String  nom;
  final String  prenom;
  final String  role;
  final String  identifiantPro;
  final String  hopital;
  final String? idHopital;
  final bool    estActif;

  PersonnelAdmin({
    required this.idPersonnel,
    required this.nom,
    required this.prenom,
    required this.role,
    required this.identifiantPro,
    required this.hopital,
    this.idHopital,
    required this.estActif,
  });

  String get nomComplet => '$prenom $nom';
  String get initiales  =>
      '${prenom.isNotEmpty ? prenom[0] : ''}'
          '${nom.isNotEmpty ? nom[0] : ''}'
          .toUpperCase();

  factory PersonnelAdmin.fromJson(
      Map<String, dynamic> json) {
    return PersonnelAdmin(
      idPersonnel:    json['idPersonnel']
          ?.toString() ?? '',
      nom:            json['nom']
          ?.toString() ?? '',
      prenom:         json['prenom']
          ?.toString() ?? '',
      role:           json['role']
          ?.toString() ?? '',
      identifiantPro: json['identifiantPro']
          ?.toString() ?? '',
      hopital:        json['hopital']
          ?.toString() ?? '',
      idHopital:      json['idHopital']
          ?.toString(),
      estActif: json['estActif'] as bool? ?? true,
    );
  }
}

class HopitalAdmin {
  final String idHopital;
  final String nom;
  final String adresse;
  final String codeUnique;
  final int    nbPersonnel;

  HopitalAdmin({
    required this.idHopital,
    required this.nom,
    required this.adresse,
    required this.codeUnique,
    required this.nbPersonnel,
  });

  factory HopitalAdmin.fromJson(
      Map<String, dynamic> json) {
    return HopitalAdmin(
      idHopital:   json['idHopital']?.toString()  ?? '',
      nom:         json['nom']?.toString()         ?? '',
      adresse:     json['adresse']?.toString()     ?? '',
      codeUnique:  json['codeUnique']?.toString()  ?? '',
      nbPersonnel:
      (json['nbPersonnel'] as num?)?.toInt() ?? 0,
    );
  }
}

class LogAdmin {
  final String  idLog;
  final String  nomPersonnel;
  final String? idPatient;
  final String  actionEffectuee;
  final String? adresseIp;
  final String  horodatage;

  LogAdmin({
    required this.idLog,
    required this.nomPersonnel,
    this.idPatient,
    required this.actionEffectuee,
    this.adresseIp,
    required this.horodatage,
  });

  factory LogAdmin.fromJson(
      Map<String, dynamic> json) {
    return LogAdmin(
      idLog:           json['idLog']?.toString()           ?? '',
      nomPersonnel:    json['nomPersonnel']?.toString()    ?? 'Système',
      idPatient:       json['idPatient']?.toString(),
      actionEffectuee: json['actionEffectuee']?.toString() ?? '',
      adresseIp:       json['adresseIp']?.toString(),
      horodatage:      json['horodatage']?.toString()      ?? '',
    );
  }
}