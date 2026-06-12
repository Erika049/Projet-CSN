import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/admin_api_service.dart';
import '../../data/admin_models.dart';

class AdminHopitauxScreen extends StatefulWidget {
  const AdminHopitauxScreen({super.key});

  @override
  State<AdminHopitauxScreen> createState() =>
      _AdminHopitauxScreenState();
}

class _AdminHopitauxScreenState
    extends State<AdminHopitauxScreen> {
  final _service = AdminApiService();
  List<HopitalAdmin> _hopitaux = [];
  bool    _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final h = await _service.getHopitaux();
      if (!mounted) { return; }
      setState(() { _hopitaux = h; _loading = false; });
    } catch (e) {
      if (!mounted) { return; }
      setState(() {
        _loading = false;
        _error   =
        'Impossible de charger les hôpitaux.';
      });
    }
  }

  void _showAjouterHopitalSheet() {
    final nomCtrl     = TextEditingController();
    final adresseCtrl = TextEditingController();
    final codeCtrl    = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24,
            MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius:
                  BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Ajouter un hôpital',
                style: AppTextStyles.h4),
            const SizedBox(height: 16),
            TextField(
              controller: nomCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'hôpital',
                hintText:
                'ex: Hôpital Central de Yaoundé',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: adresseCtrl,
              decoration: const InputDecoration(
                labelText: 'Adresse',
                hintText:
                'ex: Avenue Monseigneur Vogt, Yaoundé',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeCtrl,
              decoration: const InputDecoration(
                labelText: 'Code unique',
                hintText: 'ex: HCY-CMR-002',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  if (nomCtrl.text.isEmpty ||
                      adresseCtrl.text.isEmpty ||
                      codeCtrl.text.isEmpty) {
                    return;
                  }
                  try {
                    await _service.creerHopital(
                      nom:        nomCtrl.text,
                      adresse:    adresseCtrl.text,
                      codeUnique: codeCtrl.text,
                    );
                    if (!ctx.mounted) { return; }
                    Navigator.pop(ctx);
                    _load();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Hôpital ajouté avec succès'),
                        backgroundColor:
                        AppColors.success,
                      ),
                    );
                  } catch (e) {
                    if (!ctx.mounted) { return; }
                    ScaffoldMessenger.of(ctx)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                            'Erreur : ${e.toString()}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                child: const Text('Ajouter'),
              ),
            ),
          ],
        ),
      ),
    );
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
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  20, 20, 20, 16),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hôpitaux',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '${_hopitaux.length} établissements',
                        style: const TextStyle(
                            fontSize: 13,
                            color:
                            AppColors.textMedium),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed:
                    _showAjouterHopitalSheet,
                    icon: const Icon(Icons.add,
                        size: 16),
                    label: const Text('Ajouter'),
                    style: ElevatedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                  child:
                  CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2))
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
                        color: AppColors
                            .textLight),
                    const SizedBox(
                        height: 8),
                    Text(_error!),
                    const SizedBox(
                        height: 16),
                    ElevatedButton(
                        onPressed: _load,
                        child: const Text(
                            'Réessayer')),
                  ],
                ),
              )
                  : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _load,
                child: ListView.separated(
                  padding:
                  const EdgeInsets
                      .fromLTRB(
                      20, 0, 20, 24),
                  itemCount:
                  _hopitaux.length,
                  separatorBuilder:
                      (_, __) =>
                  const SizedBox(
                      height: 10),
                  itemBuilder: (_, i) {
                    final h = _hopitaux[i];
                    return Container(
                      padding:
                      const EdgeInsets
                          .all(16),
                      decoration:
                      BoxDecoration(
                        color: AppColors
                            .backgroundWhite,
                        borderRadius:
                        BorderRadius
                            .circular(
                            14),
                        border: Border.all(
                            color: AppColors
                                .border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration:
                            BoxDecoration(
                              color: const Color(
                                  0xFFEDE9FE),
                              borderRadius:
                              BorderRadius
                                  .circular(
                                  12),
                            ),
                            child:
                            const Icon(
                              Icons
                                  .local_hospital_outlined,
                              color: Color(
                                  0xFF7C3AED),
                              size: 22,
                            ),
                          ),
                          const SizedBox(
                              width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  h.nom,
                                  style: const TextStyle(
                                      fontSize:
                                      14,
                                      fontWeight:
                                      FontWeight
                                          .w700,
                                      color:
                                      AppColors
                                          .textDark),
                                ),
                                const SizedBox(
                                    height:
                                    2),
                                Text(
                                  h.adresse,
                                  style: const TextStyle(
                                      fontSize:
                                      12,
                                      color:
                                      AppColors
                                          .textMedium),
                                  maxLines:
                                  1,
                                  overflow:
                                  TextOverflow
                                      .ellipsis,
                                ),
                                const SizedBox(
                                    height:
                                    4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets
                                          .symmetric(
                                          horizontal:
                                          6,
                                          vertical:
                                          2),
                                      decoration:
                                      BoxDecoration(
                                        color: AppColors
                                            .primaryLight,
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            999),
                                      ),
                                      child:
                                      Text(
                                        h.codeUnique,
                                        style: const TextStyle(
                                            fontSize:
                                            10,
                                            fontWeight:
                                            FontWeight
                                                .w600,
                                            color:
                                            AppColors
                                                .primary,
                                            fontFamily:
                                            'monospace'),
                                      ),
                                    ),
                                    const SizedBox(
                                        width:
                                        8),
                                    Text(
                                      '${h.nbPersonnel} personnels',
                                      style: const TextStyle(
                                          fontSize:
                                          11,
                                          color:
                                          AppColors
                                              .textMedium),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
}