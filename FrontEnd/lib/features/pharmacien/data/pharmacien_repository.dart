import 'package:carnet_sante_numerique/features/pharmacien/data/pharmacien_mock_data.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class PharmacienRepository {
  final ApiClient _apiClient = ApiClient.instance;

  Future<List<OrdonnanceItem>> getHistorique() async {
    try {
      final response = await _apiClient.dio.get('${ApiEndpoints.baseUrl}/pharmacien/historique');
      return (response.data as List)
          .map((item) => OrdonnanceItem.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'historique: $e');
    }
  }

  Future<List<OrdonnanceItem>> getOrdonnancesActives() async {
    try {
      final response = await _apiClient.dio.get('${ApiEndpoints.baseUrl}/pharmacien/ordonnances-actives');
      return (response.data as List)
          .map((item) => OrdonnanceItem.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des ordonnances: $e');
    }
  }

  Future<dynamic> getOrdonnanceById(String idOrdonnance) async {
    try {
      final response = await _apiClient.dio.get('${ApiEndpoints.baseUrl}/ordonnances/$idOrdonnance');
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'ordonnance: $e');
    }
  }

  Future<dynamic> getPersonnelProfil(String idPersonnel) async {
    try {
      final response = await _apiClient.dio.get('${ApiEndpoints.baseUrl}/personnel/$idPersonnel/profil');
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil: $e');
    }
  }

  Future<void> delivrerOrdonnance(String idOrdonnance) async {
    try {
      await _apiClient.dio.post('${ApiEndpoints.baseUrl}/ordonnances/$idOrdonnance/delivrer');
    } catch (e) {
      throw Exception('Erreur lors de la délivrance: $e');
    }
  }

  Future<void> refuserOrdonnance(String idOrdonnance) async {
    try {
      await _apiClient.dio.post('${ApiEndpoints.baseUrl}/ordonnances/$idOrdonnance/refuser');
    } catch (e) {
      throw Exception('Erreur lors du refus: $e');
    }
  }
}
