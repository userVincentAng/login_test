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
      storeHours: (json['StoreHours'] as List?)
              ?.map((hours) => StoreHours.fromJson(hours))
              .toList() ??
          [],
      isStoreOnline: json['IsStoreOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'StoreId': storeId,
      'Name': name,
      'AddressLine1': addressLine1,
      'AddressLine2': addressLine2,
      'StoreUrl': storeUrl,
      'Lat': lat,
      'Lng': lng,
      'StoreRating': storeRating,
      'StoreHours': storeHours.map((hours) => hours.toJson()).toList(),
      'IsStoreOnline': isStoreOnline,
    };
  }

  // Helper getters for UI
  String get address =>
      addressLine2 != null ? '$addressLine1, $addressLine2' : addressLine1;
  String get imageUrl => storeUrl;
  double get rating => storeRating;
  int get reviewCount => 0; // This should be fetched from the API
  double get distance =>
      0.0; // This should be calculated based on user's location
  bool get isOpen => isStoreOnline;
  List<String> get categories => []; // This should be fetched from the API
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

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'StoreId': storeId,
      'DayOfWeek': dayOfWeek,
      'StartTime': startTime,
      'EndTime': endTime,
      'IsEnabled': isEnabled,
      'IsWholeDay': isWholeDay,
    };
  }
}
