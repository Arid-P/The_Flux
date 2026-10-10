# Database Schema

> **Last Updated:** 2026-10-10
> **Source file:** `fluxfoxus/lib/core/database/database_tables.dart`
> **TRD reference:** FF TRD Section 4

---

## SQLite Tables (6 total)

### 1. `presets`

Focus session templates. One-to-many with `preset_app_restrictions`.

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | TEXT | PRIMARY KEY | UUID v4 |
| `name` | TEXT | NOT NULL | User-defined preset name |
| `emoji` | TEXT | NOT NULL, DEFAULT '⏳' | Emoji icon for the preset |
| `break_count` | INTEGER | NOT NULL, DEFAULT 0 | Number of breaks allowed (0–6) |
| `break_duration_minutes` | INTEGER | NOT NULL, DEFAULT 5 | Break duration in minutes (1–15) |
| `youtube_mode` | TEXT | NOT NULL, DEFAULT 'study_mode' | One of: `block`, `allow`, `study_mode` |
| `description` | TEXT | nullable | Optional preset description |
| `created_at` | INTEGER | NOT NULL | Unix timestamp (seconds) |
| `updated_at` | INTEGER | NOT NULL | Unix timestamp (seconds) |

---

### 2. `preset_app_restrictions`

Per-preset app block/allow configuration.

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `preset_id` | TEXT | NOT NULL | FK → `presets.id` ON DELETE CASCADE |
| `package_name` | TEXT | NOT NULL | Android package identifier |
| `is_blocked` | INTEGER | NOT NULL, DEFAULT 1 | 1 = blocked, 0 = allowed |
| — | — | PRIMARY KEY (`preset_id`, `package_name`) | Composite PK |

---

### 3. `focus_sessions`

Historical record of all completed or abandoned focus sessions.

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | TEXT | PRIMARY KEY | UUID v4 |
| `preset_id` | TEXT | NOT NULL | FK → `presets.id` (no cascade) |
| `fd_task_id` | TEXT | nullable | Linked FluxDone task ID (IPC) |
| `session_name` | TEXT | NOT NULL | Preset name at time of session |
| `mode` | TEXT | NOT NULL | `countdown`, `stopwatch`, `open_ended` |
| `scheduled_start` | INTEGER | nullable | Planned start (ms since epoch) |
| `scheduled_end` | INTEGER | nullable | Planned end (ms since epoch) |
| `planned_duration_seconds` | INTEGER | nullable | Intended duration in seconds |
| `actual_start` | INTEGER | nullable | Actual start (ms since epoch) |
| `actual_end` | INTEGER | nullable | Actual end (ms since epoch) |
| `actual_focus_seconds` | INTEGER | nullable | Elapsed focus time in seconds |
| `status` | TEXT | NOT NULL, DEFAULT 'pending' | `pending`, `running`, `paused`, `completed`, `abandoned`, `on_break` |
| `breaks_used` | INTEGER | NOT NULL, DEFAULT 0 | How many breaks were taken |
| `source` | TEXT | NOT NULL, DEFAULT 'ff' | `ff` or `fd` (IPC-triggered) |
| `created_at` | INTEGER | NOT NULL | Record creation (ms since epoch) |

---

### 4. `app_limits`

Per-app daily screen time limits and blocking configuration.

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `package_name` | TEXT | PRIMARY KEY | Android package identifier |
| `app_name` | TEXT | NOT NULL | Display name |
| `category` | TEXT | NOT NULL | `productive`, `semi_productive`, `distracting`, `others` |
| `daily_limit_seconds` | INTEGER | NOT NULL | Daily screen time limit |
| `extra_session_count` | INTEGER | NOT NULL, DEFAULT 0 | Extra time sessions remaining (0–6) |
| `extra_session_duration_seconds` | INTEGER | NOT NULL, DEFAULT 300 | Extra session length (300=5m) |
| `is_active` | INTEGER | NOT NULL, DEFAULT 1 | 1=active, 0=turned off |
| `paused_until` | INTEGER | nullable | Timestamp when block resumes |
| `streak_days` | INTEGER | NOT NULL, DEFAULT 0 | Per-app streak counter |
| `created_at` | INTEGER | NOT NULL | Record creation timestamp |

---

### 5. `streak_records`

Focus session streak tracking.

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Single record per user |
| `current_streak` | INTEGER | NOT NULL, DEFAULT 0 | Current consecutive streak days |
| `longest_streak` | INTEGER | NOT NULL, DEFAULT 0 | All-time longest streak |
| `minimum_sessions_per_day` | INTEGER | NOT NULL, DEFAULT 1 | Sessions needed to keep streak alive |
| `last_streak_date` | INTEGER | nullable | Last date streak was counted |
| `updated_at` | INTEGER | NOT NULL | Last updated timestamp |

---

### 6. `study_channels`

YouTube Study Mode channel whitelist.

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | TEXT | PRIMARY KEY | UUID or channel ID |
| `channel_name` | TEXT | NOT NULL | Display name of channel |
| `channel_url` | TEXT | nullable | Full channel URL |
| `added_at` | INTEGER | NOT NULL | Timestamp when added |

---

## Hive Boxes (4 total)

| Box Name | Type | Key | Purpose |
|---|---|---|---|
| `preferences` | `Box` | `minimumSessionsPerDay` (int) | Min sessions per day to keep streak |
| `preferences` | `Box` | `lastUsedPresetId` (String?) | ID of last-used preset |
| `preferences` | `Box` | `sessionStartConfirmAfterHours` (int, default 60) | Hours threshold before session start confirm |
| `app_categories` | `Box<String>` | packageName → category | User overrides for app categories |
| `app_metadata` | `Box<Map>` | packageName → {displayName, iconPath, …} | Cached app metadata |
| `focus_session_state` | `Box` | `active_session` (Map) | Active session state (survives app kill) |

---

## Performance Indexes (applied at creation)

- `focus_sessions`: index on `preset_id`, `status`, `created_at`
- `app_limits`: index on `category`, `is_active`
- `streak_records`: index on `last_streak_date`
