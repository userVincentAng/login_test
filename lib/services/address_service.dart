import 'package:latlong2/latlong.dart';
import '../models/address.dart';

class AddressService {
  final List<Address> _addresses = [];
  static final AddressService _instance = AddressService._internal();

  factory AddressService() => _instance;

  AddressService._internal();

  Future<List<Address>> getAllAddresses() async => List.from(_addresses);

  Future<Address?> getDefaultAddress() async {
    try {
      return _addresses.firstWhere((address) => address.isDefault);
    } catch (_) {
      return null;
    }
  }

  Future<void> addAddress(Address address) async {
    if (_addresses.isEmpty || address.isDefault) {
      _removeDefaultFromAll();
    }
    _addresses.add(address);
  }

  Future<void> updateAddress(Address updatedAddress) async {
    final index =
        _addresses.indexWhere((address) => address.id == updatedAddress.id);
    if (index != -1) {
      if (updatedAddress.isDefault) {
        _removeDefaultFromAll();
      }
      _addresses[index] = updatedAddress;
    }
  }

  Future<void> deleteAddress(String id) async {
    _addresses.removeWhere((address) => address.id == id);
  }

  Future<void> setDefaultAddress(String id) async {
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(
        isDefault: _addresses[i].id == id,
      );
    }
  }

  void _removeDefaultFromAll() {
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(isDefault: false);
    }
  }
}
