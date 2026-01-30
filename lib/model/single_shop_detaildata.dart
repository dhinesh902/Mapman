import 'package:mapman/model/video_model.dart';

class SingleShopDetailData {
  Shop? shop;
  List<VideosData>? shopVideos;
  bool? shopSavedAlready;

  SingleShopDetailData({this.shop, this.shopVideos,this.shopSavedAlready});

  SingleShopDetailData.fromJson(Map<String, dynamic> json) {
    shop = json['shop'] != null ? Shop.fromJson(json['shop']) : null;
    if (json['shopVideos'] != null) {
      shopVideos = <VideosData>[];
      json['shopVideos'].forEach((v) {
        shopVideos!.add(VideosData.fromJson(v));
      });
    }
    shopSavedAlready = json['shopSavedAlready'];
  }
}

class Shop {
  int? id;
  int? profileId;
  String? shopImage;
  String? shopName;
  String? category;
  String? lat;
  String? long;
  String? address;
  String? description;
  String? registerNumber;
  String? shopNumber;
  String? openTime;
  String? closeTime;
  String? image1;
  String? image2;
  String? image3;
  String? image4;
  bool? shopSavedAlready;
  dynamic imageApprove;
  String? status;
  String? createdAt;
  String? updatedAt;

  Shop({
    this.id,
    this.profileId,
    this.shopImage,
    this.shopName,
    this.category,
    this.lat,
    this.long,
    this.address,
    this.description,
    this.registerNumber,
    this.shopNumber,
    this.openTime,
    this.closeTime,
    this.shopSavedAlready,
    this.image1,
    this.image2,
    this.image3,
    this.image4,
    this.imageApprove,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Shop.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    profileId = json['profileId'];
    shopImage = json['shopImage'];
    shopName = json['shopName'];
    category = json['category'];
    lat = json['lat'];
    long = json['long'];
    address = json['address'];
    description = json['description'];
    registerNumber = json['registerNumber'];
    shopNumber = json['shopNumber'];
    openTime = json['openTime'];
    closeTime = json['closeTime'];
    shopSavedAlready = json['shopSavedAlready'];
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
