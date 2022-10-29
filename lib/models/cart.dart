import 'package:flutter/material.dart';

class CartModel {
  final String id;
  final String title;
  final double amount;
  final int quantity;
  CartModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.quantity,
  });
}

class CartProvider with ChangeNotifier {
  Map<String, CartModel> _items = {};

  Map<String, CartModel> get items => {..._items};

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, value) {
      total += value.amount * value.quantity;
    });
    return total;
  }

  int get itemCount {
    var total = 0;
    _items.forEach((key, value) {
      total += value.quantity;
    });
    return total;
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productID) {
    if (!_items.containsKey(productID)) {
      return;
    } else if (_items[productID]!.quantity > 1) {
      _items.update(
          productID,
          (value) => CartModel(
              id: value.id,
              title: value.title,
              amount: value.amount,
              quantity: value.quantity - 1));
    } else if (_items[productID]!.quantity == 1) {
      _items.remove(productID);
    }
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }

  void addItem(String productId, String title, double amount) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (value) => CartModel(
          id: value.id,
          title: value.title,
          amount: value.amount,
          quantity: value.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartModel(
          id: DateTime.now().toString(),
          title: title,
          amount: amount,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }
}
