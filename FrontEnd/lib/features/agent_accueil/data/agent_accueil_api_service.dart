import 'package:dio/dio.dart';

import '../../../core/api/api.dart';
import 'agent_accueil_mock_data.dart';
import 'agent_accueil_service.dart';

/// Implémentation API (Dio) du parcours agent d'accueil.
///
/// Le backend expose aujourd'hui le scan de carte et la création de passage
/// (AdmissionController). Le profil agent, les admissions du jour et le journal
/// d'activité n'ont pas encore d'endpoint dédié (pas d'AgentController) : ces
/// méthodes renvoient donc les données mock pour ne pas casser l'écran.
class AgentAccueilApiService implements AgentAccueilService {
  final _dio = ApiClient.instance.dio;

  /// Hôpital courant. Le backend exige `idHopital` pour le scan et la création
  /// de passage.
  /// TODO: récupérer depuis la session/le login agent quand il fournira
  /// l'établissement.
  static const int _idHopital = 1;

  // ── Profil / dashboard : pas encore d'endpoint backend → mock ──────────────
  @override
  Future<AgentProfile> getAgentProfile() async => mockAgent;

  @override
  Future<List<Admission>> getAdmissions() async => mockAdmissions;

  @override
  Future<List<ActivityEntry>> getActivities() async => mockActivities;

  // ── Scan QR : POST /admission/scan-carte → PatientInfoDto ──────────────────
  @override
  Future<IdentifiedPatient> identifyPatient(String qrToken) async {
    try {
      final res = await _dio.post(ApiEndpoints.scanCarte, data: {
        'qrCodeToken': qrToken,
        'idHopital': _idHopital,
      });
      return _parseIdentifiedPatient(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ── Création passage : POST /admission/creer-passage (nécessite un JWT pro) ─
  @override
  Future<void> createPassage({
    required String patientId,
    required String motif,
    required String service,
    required String medecin,
  }) async {
    // Le backend ne stocke que le motif + l'hôpital ; le créateur est déduit du
    // JWT. `service`/`medecin` restent indicatifs côté UI.
    try {
      await _dio.post(ApiEndpoints.creerPassage, data: {
        'idPatient': patientId,
        'idHopital': _idHopital,
        'motifVisite': motif,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ── Parsing PatientInfoDto → IdentifiedPatient ─────────────────────────────
  IdentifiedPatient _parseIdentifiedPatient(Map<String, dynamic> d) {
    final id = d['idPatient']?.toString() ?? '';
    final nom = (d['nom'] ?? '').toString();
    final prenom = (d['prenom'] ?? '').toString();
    final naissance = d['dateNaissance']?.toString();
    return IdentifiedPatient(
      id: id,
      nom: '${nom.toUpperCase()} $prenom'.trim(),
      idShort: _shortId(id),
      dateNaissance: _formatDate(naissance),
      age: _age(naissance),
      groupe: (d['groupeSanguin'] ?? '').toString(),
      telephone: (d['telephone'] ?? '').toString(),
      dernierPassage: d['dernierPassageDate']?.toString() ?? 'Aucun passage',
      initials:
          '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}',
    );
  }

  String _shortId(String id) {
    if (id.length <= 12) return id;
    return '${id.substring(0, 8)}···${id.substring(id.length - 4)}';
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso);
      final yy = (d.year % 100).toString().padLeft(2, '0');
      return '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/$yy';
    } catch (_) {
      return iso;
    }
  }

  String _age(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso);
      final now = DateTime.now();
      var age = now.year - d.year;
      if (now.month < d.month || (now.month == d.month && now.day < d.day)) {
        age--;
      }
      return '$age ans';
    } catch (_) {
      return '';
    }
  }
}
