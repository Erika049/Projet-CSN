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
    if (error?.type?.toString().contains('connect') == true) {
      return const ApiException(
        message: 'Impossible de joindre le serveur. Vérifiez votre connexion.',
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