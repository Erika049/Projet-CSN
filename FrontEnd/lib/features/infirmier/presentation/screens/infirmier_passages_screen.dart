import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../patient/presentation/widgets/patient_widgets.dart';
import '../../data/infirmier_api_service.dart';
import '../../../../features/auth/data/auth_local_service.dart';

class InfirmierPassagesScreen extends StatefulWidget {
  final void Function(PassageInfirmierApi passage)         onSelectPassage;
  final void Function(PassageInfirmierApi passage, String type) onSelectActe;
  final ValueNotifier<int>?                                refreshNotifier;

  const InfirmierPassagesScreen({
    super.key,
    required this.onSelectPassage,
    required this.onSelectActe,
    this.refreshNotifier,
  });

  @override
  State<InfirmierPassagesScreen> createState() => _InfirmierPassagesScreenState();
}

class _InfirmierPassagesScreenState extends State<InfirmierPassagesScreen> {
  final _api   = InfirmierApiService();
  final _local = AuthLocalService();

  InfirmierDashboardApi? _data;
  bool   _loading   = true;
  bool   _isOffline = false;
  String _search    = '';
  String _filtre    = 'Tous'; // Tous | À faire | Faits

  @override
  void initState() {
    super.initState();
    _load();
    widget.refreshNotifier?.addListener(_load);
  }

  @override
  void dispose() {
    widget.refreshNotifier?.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _isOffline = false; });
    try {
      final id = await _local.getUserId();
      if (id == null) throw Exception('Session expirée');
      final data = await _api.getDashboard(id);
      if (mounted) setState(() { _data = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _isOffline = true; });
    }
  }

  List<PassageInfirmierApi> get _filtered {
    var list = _data?.passages ?? [];
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((p) =>
          p.nomPatient.toLowerCase().contains(q) ||
          p.prenomPatient.toLowerCase().contains(q) ||
          p.motifVisite.toLowerCase().contains(q)).toList();
    }
    if (_filtre == 'À faire') list = list.where((p) => !p.constantesFaites).toList();
    if (_filtre == 'Faits')   list = list.where((p) =>  p.constantesFaites).toList();
    return list;
  }

  void _showActionSheet(PassageInfirmierApi passage) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ActionSheet(
        passage: passage,
        onConstantes: () {
          Navigator.pop(context);
          widget.onSelectPassage(passage);
        },
        onSoin: () {
          Navigator.pop(context);
          widget.onSelectActe(passage, 'soin');
        },
        onInjection: () {
          Navigator.pop(context);
          widget.onSelectActe(passage, 'injection');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.roleInfirmier))
            : RefreshIndicator(
                onRefresh: _load,
                color: AppColors.roleInfirmier,
                child: _buildContent(),
              ),
      ),
    );
  }

  Widget _buildContent() {
    final prenom   = _data?.infirmierPrenom ?? '—';
    final initials = _data?.initials        ?? '?';
    final nomHop   = _data?.nomHopital      ?? 'Hôpital';
    final aConst   = _data?.totalAConstanter ?? 0;
    final urgences = _data?.urgences         ?? 0;
    final faits    = _data?.faits            ?? 0;
    final list     = _filtered;

    return CustomScrollView(
      slivers: [
        // ── En-tête ──────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nomHop, style: AppTextStyles.bodyMedium),
                      Text('Bonjour $prenom', style: AppTextStyles.h1),
                    ],
                  ),
                ),
                InitialsAvatar(initials: initials, size: 44,
                    background: const Color(0xFFFFF7ED),
                    foreground: AppColors.roleInfirmier),
              ],
            ),
          ),
        ),

        // ── Stats ────────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Expanded(child: _InfStatCard(value: '$aConst',   label: 'À CONSTANTER', valueColor: AppColors.textDark,   background: AppColors.primaryLight)),
                const SizedBox(width: 10),
                Expanded(child: _InfStatCard(value: '$urgences', label: 'URGENCE',       valueColor: AppColors.error,      background: AppColors.errorLight)),
                const SizedBox(width: 10),
                Expanded(child: _InfStatCard(value: '$faits',    label: 'FAITS',         valueColor: AppColors.textMedium, background: AppColors.surfaceLight)),
              ],
            ),
          ),
        ),

        // ── Bannière hors-ligne ───────────────────────────────────────────────
        if (_isOffline)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: _OfflineBanner(onRefresh: _load),
            ),
          ),

        // ── Barre de recherche ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: AppColors.textLight, size: 20),
                  border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none,
                  filled: false,
                  hintText: 'Rechercher un patient, un motif…',
                  hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
                ),
              ),
            ),
          ),
        ),

        // ── Filtres ───────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Row(
              children: ['Tous', 'À faire', 'Faits'].map((f) {
                final selected = _filtre == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filtre = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.roleInfirmier : AppColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? AppColors.roleInfirmier : AppColors.border),
                      ),
                      child: Text(f, style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textMedium,
                      )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // ── En-tête section ───────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: SectionHeader(
              title: 'Patients du jour · ${list.length}',
              actionLabel: 'Actualiser',
              onAction: _load,
            ),
          ),
        ),

        // ── Liste ─────────────────────────────────────────────────────────────
        if (list.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: _EmptyState(filtre: _filtre, search: _search),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: _PassageRow(
                  passage: list[i],
                  onTap: () => _showActionSheet(list[i]),
                ),
              ),
              childCount: list.length,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action sheet (bottom sheet)
// ─────────────────────────────────────────────────────────────────────────────

class _ActionSheet extends StatelessWidget {
  final PassageInfirmierApi passage;
  final VoidCallback onConstantes, onSoin, onInjection;
  const _ActionSheet({required this.passage, required this.onConstantes, required this.onSoin, required this.onInjection});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          // Patient
          Row(
            children: [
              InitialsAvatar(
                initials: passage.initials, size: 42,
                background: passage.isUrgence ? AppColors.errorLight : const Color(0xFFFFF7ED),
                foreground: passage.isUrgence ? AppColors.error : AppColors.roleInfirmier,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(passage.nomComplet, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    Text('${passage.motifVisite} · Admis ${passage.heure}', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              if (passage.isUrgence)
                StatusChip(label: 'Urgence', foreground: AppColors.error, background: AppColors.errorLight),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Que souhaitez-vous faire ?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMedium, letterSpacing: 0.3)),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.monitor_heart_outlined,
            iconColor: AppColors.roleInfirmier,
            iconBg: const Color(0xFFFFF7ED),
            title: passage.constantesFaites ? 'Mettre à jour les constantes' : 'Prendre les constantes',
            subtitle: passage.constantesFaites ? 'Déjà enregistrées — mise à jour possible' : 'Tension, température, SpO₂…',
            onTap: onConstantes,
          ),
          const SizedBox(height: 8),
          _ActionTile(
            icon: Icons.medical_services_outlined,
            iconColor: AppColors.success,
            iconBg: AppColors.successLight,
            title: 'Enregistrer un soin',
            subtitle: 'Pansement, massage, aspiration…',
            onTap: onSoin,
          ),
          const SizedBox(height: 8),
          _ActionTile(
            icon: Icons.vaccines_outlined,
            iconColor: const Color(0xFF7C3AED),
            iconBg: const Color(0xFFEDE9FE),
            title: 'Enregistrer une injection',
            subtitle: 'IV, IM, SC — médicament + dose',
            onTap: onInjection,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color    iconColor, iconBg;
  final String   title, subtitle;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.iconColor, required this.iconBg, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 20, color: iconColor)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textLight, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets locaux
// ─────────────────────────────────────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  final VoidCallback onRefresh;
  const _OfflineBanner({required this.onRefresh});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.warning.withValues(alpha: 0.4))),
      child: Row(children: [
        const Icon(Icons.wifi_off_rounded, size: 15, color: AppColors.warning),
        const SizedBox(width: 8),
        const Expanded(child: Text('Mode hors-ligne · données locales', style: TextStyle(fontSize: 12, color: AppColors.warning))),
        GestureDetector(onTap: onRefresh, child: const Icon(Icons.refresh, size: 16, color: AppColors.warning)),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filtre, search;
  const _EmptyState({required this.filtre, required this.search});
  @override
  Widget build(BuildContext context) {
    final msg = search.isNotEmpty
        ? 'Aucun patient trouvé pour "$search".'
        : filtre == 'À faire' ? 'Tous les patients ont leurs constantes.' : 'Aucun patient admis aujourd\'hui.';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Icon(filtre == 'À faire' ? Icons.check_circle_outline : Icons.people_outline, size: 40, color: AppColors.textLight),
        const SizedBox(height: 12),
        Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMedium, fontSize: 14)),
      ]),
    );
  }
}

class _PassageRow extends StatelessWidget {
  final PassageInfirmierApi passage;
  final VoidCallback        onTap;
  const _PassageRow({required this.passage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          InitialsAvatar(
            initials: passage.initials, size: 42,
            background: passage.isUrgence ? AppColors.errorLight : AppColors.primaryLight,
            foreground: passage.isUrgence ? AppColors.error : AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(passage.nomComplet, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  ),
                  if (passage.isUrgence)
                    StatusChip(label: 'Urgence', foreground: AppColors.error, background: AppColors.errorLight),
                  if (passage.constantesFaites && !passage.isUrgence)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.check_circle, size: 18, color: AppColors.success),
                    ),
                ]),
                const SizedBox(height: 3),
                Text('${passage.motifVisite} · admis ${passage.heure}', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Mini-indicateurs d'actions disponibles
          Column(
            children: [
              _MiniIndicator(icon: Icons.monitor_heart_outlined, done: passage.constantesFaites),
            ],
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.textLight),
        ],
      ),
    );
  }
}

class _MiniIndicator extends StatelessWidget {
  final IconData icon;
  final bool done;
  const _MiniIndicator({required this.icon, required this.done});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26, height: 26,
      decoration: BoxDecoration(
        color: done ? AppColors.successLight : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 14, color: done ? AppColors.success : AppColors.textLight),
    );
  }
}

class _InfStatCard extends StatelessWidget {
  final String value, label;
  final Color  valueColor, background;
  const _InfStatCard({required this.value, required this.label, required this.valueColor, required this.background});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: valueColor)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: valueColor, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
