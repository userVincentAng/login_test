import '../models/address.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddressService {
  List<Address> _addresses = [];
  static final AddressService _instance = AddressService._internal();
  bool _isInitialized = false;

  factory AddressService() => _instance;

  AddressService._internal();

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _loadAddresses();
      _isInitialized = true;
    }
  }

  Future<void> _loadAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = prefs.getStringList('addresses') ?? [];
      _addresses = addressesJson
          .map((json) => Address.fromJson(jsonDecode(json)))
          .toList();

      // If there are addresses but no default, set the first one as default
      if (_addresses.isNotEmpty && !_addresses.any((addr) => addr.isDefault)) {
        _addresses[0] = _addresses[0].copyWith(isDefault: true);
        await _saveAddresses();
      }
    } catch (e) {
      print('Error loading addresses: $e');
      _addresses = [];
    }
  }

  Future<void> _saveAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson =
          _addresses.map((address) => jsonEncode(address.toJson())).toList();
      await prefs.setStringList('addresses', addressesJson);
    } catch (e) {
      print('Error saving addresses: $e');
    }
  }

  Future<List<Address>> getAllAddresses() async {
    await _ensureInitialized();
    return List.from(_addresses);
  }

  Future<Address?> getDefaultAddress() async {
    await _ensureInitialized();
    if (_addresses.isEmpty) return null;
    try {
      return _addresses.firstWhere((address) => address.isDefault);
    } catch (_) {
      // If no default is set, return the first address
      return _addresses[0];
    }
  }

  Future<void> addAddress(Address address) async {
    await _ensureInitialized();
    // Make the first address default if it's the only one
    final newAddress = address.copyWith(isDefault: _addresses.isEmpty);
    if (newAddress.isDefault) {
      _removeDefaultFromAll();
    }
    _addresses.add(newAddress);
    await _saveAddresses();
  }

  Future<void> updateAddress(Address updatedAddress) async {
    await _ensureInitialized();
    final index =
        _addresses.indexWhere((address) => address.id == updatedAddress.id);
    if (index != -1) {
      if (updatedAddress.isDefault) {
        _removeDefaultFromAll();
      }
      _addresses[index] = updatedAddress;
      await _saveAddresses();
    }
  }

  Future<void> deleteAddress(String id) async {
    await _ensureInitialized();
    final wasDefault =
        _addresses.any((addr) => addr.id == id && addr.isDefault);
    _addresses.removeWhere((address) => address.id == id);

    // If we removed the default address and there are other addresses, make the first one default
    if (wasDefault && _addresses.isNotEmpty) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
    }
    await _saveAddresses();
  }

  Future<void> setDefaultAddress(String id) async {
    await _ensureInitialized();
    _removeDefaultFromAll();
    final index = _addresses.indexWhere((address) => address.id == id);
    if (index != -1) {
      _addresses[index] = _addresses[index].copyWith(isDefault: true);
      await _saveAddresses();
    }
  }

  void _removeDefaultFromAll() {
    for (var i = 0; i < _addresses.length; i++) {
      if (_addresses[i].isDefault) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
  }
}
