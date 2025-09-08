class AppDateUtils {
  static bool isTodayOrder(DateTime dateFilter, String createdDate) {
    final orderDate = DateTime.parse(createdDate);
    return (orderDate.year == dateFilter.year) && (orderDate.month == dateFilter.month) && (orderDate.day == dateFilter.day);
  }

  static bool isMonthOrder(DateTime dateFilter, String createdDate) {
    final orderDate = DateTime.parse(createdDate);
    return (orderDate.year == dateFilter.year) && (orderDate.month == dateFilter.month);
  }

  static List<DateTime> getAllDaysInMonth(int year, int month) {
    int lastDay = DateTime(year, month + 1, 0).day;
    return List.generate(
      lastDay,
      (index) => DateTime(year, month, index + 1),
    );
  }

  static String getMonth(int month) {
    const months = ['Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun', 'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'];
    return months[month - 1];
  }
}
