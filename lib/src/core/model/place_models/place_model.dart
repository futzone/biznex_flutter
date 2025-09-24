import '../order_models/order.dart';

class Place {
  String name;
  String id;
  String? image;
  List<Place>? children;
  Place? father;
  bool percentNull;
  double? price;

  String updatedDate;

  Place({
    this.father,
    required this.name,
    this.image,
    this.children,
    this.id = '',
    this.percentNull = false,
    this.price,
    this.updatedDate = '',
  });

  factory Place.fromIsar(PlaceIsar isar, {bool includeFather = true}) {
    return Place(
      name: isar.name,
      id: isar.id,
      image: isar.image,
      percentNull: isar.percentNull,
      price: isar.price,
      children: isar.children
          ?.map((e) => Place.fromIsar(e, includeFather: false))
          .toList(),
      father: includeFather && isar.father != null
          ? Place.fromIsar(isar.father!, includeFather: false)
          : null,
    );
  }

  factory Place.fromJson(json, {dynamic fatherId}) {
    return Place(
      updatedDate: json['updatedDate'] ?? '',
      father: json['father'] == null ? null : Place.fromJson(json['father']),
      name: json['name'] ?? '',
      price: json['price'],
      id: json['id'] ?? '',
      image: json['image'],
      percentNull: json['percentNull'] ?? false,
      children: (json['children'] as List?)
          ?.map((mp) => Place.fromJson(mp, fatherId: json['id'] ?? ''))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'updatedDate':'updatedDate',
      'name': name,
      'price': price,
      'id': id,
      'image': image,
      'percentNull': percentNull,
      'children': children != null
          ? children!.map((mp) => mp.toJsonWithoutChildren()).toList()
          : [],
      'father': father?.toJsonWithoutChildren(),
    };
  }

  Map<String, dynamic> toJsonWithoutChildren() {
    return {
      'name': name,
      'price': price,
      'id': id,
      'image': image,
      'percentNull': percentNull,
      'father': father?.toJsonWithoutChildren(),
    };
  }
}
