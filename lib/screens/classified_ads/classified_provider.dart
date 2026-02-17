import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/classified_product_repository.dart';
import 'package:flutter/material.dart';

import 'classified_model.dart';
import 'package:http/http.dart' as http;

class MyClassifiedProvider with ChangeNotifier {
  final ClassifiedProductRepository _repository = ClassifiedProductRepository();
  List<ClassifiedProductModel> _products = [];
  bool _loading = false;
  String _errorMessage = '';
  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasNextPage = true;

  List<ClassifiedProductModel> get products => _products;
  bool get loading => _loading;
  String get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;

  Future<void> fetchProducts({int page = 1}) async {
    if (_loading) return;

    _loading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final productModel = await _repository.getMyClassifiedProducts(page);
      _products = productModel.data;
      _currentPage = productModel.meta.currentPage;
      _lastPage = productModel.meta.lastPage;
      _hasNextPage = _currentPage < _lastPage;
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void loadNextPage() {
    if (_hasNextPage) fetchProducts(page: _currentPage + 1);
  }

  void loadPreviousPage() {
    if (_currentPage > 1) fetchProducts(page: _currentPage - 1);
  }

  // Add this method in MyClassifiedProvider
  Future<void> deleteProduct(int productId) async {
    try {
      _loading = true;
      notifyListeners();

      final response =
          await _repository.getDeleteClassifiedProductResponse(productId);

      if (response.result == true) {
        // Remove the deleted product from the list if successful
        _products.removeWhere((product) => product.id == productId);
        _errorMessage = ''; // Clear any previous error message
      } else {
        _errorMessage = 'Failed to delete the product.';
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> changeProductStatus(int id, bool newStatus) async {
    try {
      _loading = true;
      notifyListeners();

      final response = await _repository
          .getStatusChangeClassifiedProductResponse(id, newStatus);

      if (response.result == true) {
        final int index = _products.indexWhere((product) => product.id == id);
        if (index != -1) {
          _products[index] = _products[index].copyWith(status: newStatus);
        }
        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to change the product status.';
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct(id, product) async {
    final String url = "${AppConfig.BASE_URL}/classified/update/$id";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "App-Language": app_language.$!,
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "Accept": "application/json",
          "system-key": AppConfig.system_key
        },
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 200) {
        // Update successful
        print('vvvvvvvvvvvvvvvvvvvvvvv${response.body}');
        notifyListeners();

        return true;
      } else {
        // Handle error
        throw Exception('Failed to update product: ${response.body}');
      }
    } catch (error) {
      throw Exception('Failed to update product: $error');
    }
  }
}
