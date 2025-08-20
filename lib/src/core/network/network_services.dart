import 'package:biznex/src/core/model/cloud_models/client.dart';
import 'package:biznex/src/core/network/endpoints.dart';
import 'package:biznex/src/core/network/network_base.dart';

class NetworkServices {
  final Network network = Network();

  Future<bool> createClient(Client client, String password) async {
    final response = await network.post(
      ApiEndpoints.client,
      body: client.toJson(),
      password: password,
    );
    return response;
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

  Future<bool> deleteClient(String id) async {
    final response = await network.delete(ApiEndpoints.clientOne(id));
    return response;
  }
}
