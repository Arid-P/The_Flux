import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluxfoxus/core/navigation/navigation.dart';
import 'package:fluxfoxus/presentation/screens/app_limits_screen.dart';
import 'package:fluxfoxus/presentation/screens/focus_session_screen.dart';
import 'package:fluxfoxus/presentation/screens/focus_start_screen.dart';
import 'package:fluxfoxus/presentation/screens/home_screen.dart';
import 'package:fluxfoxus/presentation/screens/planner_screen.dart';
import 'package:fluxfoxus/presentation/screens/preset_create_screen.dart';
import 'package:fluxfoxus/presentation/screens/preset_edit_screen.dart';
import 'package:fluxfoxus/presentation/screens/usage_stats_screen.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildTestApp({String initialLocation = AppRoutes.home}) {
    final testRouter = createAppRouter(initialLocation: initialLocation);
    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: testRouter,
      ),
    );
  }

  group('Navigation Shell & Tab Switching Tests', () {
    testWidgets('Renders all 5 tabs and defaults to Home branch', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(FloatingBottomNavBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Usage'), findsOneWidget);
      expect(find.text('Focus'), findsOneWidget);
      expect(find.text('Planner'), findsOneWidget);
      expect(find.text('Block'), findsOneWidget);
    });

    testWidgets('Tapping Usage tab navigates to UsageStatsScreen', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Usage'));
      await tester.pumpAndSettle();

      expect(find.byType(UsageStatsScreen), findsOneWidget);
      expect(find.byType(FloatingBottomNavBar), findsOneWidget);
    });

    testWidgets('Tapping Focus tab navigates to FocusStartScreen', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Focus'));
      await tester.pumpAndSettle();

      expect(find.byType(FocusStartScreen), findsOneWidget);
      expect(find.byType(FloatingBottomNavBar), findsOneWidget);
    });

    testWidgets('Tapping Planner tab navigates to PlannerScreen', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Planner'));
      await tester.pumpAndSettle();

      expect(find.byType(PlannerScreen), findsOneWidget);
      expect(find.byType(FloatingBottomNavBar), findsOneWidget);
    });

    testWidgets('Tapping Block tab navigates to AppLimitsScreen', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Block'));
      await tester.pumpAndSettle();

      expect(find.byType(AppLimitsScreen), findsOneWidget);
      expect(find.byType(FloatingBottomNavBar), findsOneWidget);
    });
  });

  group('Full-Screen Takeover & Navigation Hiding Tests', () {
    testWidgets('Entering focus session hides floating bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(initialLocation: AppRoutes.home));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingBottomNavBar), findsOneWidget);

      // Tap 'Start Focusing' on Home screen
      await tester.tap(find.byKey(const Key('home_start_focusing_button')));
      await tester.pumpAndSettle();

      // FocusSessionScreen is displayed
      expect(find.byType(FocusSessionScreen), findsOneWidget);
      // FloatingBottomNavBar MUST be completely absent per ui_navigation.md Section 1.6 & 3.4
      expect(find.byType(FloatingBottomNavBar), findsNothing);
    });

    testWidgets('Stopping focus session returns to Home and restores bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(initialLocation: AppRoutes.focusSession));
      await tester.pumpAndSettle();

      expect(find.byType(FocusSessionScreen), findsOneWidget);
      expect(find.byType(FloatingBottomNavBar), findsNothing);

      // Tap Stop Focusing
      await tester.tap(find.byKey(const Key('stop_focusing_button')));
      await tester.pumpAndSettle();

      // Returns to Home
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(FloatingBottomNavBar), findsOneWidget);
    });
  });

  group('Secondary Push Screens Tests', () {
    testWidgets('Navigating to PresetCreateScreen displays form and back button', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(initialLocation: AppRoutes.planner));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_preset_button')));
      await tester.pumpAndSettle();

      expect(find.byType(PresetCreateScreen), findsOneWidget);
      expect(find.text('New Preset'), findsOneWidget);

      // Can pop back to Planner
      await tester.tap(find.byKey(const Key('close_preset_button')));
      await tester.pumpAndSettle();

      expect(find.byType(PlannerScreen), findsOneWidget);
    });

    testWidgets('Navigating to PresetEditScreen with path parameters', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(initialLocation: AppRoutes.presetEditPath('preset-abc')));
      await tester.pumpAndSettle();

      expect(find.byType(PresetEditScreen), findsOneWidget);
      expect(find.text('preset-abc'), findsOneWidget);
    });
  });

  group('FloatingBottomNavBar Unit Widget Tests', () {
    testWidgets('Invokes onTap callback when individual tabs are tapped', (WidgetTester tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: FloatingBottomNavBar(
              currentIndex: 0,
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Focus'));
      await tester.pump();
      expect(tappedIndex, 2);

      await tester.tap(find.text('Planner'));
      await tester.pump();
      expect(tappedIndex, 3);
    });
  });
}
