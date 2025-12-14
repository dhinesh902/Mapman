class ShopDetailData {
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
  List<String>? images;
  dynamic imageApprove;
  String? status;
  String? createdAt;
  String? updatedAt;

  ShopDetailData({
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
    this.images,
    this.imageApprove,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  ShopDetailData.fromJson(Map<String, dynamic> json) {
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
    images = json['images'].cast<String>();
    imageApprove = json['imageApprove'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}
