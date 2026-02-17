// class ClassifiedProductModel {
//   final int id;
//   final String? slug;
//   final String? name;
//   final String? thumbnailImage;
//   final String? condition;
//   final String? unitPrice;
//   final String? category;
//   final bool published;
//   final bool status;

//   ClassifiedProductModel({
//     required this.id,
//     this.slug,
//     this.name,
//     this.thumbnailImage,
//     this.condition,
//     this.unitPrice,
//     this.category,
//     required this.published,
//     required this.status,
//   });

//   // JSON deserialization
//   factory ClassifiedProductModel.fromJson(Map<String, dynamic> json) {
//     return ClassifiedProductModel(
//       id: json['id'],
//       slug: json['slug'] as String?,
//       name: json['name'] as String?,
//       thumbnailImage: json['thumbnail_image'] as String?,
//       condition: json['condition'] as String?,
//       unitPrice: json['unit_price'] as String?,
//       category: json['category'] as String?,
//       published: json['published'] ?? false,
//       status: json['status'] ?? false,
//     );
//   }
// }

// class Links {
//   final String? first;
//   final String? last;
//   final String? prev;
//   final String? next;

//   Links({
//     this.first,
//     this.last,
//     this.prev,
//     this.next,
//   });

//   // JSON deserialization
//   factory Links.fromJson(Map<String, dynamic> json) {
//     return Links(
//       first: json['first'],
//       last: json['last'],
//       prev: json['prev'],
//       next: json['next'],
//     );
//   }
// }

// class Meta {
//   final int currentPage;
//   final int from;
//   final int lastPage;
//   final int perPage;
//   final int to;
//   final int total;

//   Meta({
//     required this.currentPage,
//     required this.from,
//     required this.lastPage,
//     required this.perPage,
//     required this.to,
//     required this.total,
//   });

//   // JSON deserialization
//   factory Meta.fromJson(Map<String, dynamic> json) {
//     return Meta(
//       currentPage: json['current_page'],
//       from: json['from'],
//       lastPage: json['last_page'],
//       perPage: json['per_page'],
//       to: json['to'],
//       total: json['total'],
//     );
//   }
// }

// class MyclassifiedProductModel {
//   final List<ClassifiedProductModel> data;
//   final Links links;
//   final Meta meta;
//   final bool success;
//   final int status;

//   MyclassifiedProductModel({
//     required this.data,
//     required this.links,
//     required this.meta,
//     required this.success,
//     required this.status,
//   });

//   // JSON deserialization
//   factory MyclassifiedProductModel.fromJson(Map<String, dynamic> json) {
//     return MyclassifiedProductModel(
//       data: (json['data'] as List)
//           .map((e) => ClassifiedProductModel.fromJson(e))
//           .toList(),
//       links: Links.fromJson(json['links']),
//       meta: Meta.fromJson(json['meta']),
//       success: json['success'],
//       status: json['status'],
//     );
//   }
// }
class ClassifiedProductModel {
  final int id;
  final String? slug;
  final String? name;
  final String? thumbnailImage;
  final String? condition;
  final String? unitPrice;
  final String? category;
  final bool published;
  final bool status;

  ClassifiedProductModel({
    required this.id,
    this.slug,
    this.name,
    this.thumbnailImage,
    this.condition,
    this.unitPrice,
    this.category,
    required this.published,
    required this.status,
  });

  // CopyWith method for creating a new instance with modified values
  ClassifiedProductModel copyWith({
    bool? status,
  }) {
    return ClassifiedProductModel(
      id: id,
      slug: slug,
      name: name,
      thumbnailImage: thumbnailImage,
      condition: condition,
      unitPrice: unitPrice,
      category: category,
      published: published,
      status: status ?? this.status,
    );
  }

  // JSON deserialization
  factory ClassifiedProductModel.fromJson(Map<String, dynamic> json) {
    return ClassifiedProductModel(
      id: json['id'],
      slug: json['slug'] as String?,
      name: json['name'] as String?,
      thumbnailImage: json['thumbnail_image'] as String?,
      condition: json['condition'] as String?,
      unitPrice: json['unit_price'] as String?,
      category: json['category'] as String?,
      published: json['published'] ?? false,
      status: json['status'] ?? false,
    );
  }
}

class Links {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  Links({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  // JSON deserialization
  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}

class Meta {
  final int currentPage;
  final int from;
  final int lastPage;
  final int perPage;
  final int to;
  final int total;

  Meta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.perPage,
    required this.to,
    required this.total,
  });

  // JSON deserialization
  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'],
      from: json['from'],
      lastPage: json['last_page'],
      perPage: json['per_page'],
      to: json['to'],
      total: json['total'],
    );
  }
}

class MyclassifiedProductModel {
  final List<ClassifiedProductModel> data;
  final Links links;
  final Meta meta;
  final bool success;
  final int status;

  MyclassifiedProductModel({
    required this.data,
    required this.links,
    required this.meta,
    required this.success,
    required this.status,
  });

  // JSON deserialization
  factory MyclassifiedProductModel.fromJson(Map<String, dynamic> json) {
    return MyclassifiedProductModel(
      data: (json['data'] as List)
          .map((e) => ClassifiedProductModel.fromJson(e))
          .toList(),
      links: Links.fromJson(json['links']),
      meta: Meta.fromJson(json['meta']),
      success: json['success'],
      status: json['status'],
    );
  }
}
