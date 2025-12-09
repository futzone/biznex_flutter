import 'package:pocketbase/pocketbase.dart';

class OrdersService {
  final PocketBase pb;
  final String password;

  OrdersService(this.pb, this.password);

  Map<String, String> get _headers => {'password': password};

  Future<RecordModel> createOrder({
    String? id,
    required String clientId,
    required dynamic data,
    String? employeeId,
  }) async {
    final body = {
      if (id != null) 'id': id,
      'client_id': clientId,
      'data': data,
      'employee_id': employeeId,
    };

    return await pb.collection('orders').create(
          body: body,
          headers: _headers,
        );
  }

  Future<RecordModel> updateOrder(
    String id, {
    String? clientId,
    dynamic data,
    String? employeeId,
  }) async {
    final body = {
      if (clientId != null) 'client_id': clientId,
      if (data != null) 'data': data,
      if (employeeId != null) 'employee_id': employeeId,
    };

    return await pb.collection('orders').update(
          id,
          body: body,
          headers: _headers,
        );
  }

  Future<List<RecordModel>> getOrders({
    String? clientId,
    String? employeeId,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final filters = <String>[];

    if (clientId != null) filters.add('client_id = "$clientId"');
    if (employeeId != null) filters.add('employee_id = "$employeeId"');

    if (search != null && search.isNotEmpty) {
      filters.add('data ~ "%$search%"');
    }

    final filterQuery = filters.isEmpty ? null : filters.join(' && ');

    return (await pb.collection('orders').getList(
              page: page,
              perPage: pageSize,
              headers: _headers,
              filter: filterQuery,
            ))
        .items;
  }
}
