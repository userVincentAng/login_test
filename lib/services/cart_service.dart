import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final int storeId;
  final int itemId;
  final String name;
  final double price;
  final int quantity;
  final Map<String, dynamic>? selectedOptions;
  final String? notes;

  CartItem({
    required this.storeId,
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.selectedOptions,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'storeId': storeId,
      'itemId': itemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'selectedOptions': selectedOptions,
      'notes': notes,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      storeId: json['storeId'],
      itemId: json['itemId'],
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
      selectedOptions: json['selectedOptions'],
      notes: json['notes'],
    );
  }
}

class CartService {
  static const String _cartKey = 'cart_items';
  static final CartService _instance = CartService._internal();
  final List<CartItem> _items = [];

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    if (cartJson != null) {
      final List<dynamic> decoded = jsonDecode(cartJson);
      _items.clear();
      _items.addAll(decoded.map((item) => CartItem.fromJson(item)));
    }
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(_items.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey, cartJson);
  }

  Future<void> addItem(CartItem item) async {
    _items.add(item);
    await saveCart();
  }

  Future<void> removeItem(int index) async {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      await saveCart();
    }
  }

  Future<void> updateQuantity(int index, int newQuantity) async {
    if (index >= 0 && index < _items.length && newQuantity > 0) {
      final item = _items[index];
      _items[index] = CartItem(
        storeId: item.storeId,
        itemId: item.itemId,
        name: item.name,
        price: item.price,
        quantity: newQuantity,
        selectedOptions: item.selectedOptions,
        notes: item.notes,
      );
      await saveCart();
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    await saveCart();
  }

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }
}
