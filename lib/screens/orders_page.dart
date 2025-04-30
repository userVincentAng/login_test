import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrdersPage extends StatefulWidget {
  final String userId;

  const OrdersPage({Key? key, required this.userId}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderService _orderService = OrderService();
  List<Order> _allOrders = [];
  List<Order> _activeOrders = [];
  List<Order> _completedOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('DEBUG: OrdersPage initialized with userId: ${widget.userId}');
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      print('DEBUG: Loading orders for userId: ${widget.userId}');
      final orders = await _orderService.getMyOrders(widget.userId);
      print('DEBUG: Successfully loaded ${orders.length} orders');

      setState(() {
        _allOrders = orders;
        _activeOrders =
            orders.where((order) => order.orderStatus != 'completed').toList();
        _completedOrders =
            orders.where((order) => order.orderStatus == 'completed').toList();
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG: Error loading orders: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading orders: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(_activeOrders),
                _buildOrderList(_completedOrders, isCompleted: true),
              ],
            ),
    );
  }

  Widget _buildOrderList(List<Order> orders, {bool isCompleted = false}) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders found'));
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: order.storeImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.store),
                  ),
                ),
                title: Text(order.storeName),
                subtitle: Text(order.storeAddress),
                trailing: Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              _buildOrderStatusBar(order.orderStatus),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order PIN: ${order.orderPin}'),
                    const SizedBox(height: 8),
                    const Text('Items:'),
                    ...order.items.map((item) => ListTile(
                          dense: true,
                          leading: item.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: item.imageUrl!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                )
                              : null,
                          title: Text(item.name),
                          subtitle: Text('Quantity: ${item.quantity}'),
                          trailing: Text('\$${item.price.toStringAsFixed(2)}'),
                        )),
                  ],
                ),
              ),
              if (isCompleted) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _handleReorder(order),
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Reorder'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _handleReview(order),
                        icon: const Icon(Icons.star),
                        label: const Text('Review'),
                      ),
                    ],
                  ),
                ),
              ],
              if (order.riderId != null) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleChatRider(order),
                      icon: const Icon(Icons.chat),
                      label: const Text('Chat with Rider'),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderStatusBar(String status) {
    final List<String> statuses = [
      'pending',
      'preparing',
      'in-transit',
      'arrived',
      'completed'
    ];
    final currentIndex = statuses.indexOf(status.toLowerCase());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Status:'),
          const SizedBox(height: 8),
          Row(
            children: statuses.asMap().entries.map((entry) {
              final index = entry.key;
              final statusText = entry.value;
              final isCompleted = index <= currentIndex;

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? Colors.green : Colors.grey,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 10,
                        color: isCompleted ? Colors.green : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _handleReorder(Order order) async {
    try {
      await _orderService.reorder(order.orderId);
      // Navigate to cart page
      Navigator.pushNamed(context, '/cart');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing reorder: $e')),
      );
    }
  }

  void _handleReview(Order order) {
    // Navigate to review page
    Navigator.pushNamed(
      context,
      '/review',
      arguments: {'orderId': order.orderId, 'storeId': order.storeName},
    );
  }

  void _handleChatRider(Order order) {
    // Navigate to chat page
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {'riderId': order.riderId, 'orderId': order.orderId},
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
