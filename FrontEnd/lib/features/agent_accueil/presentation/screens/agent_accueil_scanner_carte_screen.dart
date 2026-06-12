import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/theme.dart';
import '../../../../features/auth/data/auth_local_service.dart';
import '../../data/agent_accueil_api_service.dart';
import 'agent_accueil_confirmation_passage_screen.dart';

class ScannerCarteScreen extends StatefulWidget {
  final bool          embedded;
  final VoidCallback? onAdmissionSuccess;
  final VoidCallback? onNouveauPatient;

  const ScannerCarteScreen({
    super.key,
    this.embedded = false,
    this.onAdmissionSuccess,
    this.onNouveauPatient,
  });

  @override
  State<ScannerCarteScreen> createState() => _ScannerCarteScreenState();
}

class _ScannerCarteScreenState extends State<ScannerCarteScreen>
    with SingleTickerProviderStateMixin {

  final _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  final _tokenController = TextEditingController();
  final _api   = AgentAccueilApiService();
  final _local = AuthLocalService();

  late final AnimationController _lineCtrl;
  late final Animation<double>   _lineAnim;

  bool    _loading     = false;
  bool    _torchOn     = false;
  bool    _scanned     = false;
  bool    _showManual  = false;
  String? _errorMsg;

  // ── Init ────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _lineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _lineAnim = CurvedAnimation(parent: _lineCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _lineCtrl.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  // ── Logique ─────────────────────────────────────────────────────────────────
  void _onDetect(BarcodeCapture capture) {
    if (_scanned || _loading) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    setState(() => _scanned = true);
    _processToken(raw);
  }

  Future<void> _processToken(String token) async {
    setState(() { _loading = true; _errorMsg = null; });
    try {
      final agentId = await _local.getUserId();
      if (agentId == null) throw Exception('Session expirée');
      final profil  = await _api.getProfil(agentId);
      final idHopital = profil.idHopital;
      if (idHopital == null) throw Exception('Aucun hôpital associé à ce compte. Contactez l\'administrateur.');
      final patient = await _api.scanCarte(token);
      if (!mounted) return;
      setState(() => _loading = false);
      final admitted = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmationPassageScreen(
            patient:   patient,
            idHopital: idHopital,
          ),
        ),
      );
      if (!mounted) return;
      if (admitted == true) {
        // Admission validée → notifier le shell de revenir au dashboard
        widget.onAdmissionSuccess?.call();
      }
      setState(() { _scanned = false; _errorMsg = null; _tokenController.clear(); });
    } catch (e) {
      if (mounted) setState(() {
        _loading  = false;
        _scanned  = false;
        _errorMsg = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _toggleTorch() {
    _cameraController.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Caméra ──────────────────────────────────────────────────────────
          Positioned.fill(
            child: MobileScanner(
              controller: _cameraController,
              onDetect: _onDetect,
            ),
          ),

          // ── Overlay + UI ─────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  embedded: widget.embedded,
                  torchOn: _torchOn,
                  onBack: () => Navigator.pop(context),
                  onTorch: _toggleTorch,
                ),
                Expanded(child: _ScanZone(lineAnim: _lineAnim, error: _errorMsg)),
                _BottomPanel(
                  showManual: _showManual,
                  loading: _loading,
                  controller: _tokenController,
                  error: _errorMsg,
                  onToggleManual: () => setState(() {
                    _showManual = !_showManual;
                    _errorMsg = null;
                  }),
                  onSubmit: () {
                    if (_showManual) {
                      final t = _tokenController.text.trim();
                      if (t.isEmpty) {
                        setState(() => _errorMsg = 'Saisissez le token QR.');
                        return;
                      }
                      _scanned = true;
                      _processToken(t);
                    }
                  },
                  onNouveauPatient: widget.onNouveauPatient,
                ),
              ],
            ),
          ),

          // ── Loader plein écran ───────────────────────────────────────────────
          if (_loading)
            const _LoadingOverlay(),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Barre du haut
// ════════════════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final bool embedded;
  final bool torchOn;
  final VoidCallback onBack;
  final VoidCallback onTorch;

  const _TopBar({
    required this.embedded,
    required this.torchOn,
    required this.onBack,
    required this.onTorch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          // Retour
          if (!embedded)
            _IconBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack,
            )
          else
            const SizedBox(width: 40),

          // Badge hôpital
          const Expanded(
            child: Center(
              child: _HospitalBadge(),
            ),
          ),

          // Torche
          _IconBtn(
            icon: torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            onTap: onTorch,
            active: torchOn,
          ),
        ],
      ),
    );
  }
}

class _HospitalBadge extends StatelessWidget {
  const _HospitalBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: Color(0xFF4ADE80)),
          SizedBox(width: 8),
          Text(
            'Admission · Hôpital Général',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _IconBtn({required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Zone de scan (viseur + ligne animée + overlay)
// ════════════════════════════════════════════════════════════════════════════
class _ScanZone extends StatelessWidget {
  final Animation<double> lineAnim;
  final String? error;

  const _ScanZone({required this.lineAnim, this.error});

  static const double _frameSize = 240.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final vPad = (constraints.maxHeight - _frameSize) / 2;
      final hPad = (constraints.maxWidth  - _frameSize) / 2;

      return Stack(
        children: [
          // Overlay sombre (4 bandes autour du viseur)
          CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _ScanOverlayPainter(
              frameRect: Rect.fromLTWH(hPad, vPad, _frameSize, _frameSize),
            ),
          ),

          // Ligne de scan animée
          Positioned(
            left: hPad + 20,
            right: hPad + 20,
            top: vPad,
            child: AnimatedBuilder(
              animation: lineAnim,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, lineAnim.value * (_frameSize - 2)),
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.primary,
                        AppColors.primary,
                        Colors.transparent,
                      ],
                      stops: const [0, 0.2, 0.8, 1],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Coins bleus du viseur
          Positioned(
            left: hPad, top: vPad,
            child: _ScanCorners(size: _frameSize, color: AppColors.primary),
          ),

          // Label en dessous du viseur
          Positioned(
            left: 0, right: 0,
            top: vPad + _frameSize + 20,
            child: Center(
              child: error != null
                  ? _ErrorChip(message: error!)
                  : const _HintChip(),
            ),
          ),
        ],
      );
    });
  }
}

class _ScanOverlayPainter extends CustomPainter {
  final Rect frameRect;
  _ScanOverlayPainter({required this.frameRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);
    final full  = Rect.fromLTWH(0, 0, size.width, size.height);
    final path  = Path()
      ..addRect(full)
      ..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter old) => old.frameRect != frameRect;
}

class _ScanCorners extends StatelessWidget {
  final double size;
  final Color color;
  const _ScanCorners({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    const arm = 28.0;
    const w   = 3.0;
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(
        painter: _CornersPainter(color: color, arm: arm, stroke: w),
      ),
    );
  }
}

class _CornersPainter extends CustomPainter {
  final Color color;
  final double arm;
  final double stroke;
  _CornersPainter({required this.color, required this.arm, required this.stroke});

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const r = 12.0;

    // Top-left
    canvas.drawLine(Offset(r, 0), Offset(arm, 0), p);
    canvas.drawLine(Offset(0, r), Offset(0, arm), p);
    canvas.drawArc(Rect.fromLTWH(0, 0, r * 2, r * 2), -3.14 / 2 * 2, 3.14 / 2, false, p);
    // Top-right
    canvas.drawLine(Offset(s.width - arm, 0), Offset(s.width - r, 0), p);
    canvas.drawLine(Offset(s.width, r), Offset(s.width, arm), p);
    canvas.drawArc(Rect.fromLTWH(s.width - r * 2, 0, r * 2, r * 2), -3.14 / 2, 3.14 / 2, false, p);
    // Bottom-left
    canvas.drawLine(Offset(0, s.height - arm), Offset(0, s.height - r), p);
    canvas.drawLine(Offset(r, s.height), Offset(arm, s.height), p);
    canvas.drawArc(Rect.fromLTWH(0, s.height - r * 2, r * 2, r * 2), 3.14 / 2 * 2, 3.14 / 2, false, p);
    // Bottom-right
    canvas.drawLine(Offset(s.width, s.height - arm), Offset(s.width, s.height - r), p);
    canvas.drawLine(Offset(s.width - arm, s.height), Offset(s.width - r, s.height), p);
    canvas.drawArc(Rect.fromLTWH(s.width - r * 2, s.height - r * 2, r * 2, r * 2), 0, 3.14 / 2, false, p);
  }

  @override
  bool shouldRepaint(_CornersPainter old) => false;
}

class _HintChip extends StatelessWidget {
  const _HintChip();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_rounded, color: Colors.white, size: 14),
          SizedBox(width: 6),
          Text(
            'Pointez la carte QR du patient',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ErrorChip extends StatelessWidget {
  final String message;
  const _ErrorChip({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Panel du bas
// ════════════════════════════════════════════════════════════════════════════
class _BottomPanel extends StatelessWidget {
  final bool showManual;
  final bool loading;
  final TextEditingController controller;
  final String? error;
  final VoidCallback onToggleManual;
  final VoidCallback onSubmit;
  final VoidCallback? onNouveauPatient;

  const _BottomPanel({
    required this.showManual,
    required this.loading,
    required this.controller,
    required this.error,
    required this.onToggleManual,
    required this.onSubmit,
    this.onNouveauPatient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1220),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20)],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Poignée
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Titre + FAB
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scannez la carte du patient',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Approchez le QR code dans le viseur',
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.55)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onSubmit,
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 2),
                    ],
                  ),
                  child: loading
                      ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                      : const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Saisie manuelle expansible
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: showManual
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Token QR du patient',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                        prefixIcon: const Icon(Icons.qr_code_2_outlined, color: AppColors.primary, size: 20),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send_rounded, color: AppColors.primary, size: 20),
                          onPressed: onSubmit,
                        ),
                      ),
                      onSubmitted: (_) => onSubmit(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // 2 boutons en bas
          Row(
            children: [
              Expanded(
                child: _PanelBtn(
                  icon: Icons.search_rounded,
                  label: 'Recherche manuelle',
                  onTap: onToggleManual,
                  active: showManual,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PanelBtn(
                  icon: Icons.person_add_alt_1_rounded,
                  label: 'Nouveau patient',
                  onTap: onNouveauPatient ?? () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PanelBtn extends StatelessWidget {
  final IconData   icon;
  final String     label;
  final VoidCallback onTap;
  final bool       active;

  const _PanelBtn({required this.icon, required this.label, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppColors.primary.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: active ? AppColors.primary : Colors.white70),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, color: active ? AppColors.primary : Colors.white70, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Loader plein écran
// ════════════════════════════════════════════════════════════════════════════
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2740),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
              SizedBox(height: 16),
              Text(
                'Identification en cours…',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
