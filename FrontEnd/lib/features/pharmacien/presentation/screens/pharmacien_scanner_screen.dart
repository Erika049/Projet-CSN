import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/theme.dart';
import '../../data/pharmacien_mock_data.dart';
import '../../data/pharmacien_repository.dart';
import 'pharmacien_detail_ordonnance_screen.dart';

class PharmacienScannerScreen extends StatefulWidget {
  const PharmacienScannerScreen({super.key});

  @override
  State<PharmacienScannerScreen> createState() => _PharmacienScannerScreenState();
}

class _PharmacienScannerScreenState extends State<PharmacienScannerScreen>
    with SingleTickerProviderStateMixin {
  
  final _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  
  final PharmacienRepository _repository = PharmacienRepository();
  bool _scanned = false;
  bool _loading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned || _loading) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    
    setState(() => _scanned = true);
    await _processOrdonnanceToken(raw);
  }

  Future<void> _processOrdonnanceToken(String token) async {
    setState(() { _loading = true; _errorMsg = null; });

    try {
      final ordData = await _repository.getOrdonnanceById(token);
      
      if (!mounted) return;
      
      // Conversion de la map API en OrdonnanceItem
      // Note: Cela nécessite d'adapter le constructeur de OrdonnanceItem ou de créer une factory
      // Pour l'instant, je vais laisser le passage à l'écran de détail tel quel
      // Il faudra ajuster le modèle OrdonnanceItem dans une prochaine itération
      // ou convertir ordData en OrdonnanceItem.
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PharmacienDetailOrdonnanceScreen(item: _mapToOrdonnanceItem(ordData)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() { _errorMsg = 'Ordonnance invalide ou introuvable'; });
    } finally {
      if (mounted) setState(() { _loading = false; _scanned = false; });
    }
  }
  
  // Helper temporaire
  OrdonnanceItem _mapToOrdonnanceItem(dynamic data) {
    return OrdonnanceItem.fromJson(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _cameraController,
              onDetect: _onDetect,
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      _IconBtn(icon: Icons.close, onTap: () => Navigator.pop(context)),
                      const Spacer(),
                      const Text('Scan Ordonnance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                
                // Viseur simplifié
                Expanded(child: Center(
                  child: Container(
                    width: 250, height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                )),
                
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    _errorMsg ?? 'Scannez le QR code de l\'ordonnance',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
