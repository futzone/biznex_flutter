import 'dart:core';
import 'package:biznex/src/core/extensions/for_dynamic.dart';
import 'package:biznex/src/core/model/category_model/category_model.dart';
import 'package:biznex/src/core/model/product_params_models/product_info.dart';
import 'package:biznex/src/core/utils/product_utils.dart';
import '../order_models/order.dart';

class Product {
  String name;
  String? barcode;
  String? tagnumber;
  String? cratedDate;
  String? updatedDate;
  List<ProductInfo>? informations;
  String? description;
  List<String>? images;
  String? measure;
  String? color;
  String? colorCode;
  String? size;
  double price;
  double amount;
  double percent;
  String id;
  String? productId;
  List<Product>? variants;
  Category? category;

  Product({
    required this.name,
    required this.price,
    this.barcode,
    this.tagnumber,
    this.cratedDate,
    this.updatedDate,
    this.informations,
    this.description,
    this.images,
    this.measure,
    this.size,
    this.id = '',
    this.percent = 0,
    this.color,
    this.productId,
    this.amount = 1,
    this.colorCode,
    this.variants,
    this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'barcode': barcode ?? ProductUtils.newBarcode,
      'tagnumber': tagnumber ?? ProductUtils.newTagnumber,
      'cratedDate': cratedDate ?? DateTime.now().toIso8601String(),
      'updatedDate': updatedDate ?? DateTime.now().toIso8601String(),
      'informations': informations?.map((e) => e.toJson()).toList(),
      'description': description,
      'images': images,
      'measure': measure,
      'color': color,
      'colorCode': colorCode,
      'size': size,
      'price': price,
      'amount': amount,
      'percent': percent,
      'id': id.notNullOrEmpty(ProductUtils.generateID),
      'productId': productId,
      'variants': variants?.map((e) => e.toJson()).toList(),
      'category': category?.toJson(),
    };
  }

  factory Product.fromJson(json) {
    // if (json['name'].toString().contains("Kos")) log(json.toString()); // Keep if needed for debugging
    return Product(
      name: json['name'],
      barcode: json['barcode'],
      tagnumber: json['tagnumber'],
      cratedDate: json['cratedDate'],
      updatedDate: json['updatedDate'],
      informations: (json['informations'] as List<dynamic>?)
          ?.map((e) => ProductInfo.fromJson(e))
          .toList(),
      description: json['description'],
      images: json['images'] != null
          ? List<String>.from(json['images'].map((e) => e.toString()))
          : null,
      measure: json['measure'],
      color: json['color'],
      colorCode: json['colorCode'],
      size: json['size'],
      price: (json['price'] as num).toDouble(),
      amount: (json['amount'] as num? ?? 1.0).toDouble(),
      percent: (json['percent'] as num? ?? 0.0).toDouble(),
      id: json['id'] ?? '',
      productId: json['productId'],
      category:
          json['category'] == null ? null : Category.fromJson(json['category']),
      variants: (json['variants'] as List<dynamic>?)
          ?.map((e) => Product.fromJson(e))
          .toList(),
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
  }) {
    return Product(
      name: name ?? this.name,
      price: price ?? this.price,
      barcode: setBarcodeToNull == true ? null : barcode ?? this.barcode,
      tagnumber:
          setTagnumberToNull == true ? null : tagnumber ?? this.tagnumber,
      cratedDate:
          setCratedDateToNull == true ? null : cratedDate ?? this.cratedDate,
      updatedDate:
          setUpdatedDateToNull == true ? null : updatedDate ?? this.updatedDate,
      informations: setInformationsToNull == true
          ? null
          : informations ?? this.informations,
      description:
          setDescriptionToNull == true ? null : description ?? this.description,
      images: setImagesToNull == true ? null : images ?? this.images,
      measure: setMeasureToNull == true ? null : measure ?? this.measure,
      color: setColorToNull == true ? null : color ?? this.color,
      colorCode:
          setColorCodeToNull == true ? null : colorCode ?? this.colorCode,
      size: setSizeToNull == true ? null : size ?? this.size,
      id: id ?? this.id,
      percent: percent ?? this.percent,
      productId:
          setProductIdToNull == true ? null : productId ?? this.productId,
      amount: amount ?? this.amount,
      variants: setVariantsToNull == true ? null : variants ?? this.variants,
      category: setCategoryToNull == true ? null : category ?? this.category,
    );
  }

  factory Product.fromIsar(ProductIsar isar) {
    return Product(
      name: isar.name,
      barcode: isar.barcode,
      tagnumber: isar.tagnumber,
      cratedDate: isar.cratedDate,
      updatedDate: isar.updatedDate,
      informations:
          isar.informations?.map((e) => ProductInfo.fromIsar(e)).toList(),
      description: isar.description,
      images: isar.images?.toList(),
      measure: isar.measure,
      color: isar.color,
      colorCode: isar.colorCode,
      size: isar.size,
      price: isar.price,
      amount: isar.amount,
      percent: isar.percent,
      id: isar.id,
      productId: isar.productId,
      variants: isar.variants?.map((e) => Product.fromIsar(e)).toList(),
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
