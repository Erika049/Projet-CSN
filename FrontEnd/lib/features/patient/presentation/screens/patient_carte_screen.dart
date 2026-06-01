import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../features/auth/data/auth_local_service.dart';
import '../../data/patient_api_service.dart';
import '../../data/patient_models.dart';

class PatientCarteScreen extends StatefulWidget {
  const PatientCarteScreen({super.key});

  @override
  State<PatientCarteScreen> createState() => _PatientCarteScreenState();
}

class _PatientCarteScreenState extends State<PatientCarteScreen>
    with SingleTickerProviderStateMixin {
  final _service = PatientApiService();
  final _authService = AuthLocalService();
  Patient? _patient;
  bool _loading = true;
  String? _error;
  bool _flipped = false;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final userId = await _authService.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('Session introuvable');
      }
      final patient = await _service.getProfil(userId);
      if (!mounted) { return; }
      setState(() {
        _patient = patient;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) { return; }
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _flip() {
    setState(() => _flipped = !_flipped);
    if (_flipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  void _showMoreSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ma carte numérique',
                    style: AppTextStyles.h4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _SheetTile(
                icon: Icons.home_outlined,
                label: 'Recevoir une carte physique',
                onTap: () {
                  Navigator.pop(context);
                  _showSnack('Demande envoyée à l\'hôpital');
                },
              ),
              _SheetTile(
                icon: Icons.refresh_rounded,
                label: 'Régénérer le token QR',
                onTap: () {
                  Navigator.pop(context);
                  _showSnack(
                      'Nouveau token généré · l\'ancien est révoqué');
                },
              ),
              _SheetTile(
                icon: Icons.shield_outlined,
                label: 'Voir le journal d\'accès',
                onTap: () => Navigator.pop(context),
              ),
              _SheetTile(
                icon: Icons.delete_outline,
                label: 'Déclarer ma carte perdue',
                color: AppColors.error,
                onTap: () {
                  Navigator.pop(context);
                  _showSnack(
                      'Carte suspendue · Contactez votre hôpital');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Partager ma carte',
                    style: AppTextStyles.h4,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'L\'identifiant et le QR sont transmis chiffrés.',
                  style: AppTextStyles.bodySmall,
                ),
              ),
              const SizedBox(height: 8),
              _SheetTile(
                icon: Icons.sms_outlined,
                label: 'SMS',
                onTap: () {
                  Navigator.pop(context);
                  _showSnack('Carte envoyée par SMS');
                },
              ),
              _SheetTile(
                icon: Icons.email_outlined,
                label: 'Email',
                onTap: () {
                  Navigator.pop(context);
                  _showSnack('Carte envoyée par email');
                },
              ),
              _SheetTile(
                icon: Icons.near_me_outlined,
                label: 'AirDrop / NFC',
                onTap: () {
                  Navigator.pop(context);
                  _showSnack('Recherche d\'appareils…');
                },
              ),
              _SheetTile(
                icon: Icons.link_outlined,
                label: 'Lien temporaire (24 h)',
                onTap: () {
                  Navigator.pop(context);
                  _showSnack('Lien copié dans le presse-papier');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.primary,
      ),
    );
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

    if (_patient == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Ma carte numérique'),
        ),
        body: CsnEmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Carte indisponible',
          message: 'Impossible de charger votre carte. '
              'Vérifiez votre connexion puis réessayez.',
          onRetry: _loadData,
        ),
      );
    }

    final patient = _patient!;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Ma carte numérique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: _showMoreSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Carte flip 3D — tap OU swipe horizontal
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _flip,
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity != null &&
                          details.primaryVelocity!.abs() > 100) {
                        _flip();
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _flipAnimation,
                      builder: (context, _) {
                        final angle = _flipAnimation.value * math.pi;
                        final isFront = angle < math.pi / 2;
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                          child: isFront
                              ? _CardFront(patient: patient)
                              : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..rotateY(math.pi),
                            child: _CardBack(patient: patient),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bouton retourner
              GestureDetector(
                onTap: _flip,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWhite,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.flip_camera_android_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _flipped
                            ? 'Voir le recto'
                            : 'Retourner pour le QR',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Boutons Partager / Wallet
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _showShareSheet,
                      child: const Text('Partager'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _showSnack('Carte ajoutée à Wallet'),
                      child: const Text('Ajouter à Wallet'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== RECTO ====================
class _CardFront extends StatelessWidget {
  final Patient patient;
  const _CardFront({required this.patient});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 560,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B3D91),
              Color(0xFF114BB0),
              Color(0xFF1A73E8),
            ],
            stops: [0.0, 0.48, 1.0],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B57D0).withValues(alpha: 0.55),
              blurRadius: 44,
              offset: const Offset(0, 22),
              spreadRadius: -18,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Motif guilloché
              Positioned.fill(
                child: Opacity(
                  opacity: 0.10,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ),

              // Logo Pulse décoratif bas droite
              const Positioned(
                right: -70,
                bottom: -70,
                child: Opacity(
                  opacity: 0.12,
                  child: CsnMarkPulse(
                    size: 230,
                    c1: Colors.white,
                    c2: Colors.white,
                  ),
                ),
              ),

              // Encoche badge
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 54,
                    height: 9,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.32),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
              ),

              // Contenu
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 30, 22, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header marque
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                          child: const Center(
                            child: CsnMarkPulse(
                              size: 24,
                              c1: Colors.white,
                              c2: Color(0xFF1A73E8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 11),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Carnet de Santé',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              'NUMÉRIQUE',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Text(
                            'Patient',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Photo (initiales)
                    Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFDCE8FF),
                              Color(0xFFA9C6FA),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            patient.initiales,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0B3D91),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Identité
                    Text(
                      '${patient.prenom} ${patient.nom}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ID · ${patient.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        fontFamily: 'monospace',
                        letterSpacing: 0.4,
                      ),
                    ),

                    const Spacer(),

                    // Séparateur
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    const SizedBox(height: 16),

                    // Champs bas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CardField(
                          label: 'Né(e) le',
                          value: patient.dateNaissance,
                        ),
                        _CardField(
                          label: 'Genre',
                          value: patient.genre,
                          center: true,
                        ),
                        _CardField(
                          label: 'Sang',
                          value: patient.groupeSanguin,
                          right: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== VERSO ====================
class _CardBack extends StatelessWidget {
  final Patient patient;
  const _CardBack({required this.patient});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 560,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF2F6FE)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B57D0).withValues(alpha: 0.55),
              blurRadius: 44,
              offset: const Offset(0, 22),
              spreadRadius: -18,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Encoche badge
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 54,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B3D91)
                          .withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFF0B3D91)
                            .withValues(alpha: 0.28),
                      ),
                    ),
                  ),
                ),
              ),

              // Bandeau magnétique
              Positioned(
                top: 34,
                left: 0,
                right: 0,
                child: Container(
                  height: 34,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0B3D91), Color(0xFF1A73E8)],
                    ),
                  ),
                ),
              ),

              // Contenu
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 88, 22, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Label + QR
                    const Text(
                      'PRÉSENTEZ À L\'ACCUEIL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMedium,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0B3D91)
                                .withValues(alpha: 0.4),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                            spreadRadius: -10,
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: patient.carte.qrCodeToken,
                        version: QrVersions.auto,
                        size: 158,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF0B3D91),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF0B3D91),
                        ),
                      ),
                    ),


                    const Spacer(),

                    // Stats validité
                    Row(
                      children: [
                        _BackStat(
                          label: 'Validité',
                          value: patient.carte.expiration,
                        ),
                        const SizedBox(width: 10),
                        const _BackStat(
                          label: 'Émis le',
                          value: '03 / 2024',
                        ),
                        const SizedBox(width: 10),
                        _BackStat(
                          label: 'Sang',
                          value: patient.groupeSanguin,
                          isDanger: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Contact urgence
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFF7C9C4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite_outlined,
                            size: 18,
                            color: Color(0xFFB3261E),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CONTACT D\'URGENCE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFB3261E),
                                  letterSpacing: 0.6,
                                ),
                              ),
                              Text(
                                '${patient.nom.split(' ').first} T. · ${patient.telephone}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Footer marque
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CsnMarkPulse(
                          size: 13,
                          c1: Color(0xFF0B3D91),
                          c2: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'CARNET DE SANTÉ NUMÉRIQUE · UCAC-ICAM',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== WIDGETS LOCAUX ====================

class _CardField extends StatelessWidget {
  final String label;
  final String value;
  final bool center;
  final bool right;

  const _CardField({
    required this.label,
    required this.value,
    this.center = false,
    this.right = false,
  });

  @override
  Widget build(BuildContext context) {
    final align = center
        ? TextAlign.center
        : right
        ? TextAlign.right
        : TextAlign.left;
    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : right
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          textAlign: align,
          style: const TextStyle(
            fontSize: 8,
            color: Colors.white70,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          textAlign: align,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _BackStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isDanger;

  const _BackStat({
    required this.label,
    required this.value,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: isDanger ? AppColors.errorLight : Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isDanger
                ? const Color(0xFFF7C9C4)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 8,
                color: AppColors.textMedium,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDanger
                    ? const Color(0xFFB3261E)
                    : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textDark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: c, size: 20),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: c,
        ),
      ),
      onTap: onTap,
    );
  }
}