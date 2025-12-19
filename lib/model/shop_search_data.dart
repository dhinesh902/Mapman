class ShopSearchData {
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
  dynamic imageApprove;
  String? status;
  String? createdAt;
  String? updatedAt;

  ShopSearchData({
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
    this.image1,
    this.image2,
    this.image3,
    this.image4,
    this.imageApprove,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  ShopSearchData.fromJson(Map<String, dynamic> json) {
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
