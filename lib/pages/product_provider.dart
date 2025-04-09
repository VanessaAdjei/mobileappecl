// product_provider.dart
import 'dart:convert';

import 'package:eclapp/pages/product_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ProductProvider with ChangeNotifier {
  List<ProductVariant> _products = [];
  bool _isLoading = false;
  String? _error;

  List<ProductVariant> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://eclcommerce.ernestchemists.com.gh/api/get-all-products'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['data'] != null) {
        _products = (responseData['data'] as List).map((json) {
          json['product'] ??= {
            'description': '',
            'thumbnail': '',
            'name': 'Unknown Product',
            'id': json['product_id'] ?? 0,
          };
          return ProductVariant.fromJson(json);
        }).toList();
        _error = null;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load products');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}