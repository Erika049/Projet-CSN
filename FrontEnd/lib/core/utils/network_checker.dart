import 'package:dio/dio.dart';
import '../api/api_endpoints.dart';

class NetworkChecker {
  static final _dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  static Future<NetworkStatus> checkHospitalNetwork() async {
    try {
      final response = await _dio.get(ApiEndpoints.networkCheck);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final onNetwork = data['onHospitalNetwork'] as bool? ?? false;
          return onNetwork
              ? NetworkStatus.authorized
              : NetworkStatus.unauthorized;
        }
      }
      return NetworkStatus.unauthorized;
    } on DioException {
      return NetworkStatus.unreachable;
    } catch (_) {
      return NetworkStatus.unreachable;
    }
  }
}

enum NetworkStatus {
  authorized,
  unauthorized,
  unreachable,
}