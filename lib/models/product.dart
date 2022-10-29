import 'dart:convert';

import 'package:flutter/material.dart';
import 'http_exception.dart';
import 'package:http/http.dart' as http;

class ProductModel with ChangeNotifier {
  final String? id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavorite;
  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url = Uri.parse(
        'https://dummy-project-7cd3a-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$token');

    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );
      if (response.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
      }
    } catch (_) {}
  }
}

class ProductsProvider with ChangeNotifier {
  final String? authToken;
  final String? userId;
  ProductsProvider(this.authToken, this._products, this.userId);

  List<ProductModel> _products = [
    // ProductModel(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // ProductModel(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // ProductModel(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // ProductModel(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<ProductModel> get products => [..._products];

  List<ProductModel> get favoriteProducts {
    return _products.where((element) => element.isFavorite).toList();
  }

  ProductModel findById(String productId) {
    return _products.firstWhere((element) => element.id == productId);
  }

  Future<void> addProduct(ProductModel product) async {
    final url = Uri.parse(
        'https://dummy-project-7cd3a-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'publisherId': userId,
            // 'isFavorite': product.isFavorite,
          }));

      final newProduct = ProductModel(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        // isFavorite: product.isFavorite,
      );
      _products.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    Map<String, String> params = {};
    if (filterByUser) {
      params = {
        'auth': authToken.toString(),
        'orderBy': json.encode('publisherId'),
        'equalTo': json.encode(userId),
      };
    }
    if (filterByUser == false) {
      params = <String, String>{
        'auth': authToken.toString(),
      };
    }

    var url = Uri.https(
      'dummy-project-7cd3a-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/products.json',
      params,
    );
    try {
      final response = await http.get(url);
      final List<ProductModel> loadedList = [];
      Map<String, dynamic>? extractedData = json.decode(response.body);
      if (extractedData == null) {
        return;
      }
      //
      url = Uri.parse(
          'https://dummy-project-7cd3a-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      //
      extractedData.forEach((prodId, prodData) {
        loadedList.insert(
          0,
          ProductModel(
            id: prodId,
            title: prodData['title'] ?? '',
            description: prodData['description'],
            imageUrl: prodData['imageUrl'] ?? '',
            price: prodData['price'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false,
            // isFavorite: prodData['isFavorite']),
          ),
        );
      });
      _products = loadedList;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String productId, ProductModel product) async {
    final productIndex =
        _products.indexWhere((element) => element.id == productId);
    if (productIndex >= 0) {
      final url = Uri.parse(
          'https://dummy-project-7cd3a-default-rtdb.asia-southeast1.firebasedatabase.app/products/$productId.json?auth=$authToken');
      try {
        await http.patch(url,
            body: json.encode(
              {
                'title': product.title,
                'description': product.description,
                'imageUrl': product.imageUrl,
                'price': product.price,
                // 'isFavorite': product.isFavorite,
              },
            ));
        _products[productIndex] = product;
        notifyListeners();
      } catch (error) {
        rethrow;
      }
      // _products[productIndex] = product;
      // notifyListeners();
    }
  }

  Future<void> removeItem(String productId) async {
    final url = Uri.parse(
        'https://dummy-project-7cd3a-default-rtdb.asia-southeast1.firebasedatabase.app/products/$productId.json?auth=$authToken');

    final existingProductIndex =
        _products.indexWhere((element) => element.id == productId);
    ProductModel? existingProduct = _products[existingProductIndex];
    _products.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _products.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Couldnot delete Product');
    }
    existingProduct = null;
  }

  void clearProducts() {
    _products = [];
    notifyListeners();
  }
}
