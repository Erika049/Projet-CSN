import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../patient/presentation/widgets/patient_widgets.dart';
import '../../data/infirmier_api_service.dart';

class InfirmierSaisieConstantesScreen extends StatefulWidget {
  final PassageInfirmierApi? passage;
  final String               infName;
  final String               infInitials;
  final VoidCallback?        onSaved;
  final VoidCallback?        onCancel;

  const InfirmierSaisieConstantesScreen({
    super.key,
    this.passage,
    this.infName     = '',
    this.infInitials = '?',
    this.onSaved,
    this.onCancel,
  });

  @override
  State<InfirmierSaisieConstantesScreen> createState() =>
      _InfirmierSaisieConstantesScreenState();
}

class _InfirmierSaisieConstantesScreenState
    extends State<InfirmierSaisieConstantesScreen> {
  final _api = InfirmierApiService();

  late final TextEditingController _tensionCtrl;
  late final TextEditingController _tempCtrl;
  late final TextEditingController _poidsCtrl;
  late final TextEditingController _freqCardCtrl;
  late final TextEditingController _spo2Ctrl;
  late final TextEditingController _freqRespiCtrl;
  late final TextEditingController _noteCtrl;

  bool _loading         = false;
  bool _loadingExisting = false;

  @override
  void initState() {
    super.initState();
    _tensionCtrl   = TextEditingController();
    _tempCtrl      = TextEditingController();
    _poidsCtrl     = TextEditingController();
    _freqCardCtrl  = TextEditingController();
    _spo2Ctrl      = TextEditingController();
    _freqRespiCtrl = TextEditingController();
    _noteCtrl      = TextEditingController();

    if (widget.passage?.constantesFaites == true) {
      _loadExisting();
    }
  }

  @override
  void didUpdateWidget(InfirmierSaisieConstantesScreen old) {
    super.didUpdateWidget(old);
    if (widget.passage != old.passage) {
      _clearAll();
      if (widget.passage?.constantesFaites == true) {
        _loadExisting();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _all) c.dispose();
    super.dispose();
  }

  List<TextEditingController> get _all =>
      [_tensionCtrl, _tempCtrl, _poidsCtrl, _freqCardCtrl, _spo2Ctrl, _freqRespiCtrl, _noteCtrl];

  void _clearAll() {
    for (final c in _all) c.clear();
  }

  Future<void> _loadExisting() async {
    final passage = widget.passage;
    if (passage == null) return;
    setState(() => _loadingExisting = true);
    try {
      final data = await _api.getConstantes(passage.idPassage);
      if (!mounted) return;
      _tensionCtrl.text   = data['tension']        ?? '';
      _tempCtrl.text      = data['temperature']    ?? '';
      _poidsCtrl.text     = data['poids']          ?? '';
      _freqCardCtrl.text  = data['freqCardiaque']  ?? '';
      _spo2Ctrl.text      = data['spo2']           ?? '';
      _freqRespiCtrl.text = data['freqRespi']      ?? '';
      _noteCtrl.text      = data['noteInfirmiere'] ?? '';
    } catch (_) {
      // Silently ignore: the form stays empty and can be re-filled
    } finally {
      if (mounted) setState(() => _loadingExisting = false);
    }
  }

  Future<void> _valider() async {
    final passage = widget.passage;
    if (passage == null) return;

    setState(() => _loading = true);
    try {
      await _api.updateConstantes(
        idPassage:      passage.idPassage,
        tension:        _tensionCtrl.text.trim(),
        temperature:    _tempCtrl.text.trim(),
        poids:          _poidsCtrl.text.trim(),
        freqCardiaque:  _freqCardCtrl.text.trim(),
        spo2:           _spo2Ctrl.text.trim(),
        freqRespi:      _freqRespiCtrl.text.trim(),
        noteInfirmiere: _noteCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Constantes enregistrées'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onSaved?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final passage = widget.passage;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Constantes vitales',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: passage == null
            ? _buildNoPassage()
            : _loadingExisting
                ? const Center(child: CircularProgressIndicator(color: AppColors.roleInfirmier, strokeWidth: 2))
                : _buildForm(passage),
      ),
      bottomNavigationBar: passage == null
          ? null
          : SafeArea(
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
                        onPressed: _loading ? null : _clearAll,
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
                        onPressed: _loading ? null : _valider,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        icon: _loading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.check_rounded, size: 18),
                        label: Text(_loading ? 'Enregistrement…' : 'Valider'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildForm(PassageInfirmierApi passage) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // Carte patient
        _PatientHeader(passage: passage),
        const SizedBox(height: 16),

        // Bannière mise à jour
        if (passage.constantesFaites) ...[
          _UpdateBanner(),
          const SizedBox(height: 16),
        ],

        // Section constantes
        _SectionTitle(title: 'Paramètres vitaux', icon: Icons.monitor_heart_outlined),
        const SizedBox(height: 10),

        _VitalTile(
          icon: Icons.favorite_border_rounded,
          label: 'TENSION',
          controller: _tensionCtrl,
          unit: 'cmHg',
          hint: 'ex: 120/80',
          reference: 'Réf : 80–120 / 60–80',
          color: AppColors.primary,
        ),
        _VitalTile(
          icon: Icons.thermostat_outlined,
          label: 'TEMPÉRATURE',
          controller: _tempCtrl,
          unit: '°C',
          hint: 'ex: 37.2',
          reference: 'Réf : 36.5 – 37.5',
          color: AppColors.warning,
        ),
        _VitalTile(
          icon: Icons.scale_outlined,
          label: 'POIDS',
          controller: _poidsCtrl,
          unit: 'kg',
          hint: 'ex: 70',
          reference: '',
          color: AppColors.textDark,
        ),
        _VitalTile(
          icon: Icons.graphic_eq_rounded,
          label: 'FRÉQ. CARDIAQUE',
          controller: _freqCardCtrl,
          unit: 'bpm',
          hint: 'ex: 75',
          reference: 'Réf : 60 – 100',
          color: AppColors.success,
        ),
        _VitalTile(
          icon: Icons.air_outlined,
          label: 'SpO₂',
          controller: _spo2Ctrl,
          unit: '%',
          hint: 'ex: 98',
          reference: 'Réf : ≥ 95',
          color: AppColors.success,
        ),
        _VitalTile(
          icon: Icons.waves_rounded,
          label: 'FRÉQ. RESPIRATOIRE',
          controller: _freqRespiCtrl,
          unit: '/min',
          hint: 'ex: 16',
          reference: 'Réf : 12 – 20',
          color: AppColors.textMedium,
        ),

        const SizedBox(height: 16),
        _SectionTitle(title: 'Observations', icon: Icons.notes_rounded),
        const SizedBox(height: 10),
        _NoteCard(controller: _noteCtrl),

        const SizedBox(height: 16),
        _SignatureRow(
          userName: widget.infName.isNotEmpty ? widget.infName : 'Infirmier(e)',
          initials: widget.infInitials,
        ),
      ],
    );
  }

  Widget _buildNoPassage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.touch_app_outlined, size: 36, color: AppColors.textLight),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun patient sélectionné',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            const SizedBox(height: 10),
            const Text(
              'Allez dans l\'onglet "À constanter" et appuyez sur un patient pour saisir ses constantes.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textMedium, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets internes
// ─────────────────────────────────────────────────────────────────────────────

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
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                passage.initials,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passage.nomComplet,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  '${passage.motifVisite} · Admis à ${passage.heure}',
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: passage.isUrgence
                  ? AppColors.error
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              passage.isUrgence ? 'Urgence' : 'Triage',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Constantes déjà enregistrées — vous pouvez les mettre à jour.',
              style: TextStyle(fontSize: 12, color: AppColors.primary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String   title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMedium),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMedium, letterSpacing: 0.4),
        ),
      ],
    );
  }
}

class _VitalTile extends StatelessWidget {
  final IconData               icon;
  final String                 label;
  final TextEditingController  controller;
  final String                 unit;
  final String                 hint;
  final String                 reference;
  final Color                  color;

  const _VitalTile({
    required this.icon,
    required this.label,
    required this.controller,
    required this.unit,
    required this.hint,
    required this.reference,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icône colorée
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          // Label + champ + référence
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5),
                ),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  decoration: InputDecoration(
                    border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    hintText: hint,
                    hintStyle: const TextStyle(fontSize: 20, color: AppColors.textLight, fontWeight: FontWeight.w400),
                  ),
                ),
                if (reference.isNotEmpty)
                  Text(reference, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
              ],
            ),
          ),
          // Unité
          Text(unit, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMedium)),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final TextEditingController controller;
  const _NoteCard({required this.controller});

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
        maxLines: 4,
        style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.6),
        decoration: const InputDecoration(
          border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none,
          isDense: true, contentPadding: EdgeInsets.zero,
          hintText: 'Observations : comportement, douleur, remarques particulières…',
          hintStyle: TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.5),
        ),
      ),
    );
  }
}

class _SignatureRow extends StatelessWidget {
  final String userName, initials;
  const _SignatureRow({required this.userName, required this.initials});

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final heure = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
            child: Center(
              child: Text(initials, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.success)),
                Text('Enregistrement à $heure', style: const TextStyle(fontSize: 11, color: AppColors.success)),
              ],
            ),
          ),
          const Icon(Icons.verified_outlined, size: 18, color: AppColors.success),
        ],
      ),
    );
  }
}
