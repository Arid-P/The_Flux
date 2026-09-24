/// Database table and column constants for FluxFoxus.
/// Strictly implements schemas defined in TRD Section 4.
class DatabaseTables {
  DatabaseTables._();

  // ---------------------------------------------------------------------------
  // Table: presets
  // ---------------------------------------------------------------------------
  static const String presets = 'presets';
  static const String colPresetId = 'id';
  static const String colPresetName = 'name';
  static const String colPresetEmoji = 'emoji';
  static const String colPresetBreakCount = 'break_count';
  static const String colPresetBreakDuration = 'break_duration_minutes';
  static const String colPresetYoutubeMode = 'youtube_mode';
  static const String colPresetDescription = 'description';
  static const String colPresetCreatedAt = 'created_at';
  static const String colPresetUpdatedAt = 'updated_at';

  static const String createPresetsTable = '''
    CREATE TABLE $presets (
      $colPresetId TEXT PRIMARY KEY,
      $colPresetName TEXT NOT NULL,
      $colPresetEmoji TEXT NOT NULL DEFAULT '⏳',
      $colPresetBreakCount INTEGER NOT NULL DEFAULT 0,
      $colPresetBreakDuration INTEGER NOT NULL DEFAULT 5,
      $colPresetYoutubeMode TEXT NOT NULL DEFAULT 'study_mode',
      $colPresetDescription TEXT,
      $colPresetCreatedAt INTEGER NOT NULL,
      $colPresetUpdatedAt INTEGER NOT NULL
    );
  ''';

  // ---------------------------------------------------------------------------
  // Table: preset_app_restrictions
  // ---------------------------------------------------------------------------
  static const String presetAppRestrictions = 'preset_app_restrictions';
  static const String colRestrictionPresetId = 'preset_id';
  static const String colRestrictionPackageName = 'package_name';
  static const String colRestrictionIsBlocked = 'is_blocked';

  static const String createPresetAppRestrictionsTable = '''
    CREATE TABLE $presetAppRestrictions (
      $colRestrictionPresetId TEXT NOT NULL,
      $colRestrictionPackageName TEXT NOT NULL,
      $colRestrictionIsBlocked INTEGER NOT NULL DEFAULT 1,
      PRIMARY KEY ($colRestrictionPresetId, $colRestrictionPackageName),
      FOREIGN KEY ($colRestrictionPresetId) REFERENCES $presets($colPresetId) ON DELETE CASCADE
    );
  ''';

  // ---------------------------------------------------------------------------
  // Table: focus_sessions
  // ---------------------------------------------------------------------------
  static const String focusSessions = 'focus_sessions';
  static const String colSessionId = 'id';
  static const String colSessionPresetId = 'preset_id';
  static const String colSessionFdTaskId = 'fd_task_id';
  static const String colSessionName = 'session_name';
  static const String colSessionMode = 'mode';
  static const String colSessionScheduledStart = 'scheduled_start';
  static const String colSessionScheduledEnd = 'scheduled_end';
  static const String colSessionPlannedDuration = 'planned_duration_seconds';
  static const String colSessionActualStart = 'actual_start';
  static const String colSessionActualEnd = 'actual_end';
  static const String colSessionActualFocusSeconds = 'actual_focus_seconds';
  static const String colSessionStatus = 'status';
  static const String colSessionBreaksUsed = 'breaks_used';
  static const String colSessionSource = 'source';
  static const String colSessionCreatedAt = 'created_at';

  static const String createFocusSessionsTable = '''
    CREATE TABLE $focusSessions (
      $colSessionId TEXT PRIMARY KEY,
      $colSessionPresetId TEXT NOT NULL,
      $colSessionFdTaskId TEXT,
      $colSessionName TEXT NOT NULL,
      $colSessionMode TEXT NOT NULL,
      $colSessionScheduledStart INTEGER,
      $colSessionScheduledEnd INTEGER,
      $colSessionPlannedDuration INTEGER,
      $colSessionActualStart INTEGER,
      $colSessionActualEnd INTEGER,
      $colSessionActualFocusSeconds INTEGER,
      $colSessionStatus TEXT NOT NULL DEFAULT 'pending',
      $colSessionBreaksUsed INTEGER NOT NULL DEFAULT 0,
      $colSessionSource TEXT NOT NULL DEFAULT 'ff',
      $colSessionCreatedAt INTEGER NOT NULL,
      FOREIGN KEY ($colSessionPresetId) REFERENCES $presets($colPresetId)
    );
  ''';

  // ---------------------------------------------------------------------------
  // Table: app_limits
  // ---------------------------------------------------------------------------
  static const String appLimits = 'app_limits';
  static const String colLimitPackageName = 'package_name';
  static const String colLimitAppName = 'app_name';
  static const String colLimitCategory = 'category';
  static const String colLimitDailySeconds = 'daily_limit_seconds';
  static const String colLimitExtraSessionCount = 'extra_session_count';
  static const String colLimitExtraSessionDuration = 'extra_session_duration_seconds';
  static const String colLimitIsActive = 'is_active';
  static const String colLimitPausedUntil = 'paused_until';
  static const String colLimitStreakDays = 'streak_days';
  static const String colLimitCreatedAt = 'created_at';

  static const String createAppLimitsTable = '''
    CREATE TABLE $appLimits (
      $colLimitPackageName TEXT PRIMARY KEY,
      $colLimitAppName TEXT NOT NULL,
      $colLimitCategory TEXT NOT NULL,
      $colLimitDailySeconds INTEGER NOT NULL,
      $colLimitExtraSessionCount INTEGER NOT NULL DEFAULT 0,
      $colLimitExtraSessionDuration INTEGER NOT NULL DEFAULT 300,
      $colLimitIsActive INTEGER NOT NULL DEFAULT 1,
      $colLimitPausedUntil INTEGER,
      $colLimitStreakDays INTEGER NOT NULL DEFAULT 0,
      $colLimitCreatedAt INTEGER NOT NULL
    );
  ''';

  // ---------------------------------------------------------------------------
  // Table: streak_records
  // ---------------------------------------------------------------------------
  static const String streakRecords = 'streak_records';
  static const String colStreakId = 'id';
  static const String colStreakCurrent = 'current_streak';
  static const String colStreakLongest = 'longest_streak';
  static const String colStreakMinSessionsPerDay = 'minimum_sessions_per_day';
  static const String colStreakLastDate = 'last_streak_date';
  static const String colStreakUpdatedAt = 'updated_at';

  static const String createStreakRecordsTable = '''
    CREATE TABLE $streakRecords (
      $colStreakId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colStreakCurrent INTEGER NOT NULL DEFAULT 0,
      $colStreakLongest INTEGER NOT NULL DEFAULT 0,
      $colStreakMinSessionsPerDay INTEGER NOT NULL DEFAULT 1,
      $colStreakLastDate INTEGER,
      $colStreakUpdatedAt INTEGER NOT NULL
    );
  ''';

  // ---------------------------------------------------------------------------
  // Table: study_channels
  // ---------------------------------------------------------------------------
  static const String studyChannels = 'study_channels';
  static const String colChannelId = 'id';
  static const String colChannelName = 'channel_name';
  static const String colChannelUrl = 'channel_url';
  static const String colChannelAddedAt = 'added_at';

  static const String createStudyChannelsTable = '''
    CREATE TABLE $studyChannels (
      $colChannelId TEXT PRIMARY KEY,
      $colChannelName TEXT NOT NULL,
      $colChannelUrl TEXT,
      $colChannelAddedAt INTEGER NOT NULL
    );
  ''';
}
