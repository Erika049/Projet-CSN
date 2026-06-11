import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import 'laborantin_models.dart';

class LaborantinApiService {
  final _dio = ApiClient.instance.dio;

  Future<List<PassageEnAttente>> getPassagesEnAttente()
  async {
    final res = await _dio.get(
        ApiEndpoints.laboPassagesEnAttente);
    final List<dynamic> data =
    res.data as List<dynamic>;
    return data
        .map((e) => PassageEnAttente.fromJson(
        e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ExamenPublie>> getHistorique() async {
    final res = await _dio.get(
        ApiEndpoints.laboHistorique);
    final List<dynamic> data =
    res.data as List<dynamic>;
    return data
        .map((e) => ExamenPublie.fromJson(
        e as Map<String, dynamic>))
        .toList();
  }

  Future<StatsLabo> getStats() async {
    final res = await _dio.get(
        ApiEndpoints.laboStats);
    return StatsLabo.fromJson(
        res.data as Map<String, dynamic>);
  }

  Future<void> publierExamen({
    required String idPassage,
    required String typeExamen,
    required String resultats,
  }) async {
    await _dio.post(
      ApiEndpoints.laboAjouterExamen,
      data: {
        'idPassage':  idPassage,
        'typeExamen': typeExamen,
        'resultats':  resultats,
      },
    );
  }
}