class AppDateUtils {
  int daysInMonth(int year, int month) {
    final beginningNextMonth =
        (month < 12) ? DateTime(year, month + 1, 1) : DateTime(year + 1, 1, 1);

    final lastDayOfMonth = beginningNextMonth.subtract(const Duration(days: 1));
    return lastDayOfMonth.day;
  }

  List<DateTime> last7Days() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      return now.subtract(Duration(days: i));
    }).reversed.toList();
  }

  static bool isTodayOrder(DateTime dateFilter, String createdDate) {
    final orderDate = DateTime.parse(createdDate);
    return (orderDate.year == dateFilter.year) &&
        (orderDate.month == dateFilter.month) &&
        (orderDate.day == dateFilter.day);
  }

  static bool isMonthOrder(DateTime dateFilter, String createdDate) {
    final orderDate = DateTime.parse(createdDate);
    return (orderDate.year == dateFilter.year) &&
        (orderDate.month == dateFilter.month);
  }

  static List<DateTime> getAllDaysInMonth(int year, int month) {
    int lastDay = DateTime(year, month + 1, 0).day;
    return List.generate(
      lastDay,
      (index) => DateTime(year, month, index + 1),
    );
  }

  static String getMonth(int month) {
    const months = [
      'Yanvar',
      'Fevral',
      'Mart',
      'Aprel',
      'May',
      'Iyun',
      'Iyul',
      'Avgust',
      'Sentabr',
      'Oktabr',
      'Noyabr',
      'Dekabr'
    ];
    return months[month - 1];
  }


  static List<DateTime> getDaysBetween(DateTime startDate, DateTime endDate) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    final days = <DateTime>[];

    for (var date = start;
    !date.isAfter(end);
    date = date.add(const Duration(days: 1))) {
      days.add(date);
    }

    return days;
  }

}
