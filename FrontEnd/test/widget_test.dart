import 'package:flutter_test/flutter_test.dart';
import 'package:carnet_sante_numerique/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CarnetSanteApp());
    expect(find.byType(CarnetSanteApp), findsOneWidget);
  });
}