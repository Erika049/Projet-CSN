import 'agent_accueil_mock_data.dart';
import 'agent_accueil_service.dart';

/// Implémentation hors-réseau du parcours agent d'accueil.
///
/// Renvoie les données fictives de [agent_accueil_mock_data] avec un délai
/// simulé, en respectant exactement les signatures de [AgentAccueilService]
/// (même principe que `PatientMockService`).
class AgentAccueilMockService implements AgentAccueilService {
  static final AgentAccueilMockService _instance = AgentAccueilMockService._();
  factory AgentAccueilMockService() => _instance;
  AgentAccueilMockService._();

  static const _delay = Duration(milliseconds: 500);

  @override
  Future<AgentProfile> getAgentProfile() async {
    await Future.delayed(_delay);
    return mockAgent;
  }

  @override
  Future<List<Admission>> getAdmissions() async {
    await Future.delayed(_delay);
    return mockAdmissions;
  }

  @override
  Future<List<ActivityEntry>> getActivities() async {
    await Future.delayed(_delay);
    return mockActivities;
  }

  @override
  Future<IdentifiedPatient> identifyPatient(String qrToken) async {
    await Future.delayed(_delay);
    return mockIdentifiedPatient;
  }

  @override
  Future<void> createPassage({
    required String patientId,
    required String motif,
    required String service,
    required String medecin,
  }) async {
    await Future.delayed(_delay);
  }
}
