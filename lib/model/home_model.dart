class HomeData {
  String? profile;
  String? userName;
  List<Category>? category;

  HomeData({this.profile, this.userName, this.category});

  HomeData.fromJson(Map<String, dynamic> json) {
    profile = json['profile'];
    userName = json['userName'];
    if (json['category'] != null) {
      category = <Category>[];
      json['category'].forEach((v) {
        category!.add(Category.fromJson(v));
      });
    }
  }
}

class Category {
  int? id;
  String? categoryName;
  String? categoryImage;

  Category({this.id, this.categoryName, this.categoryImage});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['categoryName'];
    categoryImage = json['categoryImage'];
  }
}
