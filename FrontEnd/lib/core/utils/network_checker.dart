import 'package:dio/dio.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../api/api_endpoints.dart';

class NetworkChecker {
  static final _dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static const List<String> _hospitalNetworks = [
    '192.168.1.',
    '192.168.137.',
    '172.22.211.',
    '10.0.0.',
    '10.0.2.',
  ];

  static Future<NetworkStatus> checkHospitalNetwork() async {
    try {
      // 1) Backend joignable ?
      final response = await _dio.get(ApiEndpoints.networkCheck);
      if (response.statusCode != 200) {
        return NetworkStatus.unreachable;
      }

      // 2) IP locale du téléphone
      final localIp = await _getLocalIp();
      if (localIp == null || localIp.isEmpty) {
        return NetworkStatus.unauthorized;
      }

      // 3) Réseau hospitalier ?
      final isOnHospital = _hospitalNetworks
          .any((prefix) => localIp.startsWith(prefix));

      return isOnHospital
          ? NetworkStatus.authorized
          : NetworkStatus.unauthorized;

    } on DioException {
      return NetworkStatus.unreachable;
    } catch (_) {
      return NetworkStatus.unreachable;
    }
  }

  static Future<String?> _getLocalIp() async {
    try {
      final info = NetworkInfo();
      final ip = await info.getWifiIP();
      return ip;
    } catch (_) {
      return null;
    }
  }
}

enum NetworkStatus {
  authorized,
  unauthorized,
  unreachable,
}