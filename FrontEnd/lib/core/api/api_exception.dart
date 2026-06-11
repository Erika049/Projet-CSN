class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioError(dynamic error) {
    if (error?.response != null) {
      final data = error.response?.data;
      final msg = data is Map
          ? data['message'] ?? data['error'] ?? 'Erreur serveur'
          : 'Erreur serveur';
      return ApiException(
        message: msg.toString(),
        statusCode: error.response?.statusCode,
      );
    }
    // Erreur réseau : connexion refusée, timeout, pas de réseau…
    final typeStr  = error?.type?.toString() ?? '';
    final errStr   = error?.error?.toString() ?? '';
    final urlStr   = '${error?.requestOptions?.baseUrl ?? ''}${error?.requestOptions?.path ?? ''}';
    final isNetworkError = typeStr.contains('connect') ||
        typeStr.contains('timeout') ||
        typeStr.contains('unknown') ||
        errStr.contains('SocketException');
    if (isNetworkError) {
      // Message de debug pour identifier la cause exacte
      return ApiException(
        message: 'Réseau : $typeStr | $errStr | URL: $urlStr',
        statusCode: 0,
      );
    }
    return ApiException(
      message: error?.message ?? 'Une erreur est survenue',
    );
  }

  @override
  String toString() => message;
}