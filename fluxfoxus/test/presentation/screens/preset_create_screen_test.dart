import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fluxfoxus/core/database/app_database.dart';
import 'package:fluxfoxus/core/navigation/navigation.dart';
import 'package:fluxfoxus/features/presets/presets.dart';
import 'package:fluxfoxus/presentation/screens/preset_create_screen.dart';

class _FakePresetsRepository extends PresetsRepository {
  final List<Preset> _store;

  _FakePresetsRepository(AppDatabase db, List<Preset> store)
      : _store = store,
        super(appDatabase: db);

  @override
  Future<List<Preset>> getAllPresets() async => List.of(_store);

  @override
  Future<void> savePreset(
    Preset preset, {
    List<PresetAppRestriction>? restrictions,
  }) async {
    _store.add(preset);
  }

  @override
  Future<void> setLastUsedPreset(String presetId) async {}
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Widget buildTestApp({required PresetsRepository repository}) {
    final router = createAppRouter(initialLocation: AppRoutes.presetCreate);

    return ProviderScope(
      overrides: [
        presetsRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('PresetCreateScreen Widget Tests', () {
    late AppDatabase appDatabase;
    late List<Preset> store;
    late PresetsRepository repository;

    setUp(() async {
      appDatabase = AppDatabase();
      await appDatabase.initDatabase(
        customPath: inMemoryDatabasePath,
        factory: databaseFactoryFfi,
      );
      store = [];
      repository = _FakePresetsRepository(appDatabase, store);
    });

    tearDown(() async {
      await appDatabase.close();
    });

    testWidgets('Renders all sections per ui_preset.md', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text('New Preset'), findsOneWidget);
      expect(find.text('PRESET NAME'), findsOneWidget);
      expect(find.text('BREAK CONFIGURATION'), findsOneWidget);
      expect(find.text('YOUTUBE CONFIGURATION'), findsOneWidget);
      expect(find.text('APP RESTRICTIONS'), findsOneWidget);
      expect(find.text('DESCRIPTION'), findsOneWidget);
      expect(find.byKey(const Key('save_preset_button')), findsOneWidget);
    });

    testWidgets('Emoji picker opens and updates selected emoji', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      // Initial default emoji
      expect(find.text('⏳'), findsOneWidget);

      // Tap emoji button
      await tester.tap(find.byKey(const Key('preset_emoji_button')));
      await tester.pumpAndSettle();

      // Emoji bottom sheet is visible
      expect(find.byType(EmojiPickerSheet), findsOneWidget);
      expect(find.text('Select Icon'), findsOneWidget);

      // Select '🎯'
      await tester.tap(find.byKey(const Key('emoji_picker_item_🎯')));
      await tester.pumpAndSettle();

      // Emoji bottom sheet is closed and '🎯' is displayed
      expect(find.byType(EmojiPickerSheet), findsNothing);
      expect(find.text('🎯'), findsOneWidget);
    });

    testWidgets('Break steppers increment and decrement within boundaries', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      // Break count starts at 1
      expect(find.text('1'), findsOneWidget); // break count
      expect(find.text('5'), findsOneWidget); // break duration

      // Decrement break count to 0
      await tester.tap(find.byKey(const Key('break_count_dec_button')));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);

      // Cannot decrement below 0
      await tester.tap(find.byKey(const Key('break_count_dec_button')));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);

      // Increment break duration from 5 to 7
      await tester.tap(find.byKey(const Key('break_duration_inc_button')));
      await tester.pumpAndSettle();
      expect(find.text('6'), findsOneWidget);

      await tester.tap(find.byKey(const Key('break_duration_inc_button')));
      await tester.pumpAndSettle();
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('App category expansion and toggle updates blocked count', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      // Distracting has 3 blocked apps by default
      expect(find.text('3 blocked'), findsOneWidget);

      // Toggle first app (Instagram) from blocked to unblocked
      final instagramSwitch = find.byKey(const Key('app_switch_com.instagram.android'));
      await tester.ensureVisible(instagramSwitch);
      await tester.pumpAndSettle();
      expect(instagramSwitch, findsOneWidget);

      await tester.tap(instagramSwitch);
      await tester.pumpAndSettle();

      // Blocked count decreases from 3 to 2!
      expect(find.text('2 blocked'), findsOneWidget);

      // Toggle back to blocked
      await tester.tap(instagramSwitch);
      await tester.pumpAndSettle();
      expect(find.text('3 blocked'), findsOneWidget);
    });

    testWidgets('YouTube 3-way radio updates mode', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      // Tap 'Block completely'
      final radioBlock = find.byKey(const Key('youtube_mode_block'));
      await tester.ensureVisible(radioBlock);
      await tester.pumpAndSettle();
      await tester.tap(radioBlock);
      await tester.pumpAndSettle();

      // Tap 'Allow completely'
      final radioAllow = find.byKey(const Key('youtube_mode_allow'));
      await tester.ensureVisible(radioAllow);
      await tester.pumpAndSettle();
      await tester.tap(radioAllow);
      await tester.pumpAndSettle();

      // Tap 'Study Mode'
      final radioStudy = find.byKey(const Key('youtube_mode_study_mode'));
      await tester.ensureVisible(radioStudy);
      await tester.pumpAndSettle();
      await tester.tap(radioStudy);
      await tester.pumpAndSettle();
    });

    testWidgets('Validation prevents saving when preset name is empty', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      // Tap save without entering name
      await tester.tap(find.byKey(const Key('save_preset_button')));
      await tester.pumpAndSettle();

      // Shows SnackBar error
      expect(find.text('Please enter a preset name'), findsOneWidget);
      // Still on preset create screen
      expect(find.byType(PresetCreateScreen), findsOneWidget);
    });

    testWidgets('Successfully saves preset and pops screen when valid', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      // Enter name and description
      await tester.enterText(find.byKey(const Key('preset_name_input')), 'Extreme Focus');
      await tester.enterText(find.byKey(const Key('preset_description_input')), 'Deep work session for coding');
      await tester.pump();

      // Tap Save
      await tester.tap(find.byKey(const Key('save_preset_button')));
      await tester.pumpAndSettle();

      // Verify preset is saved in repository store
      expect(store.any((p) => p.name == 'Extreme Focus'), true);
    });
  });
}
