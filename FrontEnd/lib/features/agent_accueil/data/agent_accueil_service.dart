import '../../../core/utils/app_mode.dart';
import 'agent_accueil_api_service.dart';
import 'agent_accueil_mock_data.dart';
import 'agent_accueil_mock_service.dart';

/// Contrat d'accès aux données du parcours agent d'accueil.
///
/// Deux implémentations partagent ces signatures (comme pour le parcours
/// patient) : [AgentAccueilApiService] (Dio → backend) et
/// [AgentAccueilMockService] (données fictives, mode hors-réseau).
abstract class AgentAccueilService {
  /// Profil de l'agent connecté.
  Future<AgentProfile> getAgentProfile();

  /// Admissions du jour (tableau de bord).
  Future<List<Admission>> getAdmissions();

  /// Journal d'activité de l'agent.
  Future<List<ActivityEntry>> getActivities();

  /// Patient identifié à partir du QR scanné.
  Future<IdentifiedPatient> identifyPatient(String qrToken);

  /// Ouvre un nouveau passage pour le patient identifié.
  Future<void> createPassage({
    required String patientId,
    required String motif,
    required String service,
    required String medecin,
  });

  /// Fabrique l'implémentation adaptée au mode courant : mock en hors-réseau,
  /// API sinon. S'appuie sur le commutateur global [AppMode].
  factory AgentAccueilService.create() => AppMode().isOffline
      ? AgentAccueilMockService()
      : AgentAccueilApiService();
}
