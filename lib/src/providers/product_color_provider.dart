import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/product_params_database/product_color_database.dart';
import 'package:biznex/src/core/model/product_params_models/product_color.dart';

final FutureProvider<List<ProductColor>> productColorProvider = FutureProvider((ref) async {
  ProductColorDatabase sizeDatabase = ProductColorDatabase();
  final allProductInformationsList = await sizeDatabase.get();
  return allProductInformationsList;
});
