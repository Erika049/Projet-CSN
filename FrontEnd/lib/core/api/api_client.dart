import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_navigator.dart';
import 'api_endpoints.dart';

import '../../features/auth/data/auth_local_service.dart';
import '../../features/auth/presentation/screens/app_entry.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 70),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
        },
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
        // ── Ajout token JWT ─────────────────────
        onRequest: (options, handler) async {
          final token = await _storage.read(
              key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] =
            'Bearer $token';
          }
          handler.next(options);
        },

        // ── Gestion erreurs globale ──────────────
        onError: (error, handler) async {
          final status =
              error.response?.statusCode;

          if (status == 401) {
            // Session expirée → logout + AppEntry
            await _handleSessionExpired();
          } else if (status == 403) {
            // Accès refusé
            _handleAccessDenied();
          } else if (status == 404) {
            // Ressource introuvable
            _handleNotFound();
          } else if (status == 503) {
            // Maintenance
            _handleMaintenance();
          } else if (_isNetworkError(error)) {
            // Pas de réseau / timeout
            _handleNoNetwork();
          }

          // On laisse quand même l'erreur
          // remonter pour que chaque écran
          // puisse aussi réagir localement
          handler.next(error);
        },
      ),
    );
  }

  // ── Handlers ────────────────────────────────

  Future<void> _handleSessionExpired() async {
    // Nettoyer la session locale
    await AuthLocalService().logout();
    // Naviguer vers AppEntry
    AppNavigator.pushAndRemoveAll(
        const AppEntry());
  }

  void _handleAccessDenied() {
    _pushErrorScreen(_ErrorType.accessDenied);
  }

  void _handleNotFound() {
    _pushErrorScreen(_ErrorType.notFound);
  }

  void _handleMaintenance() {
    _pushErrorScreen(_ErrorType.maintenance);
  }

  void _handleNoNetwork() {
    _pushErrorScreen(_ErrorType.noNetwork);
  }

  void _pushErrorScreen(_ErrorType type) {
    final context =
        AppNavigator.key.currentContext;
    if (context == null) { return; }

    // On n'empile pas plusieurs ErrorScreen
    // si une est déjà affichée
    final route = ModalRoute.of(context);
    if (route?.settings.name ==
        '/error') { return; }

    AppNavigator.state?.push(
      MaterialPageRoute(
        settings:
        const RouteSettings(name: '/error'),
        builder: (_) =>
            _buildErrorScreen(type, context),
      ),
    );
  }

  Widget _buildErrorScreen(
      _ErrorType type, BuildContext context) {
    // Import inline pour éviter les imports
    // circulaires au niveau du fichier
    return _ErrorScreenWrapper(
      type:      type,
      onPrimary: () =>
          AppNavigator.state?.pop(),
      onSecondary: type == _ErrorType.noNetwork
          ? () => AppNavigator.state?.pop()
          : null,
    );
  }

  bool _isNetworkError(DioException error) {
    return error.type ==
        DioExceptionType.connectionTimeout ||
        error.type ==
            DioExceptionType.receiveTimeout ||
        error.type ==
            DioExceptionType.sendTimeout ||
        error.type ==
            DioExceptionType.connectionError ||
        error.type ==
            DioExceptionType.unknown;
  }
}

// ── Enum local pour éviter l'import circulaire ─

enum _ErrorType {
  noNetwork,
  notFound,
  sessionExpired,
  maintenance,
  accessDenied,
}

// ── Wrapper qui appelle le vrai ErrorScreen ────

class _ErrorScreenWrapper extends StatelessWidget {
  final _ErrorType  type;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  const _ErrorScreenWrapper({
    required this.type,
    this.onPrimary,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    // Import du vrai ErrorScreen ici
    // pour éviter les dépendances circulaires
    return _ErrorScreenProxy(
      type:        type,
      onPrimary:   onPrimary,
      onSecondary: onSecondary,
    );
  }
}

class _ErrorScreenProxy extends StatelessWidget {
  final _ErrorType    type;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  const _ErrorScreenProxy({
    required this.type,
    this.onPrimary,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    // Mapping vers le vrai ErrorType
    final errorTypeMap = {
      _ErrorType.noNetwork:
      _buildNoNetwork(context),
      _ErrorType.notFound:
      _buildNotFound(context),
      _ErrorType.sessionExpired:
      _buildSessionExpired(context),
      _ErrorType.maintenance:
      _buildMaintenance(context),
      _ErrorType.accessDenied:
      _buildAccessDenied(context),
    };
    return errorTypeMap[type] ??
        const SizedBox.shrink();
  }

  Widget _buildNoNetwork(
      BuildContext context) {
    return _buildScaffold(
      context,
      icon:    Icons.wifi_off_rounded,
      color:   const Color(0xFFB45309),
      bg:      const Color(0xFFFEF3C7),
      code:    'NETWORK_UNREACHABLE',
      title:   'Connexion impossible',
      message: "L'application ne parvient pas "
          "à joindre le serveur. Vérifiez "
          "votre connexion ou contactez "
          "le service informatique.",
      primaryLabel:   'Réessayer',
      secondaryLabel: 'Fermer',
    );
  }

  Widget _buildNotFound(
      BuildContext context) {
    return _buildScaffold(
      context,
      icon:    Icons.search_off_rounded,
      color:   const Color(0xFF1A73E8),
      bg:      const Color(0xFFE8F0FE),
      code:    '404 · NOT_FOUND',
      title:   'Ressource introuvable',
      message: "La ressource demandée "
          "n'existe plus ou vous n'y "
          "avez plus accès.",
      primaryLabel: 'Retour',
    );
  }

  Widget _buildSessionExpired(
      BuildContext context) {
    return _buildScaffold(
      context,
      icon:    Icons.lock_clock_outlined,
      color:   const Color(0xFFB45309),
      bg:      const Color(0xFFFEF3C7),
      code:    'JWT_EXPIRED',
      title:   'Session expirée',
      message: 'Votre session a expiré pour '
          'protéger vos données. '
          'Reconnectez-vous pour continuer.',
      primaryLabel: 'Se reconnecter',
    );
  }

  Widget _buildMaintenance(
      BuildContext context) {
    return _buildScaffold(
      context,
      icon:    Icons.engineering_outlined,
      color:   const Color(0xFF1A73E8),
      bg:      const Color(0xFFE8F0FE),
      code:    '503 · SERVICE_UNAVAILABLE',
      title:   'Maintenance en cours',
      message: "Le système est temporairement "
          "indisponible. Réessayez dans "
          "quelques minutes.",
      primaryLabel:   'Actualiser',
      secondaryLabel: 'Fermer',
    );
  }

  Widget _buildAccessDenied(
      BuildContext context) {
    return _buildScaffold(
      context,
      icon:    Icons.block_rounded,
      color:   const Color(0xFFB3261E),
      bg:      const Color(0xFFFCE8E6),
      code:    '403 · ACCESS_DENIED',
      title:   'Accès refusé',
      message: 'Votre rôle ne dispose pas des '
          'permissions pour cette action. '
          'Contactez votre administrateur.',
      primaryLabel: 'Retour',
    );
  }

  Widget _buildScaffold(
      BuildContext context, {
        required IconData  icon,
        required Color     color,
        required Color     bg,
        required String    code,
        required String    title,
        required String    message,
        String?            primaryLabel,
        String?            secondaryLabel,
      }) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              24, 40, 24, 32),
          child: Column(
            children: [
              // ── Badge code ────────────────
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius:
                    BorderRadius.circular(6),
                  ),
                  child: Text(
                    code,
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // ── Icône ─────────────────────
              Expanded(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: bg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size:  48,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: -0.4,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints:
                      const BoxConstraints(
                          maxWidth: 300),
                      child: Text(
                        message,
                        textAlign:
                        TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Boutons ───────────────────
              Column(
                children: [
                  if (primaryLabel != null)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: onPrimary ??
                                () => Navigator.pop(
                                context),
                        child: Text(primaryLabel),
                      ),
                    ),
                  if (secondaryLabel != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: onSecondary ??
                                () => Navigator.pop(
                                context),
                        child:
                        Text(secondaryLabel),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
