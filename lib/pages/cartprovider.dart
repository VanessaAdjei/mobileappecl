

import 'package:flutter/foundation.dart';
import 'CartItem.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  List<CartItem> _purchasedItems = [];

  List<CartItem> get cartItems => _cartItems;
  List<CartItem> get purchasedItems => _purchasedItems;

  CartProvider() {
    _loadCart();
  }

  void addToCart(CartItem item) {
    int index = _cartItems.indexWhere((existingItem) => existingItem.id == item.id);
    if (index != -1) {
      _cartItems[index].updateQuantity(_cartItems[index].quantity + item.quantity);
    } else {
      _cartItems.add(item);
    }
    _saveCart(); // Save to SharedPreferences
    notifyListeners();
  }
  void purchaseItems() {
    _purchasedItems.addAll(_cartItems);
    _cartItems.clear();
    notifyListeners();
  }
  void removeFromCart(int index) {
    _cartItems.removeAt(index);
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    _cartItems[index].updateQuantity(newQuantity);
    _saveCart();
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _saveCart();
    notifyListeners();
  }

  double calculateTotal() {
    double total = 0;
    for (var item in _cartItems) {
      total += item.price * item.quantity;
    }
    return total;
  }

  double calculateSubtotal() {
    double subtotal = 0.0;
    for (var item in _cartItems) {
      subtotal += item.price* item.quantity;
    }
    return subtotal;
  }


  void _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(_cartItems.map((item) => item.toJson()).toList());
    await prefs.setString('cart', cartJson);
  }

  void _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('cart');
    if (cartJson != null) {
      final cartList = jsonDecode(cartJson) as List;
      _cartItems = cartList.map((item) => CartItem.fromJson(item)).toList();
      notifyListeners();
    }
  }
}