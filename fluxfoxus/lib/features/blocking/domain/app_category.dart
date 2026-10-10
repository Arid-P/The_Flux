/// App categories per TRD Section 3.3 and 5.2.
enum AppCategory {
  productive,
  semiProductive,
  distracting,
  others;

  String get label {
    switch (this) {
      case AppCategory.productive:
        return 'Productive';
      case AppCategory.semiProductive:
        return 'Semi-Productive';
      case AppCategory.distracting:
        return 'Distracting';
      case AppCategory.others:
        return 'Others';
    }
  }

  static AppCategory fromString(String value) {
    switch (value.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_')) {
      case 'productive':
        return AppCategory.productive;
      case 'semiproductive':
      case 'semi_productive':
        return AppCategory.semiProductive;
      case 'distracting':
        return AppCategory.distracting;
      default:
        return AppCategory.others;
    }
  }
}
