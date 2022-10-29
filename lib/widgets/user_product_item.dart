import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../screens/product_form_screen.dart';

class UserProductItem extends StatelessWidget {
  final String productid;
  final String title;
  final String imageUrl;
  const UserProductItem({
    super.key,
    required this.productid,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(title),
        trailing: SizedBox(
          width: 100,
          child: Row(
            children: [
              IconButton(
                onPressed: () async {
                  try {
                    await Provider.of<ProductsProvider>(context, listen: false)
                        .removeItem(productid);
                  } catch (error) {
                    scaffoldMessenger.showSnackBar(const SnackBar(
                        content: Text(
                      'Deleting failed!',
                      textAlign: TextAlign.center,
                    )));
                  }
                },
                icon: const Icon(Icons.delete),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      ProductFormScreen.routeName,
                      arguments: productid,
                    );
                  },
                  icon: const Icon(Icons.edit)),
            ],
          ),
        ),
      ),
    );
  }
}
