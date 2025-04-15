class Store {
  final int storeId;
  final String name;
  final String addressLine1;
  final String? addressLine2;
  final String storeUrl;
  final double lat;
  final double lng;
  final double storeRating;
  final List<StoreHours> storeHours;
  final bool isStoreOnline;

  Store({
    required this.storeId,
    required this.name,
    required this.addressLine1,
    this.addressLine2,
    required this.storeUrl,
    required this.lat,
    required this.lng,
    required this.storeRating,
    required this.storeHours,
    required this.isStoreOnline,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      storeId: json['StoreId'],
      name: json['Name'],
      addressLine1: json['AddressLine1'],
      addressLine2: json['AddressLine2'],
      storeUrl: json['StoreUrl'],
      lat: json['Lat'],
      lng: json['Lng'],
      storeRating: json['StoreRating'] ?? 0.0,
      storeHours:
          (json['StoreHours'] as List?)
              ?.map((e) => StoreHours.fromJson(e))
              .toList() ??
          [],
      isStoreOnline: json['IsStoreOnline'] ?? false,
    );
  }
}

class StoreHours {
  final int id;
  final int storeId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isEnabled;
  final bool isWholeDay;

  StoreHours({
    required this.id,
    required this.storeId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isEnabled,
    required this.isWholeDay,
  });

  factory StoreHours.fromJson(Map<String, dynamic> json) {
    return StoreHours(
      id: json['Id'],
      storeId: json['StoreId'],
      dayOfWeek: json['DayOfWeek'],
      startTime: json['StartTime'],
      endTime: json['EndTime'],
      isEnabled: json['IsEnabled'],
      isWholeDay: json['IsWholeDay'],
    );
  }
}
