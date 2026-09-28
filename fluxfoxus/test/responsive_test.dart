import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluxfoxus/presentation/screens/home_screen.dart';
import 'package:fluxfoxus/presentation/screens/focus_session_screen.dart';
import 'package:fluxfoxus/presentation/screens/planner_screen.dart';
import 'package:fluxfoxus/presentation/screens/app_limits_screen.dart';
import 'package:fluxfoxus/presentation/screens/usage_stats_screen.dart';
import 'package:fluxfoxus/presentation/screens/preset_create_screen.dart';
import 'package:fluxfoxus/presentation/screens/onboarding_screens.dart';
import 'package:fluxfoxus/core/navigation/floating_bottom_nav_bar.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> testScreenSize(
    WidgetTester tester,
    Widget widget,
    Size size,
    String description,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: widget,
        ),
      ),
    );
    await tester.pump();
  }

  group('Landscape and Aspect Ratio Scaling Verification', () {
    final testSizes = <String, Size>{
      'Narrow Phone Portrait (320x568)': const Size(320, 568),
      'Standard Phone Portrait (390x844)': const Size(390, 844),
      'Landscape Compact Phone (640x360)': const Size(640, 360),
      'Landscape Standard Phone (844x390)': const Size(844, 390),
      'Tablet Portrait (768x1024)': const Size(768, 1024),
      'Tablet Landscape (1024x768)': const Size(1024, 768),
    };

    for (final entry in testSizes.entries) {
      testWidgets('HomeScreen on ${entry.key}', (tester) async {
        await testScreenSize(tester, const HomeScreen(), entry.value, entry.key);
      });

      testWidgets('FocusSessionScreen on ${entry.key}', (tester) async {
        await testScreenSize(tester, const FocusSessionScreen(), entry.value, entry.key);
      });

      testWidgets('PlannerScreen on ${entry.key}', (tester) async {
        await testScreenSize(tester, const PlannerScreen(), entry.value, entry.key);
      });

      testWidgets('AppLimitsScreen on ${entry.key}', (tester) async {
        await testScreenSize(tester, const AppLimitsScreen(), entry.value, entry.key);
      });

      testWidgets('UsageStatsScreen on ${entry.key}', (tester) async {
        await testScreenSize(tester, const UsageStatsScreen(), entry.value, entry.key);
      });

      testWidgets('PermissionsOnboardingFlowScreen on ${entry.key}', (tester) async {
        await testScreenSize(tester, const PermissionsOnboardingFlowScreen(), entry.value, entry.key);
      });

      testWidgets('PresetCreateScreen on ${entry.key}', (tester) async {
        await testScreenSize(tester, const PresetCreateScreen(), entry.value, entry.key);
      });

      testWidgets('FloatingBottomNavBar on ${entry.key}', (tester) async {
        await testScreenSize(
          tester,
          Scaffold(
            bottomNavigationBar: FloatingBottomNavBar(
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
          entry.value,
          entry.key,
        );
      });
    }
  });
}
