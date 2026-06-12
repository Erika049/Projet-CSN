import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/api/api.dart';
import 'auth_local_service.dart';

class AuthApiService {
  final _dio = ApiClient.instance.dio;
  final _local = AuthLocalService();

  // ── Login Professionnel ──────────────────────
  Future<Map<String, dynamic>> loginProfessionnel({
    required String identifiantPro,
    required String motDePasse,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.loginProfessionnel,
        data: {
          'identifiantPro': identifiantPro,
          'motDePasse': motDePasse,
        },
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      await _local.saveSession(
        token: data['token']?.toString() ?? '',
        role: data['role']?.toString() ?? '',
        userName: '${data['prenom']} ${data['nom']}',
      );
      await _local.saveUserId(data['id']?.toString() ?? '');
      return data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // ── Login Patient ────────────────────────────
  Future<Map<String, dynamic>> loginPatient({
    required String identifiant,
    required String motDePasse,
  }) async {
    try {
      final payload = {
        'identifiant': identifiant,
        'motDePasse': motDePasse,
      };
      debugPrint('AuthApiService: Sending loginPatient payload: $payload');
      
      final response = await _dio.post(
        ApiEndpoints.loginPatient,
        data: payload,
      );
      final data = response.data as Map<String, dynamic>;
      await _local.saveSession(
        token: data['token'],
        role: data['role'],
        userName: '${data['prenom']} ${data['nom']}',
      );
      await _local.saveUserId(data['id'].toString());
      return data;
    } on DioException catch (e) {
      debugPrint('AuthApiService: loginPatient error: ${e.response?.data}');
      throw ApiException.fromDioError(e);
    }
  }

  // ── Inscription Patient ──────────────────────
  Future<Map<String, dynamic>> inscrirePatient({
    required String nom,
    required String prenom,
    required String dateNaissance,
    required String genre,
    required String groupeSanguin,
    required String telephone,
    required String email,
    required String adresse,
    required String identifiant,
    required String motDePasse,
    String? urgenceNom,
    String? urgenceTelephone,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.enregistrerPatient,
        data: {
          'nom': nom,
          'prenom': prenom,
          'dateNaissance': dateNaissance,
          'genre': genre,
          'groupeSanguin': groupeSanguin,
          'telephone': telephone,
          'email': email,
          'adresse': adresse,
          'identifiant': identifiant,
          'motDePasse': motDePasse,
          if (urgenceNom != null) 'urgenceNom': urgenceNom,
          if (urgenceTelephone != null)
            'urgenceTelephone': urgenceTelephone,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ── Enregistrer Biométrie ────────────────────
  Future<void> enregistrerBiometrie({
    required String idUtilisateur,
    required String typeUtilisateur,
    required String clePubliqueAppareil,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.enregistrerBiometrie,
        data: {
          'idUtilisateur': idUtilisateur,
          'typeUtilisateur': typeUtilisateur,
          'clePubliqueAppareil': clePubliqueAppareil,
        },
      );
      await _local.enableBiometric();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ── Login Biométrique ────────────────────────
  Future<Map<String, dynamic>> loginBiometrique({
    required String idUtilisateur,
    required String signatureDefi,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.loginBiometrique,
        data: {
          'idUtilisateur': idUtilisateur,
          'signatureDefi': signatureDefi,
        },
      );
      final data = response.data as Map<String, dynamic>;
      await _local.saveSession(
        token: data['token'],
        role: data['role'],
        userName: '${data['prenom']} ${data['nom']}',
      );
      await _local.saveUserId(data['id'].toString());
      return data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}