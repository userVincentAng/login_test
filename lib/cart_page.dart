import 'package:flutter/material.dart';
import 'services/cart_service.dart';
import 'checkout_page.dart';
import 'widgets/shimmer_widget.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    await _cartService.loadCart();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _removeItem(int index) async {
    await _cartService.removeItem(index);
    setState(() {});
  }

  Future<void> _editItem(int index) async {
    final item = _cartService.items[index];
    final TextEditingController quantityController =
        TextEditingController(text: item.quantity.toString());
    final TextEditingController notesController =
        TextEditingController(text: item.notes ?? '');

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.edit, color: Color(0xFF5D8AA8)),
              const SizedBox(width: 8),
              Text('Edit ${item.name}'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₱${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D8AA8),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Quantity: '),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        int currentQuantity =
                            int.tryParse(quantityController.text) ?? 1;
                        if (currentQuantity > 1) {
                          quantityController.text =
                              (currentQuantity - 1).toString();
                        }
                      },
                    ),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        int currentQuantity =
                            int.tryParse(quantityController.text) ?? 1;
                        quantityController.text =
                            (currentQuantity + 1).toString();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (item.selectedOptions != null) ...[
                  if (item.selectedOptions!['variant'] != null)
                    Text(
                        'Size: ${item.selectedOptions!['variant']['CombiName']}'),
                  if (item.selectedOptions!['addOns'] != null &&
                      (item.selectedOptions!['addOns'] as List).isNotEmpty)
                    Text(
                        'Add-ons: ${(item.selectedOptions!['addOns'] as List).map((a) => a['Name']).join(', ')}'),
                  if (item.selectedOptions!['sugarLevel'] != null)
                    Text(
                        'Sugar Level: ${item.selectedOptions!['sugarLevel']['Name']}'),
                  const SizedBox(height: 16),
                ],
                const Text('Special Instructions:'),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Add any special instructions...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newQuantity =
                    int.tryParse(quantityController.text) ?? item.quantity;
                final newNotes = notesController.text.trim();

                if (newQuantity != item.quantity) {
                  await _cartService.updateQuantity(index, newQuantity);
                }

                if (newNotes != item.notes) {
                  await _cartService.updateNotes(index, newNotes);
                }

                setState(() {});
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D8AA8),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearCart() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text('Are you sure you want to clear your cart?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Clear'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _cartService.clearCart();
      setState(() {});
    }
  }

  Widget _buildShimmerCartItem() {
    return const Card(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ListTile(
        title: ShimmerWidget.rectangular(height: 16),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            ShimmerWidget.rectangular(height: 12),
            SizedBox(height: 4),
            ShimmerWidget.rectangular(height: 12),
            SizedBox(height: 4),
            ShimmerWidget.rectangular(height: 12, width: 80),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShimmerWidget.rectangular(width: 32, height: 32),
            SizedBox(width: 8),
            ShimmerWidget.rectangular(width: 24, height: 24),
            SizedBox(width: 8),
            ShimmerWidget.rectangular(width: 32, height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          if (_cartService.items.isNotEmpty && !_isLoading)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearCart,
            ),
        ],
      ),
      body: _isLoading
          ? ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) => _buildShimmerCartItem(),
            )
          : _cartService.items.isEmpty
              ? const Center(
                  child: Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cartService.items.length,
                        itemBuilder: (context, index) {
                          final item = _cartService.items[index];
                          return Dismissible(
                            key: Key(item.itemId.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) => _removeItem(index),
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
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
                                      if (item.selectedOptions!['sugarLevel'] !=
                                          null)
                                        Text(
                                            'Sugar Level: ${item.selectedOptions!['sugarLevel']['Name']}'),
                                    ],
                                    if (item.notes != null &&
                                        item.notes!.isNotEmpty)
                                      Text('Notes: ${item.notes}'),
                                    Text(
                                      '₱${(item.price * item.quantity).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF5D8AA8),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () => _editItem(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () async {
                                        if (item.quantity > 1) {
                                          await _cartService.updateQuantity(
                                              index, item.quantity - 1);
                                          setState(() {});
                                        }
                                      },
                                    ),
                                    Text(
                                      item.quantity.toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () async {
                                        await _cartService.updateQuantity(
                                            index, item.quantity + 1);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
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
                                '₱${_cartService.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5D8AA8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CheckoutPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5D8AA8),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Proceed to Checkout',
                                style: TextStyle(
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
                  ],
                ),
    );
  }
}
