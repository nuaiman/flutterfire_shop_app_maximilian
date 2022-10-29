import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';
import 'product_form_screen.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({super.key});
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final products = Provider.of<ProductsProvider>(context).products;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(ProductFormScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (c, s) => s.connectionState == ConnectionState.waiting
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () => _refreshProducts(context),
                child: Consumer<ProductsProvider>(
                  builder: (c, productsProvider, _) => ListView.builder(
                    itemCount: productsProvider.products.length,
                    itemBuilder: (c, i) => UserProductItem(
                      productid: productsProvider.products[i].id as String,
                      title: productsProvider.products[i].title,
                      imageUrl: productsProvider.products[i].imageUrl,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
