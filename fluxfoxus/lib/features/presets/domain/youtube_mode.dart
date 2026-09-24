/// YouTube mode setting during a focus session per ui_preset.md Section 5.4.
enum YouTubeMode {
  block('block', 'Block completely'),
  allow('allow', 'Allow completely'),
  studyMode('study_mode', 'Study Mode');

  final String value;
  final String label;

  const YouTubeMode(this.value, this.label);

  static YouTubeMode fromString(String value) {
    switch (value) {
      case 'block':
        return YouTubeMode.block;
      case 'allow':
        return YouTubeMode.allow;
      case 'study_mode':
      default:
        return YouTubeMode.studyMode;
    }
  }
}
