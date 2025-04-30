import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import 'auth_service.dart';

class OrderService {
  static const String baseUrl = 'http://test.shoppazing.com/api/shop';

  Future<List<Order>> getMyOrders(String userId) async {
    try {
      print('DEBUG: Fetching orders for userId: $userId');
      final response = await http.post(
        Uri.parse('$baseUrl/downloadmyorders'),
        headers: AuthService.getAuthHeaders(),
        body: jsonEncode({
          'UserId': userId,
        }),
      );

      print('DEBUG: Orders API response status: ${response.statusCode}');
      print('DEBUG: Orders API response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Error fetching orders: $e');
      throw Exception('Error fetching orders: $e');
    }
  }

  Future<void> reorder(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reorder'),
        headers: AuthService.getAuthHeaders(),
        body: jsonEncode({
          'order_id': orderId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to reorder');
      }
    } catch (e) {
      throw Exception('Error processing reorder: $e');
    }
  }
}
