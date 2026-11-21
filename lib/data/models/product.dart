class Product {
  const Product({
    required this.id,
    required this.categoryId,
    required this.nameEn,
    required this.nameAr,
    required this.descEn,
    required this.descAr,
    required this.price,
    required this.oldPrice,
    required this.unitEn,
    required this.unitAr,
    required this.rating,
    required this.reviews,
    required this.inStock,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String,
        categoryId: j['categoryId'] as String,
        nameEn: j['nameEn'] as String,
        nameAr: j['nameAr'] as String,
        descEn: j['descEn'] as String,
        descAr: j['descAr'] as String,
        price: (j['price'] as num).toDouble(),
        oldPrice: (j['oldPrice'] as num?)?.toDouble(),
        unitEn: j['unitEn'] as String,
        unitAr: j['unitAr'] as String,
        rating: (j['rating'] as num).toDouble(),
        reviews: (j['reviews'] as num).toInt(),
        inStock: j['inStock'] as bool,
        image: j['image'] as String,
      );

  final String id;
  final String categoryId;
  final String nameEn;
  final String nameAr;
  final String descEn;
  final String descAr;
  final double price;
  final double? oldPrice;
  final String unitEn;
  final String unitAr;
  final double rating;
  final int reviews;
  final bool inStock;
  final String image;

  bool get hasDiscount => oldPrice != null && oldPrice! > price;
  int get discountPercent => hasDiscount ? (((oldPrice! - price) / oldPrice!) * 100).round() : 0;

  String name(String lang) => lang == 'ar' ? nameAr : nameEn;
  String description(String lang) => lang == 'ar' ? descAr : descEn;
  String unit(String lang) => lang == 'ar' ? unitAr : unitEn;
}
