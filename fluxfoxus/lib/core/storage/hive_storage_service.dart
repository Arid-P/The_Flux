import 'package:hive_flutter/hive_flutter.dart';

/// HiveStorageService manages key-value boxes for user preferences,
/// app category mappings, and app metadata per TRD Section 4.7.
class HiveStorageService {
  static const String boxPreferences = 'preferences';
  static const String boxAppCategories = 'app_categories';
  static const String boxAppMetadata = 'app_metadata';

  // Preference keys
  static const String keyMinSessionsPerDay = 'minimumSessionsPerDay';
  static const String keyLastUsedPresetId = 'lastUsedPresetId';
  static const String keyConfirmAfterHours = 'sessionStartConfirmAfterHours';

  Box? _prefBox;
  Box<String>? _categoriesBox;
  Box<Map>? _metadataBox;

  /// Initializes Hive and opens all required boxes.
  Future<void> init({String? subDir}) async {
    if (subDir != null) {
      Hive.init(subDir);
    } else {
      await Hive.initFlutter();
    }

    _prefBox = await Hive.openBox(boxPreferences);
    _categoriesBox = await Hive.openBox<String>(boxAppCategories);
    _metadataBox = await Hive.openBox<Map>(boxAppMetadata);
  }

  // ---------------------------------------------------------------------------
  // Preferences Accessors
  // ---------------------------------------------------------------------------
  Box get preferencesBox {
    if (_prefBox == null || !_prefBox!.isOpen) {
      throw StateError('Preferences box has not been initialized. Call init() first.');
    }
    return _prefBox!;
  }

  int get minimumSessionsPerDay =>
      preferencesBox.get(keyMinSessionsPerDay, defaultValue: 1) as int;

  Future<void> setMinimumSessionsPerDay(int count) async {
    await preferencesBox.put(keyMinSessionsPerDay, count);
  }

  String? get lastUsedPresetId =>
      preferencesBox.get(keyLastUsedPresetId) as String?;

  Future<void> setLastUsedPresetId(String presetId) async {
    await preferencesBox.put(keyLastUsedPresetId, presetId);
  }

  int get sessionStartConfirmAfterHours =>
      preferencesBox.get(keyConfirmAfterHours, defaultValue: 60) as int;

  Future<void> setSessionStartConfirmAfterHours(int hours) async {
    await preferencesBox.put(keyConfirmAfterHours, hours);
  }

  // ---------------------------------------------------------------------------
  // App Categories Accessors (packageName -> category override)
  // ---------------------------------------------------------------------------
  Box<String> get categoriesBox {
    if (_categoriesBox == null || !_categoriesBox!.isOpen) {
      throw StateError('App categories box has not been initialized.');
    }
    return _categoriesBox!;
  }

  String? getCategory(String packageName) => categoriesBox.get(packageName);

  Future<void> setCategory(String packageName, String category) async {
    await categoriesBox.put(packageName, category);
  }

  Map<String, String> getAllCategories() =>
      Map<String, String>.from(categoriesBox.toMap());

  // ---------------------------------------------------------------------------
  // App Metadata Accessors (packageName -> {displayName, iconPath, etc})
  // ---------------------------------------------------------------------------
  Box<Map> get metadataBox {
    if (_metadataBox == null || !_metadataBox!.isOpen) {
      throw StateError('App metadata box has not been initialized.');
    }
    return _metadataBox!;
  }

  Map? getMetadata(String packageName) => metadataBox.get(packageName);

  Future<void> setMetadata(String packageName, Map metadata) async {
    await metadataBox.put(packageName, metadata);
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------
  Future<void> close() async {
    await _prefBox?.close();
    await _categoriesBox?.close();
    await _metadataBox?.close();
  }
}
