/// Standard predefined distracting applications per TRD §5.2 and GMP_FF_BUILD Step 12.
const List<String> defaultDistractingPackages = [
  'com.instagram.android',
  'com.zhiliaoapp.musically',
  'com.ss.android.ugc.trill',
  'com.twitter.android',
  'com.facebook.katana',
  'com.google.android.youtube',
  'com.reddit.frontpage',
  'com.snapchat.android',
  'tv.twitch.android',
  'com.netflix.mediaclient',
];

/// Checks whether a package name belongs to the predefined distracting list.
bool isDefaultDistractingPackage(String packageName) {
  return defaultDistractingPackages.contains(packageName);
}
