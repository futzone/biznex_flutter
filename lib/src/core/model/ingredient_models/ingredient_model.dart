import 'package:isar/isar.dart';
import '../order_models/order.dart';
part 'ingredient_model.g.dart';


@collection
class IngredientTransaction {
  Id isarId = Isar.autoIncrement;
  late String id;
  late String createdDate;
  late String updatedDate;
  late double amount;
  late ProductIsar product;
  late bool? fromShopping;
}