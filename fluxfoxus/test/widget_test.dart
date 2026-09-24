import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluxfoxus/core/navigation/floating_bottom_nav_bar.dart';
import 'package:fluxfoxus/main.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App root smoke test renders home dashboard and navigation shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify app brand in header
    expect(find.text('FluxFoxus'), findsOneWidget);

    // Verify 5-tab floating bottom navigation bar
    expect(find.byType(FloatingBottomNavBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Usage'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('Planner'), findsOneWidget);
    expect(find.text('Block'), findsOneWidget);
  });
}
