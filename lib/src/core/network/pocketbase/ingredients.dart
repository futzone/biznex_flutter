import 'package:pocketbase/pocketbase.dart';

class IngredientsService {
  final PocketBase pb;
  final String password;

  IngredientsService(this.pb, this.password);

  Map<String, String> get _headers => {'password': password};

  Future<RecordModel> createIngredient({
    String? id,
    required String name,
    num? price,
    num? amount,
    String? measure,
    required String clientId,
    required String localId,
  }) async {
    final body = {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      'amount': amount,
      'measure': measure,
      'client_id': clientId,
      'local_id': localId,
    };

    return await pb.collection('ingredients').create(
          body: body,
          headers: _headers,
        );
  }

  Future<RecordModel> updateIngredient(
    String id, {
    String? name,
    num? price,
    num? amount,
    String? measure,
    String? clientId,
  }) async {
    final body = {
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (amount != null) 'amount': amount,
      if (measure != null) 'measure': measure,
      if (clientId != null) 'client_id': clientId,
    };

    return await pb.collection('ingredients').update(
          id,
          body: body,
          headers: _headers,
        );
  }

  Future<List<RecordModel>> getIngredients({
    String? clientId,
    String? search,
  }) async {
    final filters = <String>[];

    if (clientId != null) filters.add('client_id = "$clientId"');
    if (search != null && search.isNotEmpty) {
      filters.add('name ~ "%$search%"');
    }

    final filterQuery = filters.isEmpty ? null : filters.join(' && ');

    return await pb.collection('ingredients').getFullList(
          headers: _headers,
          filter: filterQuery,
        );
  }
}
