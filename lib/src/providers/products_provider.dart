import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/helper/services/api_services.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/providers/employee_provider.dart';

final FutureProvider<List<Product>> productsProvider = FutureProvider<List<Product>>((ref) async {
  // if (!ref.watch(serverAppProvider)) {
  //   final List<Product> products = [];
  //   final HelperApiServices apiServices = HelperApiServices();
  //   final response = await apiServices.getProducts(ref.watch(currentEmployeeProvider).pincode);
  //   if (response.statusCode == 200) {
  //     for (final item in response.data) {
  //       log((item is String).toString());
  //       products.add(Product.fromJson(item));
  //     }
  //   }
  //
  //   return products;
  // }

  ProductDatabase productDatabase = ProductDatabase();
  final list = await productDatabase.get();

  list.sort((a, b) {
    final dateA = DateTime.parse(a.cratedDate ?? DateTime.now().toIso8601String());
    final dateB = DateTime.parse(b.updatedDate ?? DateTime.now().toIso8601String());
    return dateB.compareTo(dateA);
  });

  return list;
});
