import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_endpoints.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
        responseDecoder: (responseBytes, options, responseBody) =>
            utf8.decode(responseBytes, allowMalformed: true),
      ),
    );
    _setupInterceptors();
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ajouter le token JWT à chaque requête
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Token expiré sur un appel authentifié → vider la session
          // Ne pas toucher la session sur les endpoints de login eux-mêmes
          final path = error.requestOptions.path;
          final isLoginEndpoint = path.contains('/auth/login');
          if (error.response?.statusCode == 401 && !isLoginEndpoint) {
            await _storage.deleteAll();
          }
          handler.next(error);
        },
      ),
    );
  }
}