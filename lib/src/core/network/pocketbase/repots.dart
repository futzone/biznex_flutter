import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:pocketbase/pocketbase.dart';

class ReportsService {
  final PocketBase pb;
  final String password;

  ReportsService(this.pb, this.password);

  Map<String, String> get _headers => {'password': password};

  Future updateReport({
    required String clientId,
    required num totalOrders,
    required num ordersCount,
    num? productsProfit,
    num? placesProfit,
    num? percentsProfit,
    num? totalShopping,
    num? employees,
    num? products,
    num? ingredients,
    num? transactions,
    dynamic weekly,
  }) async {
    final now = DateTime.now();
    final date = DateFormat("yyyy-MM-dd").format(now);
    final body = {
      'client_id': clientId,
      'total_orders': totalOrders,
      'orders_count': ordersCount,
      if (productsProfit != null) 'products_profit': productsProfit,
      if (placesProfit != null) 'places_profit': placesProfit,
      if (percentsProfit != null) 'percents_profit': percentsProfit,
      if (totalShopping != null) 'total_shopping': totalShopping,
      if (employees != null) 'employees': employees,
      if (products != null) 'products': products,
      if (ingredients != null) 'ingredients': ingredients,
      if (transactions != null) 'transactions': transactions,
      if (weekly != null) 'weekly': weekly,
    };

    try {
      final old = await pb.collection('reports').getList(
        query: {
          'filter':
              'client_id = "$clientId" && created >= "$date 00:00:00" && created <= "$date 23:59:59"',
        },
        headers: _headers,
      );

      if (old.items.firstOrNull != null) {
        await pb.collection('reports').update(
          old.items.first.id,
          body: body,
          headers: _headers,
          query: {
            'filter':
                'created >= "$date 00:00:00" && created <= "$date 23:59:59"',
          },
        );
      } else {
        final body = {
          'client_id': clientId,
          'total_orders': totalOrders,
          'orders_count': ordersCount.toInt(),
          'products_profit': productsProfit,
          'places_profit': placesProfit,
          'percents_profit': percentsProfit,
          'total_shopping': totalShopping,
          'employees': employees,
          'products': products,
          'ingredients': ingredients,
          'transactions': transactions,
          'weekly': weekly,
        };

        return await pb.collection('reports').create(
              body: body,
              headers: _headers,
            );
      }
    } catch (error) {
      log("Error on update report", error: error);
      final body = {
        'client_id': clientId,
        'total_orders': totalOrders,
        'orders_count': ordersCount.toInt(),
        'products_profit': productsProfit,
        'places_profit': placesProfit,
        'percents_profit': percentsProfit,
        'total_shopping': totalShopping,
        'employees': employees,
        'products': products,
        'ingredients': ingredients,
        'transactions': transactions,
        'weekly': weekly,
      };

      return await pb.collection('reports').create(
            body: body,
            headers: _headers,
          );
    }
  }

  Future<List<RecordModel>> getReports({
    required String date,
    String? clientId,
  }) async {
    final filter = [
      'created >= "$date 00:00:00"',
      'created <= "$date 23:59:59"',
      if (clientId != null) 'client_id = "$clientId"',
    ].join(' && ');

    return await pb.collection('reports').getFullList(
          headers: _headers,
          filter: filter,
        );
  }
}
