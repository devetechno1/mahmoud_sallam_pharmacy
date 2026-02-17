class WholesaleProductModel {
  final bool result;
  final ProductData products;

  WholesaleProductModel({required this.result, required this.products});

  factory WholesaleProductModel.fromJson(Map<String, dynamic> json) {
    return WholesaleProductModel(
      result: json['result'],
      products: ProductData.fromJson(json['products']),
    );
  }
}

class ProductData {
  final List<Product> data;

  ProductData({required this.data});

  factory ProductData.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List;
    final List<Product> productList =
        list.map((i) => Product.fromJson(i)).toList();

    return ProductData(
      data: productList,
    );
  }

  bool get isEmpty => data.isEmpty; // Correctly implemented isEmpty getter
}

class Product {
  final int id;
  final String slug;
  final String name;
  final List<String> photos;
  final String thumbnailImage;
  final double basePrice;
  final double baseDiscountedPrice;
  final String discount_percentage;
  final bool todaysDeal;
  final bool featured;
  final String unit;
  final double discount;
  final String discountType;
  final double rating;
  final int sales;
  final ProductLinks links;

  Product({
    required this.id,
    required this.slug,
    required this.name,
    required this.photos,
    required this.thumbnailImage,
    required this.basePrice,
    required this.baseDiscountedPrice,
    required this.discount_percentage,
    required this.todaysDeal,
    required this.featured,
    required this.unit,
    required this.discount,
    required this.discountType,
    required this.rating,
    required this.sales,
    required this.links,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final photosList = List<String>.from(json['photos']);
    return Product(
      id: json['id'],
      slug: json['slug'],
      name: json['name'],
      photos: photosList,
      thumbnailImage: json['thumbnail_image'],
      basePrice: json['base_price'].toDouble(),
      baseDiscountedPrice: json['base_discounted_price'].toDouble(),
      discount_percentage: json['discount_percentage'],
      todaysDeal: json['todays_deal'] == 1,
      featured: json['featured'] == 1,
      unit: json['unit'],
      discount: json['discount'].toDouble(),
      discountType: json['discount_type'],
      rating: json['rating'].toDouble(),
      sales: json['sales'],
      links: ProductLinks.fromJson(json['links']),
    );
  }
}

class ProductLinks {
  final String details;
  final String reviews;

  ProductLinks({required this.details, required this.reviews});

  factory ProductLinks.fromJson(Map<String, dynamic> json) {
    return ProductLinks(
      details: json['details'],
      reviews: json['reviews'],
    );
  }
}
