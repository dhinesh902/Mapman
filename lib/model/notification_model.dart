class NotificationsData {
  int? id;
  int? userId;
  String? msgTitle;
  String? msgImage;
  dynamic msgLink;
  String? msgType;
  String? msgDesc;
  String? msgStatus;
  String? readStatus;
  String? createdAt;

  NotificationsData({
    this.id,
    this.userId,
    this.msgTitle,
    this.msgImage,
    this.msgLink,
    this.msgType,
    this.msgDesc,
    this.msgStatus,
    this.readStatus,
    this.createdAt,
  });

  NotificationsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    msgTitle = json['msgTitle'];
    msgImage = json['msgImage'];
    msgLink = json['msgLink'];
    msgType = json['msgType'];
    msgDesc = json['msgDesc'];
    msgStatus = json['msgStatus'];
    readStatus = json['readStatus'];
    createdAt = json['createdAt'];
  }
}

class NotificationPreferenceData {
  int? enableNotifications;
  int? savedVideo;
  int? newVideo;
  int? newShop;

  NotificationPreferenceData({
    this.enableNotifications = 0,
    this.savedVideo = 0,
    this.newVideo = 0,
    this.newShop = 0,
  });

  factory NotificationPreferenceData.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceData(
      enableNotifications: json['enableNotifications'] == 1 ? 1 : 0,
      savedVideo: json['savedVideo'] == 1 ? 1 : 0,
      newVideo: json['newVideo'] == 1 ? 1 : 0,
      newShop: json['newShop'] == 1 ? 1 : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "enableNotifications": enableNotifications,
      "savedVideo": savedVideo,
      "newVideo": newVideo,
      "newShop": newShop,
    };
  }
}
