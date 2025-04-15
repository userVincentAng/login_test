class StoreItem {
  final int id;
  final String productName;
  final String? description;
  final int categoryId;
  final String imgUrl;
  final double price;
  final bool hasVariants;
  final bool hasModifiers;

  StoreItem({
    required this.id,
    required this.productName,
    this.description,
    required this.categoryId,
    required this.imgUrl,
    required this.price,
    required this.hasVariants,
    required this.hasModifiers,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['Id'],
      productName: json['ProductName'],
      description: json['Description'],
      categoryId: json['CategoryId'],
      imgUrl: json['ImgUrl'],
      price: json['Price'].toDouble(),
      hasVariants: json['HasVariants'],
      hasModifiers: json['HasModifiers'],
    );
  }
}

class Category {
  final int id;
  final String categoryName;

  Category({
    required this.id,
    required this.categoryName,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['Id'],
      categoryName: json['CategoryName'],
    );
  }
}
