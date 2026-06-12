import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../data/infirmier_api_service.dart';

class InfirmierSaisieSoinScreen extends StatefulWidget {
  final String               idPassage;
  final PassageInfirmierApi? passage;
  final VoidCallback         onSaved;

  const InfirmierSaisieSoinScreen({
    super.key,
    required this.idPassage,
    this.passage,
    required this.onSaved,
  });

  @override
  State<InfirmierSaisieSoinScreen> createState() => _InfirmierSaisieSoinScreenState();
}

class _InfirmierSaisieSoinScreenState extends State<InfirmierSaisieSoinScreen> {
  final _api         = InfirmierApiService();
  final _autreCtrl   = TextEditingController();
  final _descCtrl    = TextEditingController();

  static const _types = ['Pansement', 'Perfusion', 'Nettoyage', 'Bandage', 'Autre'];
  String  _typeSoin = '';
  bool    _loading  = false;

  @override
  void dispose() {
    _autreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final type = _typeSoin == 'Autre' ? _autreCtrl.text.trim() : _typeSoin;
    if (type.isEmpty) {
      _showSnack('Sélectionnez un type de soin.', AppColors.warning);
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.enregistrerSoin(
        idPassage:   widget.idPassage,
        typeSoin:    type,
        description: _descCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Soin enregistré'),
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
          'Soin infirmier',
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

            // ── Type de soin ─────────────────────────────────────────────
            _SectionLabel(icon: Icons.medical_services_outlined, title: 'Type de soin'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.map((t) {
                final selected = _typeSoin == t;
                return GestureDetector(
                  onTap: () => setState(() => _typeSoin = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            if (_typeSoin == 'Autre') ...[
              const SizedBox(height: 12),
              _FieldCard(
                icon: Icons.edit_outlined,
                label: 'PRÉCISER',
                controller: _autreCtrl,
                hint: 'Décrivez le type de soin…',
              ),
            ],

            const SizedBox(height: 20),

            // ── Description ──────────────────────────────────────────────
            _SectionLabel(icon: Icons.notes_rounded, title: 'Description / Observations'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _descCtrl,
                maxLines: 4,
                style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.6),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Zone traitée, matériel utilisé, état de la plaie, réaction du patient…',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.5),
                ),
              ),
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
                  onPressed: _loading ? null : () => setState(() { _typeSoin = ''; _autreCtrl.clear(); _descCtrl.clear(); }),
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
                  label: Text(_loading ? 'Enregistrement…' : 'Valider le soin'),
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

class _FieldCard extends StatelessWidget {
  final IconData              icon;
  final String                label;
  final TextEditingController controller;
  final String                hint;
  const _FieldCard({required this.icon, required this.label, required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMedium),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textLight),
                labelText: label,
                labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMedium, letterSpacing: 0.5),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
