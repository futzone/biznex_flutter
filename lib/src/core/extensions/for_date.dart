extension DateTimeExtension on DateTime {
  bool get isToday {
    final dateFilter = DateTime.now();

    return (year == dateFilter.year) &&
        (month == dateFilter.month) &&
        (day == dateFilter.day);
  }
}
