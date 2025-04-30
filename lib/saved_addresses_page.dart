import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'address_selection_page.dart';
import 'services/address_service.dart';
import 'models/address.dart';

class SavedAddressesPage extends StatefulWidget {
  final Future<void> Function(LatLng, String, String, String, String)
      onAddressSelected;

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
    try {
      final addresses = await _addressService.getAllAddresses();
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading addresses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addNewAddress() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddressSelectionPage(
          onAddressSelected:
              (latLng, address, floorUnit, instructions, label) async {
            final newAddress = Address.fromLatLng(
              latLng,
              address,
              label: label,
            );
            await _addressService.addAddress(newAddress);
            await _loadAddresses();
            return Future.value(newAddress.toJson());
          },
        ),
      ),
    );
  }

  Future<void> _editAddress(int index) async {
    final address = _addresses[index];
    final result = await Navigator.push<Map<String, dynamic>>(
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
          onAddressSelected:
              (latLng, newAddress, floorUnit, instructions, label) async {
            final updatedAddress = address.copyWith(
              fullAddress: newAddress,
              label: label,
              coordinates: Coordinates(
                latitude: latLng.latitude,
                longitude: latLng.longitude,
              ),
            );
            await _addressService.updateAddress(updatedAddress);
            await _loadAddresses();
            return Future.value(updatedAddress.toJson());
          },
        ),
      ),
    );
  }

  Future<void> _deleteAddress(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
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
      await _addressService.deleteAddress(_addresses[index].id);
      await _loadAddresses();
    }
  }

  Future<void> _setDefaultAddress(int index) async {
    await _addressService.setDefaultAddress(_addresses[index].id);
    await _loadAddresses();
  }

  IconData _getLabelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'partner':
        return Icons.favorite;
      default:
        return Icons.location_on;
    }
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
              ? Center(
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
                )
              : ListView.builder(
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    return ListTile(
                      leading: Icon(_getLabelIcon(address.label)),
                      title: Row(
                        children: [
                          Text(address.label),
                          if (address.isDefault) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(address.fullAddress),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!address.isDefault)
                            IconButton(
                              icon: const Icon(Icons.star_border),
                              onPressed: () => _setDefaultAddress(index),
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editAddress(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteAddress(index),
                          ),
                        ],
                      ),
                      onTap: () async {
                        await widget.onAddressSelected(
                          address.toLatLng(),
                          address.fullAddress,
                          '',
                          '',
                          address.label,
                        );
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                ),
    );
  }
}
