import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/http_exception/http_exception.dart';
import 'package:http/http.dart' as http; 

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future <void> getAndSetProducts() async {
    final url = Uri.parse('https://shop-application-2ab78-default-rtdb.firebaseio.com/products.json');
    try {
      
      final response = await http.get(url);
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) { 
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite: prodData['false']
          )
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future <void> addProduct(Product product) async {
    final url = await Uri.parse('https://shop-application-2ab78-default-rtdb.firebaseio.com/products.json');
    return http.post(url, body: json.encode({
      'title': product.title,
      'description': product.description,
      'imageUrl': product.imageUrl,
      'price': product.price,
      'isFavorite': product.isFavorite,
    }),).then((response) {
      print(response.body);
      final newProduct = Product(
      title: product.title,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      id: json.decode(response.body)['name'],
    );
    _items.add(newProduct);
      notifyListeners();
    });
    // _items.insert(0, newProduct); // at the start of the list
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = await Uri.parse('https://shop-application-2ab78-default-rtdb.firebaseio.com/products/$id.json');
      await http.patch(url, body: json.encode({
        'title': newProduct.title,
        'description': newProduct.description,
        'imageUrl': newProduct.imageUrl,
        'price': newProduct.price,
      }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async{
    // _items.removeWhere((prod) => prod.id == id);
    final url = await Uri.parse('https://shop-application-2ab78-default-rtdb.firebaseio.com/products/$id.json');
    // removing the products path cancels the optimistic updating
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id); // Looking for the index of the item we need to delete
    var existingProduct = _items[existingProductIndex]; // the item we deleted, remember dart deletes a something if it cannot find the variable attached to it, so we input a variable referencing it so dart does not delete it and we can call it again
    // this is optimistic updating because we re-add that product if we fail
  
    _items.removeAt(existingProductIndex);
    notifyListeners();  
    final response = await http.delete(url);
    // .then((response) {
      if (response.statusCode >= 400) {
        _items.insert(existingProductIndex, existingProduct); // inserting it back
        notifyListeners();
        throw HttpException('Something went wrong!');
      }
      existingProduct = null;

    // Status Codes
    // 200 201 - everything worked
    // 300 - We were redirected
    // 400 500 - Something went wrong
  }
}
