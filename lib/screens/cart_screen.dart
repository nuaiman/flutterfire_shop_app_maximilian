import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart.dart';
import '../models/order.dart';
import '../widgets/cart_item.dart';
import 'order_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  static const routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final order = Provider.of<OrdersProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              child: Row(
                children: [
                  const Text('Total'),
                  const SizedBox(width: 10),
                  Chip(
                      label: Text('\$ ${cart.totalAmount.toStringAsFixed(2)}')),
                  const Spacer(),
                  OrderButton(cart: cart, order: order, navigator: navigator),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (c, i) => CartItem(
                productId: cart.items.keys.toList()[i],
                id: cart.items.values.toList()[i].id,
                title: cart.items.values.toList()[i].title,
                price: cart.items.values.toList()[i].amount,
                quantity: cart.items.values.toList()[i].quantity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
    required this.order,
    required this.navigator,
  }) : super(key: key);

  final CartProvider cart;
  final OrdersProvider order;
  final NavigatorState navigator;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : TextButton(
            onPressed: () async {
              if (widget.cart.items.isEmpty || _isLoading) {
                return;
              }
              setState(() {
                _isLoading = true;
              });
              await widget.order.addOrder(
                  widget.cart.items.values.toList(), widget.cart.totalAmount);

              widget.cart.clearCart();
              setState(() {
                _isLoading = false;
              });
              widget.navigator.pushReplacementNamed(OrderScreen.routeName);
            },
            child: const Text('Order Now'));
  }
}
