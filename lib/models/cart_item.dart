class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final Map<String, dynamic>? customizations;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
    this.customizations,
  });

  double get total => price * quantity;

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
    Map<String, dynamic>? customizations,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      customizations: customizations ?? this.customizations,
    );
  }
}
