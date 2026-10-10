# Navigation & Routing

> **Last Updated:** 2026-10-10
> **Source files:** `lib/core/navigation/app_router.dart`, `lib/core/navigation/app_routes.dart`

---

## Route Map

| Route Path | Screen | Type | Nav Bar Visible? |
|---|---|---|---|
| `/` | `HomeScreen` | Tab 0 (shell) | ✅ Yes |
| `/usage` | `UsageStatsScreen` | Tab 1 (shell) | ✅ Yes |
| `/focus` | `FocusStartScreen` | Tab 2 (shell) | ✅ Yes |
| `/planner` | `PlannerScreen` | Tab 3 (shell) | ✅ Yes |
| `/blocks` | `AppLimitsScreen` | Tab 4 (shell) | ✅ Yes |
| `/focus/session` | `FocusSessionScreen` | Root full-screen | ❌ No |
| `/planner/preset/create` | `PresetCreateScreen` | Root pushed | ❌ No |
| `/planner/preset/:id/edit` | `PresetEditScreen` | Root pushed | ❌ No |
| `/planner/preset/:id/channels` | `ChannelWhitelistScreen` | Root pushed | ❌ No |
| `/onboarding/permissions` | `PermissionsOnboardingFlowScreen` | Root pushed | ❌ No |
| `/onboarding/usage_stats_permission` | `UsageStatsPermissionScreen` | Root pushed | ❌ No |
| `/onboarding/accessibility_permission` | `AccessibilityPermissionScreen` | Root pushed | ❌ No |

---

## Bottom Navigation Bar Structure

**Widget:** `FloatingBottomNavBar` in `floating_bottom_nav_bar.dart`

| Tab Index | Icon | Label | Route |
|---|---|---|---|
| 0 | `ApertureIcon` (custom) | Home | `/` |
| 1 | Usage/screen icon | Usage | `/usage` |
| 2 | Focus/timer icon | Focus | `/focus` |
| 3 | Calendar icon | Planner | `/planner` |
| 4 | Block/shield icon | Block | `/blocks` |

**Pill grouping:**
- Left inner pill: [Usage (1) + Focus (2)]
- Center standalone: [Home (0)]
- Right inner pill: [Planner (3) + Block (4)]

**Styling:**
- Container: `ThemeTokens.surface` (`#2B2F2E`), border `ThemeTokens.border` (`#594C3D`), radius pill (28px)
- Active tab: `ThemeTokens.primary` (`#CA9C68`)
- Inactive tab: `ThemeTokens.textMuted` (`#94A3B8`)
- 16px horizontal margin from screen edges

---

## Full-Screen Takeover Logic

When navigating to `/focus/session`:
- Route is registered on `rootNavigatorKey` (not inside the shell)
- `ScaffoldWithNavBar` is not the parent → bottom nav bar is automatically absent
- On return from session (via `context.pop()` or `context.go('/')`), nav bar reappears

---

## GoRouter Provider

```dart
final routerProvider = Provider<GoRouter>((ref) {
  return createAppRouter();
});
```

Used in `main.dart`:
```dart
final router = ref.watch(routerProvider);
return MaterialApp.router(routerConfig: router);
```

---

## Helper Methods (AppRoutes)

```dart
AppRoutes.presetEditPath(presetId)     // '/planner/preset/$presetId/edit'
AppRoutes.presetChannelsPath(presetId) // '/planner/preset/$presetId/channels'
```
