class BlogModel {
  int id;
  String title;
  String slug;
  String shortDescription;
  String description;
  String banner;
  String? metaTitle;
  String? metaDescription;
  int status;
  String category;

  BlogModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.shortDescription,
    required this.description,
    required this.banner,
    required this.metaTitle,
    required this.metaDescription,
    required this.status,
    required this.category,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      shortDescription: json['short_description'],
      description: json['description'],
      banner: json['banner'],
      metaTitle: json['meta_title'],
      metaDescription: json['meta_description'],
      status: json['status'],
      category: json['category'],
    );
  }

  String? get imageUrl => null;
}

class BlogsData {
  bool result;
  List<BlogModel> blogs;
  List<dynamic> selectedCategories;
  dynamic search;
  List<BlogModel> recentBlogs;

  BlogsData({
    required this.result,
    required this.blogs,
    required this.selectedCategories,
    required this.search,
    required this.recentBlogs,
  });

  factory BlogsData.fromJson(Map<String, dynamic> json) {
    return BlogsData(
      result: json['result'],
      blogs: List<BlogModel>.from(
          json['blogs']['data'].map((x) => BlogModel.fromJson(x))),
      selectedCategories: json['selected_categories'],
      search: json['search'],
      recentBlogs: List<BlogModel>.from(
          json['recent_blogs'].map((x) => BlogModel.fromJson(x))),
    );
  }
}
