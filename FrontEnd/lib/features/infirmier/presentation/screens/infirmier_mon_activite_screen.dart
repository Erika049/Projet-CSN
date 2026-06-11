import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../features/auth/data/auth_local_service.dart';
import '../../data/infirmier_api_service.dart';

class InfirmierMonActiviteScreen extends StatefulWidget {
  const InfirmierMonActiviteScreen({super.key});

  @override
  State<InfirmierMonActiviteScreen> createState() => _InfirmierMonActiviteScreenState();
}

class _InfirmierMonActiviteScreenState extends State<InfirmierMonActiviteScreen> {
  final _api   = InfirmierApiService();
  final _local = AuthLocalService();

  static const _filtres     = ["Aujourd'hui", '7 jours', '30 jours', '2 mois', '3 mois'];
  static const _filtresJours = [1, 7, 30, 60, 90];

  String               _filtreActif = "Aujourd'hui";
  ActiviteInfirmierApi? _data;
  bool                 _loading     = true;
  bool                 _isOffline   = false;
  String?              _errorMsg;
  String               _userName    = '';
  String               _search      = '';

  @override
  void initState() {
    super.initState();
    _local.getUserName().then((n) {
      if (mounted && n != null) setState(() => _userName = n);
    });
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _isOffline = false; _errorMsg = null; });
    try {
      final id = await _local.getUserId();
      if (id == null) throw Exception('Session expirée');
      final jours = _filtresJours[_filtres.indexOf(_filtreActif)];
      final data  = await _api.getActivite(id, jours: jours);
      if (mounted) setState(() { _data = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() {
        _loading   = false;
        _isOffline = true;
        _errorMsg  = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<ActiviteInfirmierItemApi> get _filtered {
    final items = _data?.items ?? [];
    if (_search.isEmpty) return items;
    final q = _search.toLowerCase();
    return items.where((i) =>
        i.nomPatient.toLowerCase().contains(q) ||
        i.prenomPatient.toLowerCase().contains(q)).toList();
  }

  // Groupe les items par date pour les sections
  Map<String, List<ActiviteInfirmierItemApi>> get _grouped {
    final result = <String, List<ActiviteInfirmierItemApi>>{};
    for (final item in _filtered) {
      result.putIfAbsent(item.date, () => []).add(item);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppColors.roleInfirmier,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              if (_isOffline)
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _OfflineBanner(onRefresh: _load, message: _errorMsg),
                )),
              SliverToBoxAdapter(child: _buildSearch()),
              SliverToBoxAdapter(child: _buildFilterBar()),
              if (_loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.roleInfirmier, strokeWidth: 2)),
                )
              else ...[
                SliverToBoxAdapter(child: _buildStats()),
                if (_filtered.isEmpty)
                  SliverToBoxAdapter(child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: _EmptyState(offline: _isOffline),
                  ))
                else
                  SliverList(delegate: SliverChildBuilderDelegate(
                    (ctx, idx) => _buildActivityList(idx),
                    childCount: _buildListCount(),
                  )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final initials = _userName.isNotEmpty
        ? _userName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join()
        : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mon activité', style: AppTextStyles.bodyMedium),
                Text(
                  _userName.isNotEmpty ? 'Inf. $_userName' : '—',
                  style: AppTextStyles.h1,
                ),
              ],
            ),
          ),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(initials, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.roleInfirmier)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _search = v),
          decoration: const InputDecoration(
            icon: Icon(Icons.search, color: AppColors.textLight, size: 20),
            border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none,
            filled: false,
            hintText: 'Rechercher un patient par nom…',
            hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _filtres.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final selected = _filtres[i] == _filtreActif;
            return GestureDetector(
              onTap: () {
                setState(() { _filtreActif = _filtres[i]; _search = ''; });
                _load();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.textDark : AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? AppColors.textDark : AppColors.border),
                ),
                child: Text(
                  _filtres[i],
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textMedium),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStats() {
    final d = _data;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          Expanded(child: _StatCard(value: '${d?.totalActions ?? 0}', label: 'MES\nACTIONS',  valueColor: AppColors.primary,       background: AppColors.primaryLight)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(value: '${d?.constantes  ?? 0}', label: 'CONSTANTES',    valueColor: AppColors.roleInfirmier, background: const Color(0xFFFFF7ED))),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(value: '${d?.soins       ?? 0}', label: 'SOIN',          valueColor: AppColors.success,       background: AppColors.successLight)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(value: '${d?.injections  ?? 0}', label: 'INJECTION',     valueColor: const Color(0xFF7C3AED), background: const Color(0xFFEDE9FE))),
        ],
      ),
    );
  }

  // ── Construction de la liste groupée par date ──────────────────────────────

  // Compte total d'éléments à afficher (entêtes de sections + lignes)
  int _buildListCount() {
    int count = 0;
    for (final entry in _grouped.entries) {
      count++; // header
      count += entry.value.length;
    }
    count++; // bottom padding
    return count;
  }

  Widget _buildActivityList(int idx) {
    final entries = _grouped.entries.toList();

    int cursor = 0;
    for (final entry in entries) {
      if (idx == cursor) {
        return _SectionHeader(date: entry.key);
      }
      cursor++;
      for (final item in entry.value) {
        if (idx == cursor) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: _ActiviteRow(item: item),
          );
        }
        cursor++;
      }
    }
    // Bottom padding
    return const SizedBox(height: 32);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  final VoidCallback onRefresh;
  final String?      message;
  const _OfflineBanner({required this.onRefresh, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 15, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(child: Text(
            message != null && message!.isNotEmpty ? message! : 'Données indisponibles',
            style: const TextStyle(fontSize: 12, color: AppColors.warning),
          )),
          GestureDetector(onTap: onRefresh, child: const Icon(Icons.refresh, size: 16, color: AppColors.warning)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color  valueColor, background;
  const _StatCard({required this.value, required this.label, required this.valueColor, required this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: valueColor)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: valueColor, letterSpacing: 0.3, height: 1.3)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String date;
  const _SectionHeader({required this.date});

  String get _label {
    final now = DateTime.now();
    final today = '${now.day.toString().padLeft(2, '0')}/${(now.month).toString().padLeft(2, '0')}/${now.year}';
    if (date == today) return "AUJOURD'HUI · $date";
    return date;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Text(
        _label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 0.6),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool offline;
  const _EmptyState({this.offline = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.history_toggle_off, size: 40, color: AppColors.textLight),
          const SizedBox(height: 12),
          Text(
            offline ? 'Hors ligne · aucune donnée disponible.' : 'Aucune activité enregistrée pour cette période.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMedium, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Ligne d'activité (correspond exactement à la maquette page_32) ─────────

class _ActiviteRow extends StatelessWidget {
  final ActiviteInfirmierItemApi item;
  const _ActiviteRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final config = _actionConfig(item.type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heure
          SizedBox(
            width: 38,
            child: Text(
              item.heure,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textLight),
            ),
          ),
          const SizedBox(width: 8),
          // Icône
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: config.iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(config.icon, size: 17, color: config.iconColor),
          ),
          const SizedBox(width: 10),
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.actionLabel,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ActionTag(label: config.tagLabel, color: config.tagColor, bg: config.tagBg),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.nomComplet,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMedium),
                ),
                if (item.resume.isNotEmpty && item.resume != '—') ...[
                  const SizedBox(height: 2),
                  Text(
                    item.resume,
                    style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _ActionConfig _actionConfig(String type) {
    switch (type) {
      case 'CONSTANTES_URGENCE':
        return _ActionConfig(
          icon: Icons.monitor_heart_outlined,
          iconColor: AppColors.error,
          iconBg: AppColors.errorLight,
          tagLabel: 'Constantes',
          tagColor: AppColors.error,
          tagBg: AppColors.errorLight,
        );
      case 'SOIN':
        return _ActionConfig(
          icon: Icons.medical_services_outlined,
          iconColor: AppColors.success,
          iconBg: AppColors.successLight,
          tagLabel: 'Soin',
          tagColor: AppColors.success,
          tagBg: AppColors.successLight,
        );
      case 'INJECTION':
        return _ActionConfig(
          icon: Icons.vaccines_outlined,
          iconColor: const Color(0xFF7C3AED),
          iconBg: const Color(0xFFEDE9FE),
          tagLabel: 'Injection',
          tagColor: const Color(0xFF7C3AED),
          tagBg: const Color(0xFFEDE9FE),
        );
      default: // CONSTANTES
        return _ActionConfig(
          icon: Icons.monitor_heart_outlined,
          iconColor: AppColors.roleInfirmier,
          iconBg: const Color(0xFFFFF7ED),
          tagLabel: 'Constantes',
          tagColor: AppColors.roleInfirmier,
          tagBg: const Color(0xFFFFF7ED),
        );
    }
  }
}

class _ActionConfig {
  final IconData icon;
  final Color    iconColor, iconBg;
  final String   tagLabel;
  final Color    tagColor, tagBg;
  const _ActionConfig({
    required this.icon, required this.iconColor, required this.iconBg,
    required this.tagLabel, required this.tagColor, required this.tagBg,
  });
}

class _ActionTag extends StatelessWidget {
  final String label;
  final Color  color, bg;
  const _ActionTag({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
