import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:provider/provider.dart';

import '../models/cart.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';
import 'cart_screen.dart';

enum FilterOptions {
  all,
  favorites,
}

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({super.key});
  static const routeName = '/products-overview';

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showFavorites = false;
  var _isInIt = true;
  var isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      setState(() {
        isLoading = true;
      });
      Provider.of<ProductsProvider>(context).fetchAndSetProducts().then((_) {
        setState(() {
          isLoading = false;
        });
      });
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('MyShop'),
        actions: isLoading
            ? []
            : [
                Consumer<CartProvider>(
                  builder: (c, cart, ch) => Badge(
                    value: cart.itemCount.toString(),
                    child: ch as Widget,
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(CartScreen.routeName);
                    },
                    icon: const Icon(Icons.shopping_bag),
                  ),
                ),
                PopupMenuButton(
                  onSelected: (FilterOptions value) {
                    setState(() {
                      if (value == FilterOptions.all) {
                        _showFavorites = false;
                      }
                      if (value == FilterOptions.favorites) {
                        _showFavorites = true;
                      }
                    });
                  },
                  itemBuilder: (c) => [
                    const PopupMenuItem(
                      value: FilterOptions.all,
                      child: Text('All'),
                    ),
                    const PopupMenuItem(
                      value: FilterOptions.favorites,
                      child: Text('Favorites'),
                    ),
                  ],
                ),
              ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(
              showFavorites: _showFavorites,
            ),
    );
  }
}
