import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/product_params_database/product_measure_database.dart';
import 'package:biznex/src/core/model/product_params_models/product_measure.dart';

final FutureProvider<List<ProductMeasure>> productMeasureProvider = FutureProvider((ref) async {
  ProductMeasureDatabase sizeDatabase = ProductMeasureDatabase();
  final allProductInformationsList = await sizeDatabase.get();
  return allProductInformationsList;
});
