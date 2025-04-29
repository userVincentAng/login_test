import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'services/cart_service.dart';
import 'saved_addresses_page.dart';
import 'widgets/shimmer_widget.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartService _cartService = CartService();
  String _selectedPaymentMethod = 'Cash on Delivery';
  String? _selectedAddress;
  LatLng? _selectedCoordinates;
  final List<String> _paymentMethods = [
    'Cash on Delivery',
    'Credit Card',
    'Debit Card',
    'GCash',
    'Maya'
  ];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Simulate loading data
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: _isLoading
          ? _buildShimmerCheckout()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Delivery Address Section
                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SavedAddressesPage(
                                onAddressSelected: (latLng, address, floorUnit,
                                    instructions, label) async {
                                  setState(() {
                                    _selectedAddress = address;
                                    _selectedCoordinates = latLng;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: _selectedAddress != null
                                        ? const Color(0xFF5D8AA8)
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedAddress ??
                                          'Select Delivery Address',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedAddress != null
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: _selectedAddress != null
                                        ? const Color(0xFF5D8AA8)
                                        : Colors.grey,
                                  ),
                                ],
                              ),
                              if (_selectedAddress != null) ...[
                                const SizedBox(height: 8),
                                const Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Estimated Delivery Time:',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '30-45 mins',
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Order Summary Section
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _cartService.items.length,
                            itemBuilder: (context, index) {
                              final item = _cartService.items[index];
                              return ListTile(
                                title: Text(item.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item.selectedOptions != null) ...[
                                      if (item.selectedOptions!['variant'] !=
                                          null)
                                        Text(
                                            'Size: ${item.selectedOptions!['variant']['CombiName']}'),
                                      if (item.selectedOptions!['addOns'] !=
                                              null &&
                                          (item.selectedOptions!['addOns']
                                                  as List)
                                              .isNotEmpty)
                                        Text(
                                            'Add-ons: ${(item.selectedOptions!['addOns'] as List).map((a) => a['Name']).join(', ')}'),
                                    ],
                                  ],
                                ),
                                trailing: Text(
                                  '₱${(item.price * item.quantity).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildPriceRow(
                                    'Subtotal', _cartService.totalPrice),
                                _buildPriceRow('Delivery Fee', 50.00),
                                if (_selectedPaymentMethod !=
                                    'Cash on Delivery')
                                  _buildPriceRow('Handling Fee', 15.00),
                                const Divider(),
                                _buildPriceRow(
                                  'Total',
                                  _cartService.totalPrice +
                                      50.00 +
                                      (_selectedPaymentMethod !=
                                              'Cash on Delivery'
                                          ? 15.00
                                          : 0.00),
                                  isTotal: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payment Method Section
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: _paymentMethods.map((method) {
                          return RadioListTile<String>(
                            title: Text(method),
                            value: method,
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value!;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Place Order Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedAddress == null
                            ? null
                            : () {
                                _showOrderConfirmation();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5D8AA8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _selectedAddress == null
                              ? 'Select Delivery Address'
                              : 'Place Order',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₱${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF5D8AA8) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your order has been placed successfully!'),
            const SizedBox(height: 16),
            Text('Delivery Address: $_selectedAddress'),
            const SizedBox(height: 8),
            Text('Payment Method: $_selectedPaymentMethod'),
            const SizedBox(height: 8),
            Text(
              'Total Amount: ₱${(_cartService.totalPrice + 50.00 + (_selectedPaymentMethod != 'Cash on Delivery' ? 15.00 : 0.00)).toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D8AA8),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCheckout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Delivery Address Section
          ShimmerWidget.rectangular(height: 24, width: 150),
          const SizedBox(height: 8),
          Card(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidget.rectangular(height: 16, width: double.infinity),
                  const SizedBox(height: 8),
                  ShimmerWidget.rectangular(height: 16, width: 200),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Order Summary Section
          ShimmerWidget.rectangular(height: 24, width: 150),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) => ListTile(
                    title: ShimmerWidget.rectangular(height: 16),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        ShimmerWidget.rectangular(height: 12, width: 150),
                      ],
                    ),
                    trailing: ShimmerWidget.rectangular(height: 16, width: 60),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: List.generate(
                        4,
                        (index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ShimmerWidget.rectangular(
                                      height: 16, width: 80),
                                  ShimmerWidget.rectangular(
                                      height: 16, width: 60),
                                ],
                              ),
                            )),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Payment Method Section
          ShimmerWidget.rectangular(height: 24, width: 150),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: List.generate(
                  3,
                  (index) => ListTile(
                        title: ShimmerWidget.rectangular(height: 16),
                        leading: ShimmerWidget.circular(width: 24, height: 24),
                      )),
            ),
          ),
          const SizedBox(height: 24),

          // Place Order Button
          ShimmerWidget.rectangular(
            height: 48,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
