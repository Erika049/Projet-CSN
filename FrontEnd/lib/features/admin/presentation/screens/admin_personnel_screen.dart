import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/admin_api_service.dart';
import '../../data/admin_models.dart';

class AdminPersonnelScreen extends StatefulWidget {
  const AdminPersonnelScreen({super.key});

  @override
  State<AdminPersonnelScreen> createState() =>
      _AdminPersonnelScreenState();
}

class _AdminPersonnelScreenState
    extends State<AdminPersonnelScreen> {
  final _service    = AdminApiService();
  final _searchCtrl = TextEditingController();

  List<PersonnelAdmin> _tous     = [];
  List<PersonnelAdmin> _filtered = [];
  bool    _loading     = true;
  String? _error;
  String  _searchQuery = '';
  String  _roleFilter  = 'Tous';

  final List<String> _roles = [
    'Tous',
    'medecin',
    'infirmier',
    'accueil',
    'laborantin',
    'pharmacien',
    'admin',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error   = null;
    });
    try {
      final p = await _service.getPersonnel();
      if (!mounted) return;
      setState(() {
        _tous    = p;
        _loading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error   = 'Impossible de charger.';
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filtered = _tous.where((p) {
        final matchRole =
            _roleFilter == 'Tous' ||
                p.role == _roleFilter;
        final matchSearch =
            _searchQuery.isEmpty ||
                p.nomComplet
                    .toLowerCase()
                    .contains(
                    _searchQuery.toLowerCase()) ||
                p.identifiantPro
                    .toLowerCase()
                    .contains(
                    _searchQuery.toLowerCase());
        return matchRole && matchSearch;
      }).toList();
    });
  }

  int _countRole(String role) =>
      _tous.where((p) => p.role == role).length;

  Future<void> _toggleActif(
      PersonnelAdmin p) async {
    try {
      await _service.toggleActif(p.idPersonnel);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text('Erreur : ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showCreerSheet() {
    final nomCtrl    = TextEditingController();
    final prenomCtrl = TextEditingController();
    final idCtrl     = TextEditingController();
    final mdpCtrl    = TextEditingController();

    String           roleSelect    = 'medecin';
    HopitalAdmin?    hopitalSelect;
    List<HopitalAdmin> hopitaux    = [];
    bool             loadingHop   = true;

    final roles = [
      'medecin',
      'infirmier',
      'accueil',
      'laborantin',
      'pharmacien',
      'admin',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            if (loadingHop) {
              loadingHop = false;
              _service.getHopitaux().then((h) {
                setModal(() {
                  hopitaux      = h;
                  hopitalSelect =
                  h.isNotEmpty ? h.first : null;
                });
              }).catchError((_) {
                setModal(() => hopitaux = []);
              });
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                20,
                24,
                MediaQuery.of(ctx).viewInsets.bottom +
                    24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                // Poignée
                Center(
                child: Container(
                width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius:
                    BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Créer un compte',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),

              // Nom / Prénom
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nomCtrl,
                      textCapitalization:
                      TextCapitalization
                          .characters,
                      decoration:
                      const InputDecoration(
                        labelText: 'Nom',
                        hintText: 'MBALLA',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: prenomCtrl,
                      decoration:
                      const InputDecoration(
                        labelText: 'Prénom',
                        hintText: 'Jean',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Rôle
              const Text(
                'Rôle',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: roles.map((r) {
                  final active =
                      r == roleSelect;
                  return GestureDetector(
                    onTap: () => setModal(
                            () => roleSelect = r),
                    child: Container(
                      padding: const EdgeInsets
                          .symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary
                            : AppColors
                            .primaryLight,
                        borderRadius:
                        BorderRadius
                            .circular(999),
                      ),
                      child: Text(
                        r,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                          FontWeight.w600,
                          color: active
                              ? Colors.white
                              : AppColors
                              .primary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Hôpital
              const Text(
                'Hôpital',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 8),

              hopitaux.isEmpty
                  ? Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(
                      0xFFF8F9FA),
                  borderRadius:
                  BorderRadius
                      .circular(10),
                  border: Border.all(
                      color:
                      AppColors.border),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                      AppColors.primary,
                    ),
                  ),
                ),
              )
                  : Container(
                padding: const EdgeInsets
                    .symmetric(
                    horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(
                      0xFFF8F9FA),
                  borderRadius:
                  BorderRadius
                      .circular(10),
                  border: Border.all(
                      color:
                      AppColors.border),
                ),
                child:
                DropdownButtonHideUnderline(
                  child: DropdownButton<HopitalAdmin>(
                    value: hopitalSelect,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textMedium,
                    ),
                    items: hopitaux.map((h) {
                      return DropdownMenuItem<HopitalAdmin>(
                        value: h,
                        child: Text(
                          h.nom,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (HopitalAdmin? h) {
                      setModal(() => hopitalSelect = h);
                    },
                  ),
                ),
            ),
            const SizedBox(height: 12),

            // Identifiant
            TextField(
            controller: idCtrl,
            decoration:
            const InputDecoration(
            labelText: 'Identifiant pro',
            hintText: 'dr_mballa',
            ),
            ),
            const SizedBox(height: 12),

            // Mot de passe
            TextField(
            controller: mdpCtrl,
            obscureText: true,
            decoration:
            const InputDecoration(
            labelText: 'Mot de passe',
            hintText: 'Min. 8 caractères',
            ),
            ),
            const SizedBox(height: 20),

            // Bouton créer
            SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
            onPressed: () async {
            if (nomCtrl.text.isEmpty ||
            prenomCtrl
                .text.isEmpty ||
            idCtrl.text.isEmpty ||
            mdpCtrl.text.isEmpty ||
            hopitalSelect == null) {
            ScaffoldMessenger.of(ctx)
                .showSnackBar(
            const SnackBar(
            content: Text(
            'Remplissez tous'
            ' les champs',
            ),
            backgroundColor:
            AppColors.error,
            ),
            );
            return;
            }
            try {
            await _service
                .creerPersonnel(
            nom: nomCtrl.text
                .trim(),
            prenom: prenomCtrl.text
                .trim(),
            role:   roleSelect,
            identifiantPro:
            idCtrl.text.trim(),
            motDePasse:
            mdpCtrl.text,
            idHopital: int.parse(
            hopitalSelect!
                .idHopital,
            ),
            );
            if (!ctx.mounted) return;
            Navigator.pop(ctx);
            _load();
            if (!context.mounted) {
            return;
            }
            ScaffoldMessenger.of(
            context)
                .showSnackBar(
            const SnackBar(
            content: Text(
            'Compte créé ✓'),
            backgroundColor:
            AppColors.success,
            ),
            );
            } catch (e) {
            if (!ctx.mounted) return;
            ScaffoldMessenger.of(ctx)
                .showSnackBar(
            SnackBar(
            content: Text(
            'Erreur : '
            '${e.toString()}',
            ),
            backgroundColor:
            AppColors.error,
            ),
            );
            }
            },
            child: const Text('Créer'),
            ),
            ),
            ],
            ),
            ),
            );
          },
        );
      },
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'medecin':
        return const Color(0xFF1565C0);
      case 'infirmier':
        return const Color(0xFF2E7D32);
      case 'accueil':
        return const Color(0xFF0277BD);
      case 'laborantin':
        return const Color(0xFFE65100);
      case 'pharmacien':
        return const Color(0xFFAD1457);
      case 'admin':
        return const Color(0xFF6A1B9A);
      default:
        return AppColors.textMedium;
    }
  }

  Color _roleBg(String role) {
    switch (role) {
      case 'medecin':
        return const Color(0xFFE3F2FD);
      case 'infirmier':
        return const Color(0xFFE8F5E9);
      case 'accueil':
        return const Color(0xFFE1F5FE);
      case 'laborantin':
        return const Color(0xFFFFF3E0);
      case 'pharmacien':
        return const Color(0xFFFCE4EC);
      case 'admin':
        return const Color(0xFFF3E5F5);
      default:
        return const Color(0xFFF1F3F4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personnel médical',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                            FontWeight.w700,
                            color: AppColors.textDark,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          '${_tous.length} comptes',
                          style: const TextStyle(
                            fontSize: 13,
                            color:
                            AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showCreerSheet,
                    icon: const Icon(
                        Icons.add, size: 16),
                    label: const Text('Nouveau'),
                    style: ElevatedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Barre recherche
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius:
                  BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                          left: 12),
                      child: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) {
                          _searchQuery = v;
                          _applyFilters();
                        },
                        decoration: InputDecoration(
                          hintText:
                          'Rechercher · '
                              '${_tous.length}'
                              ' comptes',
                          hintStyle: const TextStyle(
                            color:
                            AppColors.textLight,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                          right: 12),
                      child: Text(
                        'Tous',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Filtres rôles
            SizedBox(
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20),
                itemCount: _roles.length,
                itemBuilder: (_, i) {
                  final role   = _roles[i];
                  final active = role == _roleFilter;
                  final count  = role == 'Tous'
                      ? _tous.length
                      : _countRole(role);
                  return GestureDetector(
                    onTap: () {
                      setState(
                              () => _roleFilter = role);
                      _applyFilters();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          right: 8),
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.textDark
                            : AppColors.backgroundWhite,
                        borderRadius:
                        BorderRadius.circular(999),
                        border: Border.all(
                          color: active
                              ? AppColors.textDark
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        role == 'Tous'
                            ? 'Tous'
                            : '${_capitalize(role)}'
                            ' $count',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: active
                              ? Colors.white
                              : AppColors.textMedium,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Liste
            Expanded(
              child: _loading
                  ? const Center(
                child:
                CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              )
                  : _error != null
                  ? Center(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,
                  children: [
                    const Icon(
                      Icons
                          .cloud_off_rounded,
                      size: 40,
                      color:
                      AppColors.textLight,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors
                            .textMedium,
                      ),
                    ),
                    const SizedBox(
                        height: 16),
                    ElevatedButton(
                      onPressed: _load,
                      child: const Text(
                          'Réessayer'),
                    ),
                  ],
                ),
              )
                  : _filtered.isEmpty
                  ? const Center(
                child: Text(
                  'Aucun résultat',
                  style: TextStyle(
                    color: AppColors
                        .textMedium,
                  ),
                ),
              )
                  : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _load,
                child: ListView.separated(
                  padding:
                  const EdgeInsets
                      .fromLTRB(
                    20, 4, 20, 24,
                  ),
                  itemCount:
                  _filtered.length,
                  separatorBuilder:
                      (_, __) =>
                  const SizedBox(
                      height: 8),
                  itemBuilder: (_, i) {
                    final p =
                    _filtered[i];
                    return _PersonnelCard(
                      personnel: p,
                      roleColor:
                      _roleColor(
                          p.role),
                      roleBg:
                      _roleBg(p.role),
                      onToggle: () =>
                          _toggleActif(p),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) => s.isEmpty
      ? s
      : s[0].toUpperCase() + s.substring(1);
}

// ── Widgets locaux ─────────────────────────────────────

class _PersonnelCard extends StatelessWidget {
  final PersonnelAdmin personnel;
  final Color          roleColor;
  final Color          roleBg;
  final VoidCallback   onToggle;

  const _PersonnelCard({
    required this.personnel,
    required this.roleColor,
    required this.roleBg,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: personnel.estActif
              ? AppColors.border
              : AppColors.error
              .withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: roleBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                personnel.initiales,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: roleColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  '${personnel.nom}'
                      ' ${personnel.prenom}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${personnel.identifiantPro}'
                      ' · ${personnel.hopital}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMedium,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: roleBg,
                  borderRadius:
                  BorderRadius.circular(999),
                ),
                child: Text(
                  personnel.role,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: roleColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: personnel.estActif
                        ? AppColors.successLight
                        : AppColors.errorLight,
                    borderRadius:
                    BorderRadius.circular(999),
                  ),
                  child: Text(
                    personnel.estActif
                        ? '● Actif'
                        : '● Inactif',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: personnel.estActif
                          ? AppColors.success
                          : AppColors.error,
                    ),
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