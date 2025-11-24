import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/category_database/category_database.dart';

final categoryProvider = FutureProvider((ref) async {
  CategoryDatabase categoryDatabase = CategoryDatabase();

  final list = await categoryDatabase.get();
  list.sort((a, b) {
    final aIndex = a.index ?? 9999;
    final bIndex = b.index ?? 9999;
    return aIndex.compareTo(bIndex);
  });

  return list;
});

final allCategoryProvider = FutureProvider((ref) async {
  CategoryDatabase categoryDatabase = CategoryDatabase();

  return await categoryDatabase.getAll();
});
