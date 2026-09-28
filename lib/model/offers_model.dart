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
  String? fontColor;
  String? backgroundColor;
  String? font;
  String? description;
  String? cta;
  String? backgroundImage;
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
    this.fontColor,
    this.backgroundColor,
    this.font,
    this.description,
    this.cta,
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
    fontColor = json['fontColor'];
    backgroundColor = json['backgroundColor'];
    font = json['font'];
    description = json['description'];
    cta = json['cta'];
    backgroundImage = json['backgroundImage'];
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
    if (json['offerDetails'] != null) {
      offerDetails = json['offerDetails'].cast<String>();
    }
    if (json['termsAndConditions'] != null) {
      termsAndConditions = json['termsAndConditions'].cast<String>();
    }
    status = json['status'];
  }
}

class BackgroundImageModel {
  int? status;
  List<BackgroundImageData>? data;

  BackgroundImageModel({this.status, this.data});

  BackgroundImageModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <BackgroundImageData>[];
      json['data'].forEach((v) {
        data!.add(BackgroundImageData.fromJson(v));
      });
    }
  }
}

class BackgroundImageData {
  int? id;
  String? backgroundImage;
  String? status;
  String? createdAt;
  String? updatedAt;

  BackgroundImageData({
    this.id,
    this.backgroundImage,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  BackgroundImageData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    backgroundImage = json['backgroundImage'];
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
        data!.add(OffersData.fromJson(v));
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
    if (json['offerDetails'] != null) {
      offerDetails = json['offerDetails'].cast<String>();
    }
    if (json['termsAndConditions'] != null) {
      termsAndConditions = json['termsAndConditions'].cast<String>();
    }
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
