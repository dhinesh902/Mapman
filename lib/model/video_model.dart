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
  bool? watched;
  bool? savedAlready;
  int? views;
  int? viewCount;

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
    this.watched,
    this.savedAlready,
    this.views,
    this.viewCount,
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
    watched = json['watched'];
    savedAlready = json['savedAlready'];
    views = json['views'];
    viewCount = json['viewCount'];
  }
}

/// ALL VIDEOS
class CategoryVideosData {
  int? id;
  int? categoryId;
  String? categoryVideo;
  String? status;
  String? categoryName;
  String? createdAt;
  String? updatedAt;

  CategoryVideosData({
    this.id,
    this.categoryId,
    this.categoryVideo,
    this.categoryName,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  CategoryVideosData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['categoryId'];
    categoryVideo = json['categoryVideo'];
    categoryName = json['categoryName'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}
