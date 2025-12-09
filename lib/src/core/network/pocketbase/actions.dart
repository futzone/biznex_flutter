import 'package:pocketbase/pocketbase.dart';

class ActionService {
  final PocketBase pb;
  final String password;

  ActionService(this.pb, this.password);

  Map<String, String> get _headers => {
        'x-password': password,
      };

  Future<RecordModel> createAction({
    String? id,
    required String clientId,
    required String from,
    required String type,
    required dynamic data,
  }) async {
    final body = {
      if (id != null) 'id': id,
      'client_id': clientId,
      'from': from,
      'type': type,
      'data': data,
    };

    return await pb.collection('action').create(
          body: body,
          headers: _headers,
        );
  }

  Future<RecordModel> updateAction(
    String id, {
    String? clientId,
    String? from,
    String? type,
    dynamic data,
  }) async {
    final body = {
      if (clientId != null) 'client_id': clientId,
      if (from != null) 'from': from,
      if (type != null) 'type': type,
      if (data != null) 'data': data,
    };

    return await pb.collection('action').update(
          id,
          body: body,
          headers: _headers,
        );
  }

  Future<List<RecordModel>> getActions({
    required String date,
    String? clientId,
    String? from,
    String? type,
  }) async {
    final filters = <String>[
      'created >= "$date 00:00:00"',
      'created <= "$date 23:59:59"',
    ];

    if (clientId != null) filters.add('client_id = "$clientId"');
    if (from != null) filters.add('from = "$from"');
    if (type != null) filters.add('type = "$type"');

    final filterQuery = filters.join(' && ');

    return await pb.collection('action').getFullList(
          headers: _headers,
          filter: filterQuery,
        );
  }
}
