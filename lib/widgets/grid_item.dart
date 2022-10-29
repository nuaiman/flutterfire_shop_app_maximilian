import 'package:flutter/material.dart';
import 'package:flutterfire_shop_app_maximilian/models/auth.dart';
import 'package:provider/provider.dart';

import '../models/cart.dart';
import '../models/product.dart';

class GridItem extends StatelessWidget {
  const GridItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<ProductModel>(context);
    final authData = Provider.of<AuthProvider>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          leading: Consumer<CartProvider>(
            builder: (c, cart, _) => IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                cart.addItem(
                    product.id as String, product.title, product.price);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Item Added'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false)
                            .removeSingleItem(product.id as String);
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
            ),
          ),
          trailing: IconButton(
            onPressed: () {
              product.toggleFavoriteStatus(
                authData.token as String,
                authData.userId as String,
              );
            },
            icon: product.isFavorite
                ? const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  )
                : const Icon(
                    Icons.favorite_border,
                  ),
          ),
        ),
        child: Image.network(
          product.imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
