import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/auth.dart';
import 'models/cart.dart';
import 'models/order.dart';
import 'models/product.dart';
import 'screens/auth_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/order_screen.dart';
import 'screens/product_form_screen.dart';
import 'screens/products_overview_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/user_products_screen.dart';

void main() {
  runApp(const MyShop());
}

class MyShop extends StatelessWidget {
  const MyShop({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        //
        ChangeNotifierProvider(create: (c) => AuthProvider()),
        //
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          create: (_) => ProductsProvider(null.toString(), [], null.toString()),
          update: (context, auth, previousState) => ProductsProvider(
            auth.token,
            previousState == null ? [] : previousState.products,
            auth.userId,
          ),
        ),
        //
        ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
          create: (_) => OrdersProvider(null.toString(), [], null.toString()),
          update: (context, auth, previousState) => OrdersProvider(
            auth.token,
            previousState == null ? [] : previousState.orders,
            auth.userId,
          ),
        ),
        //
        ChangeNotifierProvider(create: (c) => CartProvider()),
        //
      ],
      child: Consumer<AuthProvider>(
        builder: (c, authProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.deepPurple,
            ),
            home: authProvider.isAuth
                ? const ProductsOverviewScreen()
                : FutureBuilder(
                    future: authProvider.autoLogIn(),
                    builder: (c, s) =>
                        s.connectionState == ConnectionState.waiting
                            ? const SplashScreen()
                            : const AuthScreen(),
                  ),
            routes: {
              ProductsOverviewScreen.routeName: (c) =>
                  const ProductsOverviewScreen(),
              CartScreen.routeName: (c) => const CartScreen(),
              OrderScreen.routeName: (c) => const OrderScreen(),
              UserProductsScreen.routeName: (c) => const UserProductsScreen(),
              ProductFormScreen.routeName: (c) => const ProductFormScreen(),
              AuthScreen.routeName: (c) => const AuthScreen(),
            },
          );
        },
      ),
    );
  }
}
