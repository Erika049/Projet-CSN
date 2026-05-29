import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/patient_mock_service.dart';
import '../../data/patient_models.dart' as models;

class PatientNotificationsScreen extends StatefulWidget {
  const PatientNotificationsScreen({super.key});

  @override
  State<PatientNotificationsScreen> createState() =>
      _PatientNotificationsScreenState();
}

class _PatientNotificationsScreenState
    extends State<PatientNotificationsScreen> {
  final _service = PatientMockService();
  List<models.Notification> _notifs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final notifs = await _service.getNotifications();
    if (!mounted) { return; }
    setState(() {
      _notifs = notifs;
      _loading = false;
    });
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'examen': return Icons.science_outlined;
      case 'ordonnance': return Icons.medication_outlined;
      case 'admission': return Icons.local_hospital_outlined;
      case 'acces': return Icons.person_outline;
      case 'securite': return Icons.devices_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'examen': return const Color(0xFFB45309);
      case 'ordonnance': return AppColors.primary;
      case 'admission': return AppColors.success;
      case 'acces': return AppColors.primary;
      case 'securite': return AppColors.textMedium;
      default: return AppColors.primary;
    }
  }

  Color _bgFor(String type) {
    switch (type) {
      case 'examen': return const Color(0xFFFEF3C7);
      case 'ordonnance': return AppColors.primaryLight;
      case 'admission': return AppColors.successLight;
      case 'acces': return AppColors.primaryLight;
      case 'securite': return const Color(0xFFF1F3F4);
      default: return AppColors.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Tout lu',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: _notifs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final n = _notifs[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _bgFor(n.type),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _iconFor(n.type),
                    size: 18,
                    color: _colorFor(n.type),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.titre,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                          n.lue ? FontWeight.w500 : FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        n.message,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n.temps,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!n.lue)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}