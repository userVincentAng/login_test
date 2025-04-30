import 'package:latlong2/latlong.dart';
import 'cart_item.dart';

class Order {
  final String orderId;
  final String storeName;
  final String storeAddress;
  final String storeImage;
  final double totalAmount;
  final String orderStatus;
  final String orderPin;
  final List<OrderItem> items;
  final DateTime orderDate;
  final String? riderId;

  Order({
    required this.orderId,
    required this.storeName,
    required this.storeAddress,
    required this.storeImage,
    required this.totalAmount,
    required this.orderStatus,
    required this.orderPin,
    required this.items,
    required this.orderDate,
    this.riderId,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'] ?? '',
      storeName: json['store_name'] ?? '',
      storeAddress: json['store_address'] ?? '',
      storeImage: json['store_image'] ?? '',
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      orderStatus: json['order_status'] ?? '',
      orderPin: json['order_pin'] ?? '',
      items: (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      orderDate:
          DateTime.parse(json['order_date'] ?? DateTime.now().toString()),
      riderId: json['rider_id'],
    );
  }
}

class OrderItem {
  final String itemId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;

  OrderItem({
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json['item_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 0,
      imageUrl: json['image_url'],
    );
  }
}
