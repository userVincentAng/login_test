import 'package:google_maps_flutter/google_maps_flutter.dart';

class Address {
  final String id;
  final String fullAddress;
  final String label;
  final LatLng coordinates;
  final bool isDefault;

  const Address({
    required this.id,
    required this.fullAddress,
    required this.label,
    required this.coordinates,
    this.isDefault = false,
  });

  Address copyWith({
    String? fullAddress,
    String? label,
    LatLng? coordinates,
    bool? isDefault,
  }) {
    return Address(
      id: id,
      fullAddress: fullAddress ?? this.fullAddress,
      label: label ?? this.label,
      coordinates: coordinates ?? this.coordinates,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
