import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/http_exception.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [];

  // var _showFavoritesOnly = false;
  final String authToken;
  final String userId;
  ProductsProvider(this.authToken, this.userId, this._products);

  List<Product> get products {
    // if (_showFavoritesOnly) {
    //   return _products.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._products];
  }

  List<Product> get favoritesProducts {
    return _products.where((product) => product.isFavorite).toList();
  }

  Product findById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url = 'https://flutter-shop-8e151.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return;
      final favUrl = 'https://flutter-shop-8e151.firebaseio.com/userFavorites/$userId.json?auth=$authToken';

      final favoriteResponse = await http.get(favUrl);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((id, data) => {
            loadedProducts.add(Product(
                id: id,
                title: data['title'],
                description: data['description'],
                price: data['price'],
                isFavorite: favoriteData == null ? false : favoriteData[id] ?? false,
                imageUrl: data['imageUrl']))
          });
      _products = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = 'https://flutter-shop-8e151.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          },
        ),
      );
      final id = json.decode(response.body)['name'];
      final newProduct = Product(
        id: id,
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
      );
      _products.add(newProduct);

      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _products.indexWhere((product) => product.id == id);
    if (productIndex >= 0) {
      final url = 'https://flutter-shop-8e151.firebaseio.com/products/$id.json?auth=$authToken';
      try {
        await http.patch(
          url,
          body: json.encode(
            {
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
              'price': newProduct.price
            },
          ),
        );
        _products[productIndex] = newProduct;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    } else {
      print('...somethin gwnet wrong');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = 'https://flutter-shop-8e151.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex =
        _products.indexWhere((product) => product.id == id);
    var existingProduct = _products[existingProductIndex];
    _products.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _products.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete');
    }
    existingProduct = null;
  }
}
