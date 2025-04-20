import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'models/address.dart';
import 'services/address_service.dart';
import 'address_selection_page.dart';

class SavedAddressesPage extends StatefulWidget {
  final Function(LatLng, String) onAddressSelected;

  const SavedAddressesPage({
    super.key,
    required this.onAddressSelected,
  });

  @override
  State<SavedAddressesPage> createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends State<SavedAddressesPage> {
  final AddressService _addressService = AddressService();
  List<Address> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    try {
      final addresses = await _addressService.getAllAddresses();
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading addresses: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addNewAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressSelectionPage(
          onAddressSelected: (LatLng position, String address) async {
            final newAddress = Address(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              fullAddress: address,
              label: 'Home',
              coordinates: position,
            );
            await _addressService.addAddress(newAddress);
            await _loadAddresses();
          },
        ),
      ),
    );
  }

  Future<void> _editAddress(Address address) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressSelectionPage(
          initialPosition: Position(
            latitude: address.coordinates.latitude,
            longitude: address.coordinates.longitude,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          ),
          onAddressSelected: (LatLng position, String newAddress) async {
            final updatedAddress = address.copyWith(
              fullAddress: newAddress,
              coordinates: position,
            );
            await _addressService.updateAddress(updatedAddress);
            await _loadAddresses();
          },
        ),
      ),
    );
  }

  Future<void> _deleteAddress(Address address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete ${address.label}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _addressService.deleteAddress(address.id);
      await _loadAddresses();
    }
  }

  Future<void> _setDefaultAddress(Address address) async {
    await _addressService.setDefaultAddress(address.id);
    await _loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Addresses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewAddress,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? _buildEmptyState()
              : _buildAddressList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No saved addresses',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _addNewAddress,
            child: const Text('Add New Address'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    return ListView.builder(
      itemCount: _addresses.length,
      itemBuilder: (context, index) {
        final address = _addresses[index];
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: ListTile(
            leading: Icon(
              address.isDefault ? Icons.home : Icons.location_on,
              color: address.isDefault ? Colors.blue : Colors.grey,
            ),
            title: Text(address.label),
            subtitle: Text(
              address.fullAddress,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: PopupMenuButton<String>(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'select',
                  child: Text('Select'),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                if (!address.isDefault)
                  const PopupMenuItem(
                    value: 'set_default',
                    child: Text('Set as Default'),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
              onSelected: (value) async {
                switch (value) {
                  case 'select':
                    widget.onAddressSelected(
                      address.coordinates,
                      address.fullAddress,
                    );
                    Navigator.pop(context);
                    break;
                  case 'edit':
                    await _editAddress(address);
                    break;
                  case 'set_default':
                    await _setDefaultAddress(address);
                    break;
                  case 'delete':
                    await _deleteAddress(address);
                    break;
                }
              },
            ),
          ),
        );
      },
    );
  }
}
