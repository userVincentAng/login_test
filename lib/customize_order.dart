import 'package:flutter/material.dart';
import 'models/store_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/auth_service.dart';
import 'services/cart_service.dart';

class CustomizeOrderPanel extends StatefulWidget {
  final StoreItem item;
  final int storeId;

  const CustomizeOrderPanel({
    super.key,
    required this.item,
    required this.storeId,
  });

  @override
  State<CustomizeOrderPanel> createState() => _CustomizeOrderPanelState();
}

class _CustomizeOrderPanelState extends State<CustomizeOrderPanel> {
  int _quantity = 1;
  List<dynamic> _variants = [];
  List<dynamic> _addOns = [];
  List<dynamic> _sugarLevels = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final Map<String, dynamic> _selectedOptions = {};
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItemDetails();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadItemDetails() async {
    try {
      print(
          'Loading item details for item ${widget.item.id} from store ${widget.storeId}');
      print('Auth headers: ${AuthService.getAuthHeaders()}');

      final response = await http.post(
        Uri.parse('http://test.shoppazing.com/api/shop/getonlineitemdetails'),
        headers: AuthService.getAuthHeaders(),
        body: jsonEncode({
          'StoreId': widget.storeId,
          'ItemId': widget.item.id,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Parsed response data: $data');

        if (data['status_code'] == 200) {
          setState(() {
            _variants = data['itemVariants'] ?? [];
            _addOns = data['itemModifiers'] ?? [];

            // Find the sugar level modifier from itemModifiers
            final sugarLevelModifier = _addOns.firstWhere(
              (modifier) => modifier['ModifierName'] == 'Sugar Level',
              orElse: () => null,
            );

            // Only use sugar levels from the API
            _sugarLevels = sugarLevelModifier?['ModifierOptions'] ?? [];

            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to load item details';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Server error: ${response.statusCode}\n${response.body}';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error loading item details: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _updateQuantity(bool increase) {
    setState(() {
      if (increase) {
        _quantity++;
      } else if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  void _selectOption(String type, dynamic option) {
    setState(() {
      _selectedOptions[type] = option;
    });
  }

  void _toggleAddOn(dynamic addOn) {
    setState(() {
      final List<dynamic> currentAddOns =
          List.from(_selectedOptions['addOns'] ?? []);
      if (currentAddOns.contains(addOn)) {
        currentAddOns.remove(addOn);
      } else {
        currentAddOns.add(addOn);
      }
      _selectedOptions['addOns'] = currentAddOns;
    });
  }

  double _calculateTotalPrice() {
    double total = widget.item.price * _quantity;

    // Add variant price if selected
    if (_selectedOptions['variant'] != null) {
      final variant = _selectedOptions['variant'] as Map<String, dynamic>;
      total += (variant['Price'] as double) * _quantity;
    }

    // Add add-ons prices
    final List<dynamic> addOns = _selectedOptions['addOns'] ?? [];
    for (var addOn in addOns) {
      total += (addOn['Price'] as double) * _quantity;
    }

    return total;
  }

  Future<void> _addToCart() async {
    final cartItem = CartItem(
      storeId: widget.storeId,
      itemId: widget.item.id,
      name: widget.item.productName,
      price: _calculateTotalPrice() / _quantity,
      quantity: _quantity,
      selectedOptions: _selectedOptions,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    final cartService = CartService();
    await cartService.addItem(cartItem);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item added to cart'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.item.productName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.item.description != null)
              Text(
                widget.item.description!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 16),

            // Loading or Error State
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage.isNotEmpty)
              Center(child: Text(_errorMessage))
            else ...[
              // Size Variants
              if (_variants.isNotEmpty) ...[
                const Text(
                  'Size',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ..._variants.map((variant) => RadioListTile(
                      title: Text(
                          '${variant['CombiName']} (+₱${variant['Price']})'),
                      value: variant,
                      groupValue: _selectedOptions['variant'],
                      onChanged: (value) => _selectOption('variant', value),
                    )),
                const SizedBox(height: 16),
              ],

              // Add-ons
              if (_addOns.isNotEmpty) ...[
                const Text(
                  'Add-ons',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ..._addOns.expand((modifier) {
                  // Skip sugar level modifier as it's handled separately
                  if (modifier['ModifierName'] == 'Sugar Level') {
                    return <Widget>[];
                  }

                  final options = modifier['ModifierOptions'] as List<dynamic>?;
                  if (options == null || options.isEmpty) return <Widget>[];
                  return options.map((option) => CheckboxListTile(
                        title: Text('${option['Name']} (+₱${option['Price']})'),
                        value:
                            (_selectedOptions['addOns'] ?? []).contains(option),
                        onChanged: (value) => _toggleAddOn(option),
                      ));
                }),
                const SizedBox(height: 16),
              ],

              // Sugar Levels
              if (_sugarLevels.isNotEmpty &&
                  _sugarLevels.any((level) => level['Name'] != null)) ...[
                const Text(
                  'Sugar Level',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ..._sugarLevels
                    .where((level) => level['Name'] != null)
                    .map((level) => RadioListTile(
                          title: Text(level['Name']),
                          value: level,
                          groupValue: _selectedOptions['sugarLevel'],
                          onChanged: (value) =>
                              _selectOption('sugarLevel', value),
                        )),
                const SizedBox(height: 16),
              ],

              // Notes
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Special Instructions',
                  hintText: 'Add any special requests here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Quantity Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => _updateQuantity(false),
                      ),
                      Text(
                        _quantity.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _updateQuantity(true),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total Price
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₱${_calculateTotalPrice().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D8AA8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Add to Cart Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D8AA8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
