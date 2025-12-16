class VideosData {
  int? id;
  int? profileId;
  int? shopId;
  String? video;
  String? videoTitle;
  String? shopName;
  String? category;
  String? description;
  String? status;
  String? createdAt;
  String? updatedAt;

  VideosData({
    this.id,
    this.profileId,
    this.shopId,
    this.video,
    this.videoTitle,
    this.shopName,
    this.category,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  VideosData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    profileId = json['profileId'];
    shopId = json['shopId'];
    video = json['video'];
    videoTitle = json['videoTitle'];
    shopName = json['shopName'];
    category = json['category'];
    description = json['description'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}

class ViewedVideoData {
  int? id;
  String? videoTitle;
  String? video;

  ViewedVideoData({this.id, this.videoTitle, this.video});

  ViewedVideoData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    videoTitle = json['videoTitle'];
    video = json['video'];
  }
}
