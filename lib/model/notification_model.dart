class NotificationPreferenceData {
  bool? enableNotifications;
  bool? savedVideo;
  bool? newVideo;
  bool? newShop;

  NotificationPreferenceData({
    this.enableNotifications,
    this.savedVideo,
    this.newVideo,
    this.newShop,
  });

  NotificationPreferenceData.fromJson(Map<String, dynamic> json) {
    enableNotifications = json['enableNotifications'];
    savedVideo = json['savedVideo'];
    newVideo = json['newVideo'];
    newShop = json['newShop'];
  }
}
