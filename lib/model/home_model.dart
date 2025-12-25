class HomeData {
  String? profile;
  String? userName;
  List<Category>? category;
  int? notificationCount;

  HomeData({
    this.profile,
    this.userName,
    this.category,
    this.notificationCount,
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
    notificationCount = json['notificationCount'];
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
