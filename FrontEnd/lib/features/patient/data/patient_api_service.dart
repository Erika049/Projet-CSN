import 'package:dio/dio.dart';
import '../../../core/api/api.dart';
import 'patient_models.dart';

class PatientApiService {
  final _dio = ApiClient.instance.dio;

  // ── Profil ───────────────────────────────────
  Future<Patient> getProfil(String idPatient) async {
    try {
      final res = await _dio.get(ApiEndpoints.profil(idPatient));
      return _parsePatient(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ── Historique ───────────────────────────────
  Future<List<PassageMedical>> getHistorique(String idPatient) async {
    try {
      final res = await _dio.get(ApiEndpoints.historique(idPatient));
      return (res.data as List)
          .map((p) => _parsePassage(p))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ── Passage en cours ─────────────────────────
  Future<PassageMedical?> getPassageEnCours(String idPatient) async {
    try {
      final res = await _dio.get(
          ApiEndpoints.passageEnCours(idPatient));
      if (res.statusCode == 204) { return null; }
      return _parsePassage(res.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 204) { return null; }
      throw ApiException.fromDioError(e);
    }
  }

  // ── Ordonnances ──────────────────────────────
  Future<List<Ordonnance>> getOrdonnances(String idPatient) async {
    try {
      final res = await _dio.get(
          ApiEndpoints.ordonnances(idPatient));
      return (res.data as List)
          .map((o) => _parseOrdonnance(o))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Ordonnance>> getOrdonnancesActives(
      String idPatient) async {
    try {
      final res = await _dio.get(
          ApiEndpoints.ordonnancesActives(idPatient));
      return (res.data as List)
          .map((o) => _parseOrdonnance(o))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Ordonnance> getOrdonnanceDetail(String idOrdonnance) async {
    try {
      final res = await _dio.get(
          ApiEndpoints.ordonnanceDetail(idOrdonnance));
      return _parseOrdonnance(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ── Notifications ────────────────────────────
  Future<List<Notification>> getNotifications(
      String idPatient) async {
    try {
      final res = await _dio.get(
          ApiEndpoints.notifications(idPatient));
      return (res.data as List)
          .map((n) => _parseNotification(n))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<int> getNombreNonLues(String idPatient) async {
    try {
      final res = await _dio.get(ApiEndpoints.nonLues(idPatient));
      return res.data['count'] as int;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> marquerToutesLues(String idPatient) async {
    try {
      await _dio.put(ApiEndpoints.toutLire(idPatient));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> marquerLue(String idNotification) async {
    try {
      await _dio.put(ApiEndpoints.marquerLue(idNotification));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ══════════════════════════════════════════════
  // PARSERS JSON → Modèles Flutter
  // ══════════════════════════════════════════════

  Patient _parsePatient(Map<String, dynamic> data) {
    return Patient(
      id: data['idPatient'] ?? '',
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      dateNaissance: data['dateNaissance'] != null
          ? _formatDate(data['dateNaissance'].toString())
          : '',
      genre: data['genre']?.toString() ?? 'M',
      groupeSanguin: data['groupeSanguin'] ?? '',
      telephone: data['telephone'] ?? '',
      email: data['email'],
      carte: CarteNumerique(
        qrCodeToken: data['qrCodeToken'] ?? '',
        statut: data['carteStatut'] ?? 'actif',
        expireAnnee: data['carteExpiration'] != null
            ? data['carteExpiration'].toString().substring(0, 4)
            : '2028',
        expireMois: data['carteExpiration'] != null
            ? data['carteExpiration'].toString().substring(5, 7)
            : '12',
      ),
    );
  }

  PassageMedical _parsePassage(Map<String, dynamic> data) {
    final constData = data['constantes'] as Map<String, dynamic>?;
    ConstantesVitales? constantes;
    if (constData != null) {
      constantes = ConstantesVitales(
        tension: constData['tension']?.toString(),
        temperature: constData['temperature']?.toString(),
        poids: constData['poids']?.toString(),
        pouls: constData['pouls']?.toString(),
      );
    }

    final examensData = data['examens'] as List? ?? [];
    final examens = examensData.map((e) => ExamenLabo(
      id: e['idExamen'].toString(),
      type: e['type'] ?? '',
      resultats: e['resultats'] ?? '',
      dateResultat: _formatDateTime(
          e['dateResultat']?.toString() ?? ''),
    )).toList();

    final dateAdmission = data['dateAdmission']?.toString() ?? '';

    return PassageMedical(
      id: data['idPassage'] ?? '',
      hopital: data['hopital'] ?? '',
      service: data['service'] ?? data['motif'] ?? '',
      dateAdmission: _formatDateSimple(dateAdmission),
      heureAdmission: _formatHeure(dateAdmission),
      motifVisite: data['motif'] ?? '',
      statut: data['statut'] ?? 'termine',
      medecin: data['medecin'],
      constantes: constantes,
      diagnostic: data['diagnostic'],
      prescription: data['prescription'],
      examens: examens,
    );
  }

  Ordonnance _parseOrdonnance(Map<String, dynamic> data) {
    final medsData = data['medicaments'] as List? ?? [];
    final medicaments = medsData.map((m) => Medicament(
      nom: m['nom'] ?? '',
      posologie: m['posologie'] ?? '',
      comprimesRestants: m['comprimesRestants'] as int?,
      comprimesTotaux: m['comprimesTotaux'] as int?,
    )).toList();

    return Ordonnance(
      id: data['idOrdonnance'] ?? '',
      titre: data['titre'] ?? '',
      medecin: data['medecin'] ?? '',
      specialite: data['specialite'] ?? '',
      dateDelivrance: data['dateDelivrance'] != null
          ? _formatDate(data['dateDelivrance'].toString())
          : '',
      dateExpiration: data['dateExpiration'] != null
          ? _formatDate(data['dateExpiration'].toString())
          : '',
      statut: data['statut'] ?? 'active',
      joursRestants: data['joursRestants'] as int? ?? 0,
      medicaments: medicaments,
    );
  }

  Notification _parseNotification(Map<String, dynamic> data) {
    return Notification(
      id: data['idNotification'].toString(),
      titre: data['titre'] ?? '',
      message: data['message'] ?? '',
      temps: _formatDateTimeRelative(
          data['creeLe']?.toString() ?? ''),
      type: data['type'] ?? 'info',
      lue: data['lue'] as bool? ?? false,
    );
  }

  // ── Formatters ────────────────────────────────

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')} '
          '${_mois(d.month)} ${d.year}';
    } catch (_) {
      return iso;
    }
  }

  String _formatDateSimple(String iso) {
    try {
      final d = DateTime.parse(iso);
      final now = DateTime.now();
      if (d.year == now.year &&
          d.month == now.month &&
          d.day == now.day) {
        return "Aujourd'hui";
      }
      return '${d.day.toString().padLeft(2, '0')} '
          '${_mois(d.month)} ${d.year}';
    } catch (_) {
      return iso;
    }
  }

  String _formatHeure(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  String _formatDateTime(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${_formatDate(iso)} · ${_formatHeure(iso)}';
    } catch (_) {
      return iso;
    }
  }

  String _formatDateTimeRelative(String iso) {
    try {
      final d = DateTime.parse(iso);
      final diff = DateTime.now().difference(d);
      if (diff.inMinutes < 60) {
        return 'il y a ${diff.inMinutes} min';
      }
      if (diff.inHours < 24) {
        return 'il y a ${diff.inHours} h';
      }
      return _formatDate(iso);
    } catch (_) {
      return iso;
    }
  }

  String _mois(int m) {
    const mois = [
      '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return mois[m];
  }
}