class PassageEnAttente {
  final String idPassage;
  final String idPatient;
  final String nom;
  final String prenom;
  final String motifVisite;
  final String heure;
  final String hopital;
  final int    age;
  final String groupeSanguin;

  PassageEnAttente({
    required this.idPassage,
    required this.idPatient,
    required this.nom,
    required this.prenom,
    required this.motifVisite,
    required this.heure,
    required this.hopital,
    required this.age,
    required this.groupeSanguin,
  });

  String get nomComplet => '$prenom $nom';
  String get initiales  =>
      '${prenom.isNotEmpty ? prenom[0] : ''}'
          '${nom.isNotEmpty ? nom[0] : ''}'.toUpperCase();

  factory PassageEnAttente.fromJson(
      Map<String, dynamic> json) {
    return PassageEnAttente(
      idPassage:    json['idPassage']?.toString()    ?? '',
      idPatient:    json['idPatient']?.toString()    ?? '',
      nom:          json['nomPatient']?.toString()   ?? '',
      prenom:       json['prenomPatient']?.toString() ?? '',
      motifVisite:  json['motifVisite']?.toString()  ?? '',
      heure:        json['heure']?.toString()        ?? '',
      hopital:      json['hopital']?.toString()      ?? '',
      age:          (json['age'] as num?)?.toInt()   ?? 0,
      groupeSanguin:
      json['groupeSanguin']?.toString() ?? '',
    );
  }
}

class ExamenPublie {
  final String idExamen;
  final String idPassage;
  final String idPatient;
  final String nomPatient;
  final String prenomPatient;
  final String typeExamen;
  final String resultats;
  final String dateResultat;
  final String hopital;
  final int    age;
  final String groupeSanguin;

  ExamenPublie({
    required this.idExamen,
    required this.idPassage,
    required this.idPatient,
    required this.nomPatient,
    required this.prenomPatient,
    required this.typeExamen,
    required this.resultats,
    required this.dateResultat,
    required this.hopital,
    required this.age,
    required this.groupeSanguin,
  });

  String get nomComplet => '$prenomPatient $nomPatient';
  String get initiales  =>
      '${prenomPatient.isNotEmpty ? prenomPatient[0] : ''}'
          '${nomPatient.isNotEmpty ? nomPatient[0] : ''}'
          .toUpperCase();

  factory ExamenPublie.fromJson(
      Map<String, dynamic> json) {
    return ExamenPublie(
      idExamen:      json['idExamen']?.toString()      ?? '',
      idPassage:     json['idPassage']?.toString()     ?? '',
      idPatient:     json['idPatient']?.toString()     ?? '',
      nomPatient:    json['nomPatient']?.toString()    ?? '',
      prenomPatient: json['prenomPatient']?.toString() ?? '',
      typeExamen:    json['typeExamen']?.toString()    ?? '',
      resultats:     json['resultats']?.toString()     ?? '',
      dateResultat:  json['dateResultat']?.toString()  ?? '',
      hopital:       json['hopital']?.toString()       ?? '',
      age:           (json['age'] as num?)?.toInt()    ?? 0,
      groupeSanguin:
      json['groupeSanguin']?.toString() ?? '',
    );
  }
}

class StatsLabo {
  final int total;
  final int enAttente;

  StatsLabo({required this.total, required this.enAttente});

  factory StatsLabo.fromJson(Map<String, dynamic> json) {
    return StatsLabo(
      total:     (json['total']     as num?)?.toInt() ?? 0,
      enAttente: (json['en_attente'] as num?)?.toInt() ?? 0,
    );
  }
}