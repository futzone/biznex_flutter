import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/category_database/category_database.dart';

final categoryProvider = FutureProvider((ref) async {
  CategoryDatabase categoryDatabase = CategoryDatabase();

  return await categoryDatabase.get();
});

final allCategoryProvider = FutureProvider((ref) async {
  CategoryDatabase categoryDatabase = CategoryDatabase();

  return await categoryDatabase.getAll();
});
