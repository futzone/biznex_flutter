import 'package:pocketbase/pocketbase.dart';

class ProductsService {
  final PocketBase pb;
  final String password;

  ProductsService(this.pb, this.password);

  Map<String, String> get _headers => {'password': password};

  Future<RecordModel> createProduct({
    String? id,
    required String name,
    required String localId,
    String? measure,
    required num price,
    num? amount,
    num? oldPrice,
    required String clientId,
  }) async {
    final body = {
      if (id != null) 'id': id,
      'name': name,
      'measure': measure,
      'price': price,
      'amount': amount,
      'old_price': oldPrice,
      'client_id': clientId,
      'local_id': localId,
    };

    return await pb.collection('products').create(
          body: body,
          headers: _headers,
        );
  }

  Future<RecordModel> updateProduct(
    String id, {
    String? name,
    required String localId,
    String? measure,
    required num price,
    num? amount,
    num? oldPrice,
    required String clientId,
  }) async {
    final body = {
      'name': name,
      'measure': measure,
      'price': price,
      'amount': amount,
      'old_price': oldPrice,
      'client_id': clientId,
      'local_id': localId,
    };

    return await pb.collection('products').update(
      id,
      body: body,
      headers: _headers,
      query: {'filter': 'local_id = "$localId"'},
    );
  }

  Future<List<RecordModel>> getProducts({
    String? clientId,
    String? search,
  }) async {
    final filters = <String>[];

    if (clientId != null) filters.add('client_id = "$clientId"');
    if (search != null && search.isNotEmpty) {
      filters.add('name ~ "%$search%"');
    }

    final filterQuery = filters.isEmpty ? null : filters.join(' && ');

    return await pb.collection('products').getFullList(
          headers: _headers,
          filter: filterQuery,
        );
  }
}
