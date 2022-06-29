import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    this.id,
    this.amount,
    this.products,
    this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://shop-application-2ab78-default-rtdb.firebaseio.com/orders.json');
    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'cartProducts': cartProducts.map((e) {
            return {
              'id': e.id,
              'title': e.title,
              'quantity': e.quantity,
              'price': e.price
            };
          }).toList()
        }));
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: timeStamp,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }

  Future<void> fetchandSetOrder() async {
    final url = Uri.parse(
        'https://shop-application-2ab78-default-rtdb.firebaseio.com/orders.json');
    final response = await http.get(url);
    final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
    final List<OrderItem> loadedOrders = [];
    extractedData.forEach((OrderId, orderData) {
      loadedOrders.add(OrderItem(
        amount: orderData['amount'],
        dateTime: DateTime.parse(orderData['dateTime']),
        id: OrderId,
        products: (orderData['cartProducts'] as List<dynamic>).map((e) {
          return CartItem(
            id: e['id'],
            title: e['title'],
            quantity: e['quantity'],
            price: e['price'],
          );
        }).toList(),
      ));
    });
    _orders = loadedOrders;
    notifyListeners();
  }
}
