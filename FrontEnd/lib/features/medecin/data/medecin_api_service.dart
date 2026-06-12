import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import 'medecin_models.dart';

class MedecinApiService {
  final _dio = ApiClient.instance.dio;

  Future<List<PatientDuJour>> getPatientsDuJour() async {
    final response = await _dio.get(
        ApiEndpoints.medecinPatientsDuJour);
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => PatientDuJour.fromJson(
        e as Map<String, dynamic>))
        .toList();
  }

  Future<StatsDuJour> getStatsDuJour() async {
    final response = await _dio.get(
        ApiEndpoints.medecinStatsDuJour);
    return StatsDuJour.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<PassageDetail> getPassageDetail(
      String idPassage) async {
    final response = await _dio.get(
        ApiEndpoints.medecinPassageDetail(idPassage));
    return PassageDetail.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<List<ActivitePro>> getActivite(
      {int jours = 30}) async {
    final response = await _dio.get(
        ApiEndpoints.medecinActivite,
        queryParameters: {'jours': jours});
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => ActivitePro.fromJson(
        e as Map<String, dynamic>))
        .toList();
  }
}