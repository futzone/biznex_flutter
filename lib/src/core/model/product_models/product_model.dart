import 'dart:core';
import 'package:biznex/src/core/extensions/for_dynamic.dart';
import 'package:biznex/src/core/model/category_model/category_model.dart';
import 'package:biznex/src/core/model/product_params_models/product_info.dart';
import 'package:biznex/src/core/utils/product_utils.dart';
import '../order_models/order.dart';

class Product {
  static const String version = "1.0.0";

  String name;

  String? cratedDate;
  String? updatedDate;

  String? description;
  List<String>? images;
  String? oldImage;
  String? measure;
  String? color;

  String? size;
  double price;
  double amount;
  double percent;
  String id;
  String? productId;

  Category? category;
  bool unlimited;

  Product({
    this.unlimited = false,
    required this.name,
    required this.price,
    this.cratedDate,
    this.updatedDate,
    this.description,
    this.images,
    this.measure,
    this.size,
    this.id = '',
    this.percent = 0,
    this.color,
    this.productId,
    this.amount = 1,
    this.category,
    this.oldImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cratedDate': cratedDate ?? DateTime.now().toIso8601String(),
      'updatedDate': updatedDate ?? DateTime.now().toIso8601String(),
      'description': description,
      'images': images,
      'measure': measure,
      'color': color,
      'size': size,
      'price': price,
      'amount': amount,
      'percent': percent,
      'id': id.notNullOrEmpty(ProductUtils.generateID),
      'productId': productId,
      'category': category?.toJson(),
      'unlimited': unlimited,
      'oldImage': oldImage,
    };
  }

  factory Product.fromJson(json) {
    double safeDouble(num? value, {double fallback = 0.0}) {
      if (value == null) return fallback;
      final d = value.toDouble();
      if (d.isNaN || d.isInfinite) return fallback;
      return d;
    }

    return Product(
      unlimited: json['unlimited'] ?? false,
      name: json['name'],
      cratedDate: json['cratedDate'],
      updatedDate: json['updatedDate'],
      description: json['description'],
      images: json['images'] != null
          ? List<String>.from(json['images'].map((e) => e.toString()))
          : null,
      measure: json['measure'],
      color: json['color'],
      size: json['size'],
      price: safeDouble(json['price'], fallback: 0.0),
      amount: safeDouble(json['amount'], fallback: 1.0),
      percent: safeDouble(json['percent'], fallback: 0.0),
      id: json['id'] ?? '',
      oldImage: json['oldImage'],
      productId: json['productId'],
      category:
          json['category'] == null ? null : Category.fromJson(json['category']),
    );
  }

  Product copyWith({
    String? name,
    String? barcode,
    String? tagnumber,
    String? cratedDate,
    String? updatedDate,
    List<ProductInfo>? informations,
    String? description,
    List<String>? images,
    String? measure,
    String? color,
    String? colorCode,
    String? size,
    double? price,
    double? amount,
    double? percent,
    String? id,
    bool? unlimited,
    String? productId,
    List<Product>? variants,
    Category? category,
    bool? setBarcodeToNull,
    bool? setTagnumberToNull,
    bool? setCratedDateToNull,
    bool? setUpdatedDateToNull,
    bool? setInformationsToNull,
    bool? setDescriptionToNull,
    bool? setImagesToNull,
    bool? setMeasureToNull,
    bool? setColorToNull,
    bool? setColorCodeToNull,
    bool? setSizeToNull,
    bool? setProductIdToNull,
    bool? setVariantsToNull,
    bool? setCategoryToNull,
    String? oldImage,
  }) {
    return Product(
      name: name ?? this.name,
      price: price ?? this.price,
      cratedDate:
          setCratedDateToNull == true ? null : cratedDate ?? this.cratedDate,
      updatedDate:
          setUpdatedDateToNull == true ? null : updatedDate ?? this.updatedDate,
      description:
          setDescriptionToNull == true ? null : description ?? this.description,
      images: setImagesToNull == true ? null : images ?? this.images,
      measure: setMeasureToNull == true ? null : measure ?? this.measure,
      color: setColorToNull == true ? null : color ?? this.color,
      size: setSizeToNull == true ? null : size ?? this.size,
      id: id ?? this.id,
      percent: percent ?? this.percent,
      productId:
          setProductIdToNull == true ? null : productId ?? this.productId,
      amount: amount ?? this.amount,
      category: setCategoryToNull == true ? null : category ?? this.category,
      unlimited: unlimited ?? this.unlimited,
      oldImage: oldImage ?? this.oldImage,
    );
  }

  factory Product.fromIsar(ProductIsar isar) {
    // log("fromIsar: ${isar.unlimited}");
    return Product(
      name: isar.name,
      unlimited: isar.unlimited,
      cratedDate: isar.cratedDate,
      updatedDate: isar.updatedDate,
      description: isar.description,
      images: isar.images?.toList(),
      measure: isar.measure,
      color: isar.color,
      size: isar.size,
      price: isar.price,
      amount: isar.amount,
      percent: isar.percent,
      id: isar.id,
      productId: isar.productId,
      category:
          isar.category != null ? Category.fromIsar(isar.category!) : null,
    );
  }
}

class CloudProduct {
  String id;
  String clientId;
  String name;
  String categoryName;
  String createdAt;
  String updatedAt;
  num price;
  num oldPrice;
  num amount;

  CloudProduct({
    this.id = '',
    this.clientId = '',
    this.name = '',
    this.categoryName = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.price = 0,
    this.oldPrice = 0,
    this.amount = 0,
  });

  factory CloudProduct.fromJson(Map<String, dynamic> json) {
    return CloudProduct(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      name: json['name'] ?? '',
      categoryName: json['category_name'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      price: json['price'] ?? 0,
      oldPrice: json['old_price'] ?? 0,
      amount: json['amount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'name': name,
      'category_name': categoryName,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'price': price,
      'old_price': oldPrice,
      'amount': amount,
    };
  }
}
