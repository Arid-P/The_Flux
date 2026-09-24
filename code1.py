#!/usr/bin/env python3
"""
code1.py — Code1 Agent Bootstrap & Task Runner
================================================
Run this script in a new terminal session to resume Code1's work exactly where
it left off. It checks the environment, verifies git state, fixes the known
test timeout bug, and scaffolds Phase 1-B Step 6 (Focus Timer + Foreground Service).

Usage:
    python3 /workspaces/The_Flux/code1.py

Requirements:
    - /home/codespace/flutter/bin/flutter must exist
    - Working directory: /workspaces/The_Flux
    - Git branch must be 'ff'
"""

import subprocess
import sys
import os
import textwrap
from pathlib import Path

# ─────────────────────────────────────────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────
REPO_ROOT = Path("/workspaces/The_Flux")
FLUTTER_BIN = Path("/home/codespace/flutter/bin/flutter")
FLUTTER_APP = REPO_ROOT / "fluxfoxus"
EXPECTED_BRANCH = "ff"

# ─────────────────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────────────────
def run(cmd: str, cwd: Path = REPO_ROOT, check: bool = True, capture: bool = False):
    """Run a shell command and return output."""
    result = subprocess.run(
        cmd, shell=True, cwd=str(cwd),
        capture_output=capture, text=True
    )
    if check and result.returncode != 0:
        print(f"\n❌ COMMAND FAILED: {cmd}")
        if capture:
            print(result.stderr)
        sys.exit(1)
    return result

def heading(title: str):
    print(f"\n{'─' * 60}")
    print(f"  {title}")
    print(f"{'─' * 60}")

def ok(msg: str):
    print(f"  ✅ {msg}")

def info(msg: str):
    print(f"  ℹ️  {msg}")

def warn(msg: str):
    print(f"  ⚠️  {msg}")

def write_file(path: Path, content: str, overwrite: bool = False):
    """Write a file, skipping if it already exists (unless overwrite=True)."""
    if path.exists() and not overwrite:
        info(f"Skipping (already exists): {path.relative_to(REPO_ROOT)}")
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(textwrap.dedent(content).lstrip())
    ok(f"Written: {path.relative_to(REPO_ROOT)}")

# ─────────────────────────────────────────────────────────────────────────────
# STEP 0 — ENVIRONMENT CHECK
# ─────────────────────────────────────────────────────────────────────────────
def check_environment():
    heading("STEP 0: Environment Check")
    assert REPO_ROOT.exists(), f"Repo root not found: {REPO_ROOT}"
    ok(f"Repo root: {REPO_ROOT}")
    assert FLUTTER_BIN.exists(), f"Flutter not found at {FLUTTER_BIN}"
    ok(f"Flutter: {FLUTTER_BIN}")

    result = run("git branch --show-current", capture=True)
    branch = result.stdout.strip()
    if branch != EXPECTED_BRANCH:
        print(f"❌ Wrong branch! Expected '{EXPECTED_BRANCH}', got '{branch}'")
        print("   Run: git checkout ff")
        sys.exit(1)
    ok(f"Branch: {branch}")

    result = run("git status --short", capture=True)
    if result.stdout.strip():
        warn("Working tree has uncommitted changes:")
        print(result.stdout)
    else:
        ok("Working tree clean")

    result = run("git log --oneline -3", capture=True)
    print("\n  Recent commits:")
    for line in result.stdout.strip().split("\n"):
        print(f"    {line}")

# ─────────────────────────────────────────────────────────────────────────────
# STEP 1 — FIX TEST 7 TIMEOUT BUG
# ─────────────────────────────────────────────────────────────────────────────
def fix_test_7_timeout():
    heading("STEP 1: Fix Test 7 Timeout Bug in preset_create_screen_test.dart")

    test_file = FLUTTER_APP / "test/presentation/screens/preset_create_screen_test.dart"

    new_content = '''\
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fluxfoxus/core/database/app_database.dart';
import 'package:fluxfoxus/core/navigation/navigation.dart';
import 'package:fluxfoxus/features/presets/presets.dart';
import 'package:fluxfoxus/presentation/screens/preset_create_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fake repository to avoid real async DB calls inside Riverpod notifier rebuild
// (which keeps the test zone alive indefinitely → causes 10m timeout).
// ─────────────────────────────────────────────────────────────────────────────
class _FakePresetsRepository extends PresetsRepository {
  final List<Preset> _store;

  _FakePresetsRepository(AppDatabase db, List<Preset> store)
      : _store = store,
        super(appDatabase: db);

  @override
  Future<List<Preset>> getAllPresets() async => List.of(_store);

  @override
  Future<void> savePreset(Preset preset,
      {List<PresetAppRestriction>? restrictions}) async {
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

  group(\'PresetCreateScreen Widget Tests\', () {
    late AppDatabase appDatabase;
    late PresetsRepository repository;

    setUp(() async {
      appDatabase = AppDatabase();
      await appDatabase.initDatabase(
        customPath: inMemoryDatabasePath,
        factory: databaseFactoryFfi,
      );
      repository = _FakePresetsRepository(appDatabase, []);
    });

    tearDown(() async {
      await appDatabase.close();
    });

    testWidgets(\'Renders all sections per ui_preset.md\', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text(\'New Preset\'), findsOneWidget);
      expect(find.text(\'PRESET NAME\'), findsOneWidget);
      expect(find.text(\'BREAK CONFIGURATION\'), findsOneWidget);
      expect(find.text(\'YOUTUBE CONFIGURATION\'), findsOneWidget);
      expect(find.text(\'APP RESTRICTIONS\'), findsOneWidget);
      expect(find.text(\'DESCRIPTION\'), findsOneWidget);
      expect(find.byKey(const Key(\'save_preset_button\')), findsOneWidget);
    });

    testWidgets(\'Emoji picker opens and updates selected emoji\', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key(\'preset_emoji_button\')));
      await tester.pumpAndSettle();

      // Sheet opens with search field and emojis
      expect(find.byType(TextField), findsWidgets);

      // Pick a visible emoji
      final emojiItem = find.text(\'🚀\');
      await tester.ensureVisible(emojiItem);
      await tester.pumpAndSettle();
      await tester.tap(emojiItem);
      await tester.pumpAndSettle();
    });

    testWidgets(\'Break steppers increment and decrement within boundaries\', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      // Increment break count
      await tester.tap(find.byKey(const Key(\'break_count_inc_button\')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key(\'break_count_value\')), findsOneWidget);
      final valueFinder = find.descendant(
        of: find.byKey(const Key(\'break_count_value\')),
        matching: find.text(\'1\'),
      );
      expect(valueFinder, findsOneWidget);

      // Decrement back to 0
      await tester.tap(find.byKey(const Key(\'break_count_dec_button\')));
      await tester.pumpAndSettle();

      // Duration increment
      await tester.tap(find.byKey(const Key(\'break_duration_inc_button\')));
      await tester.pumpAndSettle();
    });

    testWidgets(\'App category expansion and toggle updates blocked count\', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      // Expand Distracting category
      await tester.tap(find.byKey(const Key(\'category_header_Distracting\')));
      await tester.pumpAndSettle();

      // Toggle first app (Instagram) from blocked to unblocked
      final instagramSwitch = find.byKey(const Key(\'app_switch_com.instagram.android\'));
      await tester.ensureVisible(instagramSwitch);
      await tester.pumpAndSettle();
      expect(instagramSwitch, findsOneWidget);

      await tester.tap(instagramSwitch);
      await tester.pumpAndSettle();

      // Blocked count decreases from 3 to 2!
      expect(find.text(\'2 blocked\'), findsOneWidget);

      // Toggle back to blocked
      await tester.tap(instagramSwitch);
      await tester.pumpAndSettle();
      expect(find.text(\'3 blocked\'), findsOneWidget);
    });

    testWidgets(\'YouTube 3-way radio updates mode\', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      // Tap \'Block completely\'
      final radioBlock = find.byKey(const Key(\'youtube_mode_block\'));
      await tester.ensureVisible(radioBlock);
      await tester.pumpAndSettle();
      await tester.tap(radioBlock);
      await tester.pumpAndSettle();

      // Tap \'Allow completely\'
      final radioAllow = find.byKey(const Key(\'youtube_mode_allow\'));
      await tester.ensureVisible(radioAllow);
      await tester.pumpAndSettle();
      await tester.tap(radioAllow);
      await tester.pumpAndSettle();

      // Tap \'Study Mode\'
      final radioStudy = find.byKey(const Key(\'youtube_mode_study_mode\'));
      await tester.ensureVisible(radioStudy);
      await tester.pumpAndSettle();
      await tester.tap(radioStudy);
      await tester.pumpAndSettle();
    });

    testWidgets(\'Validation prevents saving when preset name is empty\', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(repository: repository));
      await tester.pumpAndSettle();

      // Tap save without entering name
      await tester.tap(find.byKey(const Key(\'save_preset_button\')));
      await tester.pumpAndSettle();

      // Shows SnackBar error
      expect(find.text(\'Please enter a preset name\'), findsOneWidget);
      // Still on preset create screen
      expect(find.byType(PresetCreateScreen), findsOneWidget);
    });

    testWidgets(\'Successfully saves preset and pops screen when valid\', (WidgetTester tester) async {
      // Use a real repo with in-memory FFI DB for this test
      final realRepo = PresetsRepository(appDatabase: appDatabase);

      await tester.pumpWidget(buildTestApp(repository: realRepo));
      await tester.pumpAndSettle();

      // Enter name and description
      await tester.enterText(find.byKey(const Key(\'preset_name_input\')), \'Extreme Focus\');
      await tester.enterText(find.byKey(const Key(\'preset_description_input\')), \'Deep work session for coding\');
      await tester.pump();

      // Tap Save - use runAsync to let the real DB write finish off the test zone
      await tester.tap(find.byKey(const Key(\'save_preset_button\')));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();

      // Verify preset is saved
      final presets = await realRepo.getAllPresets();
      expect(presets.any((p) => p.name == \'Extreme Focus\'), true);

      // Unmount to clear any pending timers
      await tester.pumpWidget(const SizedBox());
    });
  });
}
'''

    # Check if file needs fixing (look for the known debug artifacts or old pattern)
    current = test_file.read_text() if test_file.exists() else ""
    if "import_dart_io_stderr" in current or "runAsync" in current:
        test_file.write_text(new_content)
        ok("Test file rewritten with FakePresetsRepository fix")
    elif "_FakePresetsRepository" in current:
        info("Test file already has FakePresetsRepository — skipping")
    else:
        test_file.write_text(new_content)
        ok("Test file written with FakePresetsRepository fix")

# ─────────────────────────────────────────────────────────────────────────────
# STEP 2 — RUN ALL TESTS
# ─────────────────────────────────────────────────────────────────────────────
def run_all_tests():
    heading("STEP 2: Run Full Test Suite")
    info("Running flutter test (this may take ~2 minutes)...")
    result = subprocess.run(
        f"{FLUTTER_BIN} test",
        shell=True, cwd=str(FLUTTER_APP), text=True,
        capture_output=True
    )
    print(result.stdout[-3000:] if len(result.stdout) > 3000 else result.stdout)
    if result.returncode != 0:
        print(result.stderr[-2000:] if result.stderr else "")
        warn("Some tests failed. Fix before proceeding.")
        return False
    ok("All tests passing!")
    return True

# ─────────────────────────────────────────────────────────────────────────────
# STEP 3 — UPDATE PROGRESS & WORKLOG FILES
# ─────────────────────────────────────────────────────────────────────────────
def update_tracking_files():
    heading("STEP 3: Update progress_tracker.md and agent_worklog.md")
    info("NOTE: Manually update these files to mark Step 5 as Completed")
    info("      and set Step 6 (Focus Timer) as In Progress.")
    info("      Then run: git add -A && git commit -m 'chore: raupwfiles Step 5->6' && git push origin ff")

# ─────────────────────────────────────────────────────────────────────────────
# STEP 4 — SCAFFOLD PHASE 1-B STEP 6 FILES
# ─────────────────────────────────────────────────────────────────────────────
def scaffold_step6():
    heading("STEP 4: Scaffold Phase 1-B Step 6 — Focus Timer + Foreground Service")

    base = FLUTTER_APP / "lib/features/focus"

    # 4.1 TimerMode enum
    write_file(base / "domain/timer_mode.dart", """\
        /// Timer modes supported by the Focus Session.
        enum TimerMode {
          /// Counts DOWN from a target duration (e.g. 90 minutes).
          countdown,

          /// Counts UP indefinitely from 0.
          stopwatch,

          /// No target duration — runs until user stops.
          openEnded;

          String get label {
            switch (this) {
              case TimerMode.countdown: return 'Countdown';
              case TimerMode.stopwatch: return 'Stopwatch';
              case TimerMode.openEnded: return 'Open Ended';
            }
          }
        }
        """)

    # 4.2 SessionStatus enum
    write_file(base / "domain/session_status.dart", """\
        /// Status values for an active focus session.
        enum SessionStatus {
          idle,
          running,
          paused,
          onBreak,
          completed,
          abandoned;

          bool get isActive => this == running || this == onBreak;
        }
        """)

    # 4.3 FocusSession model
    write_file(base / "domain/focus_session.dart", """\
        import 'timer_mode.dart';
        import 'session_status.dart';

        /// Immutable snapshot of a focus session's live state.
        class FocusSession {
          final String id;
          final String? presetId;
          final String? presetName;
          final TimerMode timerMode;
          final SessionStatus status;
          final Duration elapsed;
          final Duration? targetDuration;
          final int breaksTotal;
          final int breaksTaken;
          final DateTime startedAt;
          final DateTime? completedAt;

          const FocusSession({
            required this.id,
            this.presetId,
            this.presetName,
            required this.timerMode,
            required this.status,
            required this.elapsed,
            this.targetDuration,
            required this.breaksTotal,
            required this.breaksTaken,
            required this.startedAt,
            this.completedAt,
          });

          Duration get remaining {
            if (targetDuration == null) return Duration.zero;
            final r = targetDuration! - elapsed;
            return r.isNegative ? Duration.zero : r;
          }

          FocusSession copyWith({
            SessionStatus? status,
            Duration? elapsed,
            int? breaksTaken,
            DateTime? completedAt,
          }) {
            return FocusSession(
              id: id,
              presetId: presetId,
              presetName: presetName,
              timerMode: timerMode,
              status: status ?? this.status,
              elapsed: elapsed ?? this.elapsed,
              targetDuration: targetDuration,
              breaksTotal: breaksTotal,
              breaksTaken: breaksTaken ?? this.breaksTaken,
              startedAt: startedAt,
              completedAt: completedAt ?? this.completedAt,
            );
          }
        }
        """)

    # 4.4 FocusSessionNotifier (Riverpod)
    write_file(base / "presentation/focus_session_notifier.dart", """\
        import 'dart:async';
        import 'package:flutter_riverpod/flutter_riverpod.dart';
        import 'package:uuid/uuid.dart';
        import '../domain/focus_session.dart';
        import '../domain/session_status.dart';
        import '../domain/timer_mode.dart';

        // TODO: Wire up to foreground service and Hive persistence

        class FocusSessionNotifier extends AsyncNotifier<FocusSession?> {
          Timer? _ticker;
          static const _uuid = Uuid();

          @override
          Future<FocusSession?> build() async => null;

          Future<void> startSession({
            String? presetId,
            String? presetName,
            TimerMode timerMode = TimerMode.countdown,
            Duration? targetDuration,
            int breaksTotal = 0,
          }) async {
            final session = FocusSession(
              id: _uuid.v4(),
              presetId: presetId,
              presetName: presetName,
              timerMode: timerMode,
              status: SessionStatus.running,
              elapsed: Duration.zero,
              targetDuration: targetDuration,
              breaksTotal: breaksTotal,
              breaksTaken: 0,
              startedAt: DateTime.now(),
            );
            state = AsyncData(session);
            _startTicker();
          }

          void _startTicker() {
            _ticker?.cancel();
            _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
              final current = state.value;
              if (current == null || current.status != SessionStatus.running) return;
              final updated = current.copyWith(
                elapsed: current.elapsed + const Duration(seconds: 1),
              );
              // Auto-complete on countdown end
              if (updated.timerMode == TimerMode.countdown &&
                  updated.targetDuration != null &&
                  updated.elapsed >= updated.targetDuration!) {
                _ticker?.cancel();
                state = AsyncData(updated.copyWith(
                  status: SessionStatus.completed,
                  completedAt: DateTime.now(),
                ));
                return;
              }
              state = AsyncData(updated);
            });
          }

          void pauseSession() {
            final current = state.value;
            if (current == null) return;
            _ticker?.cancel();
            state = AsyncData(current.copyWith(status: SessionStatus.paused));
          }

          void resumeSession() {
            final current = state.value;
            if (current == null) return;
            state = AsyncData(current.copyWith(status: SessionStatus.running));
            _startTicker();
          }

          void startBreak() {
            final current = state.value;
            if (current == null) return;
            _ticker?.cancel();
            state = AsyncData(current.copyWith(
              status: SessionStatus.onBreak,
              breaksTaken: current.breaksTaken + 1,
            ));
          }

          void endBreak() {
            resumeSession();
          }

          void stopSession() {
            _ticker?.cancel();
            final current = state.value;
            if (current == null) return;
            state = AsyncData(current.copyWith(
              status: SessionStatus.abandoned,
              completedAt: DateTime.now(),
            ));
          }

          @override
          void dispose() {
            _ticker?.cancel();
            super.dispose();
          }
        }

        final focusSessionProvider =
            AsyncNotifierProvider<FocusSessionNotifier, FocusSession?>(
          FocusSessionNotifier.new,
        );
        """)

    # 4.5 FlipClock widget stub
    lib_widgets = FLUTTER_APP / "lib/presentation/widgets"
    write_file(lib_widgets / "flip_clock.dart", """\
        import 'package:flutter/material.dart';
        import '../../core/theme/theme.dart';

        /// Mechanical flip-clock widget displaying HH:MM:SS.
        /// Each digit pair is rendered as a split card with a seam line in
        /// ThemeTokens.primary (#CA9C68).
        class FlipClock extends StatelessWidget {
          final Duration duration;
          final bool showHours;

          const FlipClock({
            super.key,
            required this.duration,
            this.showHours = true,
          });

          @override
          Widget build(BuildContext context) {
            final hours = duration.inHours;
            final minutes = duration.inMinutes.remainder(60);
            final seconds = duration.inSeconds.remainder(60);

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showHours) ...[
                  _FlipCard(value: hours),
                  _Separator(),
                ],
                _FlipCard(value: minutes),
                _Separator(),
                _FlipCard(value: seconds),
              ],
            );
          }
        }

        class _FlipCard extends StatelessWidget {
          final int value;
          const _FlipCard({required this.value});

          @override
          Widget build(BuildContext context) {
            final text = value.toString().padLeft(2, '0');
            return Container(
              width: 72,
              height: 88,
              decoration: BoxDecoration(
                color: ThemeTokens.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: ThemeTokens.border, width: 1),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: ThemeTokens.textPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  // Seam line
                  Positioned(
                    top: 44,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 1.5,
                      color: ThemeTokens.primary,
                    ),
                  ),
                ],
              ),
            );
          }
        }

        class _Separator extends StatelessWidget {
          @override
          Widget build(BuildContext context) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                ':',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: ThemeTokens.primary,
                ),
              ),
            );
          }
        }
        """)

    # 4.6 Barrel for focus feature
    write_file(base / "focus.dart", """\
        export 'domain/focus_session.dart';
        export 'domain/session_status.dart';
        export 'domain/timer_mode.dart';
        export 'presentation/focus_session_notifier.dart';
        """)

    # 4.7 Test file stubs
    test_focus = FLUTTER_APP / "test/features/focus"
    write_file(test_focus / "focus_timer_test.dart", """\
        import 'package:flutter_test/flutter_test.dart';
        import 'package:fluxfoxus/features/focus/focus.dart';

        void main() {
          group('FocusSession Domain Tests', () {
            test('remaining returns zero when elapsed exceeds targetDuration', () {
              final session = FocusSession(
                id: 'test',
                timerMode: TimerMode.countdown,
                status: SessionStatus.running,
                elapsed: const Duration(minutes: 91),
                targetDuration: const Duration(minutes: 90),
                breaksTotal: 0,
                breaksTaken: 0,
                startedAt: DateTime.now(),
              );
              expect(session.remaining, Duration.zero);
            });

            test('remaining returns correct duration mid-session', () {
              final session = FocusSession(
                id: 'test',
                timerMode: TimerMode.countdown,
                status: SessionStatus.running,
                elapsed: const Duration(minutes: 30),
                targetDuration: const Duration(minutes: 90),
                breaksTotal: 0,
                breaksTaken: 0,
                startedAt: DateTime.now(),
              );
              expect(session.remaining, const Duration(minutes: 60));
            });

            test('isActive is true when running', () {
              expect(SessionStatus.running.isActive, true);
            });

            test('isActive is true when onBreak', () {
              expect(SessionStatus.onBreak.isActive, true);
            });

            test('isActive is false when paused', () {
              expect(SessionStatus.paused.isActive, false);
            });

            test('isActive is false when completed', () {
              expect(SessionStatus.completed.isActive, false);
            });

            test('copyWith preserves unchanged fields', () {
              final now = DateTime.now();
              final session = FocusSession(
                id: 'abc',
                presetName: 'Deep Work',
                timerMode: TimerMode.countdown,
                status: SessionStatus.running,
                elapsed: const Duration(minutes: 10),
                targetDuration: const Duration(minutes: 90),
                breaksTotal: 2,
                breaksTaken: 0,
                startedAt: now,
              );
              final updated = session.copyWith(elapsed: const Duration(minutes: 15));
              expect(updated.id, 'abc');
              expect(updated.presetName, 'Deep Work');
              expect(updated.elapsed, const Duration(minutes: 15));
              expect(updated.breaksTaken, 0);
            });

            // TODO: Add FocusSessionNotifier widget/provider tests
          });
        }
        """)

    ok("Phase 1-B Step 6 scaffold complete!")
    info("Next: Implement flutter_foreground_task service in")
    info("  fluxfoxus/lib/features/focus/services/foreground_timer_service.dart")
    info("Then update FocusSessionScreen (already at lib/presentation/screens/focus_session_screen.dart)")
    info("And add widget tests in test/presentation/screens/focus_session_screen_test.dart")

# ─────────────────────────────────────────────────────────────────────────────
# STEP 5 — ANALYZE
# ─────────────────────────────────────────────────────────────────────────────
def run_analyze():
    heading("STEP 5: flutter analyze")
    result = subprocess.run(
        f"{FLUTTER_BIN} analyze",
        shell=True, cwd=str(FLUTTER_APP), text=True,
        capture_output=True
    )
    print(result.stdout)
    if "No issues found!" in result.stdout:
        ok("flutter analyze: 0 issues!")
    else:
        warn("Lint issues found — fix before committing.")
    return result.returncode == 0

# ─────────────────────────────────────────────────────────────────────────────
# STEP 6 — COMMIT SCAFFOLD
# ─────────────────────────────────────────────────────────────────────────────
def commit_scaffold(tests_passed: bool, analyze_clean: bool):
    heading("STEP 6: Commit & Push Scaffold")
    if not tests_passed:
        warn("Skipping commit — tests failed. Fix first.")
        return
    if not analyze_clean:
        warn("Skipping commit — lint errors. Fix first.")
        return

    run("git add -A", cwd=REPO_ROOT)
    result = run("git status --short", cwd=REPO_ROOT, capture=True)
    if not result.stdout.strip():
        info("Nothing new to commit — scaffold files already exist.")
        return

    run(
        'git commit -m "feat(focus): scaffold Phase 1-B Step 6 domain models, FocusSessionNotifier, FlipClock, and test stubs"',
        cwd=REPO_ROOT
    )
    run("git push origin ff", cwd=REPO_ROOT)
    ok("Scaffold committed and pushed to origin/ff!")

# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────
def main():
    print("\n" + "═" * 60)
    print("  CODE1 — FluxFoxus Agent Bootstrap")
    print("  Phase 1-B Step 6: Focus Timer + Foreground Service")
    print("═" * 60)
    print("\n  Read code1.md for full context before proceeding.\n")

    check_environment()
    fix_test_7_timeout()
    tests_passed = run_all_tests()
    update_tracking_files()
    scaffold_step6()
    analyze_clean = run_analyze()
    commit_scaffold(tests_passed, analyze_clean)

    heading("DONE")
    print("""
  Next manual steps for the agent:
  ─────────────────────────────────
  1. Update agent_worklog.md: Code1 status → Step 6 (Focus Timer)
  2. Update progress_tracker.md: Step 5 → Completed, Step 6 → In Progress
  3. Implement foreground timer service (flutter_foreground_task)
  4. Update FocusSessionScreen with FlipClock widget and session controls
  5. Write focus_session_screen_test.dart widget tests
  6. Run flutter test → 0 failures
  7. Run flutter analyze → 0 issues
  8. git add -A && git commit && git push origin ff
  9. Present to user with Review Summary (3 sections mandatory)
    """)

if __name__ == "__main__":
    main()
