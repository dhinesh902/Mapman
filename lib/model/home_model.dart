class HomeData {
  String? profile;
  String? userName;
  List<TopBanners>? topBanners;
  List<Category>? category;
  bool? reviewStatus;
  List<CategoryBanners>? categoryBanners;
  List<HomeShops>? shops;

  HomeData({
    this.profile,
    this.userName,
    this.category,
    this.reviewStatus,
    this.topBanners,
    this.categoryBanners,
    this.shops
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
    if (json['shops'] != null) {
      shops = <HomeShops>[];
      json['shops'].forEach((v) {
        shops!.add( HomeShops.fromJson(v));
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

class HomeShops {
  int? id;
  int? profileId;
  String? shopImage;
  String? shopName;
  String? category;
  String? lat;
  String? long;
  String? websiteLink;
  String? address;
  String? description;
  String? whatsappNumber;
  String? registerNumber;
  String? shopNumber;
  String? openTime;
  String? closeTime;
  String? image1;
  String? image2;
  String? image3;
  String? image4;
  dynamic imageApprove;
  String? status;
  String? createdAt;
  String? updatedAt;

  HomeShops({
    this.id,
    this.profileId,
    this.shopImage,
    this.shopName,
    this.category,
    this.lat,
    this.long,
    this.websiteLink,
    this.address,
    this.description,
    this.whatsappNumber,
    this.registerNumber,
    this.shopNumber,
    this.openTime,
    this.closeTime,
    this.image1,
    this.image2,
    this.image3,
    this.image4,
    this.imageApprove,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  HomeShops.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    profileId = json['profileId'];
    shopImage = json['shopImage'];
    shopName = json['shopName'];
    category = json['category'];
    lat = json['lat'];
    long = json['long'];
    websiteLink = json['websiteLink'];
    address = json['address'];
    description = json['description'];
    whatsappNumber = json['whatsappNumber'];
    registerNumber = json['registerNumber'];
    shopNumber = json['shopNumber'];
    openTime = json['openTime'];
    closeTime = json['closeTime'];
    image1 = json['image1'];
    image2 = json['image2'];
    image3 = json['image3'];
    image4 = json['image4'];
    imageApprove = json['imageApprove'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}

class VersionData {
  String? androidVersion;
  String? iosVersion;
  String? forceUpdate;
  String? updateTitle;
  String? updateMessage;
  String? androidStoreUrl;
  String? iosStoreUrl;

  VersionData({
    this.androidVersion,
    this.iosVersion,
    this.forceUpdate,
    this.updateTitle,
    this.updateMessage,
    this.androidStoreUrl,
    this.iosStoreUrl,
  });

  VersionData.fromJson(Map<String, dynamic> json) {
    androidVersion = json['androidVersion']?.toString();
    iosVersion = json['iosVersion']?.toString();
    forceUpdate = json['forceUpdate']?.toString();
    updateTitle = json['updateTitle']?.toString();
    updateMessage = json['updateMessage']?.toString();
    androidStoreUrl = json['androidStoreUrl']?.toString();
    iosStoreUrl = json['iosStoreUrl']?.toString();
  }
}
