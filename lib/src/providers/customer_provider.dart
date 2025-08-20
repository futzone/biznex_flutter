import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/customer_database/customer_database.dart';
import 'package:biznex/src/core/model/other_models/customer_model.dart';

final FutureProvider<List<Customer>> customerProvider = FutureProvider((ref) async {
  CustomerDatabase customerDatabase = CustomerDatabase();
  return await customerDatabase.get();
});
