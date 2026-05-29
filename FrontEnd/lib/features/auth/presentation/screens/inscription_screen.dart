import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _identifiantController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _dateNaissance;
  String _genre = 'Masculin';
  String _groupeSanguin = 'A+';
  bool _obscurePassword = true;

  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _adresseController = TextEditingController();
  final _urgenceNomController = TextEditingController();
  final _urgenceTelController = TextEditingController();

  bool _biometrieActivee = true;
  bool _accepteCGU = false;

  final List<String> _genres = ['Masculin', 'Féminin'];
  final List<String> _groupesSanguins = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _identifiantController.dispose();
    _passwordController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _adresseController.dispose();
    _urgenceNomController.dispose();
    _urgenceTelController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choisir une photo',
                    style: AppTextStyles.h4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 24),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text('Prendre une photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final img = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 512,
                    maxHeight: 512,
                    imageQuality: 85,
                  );
                  if (img != null) {
                    setState(() => _profileImage = File(img.path));
                  }
                },
              ),
              ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 24),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                title: const Text('Choisir depuis la galerie'),
                onTap: () async {
                  Navigator.pop(context);
                  final img = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 512,
                    maxHeight: 512,
                    imageQuality: 85,
                  );
                  if (img != null) {
                    setState(() => _profileImage = File(img.path));
                  }
                },
              ),
              if (_profileImage != null)
                ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                  ),
                  title: const Text('Supprimer la photo'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _profileImage = null);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initial = _dateNaissance ?? DateTime(1990, 1, 1);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        DateTime tempDate = initial;
        return StatefulBuilder(
          builder: (context, setModalState) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Date de naissance',
                        style: AppTextStyles.h4,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _dateNaissance = tempDate);
                          Navigator.pop(context);
                        },
                        child: const Text('Confirmer'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 320,
                  child: CalendarDatePicker(
                    initialDate: initial,
                    firstDate: DateTime(1900),
                    lastDate: now,
                    onDateChanged: (d) =>
                        setModalState(() => tempDate = d),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showModernPicker({
    required String title,
    required List<String> items,
    required String selected,
    required void Function(String) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(title, style: AppTextStyles.h4),
              ),
            ),
            const SizedBox(height: 8),
            ...items.map(
                  (item) => ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 24),
                title: Text(item, style: AppTextStyles.bodyLarge),
                trailing: item == selected
                    ? const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                )
                    : null,
                onTap: () {
                  onSelect(item);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    bool valid = false;
    if (_currentStep == 0) {
      valid = _formKey1.currentState?.validate() ?? false;
      if (_dateNaissance == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Veuillez sélectionner votre date de naissance',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }
    if (_currentStep == 1) {
      valid = _formKey2.currentState?.validate() ?? false;
    }
    if (_currentStep == 2) {
      valid = _formKey3.currentState?.validate() ?? false;
    }

    if (!valid) { return; }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _soumettre() async {
    if (!_accepteCGU) { return; }

    CsnLoaderOverlay.show(context, message: 'Création du compte…');

    try {
      // Simulation appel API inscription
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) { return; }
      CsnLoaderOverlay.hide(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé avec succès ! (Dashboard à venir)'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) { return; }
      CsnLoaderOverlay.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: _currentStep > 0
              ? _previousStep
              : () => Navigator.pop(context),
        ),
        title: const Text('Créer mon carnet'),
      ),
      body: Column(
        children: [
          AppStepper(
            steps: const ['Identité', 'Contact', 'Sécurité'],
            currentStep: _currentStep,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildEtapeIdentite(),
                _buildEtapeContact(),
                _buildEtapeSecurite(),
              ],
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildEtapeIdentite() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceLight,
                        border: Border.all(
                          color: AppColors.border,
                          width: 2,
                        ),
                        image: _profileImage != null
                            ? DecorationImage(
                          image: FileImage(_profileImage!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: _profileImage == null
                          ? const Icon(
                        Icons.person_outline,
                        size: 40,
                        color: AppColors.textLight,
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Photo de profil',
                style: AppTextStyles.labelLarge,
              ),
            ),
            const SizedBox(height: 2),
            const Center(
              child: Text(
                'Sera visible par le personnel médical',
                style: AppTextStyles.bodySmall,
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildValidatedField(
                    label: 'NOM',
                    controller: _nomController,
                    hint: 'TCHAMENI',
                    validator: (v) {
                      if (v!.isEmpty) { return 'Champ requis'; }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildValidatedField(
                    label: 'PRÉNOM',
                    controller: _prenomController,
                    hint: 'Jean',
                    validator: (v) {
                      if (v!.isEmpty) { return 'Champ requis'; }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildLabel('DATE DE NAISSANCE'),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _dateNaissance == null
                        ? AppColors.border
                        : AppColors.primary,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dateNaissance != null
                            ? '${_dateNaissance!.day.toString().padLeft(2, '0')} / ${_dateNaissance!.month.toString().padLeft(2, '0')} / ${_dateNaissance!.year}'
                            : 'JJ / MM / AAAA',
                        style: _dateNaissance != null
                            ? AppTextStyles.bodyLarge
                            : AppTextStyles.bodyMedium,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.textLight,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildModernSelector(
                    label: 'GENRE',
                    value: _genre,
                    onTap: () => _showModernPicker(
                      title: 'Genre',
                      items: _genres,
                      selected: _genre,
                      onSelect: (v) => setState(() => _genre = v),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModernSelector(
                    label: 'GROUPE SANGUIN',
                    value: _groupeSanguin,
                    onTap: () => _showModernPicker(
                      title: 'Groupe sanguin',
                      items: _groupesSanguins,
                      selected: _groupeSanguin,
                      onSelect: (v) =>
                          setState(() => _groupeSanguin = v),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildValidatedField(
              label: 'IDENTIFIANT SOUHAITÉ',
              controller: _identifiantController,
              hint: 'jean.tchameni',
              prefixIcon: Icons.person_outline,
              validator: (v) {
                if (v!.isEmpty) { return 'Champ requis'; }
                if (v.length < 4) { return 'Min. 4 caractères'; }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildLabel('MOT DE PASSE'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) {
                if (v!.isEmpty) { return 'Champ requis'; }
                if (v.length < 12) { return 'Min. 12 caractères'; }
                if (!v.contains(RegExp(r'[A-Z]'))) {
                  return '1 majuscule requise';
                }
                if (!v.contains(RegExp(r'[0-9]'))) {
                  return '1 chiffre requis';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: '••••••••••••',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppColors.textLight,
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                  onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Min. 12 caractères · 1 majuscule · 1 chiffre',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: 'Votre carte numérique ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text:
                            "avec QR code unique chiffré sera générée à la fin de l'inscription.",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEtapeContact() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildValidatedField(
              label: 'TÉLÉPHONE',
              controller: _telephoneController,
              hint: '+237 6XX XX XX XX',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (v) {
                if (v!.isEmpty) { return 'Champ requis'; }
                if (v.length < 9) { return 'Numéro invalide'; }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildValidatedField(
              label: 'EMAIL',
              controller: _emailController,
              hint: 'jean.tchameni@email.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (v) {
                if (v!.isEmpty) { return 'Champ requis'; }
                if (!v.contains('@')) { return 'Email invalide'; }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildValidatedField(
              label: 'ADRESSE',
              controller: _adresseController,
              hint: 'Quartier, Ville',
              prefixIcon: Icons.location_on_outlined,
              validator: (v) {
                if (v!.isEmpty) { return 'Champ requis'; }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              "Contact d'urgence",
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 4),
            const Text(
              "Personne à prévenir en cas d'urgence médicale.",
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildValidatedField(
              label: 'NOM COMPLET',
              controller: _urgenceNomController,
              hint: 'Nom du contact',
              prefixIcon: Icons.person_outline,
              validator: (v) {
                if (v!.isEmpty) { return 'Champ requis'; }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildValidatedField(
              label: 'TÉLÉPHONE URGENCE',
              controller: _urgenceTelController,
              hint: '+237 6XX XX XX XX',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (v) {
                if (v!.isEmpty) { return 'Champ requis'; }
                if (v.length < 9) { return 'Numéro invalide'; }
                return null;
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEtapeSecurite() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Sécurité & Confidentialité',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 4),
            const Text(
              'Configurez la sécurité de votre carnet.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fingerprint,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verrouillage biométrique',
                          style: AppTextStyles.labelLarge,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Empreinte digitale ou Face ID',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _biometrieActivee,
                    onChanged: (v) =>
                        setState(() => _biometrieActivee = v),
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _accepteCGU,
                  onChanged: (v) => setState(() => _accepteCGU = v!),
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMedium,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(text: "J'accepte les "),
                          TextSpan(
                            text: "Conditions Générales d'Utilisation",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                          TextSpan(
                            text:
                            ' et la politique de confidentialité des données médicales.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(
            'Étape ${_currentStep + 1}/3',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep == 2 && !_accepteCGU
                  ? null
                  : () {
                if (_currentStep < 2) {
                  _nextStep();
                } else {
                  _soumettre();
                }
              },
              child: Text(
                _currentStep < 2 ? 'Continuer →' : 'Créer mon carnet',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMedium,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildValidatedField({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(
              prefixIcon,
              color: AppColors.textLight,
              size: 20,
            )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildModernSelector({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(value, style: AppTextStyles.bodyLarge),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textLight,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}