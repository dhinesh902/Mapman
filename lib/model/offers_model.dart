class BannerImagesModel {
  int? status;
  List<BannerData>? data;

  BannerImagesModel({this.status, this.data});

  BannerImagesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <BannerData>[];
      json['data'].forEach((v) {
        data!.add(BannerData.fromJson(v));
      });
    }
  }
}

class BannerData {
  int? id;
  int? shopId;
  int? profileId;
  String? bannerType;
  String? type;
  dynamic image;
  String? headerText;
  String? description;
  String? cta;
  String? illustration;
  String? color;
  String? category;
  String? status;
  List<String>? bannerSchedule;

  BannerData({
    this.id,
    this.shopId,
    this.profileId,
    this.bannerType,
    this.type,
    this.image,
    this.headerText,
    this.description,
    this.cta,
    this.illustration,
    this.color,
    this.category,
    this.status,
    this.bannerSchedule,
  });

  BannerData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shopId = json['shopId'];
    profileId = json['profileId'];
    bannerType = json['bannerType'];
    type = json['type'];
    image = json['image'];
    headerText = json['headerText'];
    description = json['description'];
    cta = json['cta'];
    illustration = json['illustration'];
    color = json['color'];
    category = json['category'];
    status = json['status'];
    if (json['bannerSchedule'] != null) {
      bannerSchedule = json['bannerSchedule'].cast<String>();
    }
  }
}

class OfferModel {
  int? status;
  List<OfferData>? data;

  OfferModel({this.status, this.data});

  OfferModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <OfferData>[];
      json['data'].forEach((v) {
        data!.add(OfferData.fromJson(v));
      });
    }
  }
}

class OfferData {
  int? id;
  int? shopId;
  int? profileId;
  String? offerTitle;
  String? offerPercentage;
  String? offerExpiry;
  List<String>? offerDetails;
  List<String>? termsAndConditions;
  String? status;

  OfferData({
    this.id,
    this.shopId,
    this.profileId,
    this.offerTitle,
    this.offerPercentage,
    this.offerExpiry,
    this.offerDetails,
    this.termsAndConditions,
    this.status,
  });

  OfferData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shopId = json['shopId'];
    profileId = json['profileId'];
    offerTitle = json['offerTitle'];
    offerPercentage = json['offerPercentage'];
    offerExpiry = json['offerExpiry'];
    offerDetails = json['offerDetails'].cast<String>();
    termsAndConditions = json['termsAndConditions'].cast<String>();
    status = json['status'];
  }
}

class ColorsData {
  int? id;
  String? color;
  String? status;
  String? createdAt;
  String? updatedAt;

  ColorsData({
    this.id,
    this.color,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  ColorsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    color = json['color'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}

class IllustrationsData {
  int? id;
  String? illustration;
  String? status;
  String? createdAt;
  String? updatedAt;

  IllustrationsData({
    this.id,
    this.illustration,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  IllustrationsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    illustration = json['illustration'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}

class OffersModel {
  int? status;
  List<OffersData>? data;

  OffersModel({this.status, this.data});

  OffersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <OffersData>[];
      json['data'].forEach((v) {
        data!.add(new OffersData.fromJson(v));
      });
    }
  }
}

class OffersData {
  int? id;
  int? shopId;
  int? profileId;
  String? offerTitle;
  String? offerPercentage;
  String? offerExpiry;
  List<String>? offerDetails;
  List<String>? termsAndConditions;
  String? openStatus;
  String? status;
  String? createdAt;
  String? updatedAt;
  bool? isOpened;

  OffersData({
    this.id,
    this.shopId,
    this.profileId,
    this.offerTitle,
    this.offerPercentage,
    this.offerExpiry,
    this.offerDetails,
    this.termsAndConditions,
    this.openStatus,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.isOpened,
  });

  OffersData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shopId = json['shopId'];
    profileId = json['profileId'];
    offerTitle = json['offerTitle'];
    offerPercentage = json['offerPercentage'];
    offerExpiry = json['offerExpiry'];
    offerDetails = json['offerDetails'].cast<String>();
    termsAndConditions = json['termsAndConditions'].cast<String>();
    openStatus = json['openStatus'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isOpened = json['isOpened'];
  }
}

class AvailableSlotModel {
  int? status;
  Data? data;

  AvailableSlotModel({this.status, this.data});

  AvailableSlotModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  int? count;
  List<Banner>? banners;

  Data({this.count, this.banners});

  Data.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['banners'] != null) {
      banners = <Banner>[];
      json['banners'].forEach((v) {
        banners!.add(Banner.fromJson(v));
      });
    }
  }
}

class Banner {
  int? id;
  int? shopId;
  int? profileId;
  String? bannerType;
  String? image;
  dynamic headerText;
  dynamic description;
  dynamic cta;
  dynamic illustration;
  dynamic color;
  List<String>? bannerSchedule;
  String? status;
  String? createdAt;
  String? updatedAt;

  Banner({
    this.id,
    this.shopId,
    this.profileId,
    this.bannerType,
    this.image,
    this.headerText,
    this.description,
    this.cta,
    this.illustration,
    this.color,
    this.bannerSchedule,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Banner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shopId = json['shopId'];
    profileId = json['profileId'];
    bannerType = json['bannerType'];
    image = json['image'];
    headerText = json['headerText'];
    description = json['description'];
    cta = json['cta'];
    illustration = json['illustration'];
    color = json['color'];
    if (json['bannerSchedule'] != null) {
      bannerSchedule = json['bannerSchedule'].cast<String>();
    }
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}
