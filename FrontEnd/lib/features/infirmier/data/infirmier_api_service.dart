import 'package:dio/dio.dart';
import '../../../core/api/api.dart';

// ---------------------------------------------------------------------------
// Modèle passage (dashboard infirmier)
// ---------------------------------------------------------------------------

class PassageInfirmierApi {
  final String idPassage;
  final String nomPatient;
  final String prenomPatient;
  final String motifVisite;
  final String heure;
  final bool   isUrgence;
  final bool   constantesFaites;

  const PassageInfirmierApi({
    required this.idPassage,
    required this.nomPatient,
    required this.prenomPatient,
    required this.motifVisite,
    required this.heure,
    required this.isUrgence,
    required this.constantesFaites,
  });

  String get nomComplet => '$nomPatient $prenomPatient';
  String get initials   =>
      '${nomPatient.isNotEmpty ? nomPatient[0] : ''}${prenomPatient.isNotEmpty ? prenomPatient[0] : ''}';

  factory PassageInfirmierApi.fromJson(Map<String, dynamic> json) =>
      PassageInfirmierApi(
        idPassage:       json['idPassage']       as String,
        nomPatient:      json['nomPatient']      as String,
        prenomPatient:   json['prenomPatient']   as String,
        motifVisite:     json['motifVisite']     as String,
        heure:           json['heure']           as String,
        isUrgence:       (json['urgence'] ?? json['isUrgence']) as bool? ?? false,
        constantesFaites: json['constantesFaites'] as bool? ?? false,
      );
}

// ---------------------------------------------------------------------------
// Modèle dashboard infirmier
// ---------------------------------------------------------------------------

class InfirmierDashboardApi {
  final String infirmierPrenom;
  final String infirmierNom;
  final String nomHopital;
  final int    totalAConstanter;
  final int    urgences;
  final int    faits;
  final List<PassageInfirmierApi> passages;

  const InfirmierDashboardApi({
    required this.infirmierPrenom,
    required this.infirmierNom,
    required this.nomHopital,
    required this.totalAConstanter,
    required this.urgences,
    required this.faits,
    required this.passages,
  });

  String get initials =>
      '${infirmierPrenom.isNotEmpty ? infirmierPrenom[0] : ''}${infirmierNom.isNotEmpty ? infirmierNom[0] : ''}';

  factory InfirmierDashboardApi.fromJson(Map<String, dynamic> json) =>
      InfirmierDashboardApi(
        infirmierPrenom:   json['infirmierPrenom']   as String,
        infirmierNom:      json['infirmierNom']      as String,
        nomHopital:        json['nomHopital']        as String,
        totalAConstanter:  json['totalAConstanter']  as int,
        urgences:          json['urgences']          as int,
        faits:             json['faits']             as int,
        passages: (json['passages'] as List)
            .map((e) => PassageInfirmierApi.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ---------------------------------------------------------------------------
// Modèles activité infirmier
// ---------------------------------------------------------------------------

class ActiviteInfirmierItemApi {
  final String idPassage;
  final String nomPatient;
  final String prenomPatient;
  final String motifVisite;
  final String date;
  final String heure;
  final bool   urgence;
  final String type;        // CONSTANTES | CONSTANTES_URGENCE
  final String actionLabel; // "Constantes prises" | "Constantes urgence"
  final String resume;      // "Tension 120/80 · 37.2°"

  const ActiviteInfirmierItemApi({
    required this.idPassage,
    required this.nomPatient,
    required this.prenomPatient,
    required this.motifVisite,
    required this.date,
    required this.heure,
    required this.urgence,
    required this.type,
    required this.actionLabel,
    required this.resume,
  });

  String get nomComplet => '$prenomPatient $nomPatient';
  String get initials   =>
      '${prenomPatient.isNotEmpty ? prenomPatient[0] : ''}${nomPatient.isNotEmpty ? nomPatient[0] : ''}';

  factory ActiviteInfirmierItemApi.fromJson(Map<String, dynamic> j) =>
      ActiviteInfirmierItemApi(
        idPassage:    j['idPassage']    as String,
        nomPatient:   j['nomPatient']   as String,
        prenomPatient:j['prenomPatient']as String,
        motifVisite:  j['motifVisite']  as String,
        date:         j['date']         as String,
        heure:        j['heure']        as String,
        urgence:      j['urgence']      as bool? ?? false,
        type:         j['type']         as String? ?? 'CONSTANTES',
        actionLabel:  j['actionLabel']  as String? ?? 'Constantes prises',
        resume:       j['resume']       as String? ?? '—',
      );
}

class ActiviteInfirmierApi {
  final int totalActions;
  final int constantes;
  final int soins;
  final int injections;
  final int urgences;
  final List<ActiviteInfirmierItemApi> items;

  const ActiviteInfirmierApi({
    required this.totalActions,
    required this.constantes,
    required this.soins,
    required this.injections,
    required this.urgences,
    required this.items,
  });

  factory ActiviteInfirmierApi.fromJson(Map<String, dynamic> j) =>
      ActiviteInfirmierApi(
        totalActions: j['totalActions'] as int,
        constantes:   j['constantes']   as int,
        soins:        j['soins']        as int? ?? 0,
        injections:   j['injections']   as int? ?? 0,
        urgences:     j['urgences']     as int,
        items: (j['items'] as List)
            .map((e) => ActiviteInfirmierItemApi.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ---------------------------------------------------------------------------
// Service API
// ---------------------------------------------------------------------------

class InfirmierApiService {
  final _dio = ApiClient.instance.dio;

  /// Dashboard infirmier : passages du jour + stats.
  Future<InfirmierDashboardApi> getDashboard(String idPersonnel) async {
    try {
      final res = await _dio.get(ApiEndpoints.dashboardInfirmier(idPersonnel));
      return InfirmierDashboardApi.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Activité de l'infirmier : constantes prises sur une période.
  Future<ActiviteInfirmierApi> getActivite(String idPersonnel, {int jours = 1}) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.activiteInfirmier(idPersonnel),
        queryParameters: {'jours': jours},
      );
      return ActiviteInfirmierApi.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Récupère les constantes existantes d'un passage (pour pré-remplir le formulaire).
  Future<Map<String, String>> getConstantes(String idPassage) async {
    try {
      final res = await _dio.get(ApiEndpoints.constantes(idPassage));
      return Map<String, String>.from(
          (res.data as Map).map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Enregistre un soin infirmier.
  Future<void> enregistrerSoin({
    required String idPassage,
    required String typeSoin,
    required String description,
  }) async {
    try {
      await _dio.post(ApiEndpoints.soin(idPassage), data: {
        'typeSoin':    typeSoin,
        'description': description,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Enregistre une injection.
  Future<void> enregistrerInjection({
    required String idPassage,
    required String medicament,
    required String dose,
    required String voie,
  }) async {
    try {
      await _dio.post(ApiEndpoints.injection(idPassage), data: {
        'medicament': medicament,
        'dose':       dose,
        'voie':       voie,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Enregistre les constantes vitales d'un passage.
  Future<void> updateConstantes({
    required String idPassage,
    required String tension,
    required String temperature,
    required String poids,
    required String freqCardiaque,
    required String spo2,
    required String freqRespi,
    required String noteInfirmiere,
  }) async {
    try {
      await _dio.put(
        ApiEndpoints.constantes(idPassage),
        data: {
          'tension':         tension,
          'temperature':     temperature,
          'poids':           poids,
          'freqCardiaque':   freqCardiaque,
          'spo2':            spo2,
          'freqRespi':       freqRespi,
          'noteInfirmiere':  noteInfirmiere,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
