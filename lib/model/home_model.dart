class HomeData {
  String? profile;
  String? userName;
  List<TopBanners>? topBanners;
  List<Category>? category;
  bool? reviewStatus;
  List<CategoryBanners>? categoryBanners;

  HomeData({
    this.profile,
    this.userName,
    this.category,
    this.reviewStatus,
    this.topBanners,
    this.categoryBanners,
  });

  HomeData.fromJson(Map<String, dynamic> json) {
    profile = json['profile'];
    userName = json['userName'];
    if (json['category'] != null) {
      category = <Category>[];
      json['category'].forEach((v) {
        category!.add(Category.fromJson(v));
      });
    }
    if (json['topBanners'] != null) {
      topBanners = <TopBanners>[];
      json['topBanners'].forEach((v) {
        topBanners!.add(TopBanners.fromJson(v));
      });
    }
    if (json['categoryBanners'] != null) {
      categoryBanners = <CategoryBanners>[];
      json['categoryBanners'].forEach((v) {
        categoryBanners!.add(CategoryBanners.fromJson(v));
      });
    }
    reviewStatus = json['reviewStatus'];
  }
}

class Category {
  int? id;
  String? categoryName;
  String? categoryImage;
  String? categoryType;

  Category({this.id, this.categoryName, this.categoryImage, this.categoryType});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['categoryName'];
    categoryImage = json['categoryImage'];
    categoryType = json['categoryType'];
  }
}

class TopBanners {
  int? id;
  String? backgroundImage;
  String? image;
  String? title;
  String? subtitle;
  String? contact;
  String? status;
  String? createdAt;
  String? updatedAt;

  TopBanners({
    this.id,
    this.backgroundImage,
    this.image,
    this.title,
    this.subtitle,
    this.contact,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  TopBanners.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    backgroundImage = json['backgroundImage'];
    image = json['image'];
    title = json['title'];
    subtitle = json['subtitle'];
    contact = json['contact'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}

class CategoryBanners {
  int? id;
  String? category;
  String? backgroundImage;
  String? image;
  String? title;
  String? subtitle;
  String? contact;
  String? status;
  String? createdAt;
  String? updatedAt;

  CategoryBanners({
    this.id,
    this.category,
    this.backgroundImage,
    this.image,
    this.title,
    this.subtitle,
    this.contact,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  CategoryBanners.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = json['category'];
    backgroundImage = json['backgroundImage'];
    image = json['image'];
    title = json['title'];
    subtitle = json['subtitle'];
    contact = json['contact'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}
