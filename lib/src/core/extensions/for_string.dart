extension AppString on String {
  String get initials {
    final input = this;
    final words = input.trim().split(RegExp(r'\s+'));

    if (words.length >= 2) {
      return words[0][0].toUpperCase() + words[1][0].toUpperCase();
    } else if (words.length == 1 && words[0].length >= 2) {
      return words[0].substring(0, 2).toUpperCase();
    } else if (words[0].isNotEmpty) {
      return words[0][0].toUpperCase();
    } else {
      return "";
    }
  }
}
