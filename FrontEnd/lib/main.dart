import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/theme.dart';
import 'features/auth/presentation/screens/app_entry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(const CarnetSanteApp());
}

class CarnetSanteApp extends StatelessWidget {
  const CarnetSanteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carnet Santé',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppEntry(),
    );
  }
}
