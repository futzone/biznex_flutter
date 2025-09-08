import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/product_params_database/product_information_database.dart';
import 'package:biznex/src/core/model/product_params_models/product_info.dart';

final FutureProvider<List<ProductInfo>> productInformationProvider = FutureProvider((ref) async {
  ProductInformationDatabase productInformationDatabase = ProductInformationDatabase();
  final allProductInformationsList = await productInformationDatabase.get();
  return allProductInformationsList;
});
