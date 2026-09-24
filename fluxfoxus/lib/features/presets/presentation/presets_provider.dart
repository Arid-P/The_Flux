import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/storage/hive_storage_service.dart';
import '../data/presets_repository.dart';
import '../domain/preset.dart';
import '../domain/preset_app_restriction.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final hiveStorageServiceProvider = Provider<HiveStorageService>((ref) {
  final storage = HiveStorageService();
  ref.onDispose(() => storage.close());
  return storage;
});

final presetsRepositoryProvider = Provider<PresetsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final hive = ref.watch(hiveStorageServiceProvider);
  return PresetsRepository(appDatabase: db, hiveStorage: hive);
});

/// AsyncNotifier managing the active list of presets.
class PresetsListNotifier extends AsyncNotifier<List<Preset>> {
  @override
  Future<List<Preset>> build() async {
    final repo = ref.watch(presetsRepositoryProvider);
    return repo.getAllPresets();
  }

  Future<void> createPreset(
    Preset preset, {
    List<PresetAppRestriction>? restrictions,
  }) async {
    final repo = ref.read(presetsRepositoryProvider);
    await repo.savePreset(preset, restrictions: restrictions);
    state = AsyncData(await repo.getAllPresets());
  }

  Future<void> updatePreset(
    Preset preset, {
    List<PresetAppRestriction>? restrictions,
  }) async {
    final repo = ref.read(presetsRepositoryProvider);
    await repo.updatePreset(preset, restrictions: restrictions);
    state = AsyncData(await repo.getAllPresets());
  }

  Future<void> deletePreset(String id) async {
    final repo = ref.read(presetsRepositoryProvider);
    await repo.deletePreset(id);
    state = AsyncData(await repo.getAllPresets());
  }
}

final presetsListProvider =
    AsyncNotifierProvider<PresetsListNotifier, List<Preset>>(
  PresetsListNotifier.new,
);

final currentPresetProvider = FutureProvider<Preset?>((ref) async {
  final repo = ref.watch(presetsRepositoryProvider);
  return repo.getLastUsedPreset();
});
