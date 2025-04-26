import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'models/address.dart';
import 'services/address_service.dart';
import 'address_selection_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  List<Map<String, dynamic>> _savedAddresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = prefs.getStringList('saved_addresses') ?? [];
      setState(() {
        _savedAddresses = addressesJson
            .map((json) => Map<String, dynamic>.from(jsonDecode(json)))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading saved addresses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson =
          _savedAddresses.map((address) => jsonEncode(address)).toList();
      await prefs.setStringList('saved_addresses', addressesJson);
      debugPrint(
          'Addresses saved successfully: ${_savedAddresses.length} addresses');
    } catch (e) {
      debugPrint('Error saving addresses: $e');
    }
  }

  Future<void> _addNewAddress() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddressSelectionPage(
          onAddressSelected:
              (latLng, address, floorUnit, instructions, label) async {
            final newAddress = {
              'lat': latLng.latitude,
              'lng': latLng.longitude,
              'address': address,
              'floorUnit': floorUnit,
              'instructions': instructions,
              'label': label,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            };
            setState(() {
              _savedAddresses.add(newAddress);
            });
            await _saveAddresses();
            return Future.value(newAddress);
          },
        ),
      ),
    );
  }

  Future<void> _editAddress(int index) async {
    final address = _savedAddresses[index];
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddressSelectionPage(
          initialPosition: Position(
            latitude: address['lat'],
            longitude: address['lng'],
            timestamp:
                DateTime.fromMillisecondsSinceEpoch(address['timestamp']),
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
            final updatedAddress = {
              'lat': latLng.latitude,
              'lng': latLng.longitude,
              'address': newAddress,
              'floorUnit': floorUnit,
              'instructions': instructions,
              'label': label,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            };
            setState(() {
              _savedAddresses[index] = updatedAddress;
            });
            await _saveAddresses();
            return Future.value(updatedAddress);
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
      setState(() {
        _savedAddresses.removeAt(index);
      });
      await _saveAddresses();
    }
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
          : _savedAddresses.isEmpty
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
                  itemCount: _savedAddresses.length,
                  itemBuilder: (context, index) {
                    final address = _savedAddresses[index];
                    return ListTile(
                      leading: Icon(_getLabelIcon(address['label'])),
                      title: Text(address['label']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(address['address']),
                          if (address['floorUnit']?.isNotEmpty == true)
                            Text('${address['floorUnit']}'),
                          if (address['instructions']?.isNotEmpty == true)
                            Text(
                              'Note: ${address['instructions']}',
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                      onTap: () {
                        widget.onAddressSelected(
                          LatLng(address['lat'], address['lng']),
                          address['address'],
                          address['floorUnit'] ?? '',
                          address['instructions'] ?? '',
                          address['label'],
                        );
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
    );
  }
}
