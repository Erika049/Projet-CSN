import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../patient/presentation/widgets/patient_widgets.dart';
import '../../../../features/auth/data/auth_local_service.dart';
import '../../data/agent_accueil_api_service.dart';

class MonActiviteScreen extends StatefulWidget {
  const MonActiviteScreen({super.key});

  @override
  State<MonActiviteScreen> createState() => _MonActiviteScreenState();
}

class _MonActiviteScreenState extends State<MonActiviteScreen> {
  final _api   = AgentAccueilApiService();
  final _local = AuthLocalService();

  static const _filtres = <String, int>{
    "Aujourd'hui": 1,
    '7 jours':     7,
    '30 jours':    30,
    '2 mois':      60,
    '3 mois':      90,
  };

  String            _filtre    = "Aujourd'hui";
  String            _recherche = '';
  String            _userName  = '';
  String            _initiales = '';
  ActiviteAgentApi? _data;
  bool              _loading   = true;
  String?           _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final name = await _local.getUserName();
    if (mounted && name != null) {
      final parts = name.split(' ');
      setState(() {
        _userName  = name;
        _initiales = parts.map((w) => w.isNotEmpty ? w[0] : '').take(2).join();
      });
    }
    await _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final id = await _local.getUserId();
      if (id == null) throw Exception('Session expirée');
      final data = await _api.getActivite(id, jours: _filtres[_filtre]!);
      if (mounted) setState(() { _data = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() {
        _loading = false;
        _error   = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<ActiviteItemApi> get _filtered {
    final all = _data?.passages ?? [];
    if (_recherche.isEmpty) return all;
    final q = _recherche.toLowerCase();
    return all.where((p) =>
        p.nomComplet.toLowerCase().contains(q) ||
        p.motifVisite.toLowerCase().contains(q)).toList();
  }

  // Regroupe les items par date
  Map<String, List<ActiviteItemApi>> get _grouped {
    final result = <String, List<ActiviteItemApi>>{};
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 14),
              _buildFilterBar(),
              const SizedBox(height: 16),
              _buildStats(),
              const SizedBox(height: 20),
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mon activité', style: AppTextStyles.bodyMedium),
              Text(_userName.isNotEmpty ? _userName : '—', style: AppTextStyles.h1),
              const SizedBox(height: 2),
              const Text(
                "Agent d'accueil · Accueil · Hôp. Général",
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
            ],
          ),
        ),
        InitialsAvatar(
          initials: _initiales.isNotEmpty ? _initiales : '?',
          size: 44,
          background: AppColors.primaryLight,
          foreground: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        onChanged: (v) => setState(() => _recherche = v),
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: AppColors.textLight, size: 20),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          filled: false,
          hintText: 'Rechercher un patient par nom…',
          hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filtres.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final label    = _filtres.keys.elementAt(i);
          final selected = label == _filtre;
          return GestureDetector(
            onTap: () { setState(() => _filtre = label); _load(); },
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
                label,
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textMedium,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats() {
    final total     = _data?.totalActions ?? 0;
    final scans     = _data?.scans        ?? 0;
    final creations = _data?.creations    ?? 0;
    final urgences  = _data?.urgences     ?? 0;

    return Row(
      children: [
        Expanded(child: _StatCard(value: total.toString(),     label: 'TOTAL',    valueColor: AppColors.primary, bg: AppColors.primaryLight)),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(value: scans.toString(),     label: 'SCANS',    valueColor: AppColors.success, bg: AppColors.successLight)),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(value: creations.toString(), label: 'CRÉATIONS',valueColor: AppColors.primary, bg: AppColors.primaryLight)),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(value: urgences.toString(),  label: 'URGENCES', valueColor: AppColors.error,   bg: AppColors.errorLight)),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return _EmptyCard(
        icon: Icons.wifi_off_rounded,
        label: _error!,
        color: AppColors.error,
        onRetry: _load,
      );
    }
    final grouped = _grouped;
    if (grouped.isEmpty) {
      return _EmptyCard(
        icon: Icons.history_toggle_off,
        label: _recherche.isNotEmpty
            ? 'Aucun résultat pour "$_recherche"'
            : 'Aucune activité sur cette période.',
        color: AppColors.textLight,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.expand((entry) {
        return [
          _DateHeader(date: entry.key),
          const SizedBox(height: 10),
          ...entry.value.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TimelineRow(item: item),
              )),
          const SizedBox(height: 8),
        ];
      }).toList(),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Stat card compacte (4 colonnes)
// ════════════════════════════════════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color  valueColor;
  final Color  bg;
  const _StatCard({required this.value, required this.label, required this.valueColor, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: valueColor)),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: valueColor, letterSpacing: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// En-tête de date
// ════════════════════════════════════════════════════════════════════════════
class _DateHeader extends StatelessWidget {
  final String date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    return Text(
      date.toUpperCase(),
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textLight, letterSpacing: 0.6),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Ligne timeline
// ════════════════════════════════════════════════════════════════════════════
class _TimelineRow extends StatelessWidget {
  final ActiviteItemApi item;
  const _TimelineRow({required this.item});

  @override
  Widget build(BuildContext context) {
    // Visuel selon le type
    final IconData iconData;
    final Color    iconColor, iconBg, badgeColor, badgeBg;
    final String   badgeLabel, titre;

    // Triple vérification : type API, bool urgence, ou motif contient "urgence"
    final isUrgence = item.type == 'URGENCE'
        || item.urgence
        || item.motifVisite.toLowerCase().contains('urgence');
    final effectiveType = isUrgence ? 'URGENCE' : item.type;

    switch (effectiveType) {
      case 'URGENCE':
        iconData   = Icons.flash_on_rounded;
        iconColor  = AppColors.error;
        iconBg     = AppColors.errorLight;
        badgeColor = AppColors.error;
        badgeBg    = AppColors.errorLight;
        badgeLabel = 'Urgence';
        titre      = 'Admission urgence';
        break;
      case 'NOUVEAU_PATIENT':
        iconData   = Icons.person_add_alt_1_rounded;
        iconColor  = AppColors.primary;
        iconBg     = AppColors.primaryLight;
        badgeColor = AppColors.primary;
        badgeBg    = AppColors.primaryLight;
        badgeLabel = 'Création';
        titre      = 'Nouveau patient';
        break;
      default: // SCAN
        iconData   = Icons.qr_code_scanner_rounded;
        iconColor  = AppColors.success;
        iconBg     = AppColors.successLight;
        badgeColor = AppColors.success;
        badgeBg    = AppColors.successLight;
        badgeLabel = 'Scan';
        titre      = 'Scan QR validé';
    }

    return Container(
      decoration: BoxDecoration(
        color: isUrgence
            ? AppColors.error.withValues(alpha: 0.05)
            : AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUrgence ? AppColors.error : AppColors.border,
          width: isUrgence ? 1.5 : 1.0,
        ),
      ),
      // Barre d'accent rouge gauche pour les urgences
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isUrgence)
                Container(width: 4, color: AppColors.error),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icône type
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                        child: Icon(iconData, size: 18, color: iconColor),
                      ),
                      const SizedBox(width: 12),

                      // Infos
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Titre + badge type
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    titre,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isUrgence ? AppColors.error : AppColors.textDark,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                                  child: Text(badgeLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(item.nomComplet, style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
                            if (item.motifVisite.isNotEmpty)
                              Text(
                                item.motifVisite,
                                style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 8),
                            // Statut + heure en bas à droite
                            Row(
                              children: [
                                _StatutBadge(statut: item.statut),
                                const Spacer(),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.access_time_rounded, size: 11,
                                        color: isUrgence ? AppColors.error.withValues(alpha: 0.6) : AppColors.textLight),
                                    const SizedBox(width: 3),
                                    Text(
                                      item.heure,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isUrgence ? AppColors.error.withValues(alpha: 0.7) : AppColors.textLight,
                                      ),
                                    ),
                                  ],
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
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Badge statut du passage
// ════════════════════════════════════════════════════════════════════════════
class _StatutBadge extends StatelessWidget {
  final String statut;
  const _StatutBadge({required this.statut});

  @override
  Widget build(BuildContext context) {
    final Color fg, bg;
    final String label;
    final IconData icon;

    switch (statut) {
      case 'en_cours':
        fg    = AppColors.warning;
        bg    = AppColors.warningLight;
        label = 'En cours';
        icon  = Icons.timelapse_rounded;
        break;
      case 'termine':
        fg    = AppColors.success;
        bg    = AppColors.successLight;
        label = 'Terminé';
        icon  = Icons.check_circle_outline_rounded;
        break;
      case 'inscrit':
        fg    = AppColors.primary;
        bg    = AppColors.primaryLight;
        label = 'Inscrit';
        icon  = Icons.person_outline_rounded;
        break;
      default:
        fg    = AppColors.textLight;
        bg    = AppColors.surfaceLight;
        label = statut;
        icon  = Icons.info_outline_rounded;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: fg),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// État vide / erreur
// ════════════════════════════════════════════════════════════════════════════
class _EmptyCard extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback? onRetry;
  const _EmptyCard({required this.icon, required this.label, required this.color, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMedium, fontSize: 14)),
          if (onRetry != null) ...[
            const SizedBox(height: 14),
            TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh, size: 16), label: const Text('Réessayer')),
          ],
        ],
      ),
    );
  }
}
