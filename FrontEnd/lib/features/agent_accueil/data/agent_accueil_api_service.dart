import 'package:dio/dio.dart';
import '../../../core/api/api.dart';

// ---------------------------------------------------------------------------
// Modèle profil agent (GET /personnel/{id}/profil)
// ---------------------------------------------------------------------------

class AgentProfilApi {
  final int     idPersonnel;
  final String  nom;
  final String  prenom;
  final String  role;
  final String  identifiantPro;
  final int?    idHopital;
  final String? nomHopital;
  final String? adresseHopital;

  const AgentProfilApi({
    required this.idPersonnel,
    required this.nom,
    required this.prenom,
    required this.role,
    required this.identifiantPro,
    this.idHopital,
    this.nomHopital,
    this.adresseHopital,
  });

  String get fullName   => '$prenom $nom';
  String get initials   => '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}';
  String get posteLabel => _roleLabel(role);
  String get lieuLabel  => nomHopital ?? 'Établissement';

  static String _roleLabel(String role) {
    switch (role) {
      case 'accueil':    return "Agent d'accueil";
      case 'infirmier':  return 'Infirmier(e)';
      case 'medecin':    return 'Médecin';
      case 'pharmacien': return 'Pharmacien(ne)';
      case 'laborantin': return 'Laborantin(e)';
      case 'admin':      return 'Administrateur';
      default:           return role;
    }
  }

  factory AgentProfilApi.fromJson(Map<String, dynamic> json) => AgentProfilApi(
        idPersonnel:    json['idPersonnel']    as int,
        nom:            json['nom']            as String,
        prenom:         json['prenom']         as String,
        role:           json['role']           as String,
        identifiantPro: json['identifiantPro'] as String,
        idHopital:      json['idHopital']      as int?,
        nomHopital:     json['nomHopital']     as String?,
        adresseHopital: json['adresseHopital'] as String?,
      );
}

// ---------------------------------------------------------------------------
// Modèle patient identifié après scan (POST /admission/scan-carte)
// ---------------------------------------------------------------------------

class PatientScanApi {
  final String  idPatient;
  final String  nom;
  final String  prenom;
  final String  dateNaissance;
  final String  groupeSanguin;
  final String  telephone;
  final String  carteStatut;
  final String? dernierPassageDate;

  const PatientScanApi({
    required this.idPatient,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.groupeSanguin,
    required this.telephone,
    required this.carteStatut,
    this.dernierPassageDate,
  });

  String get nomComplet => '$nom $prenom';
  String get initials   => '${nom.isNotEmpty ? nom[0] : ''}${prenom.isNotEmpty ? prenom[0] : ''}';

  factory PatientScanApi.fromJson(Map<String, dynamic> json) => PatientScanApi(
        idPatient:         json['idPatient']         as String,
        nom:               json['nom']               as String,
        prenom:            json['prenom']            as String,
        dateNaissance:     json['dateNaissance']     as String,
        groupeSanguin:     json['groupeSanguin']     as String,
        telephone:         json['telephone']         as String,
        carteStatut:       json['carteStatut']       as String,
        dernierPassageDate: json['dernierPassageDate'] as String?,
      );
}

// ---------------------------------------------------------------------------
// Modèles activité agent
// ---------------------------------------------------------------------------

class ActiviteItemApi {
  final String? idPassage;   // null pour NOUVEAU_PATIENT
  final String  nomPatient;
  final String  prenomPatient;
  final String  motifVisite;
  final String  date;
  final String  heure;
  final String  statut;
  final bool    urgence;
  final String  type;        // SCAN | URGENCE | NOUVEAU_PATIENT

  const ActiviteItemApi({
    required this.idPassage,
    required this.nomPatient,
    required this.prenomPatient,
    required this.motifVisite,
    required this.date,
    required this.heure,
    required this.statut,
    required this.urgence,
    required this.type,
  });

  String get nomComplet => '$prenomPatient $nomPatient';
  String get initials   =>
      '${prenomPatient.isNotEmpty ? prenomPatient[0] : ''}${nomPatient.isNotEmpty ? nomPatient[0] : ''}';

  factory ActiviteItemApi.fromJson(Map<String, dynamic> j) => ActiviteItemApi(
        idPassage:    j['idPassage']    as String?,
        nomPatient:   j['nomPatient']   as String,
        prenomPatient:j['prenomPatient']as String,
        motifVisite:  j['motifVisite']  as String,
        date:         j['date']         as String,
        heure:        j['heure']        as String,
        statut:       j['statut']       as String,
        urgence:      j['urgence']      as bool? ?? false,
        type:         j['type']         as String? ?? 'SCAN',
      );
}

class ActiviteAgentApi {
  final int                  totalActions;
  final int                  scans;
  final int                  creations;
  final int                  urgences;
  final List<ActiviteItemApi> passages;

  const ActiviteAgentApi({
    required this.totalActions,
    required this.scans,
    required this.creations,
    required this.urgences,
    required this.passages,
  });

  factory ActiviteAgentApi.fromJson(Map<String, dynamic> j) => ActiviteAgentApi(
        totalActions: j['totalActions'] as int,
        scans:        j['scans']        as int,
        creations:    j['creations']    as int,
        urgences:     j['urgences']     as int,
        passages: (j['passages'] as List)
            .map((e) => ActiviteItemApi.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ---------------------------------------------------------------------------
// Modèle admission (ligne dans la liste du dashboard)
// ---------------------------------------------------------------------------

class AdmissionApi {
  final String idPassage;
  final String nomPatient;
  final String prenomPatient;
  final String motifVisite;
  final String heure;
  final String statut;
  final bool   isUrgence;

  const AdmissionApi({
    required this.idPassage,
    required this.nomPatient,
    required this.prenomPatient,
    required this.motifVisite,
    required this.heure,
    required this.statut,
    required this.isUrgence,
  });

  String get nomComplet => '$nomPatient $prenomPatient';
  String get initials   =>
      '${nomPatient.isNotEmpty ? nomPatient[0] : ''}${prenomPatient.isNotEmpty ? prenomPatient[0] : ''}';

  factory AdmissionApi.fromJson(Map<String, dynamic> json) => AdmissionApi(
        idPassage:     json['idPassage']     as String,
        nomPatient:    json['nomPatient']    as String,
        prenomPatient: json['prenomPatient'] as String,
        motifVisite:   json['motifVisite']   as String,
        heure:         json['heure']         as String,
        statut:        json['statut']        as String,
        isUrgence:     (json['urgence'] ?? json['isUrgence']) as bool? ?? false,
      );
}

// ---------------------------------------------------------------------------
// Modèle dashboard complet (GET /admission/dashboard/{id})
// ---------------------------------------------------------------------------

class DashboardAccueilApi {
  final String             agentPrenom;
  final String             agentNom;
  final String             nomHopital;
  final int                totalAdmissions;
  final int                enAttente;
  final int                urgences;
  final List<AdmissionApi> admissions;

  const DashboardAccueilApi({
    required this.agentPrenom,
    required this.agentNom,
    required this.nomHopital,
    required this.totalAdmissions,
    required this.enAttente,
    required this.urgences,
    required this.admissions,
  });

  String get agentInitials =>
      '${agentPrenom.isNotEmpty ? agentPrenom[0] : ''}${agentNom.isNotEmpty ? agentNom[0] : ''}';

  factory DashboardAccueilApi.fromJson(Map<String, dynamic> json) =>
      DashboardAccueilApi(
        agentPrenom:     json['agentPrenom']     as String,
        agentNom:        json['agentNom']        as String,
        nomHopital:      json['nomHopital']      as String,
        totalAdmissions: json['totalAdmissions'] as int,
        enAttente:       json['enAttente']       as int,
        urgences:        json['urgences']        as int,
        admissions: (json['admissions'] as List)
            .map((e) => AdmissionApi.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ---------------------------------------------------------------------------
// Service API
// ---------------------------------------------------------------------------

class AgentAccueilApiService {
  final _dio = ApiClient.instance.dio;

  /// Profil du personnel médical.
  Future<AgentProfilApi> getProfil(String idPersonnel) async {
    try {
      final res = await _dio.get(ApiEndpoints.personnelProfil(idPersonnel));
      return AgentProfilApi.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Dashboard agent d'accueil : profil agent + stats + admissions du jour.
  Future<DashboardAccueilApi> getDashboard(String idPersonnel) async {
    try {
      final res = await _dio.get(ApiEndpoints.dashboardAccueil(idPersonnel));
      return DashboardAccueilApi.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Scanne un QR code et retourne les infos du patient.
  Future<PatientScanApi> scanCarte(String qrToken) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.scanCarte,
        data: {'qrCodeToken': qrToken},
      );
      return PatientScanApi.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Activité de l'agent : ses passages créés sur une période.
  Future<ActiviteAgentApi> getActivite(String idPersonnel, {int jours = 1}) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.activiteAgent(idPersonnel),
        queryParameters: {'jours': jours},
      );
      return ActiviteAgentApi.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Crée un nouveau passage médical.
  Future<String> creerPassage({
    required String idPatient,
    required int    idHopital,
    required String motifVisite,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.creerPassage,
        data: {
          'idPatient':   idPatient,
          'idHopital':   idHopital,
          'motifVisite': motifVisite,
        },
      );
      return (res.data as Map<String, dynamic>)['id_passage'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
