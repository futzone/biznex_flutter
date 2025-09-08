extension NullEmptyChecker on String? {
  String notNullOrEmpty(String value) {
    if (toString() == "null" || toString().isEmpty) return value;
    return toString();
  }
}
