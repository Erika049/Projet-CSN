import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../data/infirmier_api_service.dart';

class InfirmierSaisieInjectionScreen extends StatefulWidget {
  final String               idPassage;
  final PassageInfirmierApi? passage;
  final VoidCallback         onSaved;

  const InfirmierSaisieInjectionScreen({
    super.key,
    required this.idPassage,
    this.passage,
    required this.onSaved,
  });

  @override
  State<InfirmierSaisieInjectionScreen> createState() => _InfirmierSaisieInjectionScreenState();
}

class _InfirmierSaisieInjectionScreenState extends State<InfirmierSaisieInjectionScreen> {
  final _api           = InfirmierApiService();
  final _medicCtrl     = TextEditingController();
  final _doseCtrl      = TextEditingController();

  static const _voies = [
    _Voie('IV',  'Intra-veineuse'),
    _Voie('IM',  'Intra-musculaire'),
    _Voie('SC',  'Sous-cutanée'),
    _Voie('PO',  'Orale'),
  ];
  String _voie    = '';
  bool   _loading = false;

  @override
  void dispose() {
    _medicCtrl.dispose();
    _doseCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_medicCtrl.text.trim().isEmpty) {
      _showSnack('Indiquez le médicament.', AppColors.warning);
      return;
    }
    if (_voie.isEmpty) {
      _showSnack("Sélectionnez la voie d'administration.", AppColors.warning);
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.enregistrerInjection(
        idPassage:  widget.idPassage,
        medicament: _medicCtrl.text.trim(),
        dose:       _doseCtrl.text.trim(),
        voie:       _voie,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Injection enregistrée'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
      widget.onSaved();
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''), AppColors.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Injection médicamenteuse',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [

            // ── Contexte patient ────────────────────────────────────────
            if (widget.passage != null) ...[
              _PatientHeader(passage: widget.passage!),
              const SizedBox(height: 20),
            ],

            // ── Médicament ───────────────────────────────────────────────
            _SectionLabel(icon: Icons.medication_outlined, title: 'Médicament'),
            const SizedBox(height: 10),
            _InputCard(
              controller: _medicCtrl,
              hint: 'Nom du médicament (DCI ou commercial)',
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 20),

            // ── Dose ─────────────────────────────────────────────────────
            _SectionLabel(icon: Icons.science_outlined, title: 'Dosage'),
            const SizedBox(height: 10),
            _InputCard(
              controller: _doseCtrl,
              hint: 'ex: 500 mg · 1 ampoule · 10 ml',
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 20),

            // ── Voie ─────────────────────────────────────────────────────
            _SectionLabel(icon: Icons.route_outlined, title: "Voie d'administration"),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3.0,
              children: _voies.map((v) {
                final selected = _voie == v.code;
                return GestureDetector(
                  onTap: () => setState(() => _voie = v.code),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          v.code,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          v.label,
                          style: TextStyle(
                            fontSize: 11,
                            color: selected ? Colors.white.withValues(alpha: 0.85) : AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: const BoxDecoration(
            color: AppColors.backgroundWhite,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _loading ? null : () => setState(() {
                    _medicCtrl.clear();
                    _doseCtrl.clear();
                    _voie = '';
                  }),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: AppColors.textMedium,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Réinitialiser'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: _loading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(_loading ? 'Enregistrement…' : "Valider l'injection"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Voie {
  final String code;
  final String label;
  const _Voie(this.code, this.label);
}

class _PatientHeader extends StatelessWidget {
  final PassageInfirmierApi passage;
  const _PatientHeader({required this.passage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Center(child: Text(passage.initials, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(passage.nomComplet, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 2),
                Text('${passage.motifVisite} · ${passage.heure}', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
          ),
          if (passage.isUrgence)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
              child: const Text('Urgence', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String   title;
  const _SectionLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMedium),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMedium, letterSpacing: 0.3)),
      ],
    );
  }
}

class _InputCard extends StatelessWidget {
  final TextEditingController controller;
  final String                hint;
  final TextInputType         keyboardType;
  const _InputCard({required this.controller, required this.hint, required this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, color: AppColors.textDark),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textLight),
        ),
      ),
    );
  }
}
