import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import 'admin_models.dart';

class AdminApiService {
  final _dio = ApiClient.instance.dio;

  Future<AdminStats> getStats() async {
    final res = await _dio.get(
        ApiEndpoints.adminStats);
    return AdminStats.fromJson(
        res.data as Map<String, dynamic>);
  }

  Future<List<PersonnelAdmin>> getPersonnel()
  async {
    final res = await _dio.get(
        ApiEndpoints.adminPersonnel);
    final List<dynamic> data =
    res.data as List<dynamic>;
    return data
        .map((e) => PersonnelAdmin.fromJson(
        e as Map<String, dynamic>))
        .toList();
  }

  Future<PersonnelAdmin> creerPersonnel({
    required String nom,
    required String prenom,
    required String role,
    required String identifiantPro,
    required String motDePasse,
    required int    idHopital,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.adminPersonnel,
      data: {
        'nom':           nom,
        'prenom':        prenom,
        'role':          role,
        'identifiantPro': identifiantPro,
        'motDePasse':    motDePasse,
        'idHopital':     idHopital,
      },
    );
    return PersonnelAdmin.fromJson(
        res.data as Map<String, dynamic>);
  }

  Future<PersonnelAdmin> toggleActif(
      String idPersonnel) async {
    final res = await _dio.patch(
        ApiEndpoints.adminToggleActif(
            idPersonnel));
    return PersonnelAdmin.fromJson(
        res.data as Map<String, dynamic>);
  }

  Future<List<HopitalAdmin>> getHopitaux() async {
    final res = await _dio.get(
        ApiEndpoints.adminHopitaux);
    final List<dynamic> data =
    res.data as List<dynamic>;
    return data
        .map((e) => HopitalAdmin.fromJson(
        e as Map<String, dynamic>))
        .toList();
  }

  Future<HopitalAdmin> creerHopital({
    required String nom,
    required String adresse,
    required String codeUnique,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.adminHopitaux,
      data: {
        'nom':        nom,
        'adresse':    adresse,
        'codeUnique': codeUnique,
      },
    );
    return HopitalAdmin.fromJson(
        res.data as Map<String, dynamic>);
  }

  Future<List<LogAdmin>> getLogs(
      {int limit = 50}) async {
    final res = await _dio.get(
      ApiEndpoints.adminLogs,
      queryParameters: {'limit': limit},
    );
    final List<dynamic> data =
    res.data as List<dynamic>;
    return data
        .map((e) => LogAdmin.fromJson(
        e as Map<String, dynamic>))
        .toList();
  }
}