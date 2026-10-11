import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fluxfoxus/core/database/app_database.dart';
import 'package:fluxfoxus/core/navigation/navigation.dart';
import 'package:fluxfoxus/features/presets/presets.dart';

class _FakePresetsRepository extends PresetsRepository {
  final List<Preset> _store;
  bool updateCalled = false;

  _FakePresetsRepository(AppDatabase db, List<Preset> store)
      : _store = store,
        super(appDatabase: db);

  @override
  Future<List<Preset>> getAllPresets() async => List.of(_store);

  @override
  Future<Preset?> getPresetById(String id) async {
    final matches = _store.where((p) => p.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<List<PresetAppRestriction>> getRestrictions(String presetId) async => [];

  @override
  Future<void> updatePreset(
    Preset preset, {
    List<PresetAppRestriction>? restrictions,
  }) async {
    updateCalled = true;
    final idx = _store.indexWhere((p) => p.id == preset.id);
    if (idx != -1) {
      _store[idx] = preset;
    } else {
      _store.add(preset);
    }
  }

  @override
  Future<void> deletePreset(String id) async {
    _store.removeWhere((p) => p.id == id);
  }
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Widget buildTestApp({required PresetsRepository repository, required String presetId}) {
    final router = createAppRouter(initialLocation: AppRoutes.presetEditPath(presetId));

    return ProviderScope(
      overrides: [
        presetsRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('PresetEditScreen Widget Tests', () {
    late AppDatabase appDatabase;
    late List<Preset> store;
    late _FakePresetsRepository repository;
    final testPreset = Preset(
      id: 'test-edit-id',
      name: 'Edit Deep Work',
      emoji: '⚡',
      breakCount: 2,
      breakDurationMinutes: 10,
      youtubeMode: YouTubeMode.studyMode,
      description: 'Test notes',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() async {
      appDatabase = AppDatabase();
      await appDatabase.initDatabase(
        customPath: inMemoryDatabasePath,
        factory: databaseFactoryFfi,
      );
      store = [testPreset];
      repository = _FakePresetsRepository(appDatabase, store);
    });

    tearDown(() async {
      await appDatabase.close();
    });

    testWidgets('Renders edit screen with loaded preset data', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(repository: repository, presetId: 'test-edit-id'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Preset'), findsOneWidget);
      expect(find.text('Edit Deep Work'), findsOneWidget);
      expect(find.text('PRESET NAME'), findsOneWidget);
      expect(find.text('BREAK CONFIGURATION'), findsOneWidget);
      expect(find.text('YOUTUBE CONFIGURATION'), findsOneWidget);
      expect(find.byKey(const Key('update_preset_button')), findsOneWidget);
    });

    testWidgets('Tapping Save Changes calls updatePreset on repository', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(repository: repository, presetId: 'test-edit-id'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('update_preset_button')));
      await tester.pumpAndSettle();

      expect(repository.updateCalled, isTrue);
    });
  });
}
