import 'package:isar/isar.dart';

part 'order.g.dart';

@collection
class OrderIsar {
  static const String completed = "completed";
  static const String cancelled = "cancelled";
  static const String opened = "opened";
  static const String confirmed = "confirmed";

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, type: IndexType.hash)
  late String id;

  @Index(caseSensitive: false)
  late String createdDate;

  @Index(caseSensitive: false)
  String? updatedDate;

  @Index()
  String? status;

  @Index()
  bool closed = false;

  @Index(caseSensitive: false)
  String? scheduledDate;

  CustomerIsar? customer;
  late EmployeeIsar employee;

  double? realPrice;
  late double price;
  String? note;

  late PlaceIsar place;
  String? orderNumber;

  List<OrderItemIsar> products = [];
  List<PercentIsar> paymentTypes = [];
}

@embedded
class OrderItemIsar {
  ProductIsar? product;
  double amount = 0;
  String placeId = '';
}

@embedded
class PercentIsar {
  double amount = 0;
  String name = '';
}

@embedded
class CustomerIsar {
  String name = '';
  String phone = '';
  String id = '';
  DateTime? created;
  DateTime? updated;
  String? note;
  String? address;
}

@embedded
class EmployeeIsar {
  String id = '';
  String fullname = '';
  String createdDate = '';
  String? phone = '';
  String? description = '';
  String roleId = '';
  String roleName = '';
  String pincode = '';
}

@embedded
class PlaceIsar {
  String name = '';
  String id = '';
  String? image;
  List<PlaceIsar>? children;
  PlaceIsar? father;
  bool percentNull = false;
  double? price;
  double? percent;
}

@embedded
class ProductIsar {
  String name = '';
  String? barcode;
  String? tagnumber;
  String? cratedDate;
  String? updatedDate;
  List<ProductInfoIsar>? informations;
  String? description;
  List<String>? images;
  String? measure;
  String? color;
  String? colorCode;
  String? size;
  double price = 0;
  double amount = 0;
  double percent = 0;
  String id = '';
  String? productId;
  List<ProductIsar>? variants;
  CategoryIsar? category;
  bool unlimited = false;
}

@embedded
class ProductInfoIsar {
  String name = '';
  String data = '';
  String id = '';
}

@embedded
class CategoryIsar {
  String name = '';
  String id = '';
  String? parentId;
  String? printerParams;
  List<CategoryIsar>? subcategories;
  String? icon;
  int? index;
}
