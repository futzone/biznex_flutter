import 'dart:developer';

import 'package:biznex/src/core/model/cloud_models/client.dart';
import 'package:biznex/src/core/network/endpoints.dart';
import 'package:biznex/src/core/network/network_base.dart';
import 'package:dio/dio.dart';

class NetworkServices {
  final Network network = Network();

  Future<bool> createClient(Client client, String password) async {
    // final response = await network.post(
    //   skipPassword: true,
    //   ApiEndpoints.client,
    //   body: client.toJson(),
    //   password: password,
    // );

    try {
      final dio = Dio(BaseOptions(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'password': password,
      }));
      final response = await dio.post(ApiEndpoints.baseUrl + ApiEndpoints.client, data: client.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) return true;
      return false;
    } on DioException catch (e, st) {
      log("Error on client create: ${e.response?.data}", error: e, stackTrace: st);
      return false;
    }
  }

  Future<bool> updateClient(Client client) async {
    final response = await network.put(
      ApiEndpoints.client,
      body: client.toJson(),
    );
    return response;
  }

  Future<Client?> getClient(String id) async {
    final response = await network.get(ApiEndpoints.clientOne(id));
    if (response == null) return null;
    return Client.fromJson(response);
  }

  Future<bool> deleteClient(String id, String password) async {
    final response = await network.delete(ApiEndpoints.clientOne(id), password: password);
    return response;
  }
}
