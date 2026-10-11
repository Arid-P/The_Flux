import '../domain/app_category.dart';

/// Predefined category mappings for popular applications per PRD Step 12.
class DefaultAppCategories {
  static const Map<String, AppCategory> defaultMappings = {
    // Distracting
    'com.instagram.android': AppCategory.distracting,
    'com.google.android.youtube': AppCategory.distracting,
    'com.zhiliaoapp.musically': AppCategory.distracting,
    'com.ss.android.ugc.trill': AppCategory.distracting,
    'com.tiktok.android': AppCategory.distracting,
    'com.twitter.android': AppCategory.distracting,
    'com.facebook.katana': AppCategory.distracting,
    'com.facebook.orca': AppCategory.distracting,
    'com.snapchat.android': AppCategory.distracting,
    'com.reddit.frontpage': AppCategory.distracting,
    'com.netflix.mediaclient': AppCategory.distracting,
    'com.spotify.music': AppCategory.distracting,
    'com.discord': AppCategory.distracting,
    'com.pinterest': AppCategory.distracting,
    'tv.twitch.android.app': AppCategory.distracting,
    'com.amazon.mShop.android.shopping': AppCategory.distracting,

    // Productive
    'com.fluxfoxus.fluxfoxus': AppCategory.productive,
    'notion.id': AppCategory.productive,
    'com.todoist': AppCategory.productive,
    'com.google.android.apps.docs': AppCategory.productive,
    'com.google.android.apps.sheets': AppCategory.productive,
    'com.google.android.keep': AppCategory.productive,
    'com.duolingo': AppCategory.productive,
    'com.ichi2.anki': AppCategory.productive,
    'com.ticktick.task': AppCategory.productive,
    'com.github.android': AppCategory.productive,
    'org.coursera.android': AppCategory.productive,
    'org.khanacademy.android': AppCategory.productive,

    // Semi-Productive
    'com.google.android.gm': AppCategory.semiProductive,
    'com.google.android.apps.maps': AppCategory.semiProductive,
    'com.whatsapp': AppCategory.semiProductive,
    'org.telegram.messenger': AppCategory.semiProductive,
    'com.slack': AppCategory.semiProductive,
    'com.google.android.calendar': AppCategory.semiProductive,
    'com.microsoft.teams': AppCategory.semiProductive,
    'com.google.android.apps.messaging': AppCategory.semiProductive,
    'com.android.chrome': AppCategory.others,
  };

  /// Resolves the category for a given packageName, checking default dictionary.
  static AppCategory resolveCategory(String packageName) {
    return defaultMappings[packageName] ?? AppCategory.others;
  }
}
