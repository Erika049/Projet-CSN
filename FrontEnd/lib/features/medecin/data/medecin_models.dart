class PatientDuJour {
  final String id;
  final String nom;
  final String prenom;
  final String motif;
  final String heure;
  final String statut; // en_attente | en_cours | termine | a_venir | urgence
  final String? idPassage;

  const PatientDuJour({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.motif,
    required this.heure,
    required this.statut,
    this.idPassage,
  });

  String get nomComplet => '$prenom $nom';
  String get initiales =>
      '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}'
          .toUpperCase();
}

class DossierPatient {
  final String id;
  final String nom;
  final String prenom;
  final String dateNaissance;
  final String genre;
  final String groupeSanguin;
  final String telephone;
  final int age;
  final int nbHopitaux;
  final int nbPassages;
  final int nbOrdonnancesActives;
  final PassageActif? passageActif;
  final List<Antecedent> antecedents;
  final List<DernierPassage> derniersPassages;

  const DossierPatient({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.genre,
    required this.groupeSanguin,
    required this.telephone,
    required this.age,
    required this.nbHopitaux,
    required this.nbPassages,
    required this.nbOrdonnancesActives,
    this.passageActif,
    required this.antecedents,
    required this.derniersPassages,
  });

  String get nomComplet => '$prenom $nom';
  String get initiales =>
      '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}'
          .toUpperCase();
}

class PassageActif {
  final String id;
  final String motif;
  final String heure;
  final String? tension;
  final String? temperature;
  final String? poids;
  final String? pouls;
  final String? diagnostic;
  final String? prescription;

  const PassageActif({
    required this.id,
    required this.motif,
    required this.heure,
    this.tension,
    this.temperature,
    this.poids,
    this.pouls,
    this.diagnostic,
    this.prescription,
  });
}

class Antecedent {
  final String titre;
  final String date;
  final String type; // allergie | maladie | examen
  final String tone; // danger | warning | primary

  const Antecedent({
    required this.titre,
    required this.date,
    required this.type,
    required this.tone,
  });
}

class DernierPassage {
  final String titre;
  final String hopital;
  final String date;

  const DernierPassage({
    required this.titre,
    required this.hopital,
    required this.date,
  });
}

class ConsultationData {
  final String idPassage;
  final String diagnostic;
  final String prescription;
  final List<MedicamentConsult> medicaments;
  final List<String> examens;
  final bool cloturerPassage;

  const ConsultationData({
    required this.idPassage,
    required this.diagnostic,
    required this.prescription,
    required this.medicaments,
    required this.examens,
    required this.cloturerPassage,
  });
}

class MedicamentConsult {
  final String nom;
  final String posologie;

  const MedicamentConsult({
    required this.nom,
    required this.posologie,
  });
}

class ActivitePro {
  final String type;
  final String label;
  final String patient;
  final String detail;
  final String tone;
  final DateTime date;

  const ActivitePro({
    required this.type,
    required this.label,
    required this.patient,
    required this.detail,
    required this.tone,
    required this.date,
  });
}