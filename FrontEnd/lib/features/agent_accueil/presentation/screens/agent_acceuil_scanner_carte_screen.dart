import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/theme.dart';
import 'agent_acceuil_confirmation_passage_screen.dart';

/// Écran "Scanner la carte" (AGENT 15/41).
///
/// Caméra réelle via `mobile_scanner` : à la lecture d'un QR, on récupère le
/// token de la carte et on ouvre l'écran de confirmation, qui interroge le
/// backend (`/admission/scan-carte`) pour identifier le patient.
///
/// [embedded] passe à `true` quand l'écran est intégré comme onglet dans la
/// coquille (pas de bouton retour, on change d'onglet pour quitter).
class ScannerCarteScreen extends StatefulWidget {
  final bool embedded;

  const ScannerCarteScreen({super.key, this.embedded = false});

  @override
  State<ScannerCarteScreen> createState() => _ScannerCarteScreenState();
}

class _ScannerCarteScreenState extends State<ScannerCarteScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final code =
        capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (code == null || code.isEmpty) return;

    setState(() => _handled = true);
    await _controller.stop();
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmationPassageScreen(qrToken: code),
      ),
    );

    // Retour sur le scanner → on réautorise une nouvelle lecture.
    if (!mounted) return;
    setState(() => _handled = false);
    await _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(embedded: widget.embedded, controller: _controller),
            Expanded(
              child: _ScanArea(controller: _controller, onDetect: _onDetect),
            ),
            const _BottomPanel(),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool embedded;
  final MobileScannerController controller;
  const _TopBar({required this.embedded, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (embedded)
            const SizedBox(width: 40)
          else
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.white,
              ),
            ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 4, backgroundColor: AppColors.success),
                SizedBox(width: 8),
                Text(
                  'Admission · Hôpital Général',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white12,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => controller.toggleTorch(),
              icon: const Icon(Icons.flash_on, color: Colors.white, size: 18),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanArea extends StatelessWidget {
  final MobileScannerController controller;
  final void Function(BarcodeCapture) onDetect;
  const _ScanArea({required this.controller, required this.onDetect});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox.expand(
                  child: MobileScanner(
                    controller: controller,
                    onDetect: onDetect,
                    errorBuilder: (context, error, child) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Caméra indisponible.\n'
                            'Vérifiez les autorisations de l’appareil.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const _Corner(top: true, left: true),
              const _Corner(top: true, left: false),
              const _Corner(top: false, left: true),
              const _Corner(top: false, left: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final bool top;
  final bool left;
  const _Corner({required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: AppColors.primary, width: 4);
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          border: Border(
            top: top ? side : BorderSide.none,
            bottom: top ? BorderSide.none : side,
            left: left ? side : BorderSide.none,
            right: left ? BorderSide.none : side,
          ),
        ),
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scannez la carte du patient',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Approchez le QR code dans le viseur',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 36),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.search, size: 18, color: Colors.white),
                  label: const Text(
                    'Recherche manuelle',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    backgroundColor: Colors.white10,
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text(
                    'Nouveau patient',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    backgroundColor: Colors.white10,
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
