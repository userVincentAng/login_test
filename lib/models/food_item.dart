class FoodItem {
  final int id;
  final String name;
  final double price;
  final String imgUrl;
  final int storeId;
  final String storeName;
  final double storeLat;
  final double storeLng;
  final double distance;
  final double storeRating;

  FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imgUrl,
    required this.storeId,
    required this.storeName,
    required this.storeLat,
    required this.storeLng,
    required this.distance,
    required this.storeRating,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['ItemId'],
      name: json['ItemName'],
      price: json['ItemPrice'].toDouble(),
      imgUrl: json['ImageUrl'],
      storeId: json['StoreId'],
      storeName: json['StoreName'],
      storeLat: json['StoreLat'].toDouble(),
      storeLng: json['StoreLng'].toDouble(),
      distance: json['Distance'].toDouble(),
      storeRating: json['StoreRating'].toDouble(),
    );
  }
}
