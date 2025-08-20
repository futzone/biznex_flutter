import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/product_params_database/product_size_database.dart';
import 'package:biznex/src/core/model/product_params_models/product_size.dart';

final FutureProvider<List<ProductSize>> productSizeProvider = FutureProvider((ref) async {
  ProductSizeDatabase sizeDatabase = ProductSizeDatabase();
  final allProductInformationsList = await sizeDatabase.get();
  return allProductInformationsList;
});
