import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';

class OrderItem extends StatefulWidget {
  final OrderModel orderItem;
  const OrderItem({
    super.key,
    required this.orderItem,
  });

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('\$ ${widget.orderItem.amount}'),
            subtitle: Text(DateFormat.yMMMMd().format(widget.orderItem.date)),
            trailing: IconButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                icon:
                    Icon(_isExpanded ? Icons.expand_less : Icons.expand_more)),
          ),
          if (_isExpanded)
            SizedBox(
              height: min(widget.orderItem.items.length * 20 + 100, 180),
              child: SingleChildScrollView(
                child: Column(
                  children: widget.orderItem.items.map((prod) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                            child:
                                FittedBox(child: Text('x ${prod.quantity}'))),
                        title: Text(prod.title),
                        subtitle: Text(
                          '\$ ${(prod.quantity * prod.amount).toStringAsFixed(2)}',
                        ),
                        trailing: Text('\$ ${prod.amount}'),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
