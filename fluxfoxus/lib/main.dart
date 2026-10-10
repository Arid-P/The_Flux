import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/app_database.dart';
import 'core/navigation/navigation.dart';
import 'core/permissions/permission_service.dart';
import 'core/storage/hive_storage_service.dart';
import 'core/theme/theme.dart';
import 'features/presets/data/presets_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage & database
  final hiveStorage = HiveStorageService();
  await hiveStorage.init();

  final appDatabase = AppDatabase();
  await appDatabase.database;

  // Pre-seed default presets on first launch
  final presetsRepo = PresetsRepository(
    appDatabase: appDatabase,
    hiveStorage: hiveStorage,
  );
  await presetsRepo.getAllPresets();

  // Check onboarding status and critical permissions
  final hasCompletedOnboarding = hiveStorage.preferencesBox.get(
    'hasCompletedOnboarding',
    defaultValue: false,
  ) as bool;
  final permissionService = DefaultPermissionService();
  final hasAllCritical = await permissionService.hasAllCriticalPermissions();

  final String initialRoute = (!hasCompletedOnboarding && !hasAllCritical)
      ? AppRoutes.permissionsOnboarding
      : AppRoutes.home;

  runApp(
    ProviderScope(
      overrides: [
        initialLocationProvider.overrideWithValue(initialRoute),
      ],
      child: const MyApp(),
    ),
  );
}

/// Root application widget configuring theme and GoRouter navigation shell.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'FluxFoxus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
