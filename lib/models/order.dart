import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'cart.dart';

class OrderModel {
  final String id;
  final List<CartModel> items;
  final double amount;
  final DateTime date;
  OrderModel({
    required this.id,
    required this.items,
    required this.amount,
    required this.date,
  });
}

class OrdersProvider with ChangeNotifier {
  final String? authToken;
  final String? userId;
  OrdersProvider(this.authToken, this._orders, this.userId);

  List<OrderModel> _orders = [];

  List<OrderModel> get orders => [..._orders];

  Future<void> addOrder(List<CartModel> items, double amount) async {
    var params = {
      'auth': authToken,
    };
    final url = Uri.https(
      'dummy-project-7cd3a-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/orders/$userId.json',
      params,
    );
    final timeStamp = DateTime.now();

    final response = await http.post(
      url,
      body: json.encode({
        'amount': amount,
        'dateTime': timeStamp.toIso8601String(),
        'products': items
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.amount,
                })
            .toList(),
      }),
    );

    _orders.insert(
      0,
      OrderModel(
        id: json.decode(response.body)['name'],
        items: items,
        amount: amount,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    var params = {
      'auth': authToken,
    };
    final url = Uri.https(
      'dummy-project-7cd3a-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/orders/$userId.json',
      params,
    );
    final response = await http.get(url);

    final List<OrderModel> loadedOrders = [];
    Map<String, dynamic>? extractedData = json.decode(response.body);
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.insert(
          0,
          OrderModel(
            id: orderId,
            items: (orderData['products'] as List<dynamic>).map((item) {
              return CartModel(
                id: item['id'],
                title: item['title'],
                amount: double.parse(item['price'].toString()),
                quantity: item['quantity'],
              );
            }).toList(),
            amount: double.parse(orderData['amount'].toString()),
            date: DateTime.parse(
              orderData['dateTime'],
            ),
          ));
    });

    _orders = loadedOrders;
    notifyListeners();
  }

  void clearOrder() {
    _orders = [];
    notifyListeners();
  }
}
