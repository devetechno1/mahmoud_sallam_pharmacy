class ClassifiedUpdateModel {
  String name;
  String addedBy;
  String categoryId;
  String brandId;
  String unit;
  String conditon;
  String location;
  List<String> tags;
  String description;
  String photos;
  String thumbnailImg;
  String videoProvider;
  String videoLink;
  String? pdf;
  String unitPrice;
  String metaTitle;
  String metaDescription;
  String? metaImg;
  String lang;
  int customerProductId;

  ClassifiedUpdateModel({
    required this.name,
    required this.addedBy,
    required this.categoryId,
    required this.brandId,
    required this.unit,
    required this.conditon,
    required this.location,
    required this.tags,
    required this.description,
    required this.photos,
    required this.thumbnailImg,
    required this.videoProvider,
    required this.videoLink,
    this.pdf,
    required this.unitPrice,
    required this.metaTitle,
    required this.metaDescription,
    this.metaImg,
    required this.lang,
    required this.customerProductId,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "added_by": addedBy,
      "category_id": categoryId,
      "brand_id": brandId,
      "unit": unit,
      "conditon": conditon, // Corrected typo
      "location": location,
      "tags": tags,
      "description": description,
      "photos": photos,
      "thumbnail_img": thumbnailImg,
      "video_provider": videoProvider,
      "video_link": videoLink,
      "pdf": pdf,
      "unit_price": unitPrice,
      "meta_title": metaTitle,
      "meta_description": metaDescription,
      "meta_img": metaImg,
      "lang": lang,
      "customer_product_id": customerProductId,
    };
  }

  ClassifiedUpdateModel copyWith({
    String? name,
    String? addedBy,
    String? categoryId,
    String? brandId,
    String? unit,
    String? conditon,
    String? location,
    List<String>? tags,
    String? description,
    String? photos,
    String? thumbnailImg,
    String? videoProvider,
    String? videoLink,
    String? pdf,
    String? unitPrice,
    String? metaTitle,
    String? metaDescription,
    String? metaImg,
    String? lang,
    int? customerProductId,
  }) {
    return ClassifiedUpdateModel(
      name: name ?? this.name,
      addedBy: addedBy ?? this.addedBy,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      unit: unit ?? this.unit,
      conditon: conditon ?? this.conditon,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      thumbnailImg: thumbnailImg ?? this.thumbnailImg,
      videoProvider: videoProvider ?? this.videoProvider,
      videoLink: videoLink ?? this.videoLink,
      pdf: pdf ?? this.pdf,
      unitPrice: unitPrice ?? this.unitPrice,
      metaTitle: metaTitle ?? this.metaTitle,
      metaDescription: metaDescription ?? this.metaDescription,
      metaImg: metaImg ?? this.metaImg,
      lang: lang ?? this.lang,
      customerProductId: customerProductId ?? this.customerProductId,
    );
  }
}
