import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import 'grid_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavorites;
  const ProductsGrid({super.key, required this.showFavorites});

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final products = showFavorites
        ? productsProvider.favoriteProducts
        : productsProvider.products;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (c, i) => ChangeNotifierProvider.value(
        value: products[i],
        child: const GridItem(),
      ),
    );
  }
}
