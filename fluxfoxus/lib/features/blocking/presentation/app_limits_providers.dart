import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presets/presets.dart';
import '../data/app_limits_repository.dart';
import '../domain/app_limit.dart';

/// Provider for AppLimitsRepository.
final appLimitsRepositoryProvider = Provider<AppLimitsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppLimitsRepository(appDatabase: db);
});

/// AsyncNotifier managing the reactive state of App Limits.
class AppLimitsListNotifier extends AsyncNotifier<List<AppLimit>> {
  @override
  Future<List<AppLimit>> build() async {
    final repo = ref.watch(appLimitsRepositoryProvider);
    return repo.getAllLimits();
  }

  Future<void> addLimit(AppLimit limit) async {
    final repo = ref.read(appLimitsRepositoryProvider);
    await repo.saveLimit(limit);
    ref.invalidateSelf();
  }

  Future<void> updateLimit(AppLimit limit) async {
    final repo = ref.read(appLimitsRepositoryProvider);
    await repo.updateLimit(limit);
    ref.invalidateSelf();
  }

  Future<void> deleteLimit(String packageName) async {
    final repo = ref.read(appLimitsRepositoryProvider);
    await repo.deleteLimit(packageName);
    ref.invalidateSelf();
  }

  Future<void> toggleActive(String packageName, bool active) async {
    final repo = ref.read(appLimitsRepositoryProvider);
    final limit = await repo.getLimit(packageName);
    if (limit != null) {
      final updated = limit.copyWith(isActive: active);
      await repo.updateLimit(updated);
      ref.invalidateSelf();
    }
  }

  Future<void> pauseLimit(String packageName, DateTime pausedUntil) async {
    final repo = ref.read(appLimitsRepositoryProvider);
    await repo.pauseLimit(packageName, pausedUntil);
    ref.invalidateSelf();
  }

  Future<void> resumeLimit(String packageName) async {
    final repo = ref.read(appLimitsRepositoryProvider);
    await repo.resumeLimit(packageName);
    ref.invalidateSelf();
  }

  Future<bool> addExtraSession(String packageName, int durationSeconds) async {
    final repo = ref.read(appLimitsRepositoryProvider);
    final success = await repo.addExtraSession(packageName, durationSeconds);
    if (success) {
      ref.invalidateSelf();
    }
    return success;
  }
}

final appLimitsListProvider =
    AsyncNotifierProvider<AppLimitsListNotifier, List<AppLimit>>(
  AppLimitsListNotifier.new,
);
