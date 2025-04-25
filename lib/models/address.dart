import 'package:google_maps_flutter/google_maps_flutter.dart';

class Address {
  final String id;
  final String fullAddress;
  final String label;
  final Coordinates coordinates;
  final bool isDefault;

  Address({
    required this.id,
    required this.fullAddress,
    required this.label,
    required this.coordinates,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      fullAddress: json['fullAddress'] as String,
      label: json['label'] as String? ?? 'Home',
      coordinates:
          Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullAddress': fullAddress,
      'label': label,
      'coordinates': coordinates.toJson(),
      'isDefault': isDefault,
    };
  }

  Address copyWith({
    String? fullAddress,
    String? label,
    Coordinates? coordinates,
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

  // Convert to LatLng for Google Maps
  LatLng toLatLng() {
    return LatLng(coordinates.latitude, coordinates.longitude);
  }

  // Create from LatLng
  static Address fromLatLng(LatLng position, String address, {String? label}) {
    return Address(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullAddress: address,
      label: label ?? 'Home',
      coordinates: Coordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
  }
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({
    required this.latitude,
    required this.longitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Convert to LatLng
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }

  // Create from LatLng
  static Coordinates fromLatLng(LatLng position) {
    return Coordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
