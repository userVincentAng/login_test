import 'package:latlong2/latlong.dart';
import 'cart_item.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String deliveryAddress;
  final LatLng deliveryLocation;
  final String paymentMethod;
  final String? deliveryNotes;
  final DateTime orderTime;
  final String status;

  const Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.deliveryAddress,
    required this.deliveryLocation,
    required this.paymentMethod,
    this.deliveryNotes,
    required this.orderTime,
    this.status = 'pending',
  });

  Order copyWith({
    String? id,
    List<CartItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    String? deliveryAddress,
    LatLng? deliveryLocation,
    String? paymentMethod,
    String? deliveryNotes,
    DateTime? orderTime,
    String? status,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      orderTime: orderTime ?? this.orderTime,
      status: status ?? this.status,
    );
  }
}
