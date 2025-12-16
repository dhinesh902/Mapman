import 'package:mapman/model/video_model.dart';

class AnalyticsData {
  List<VideosData>? totalVideos;
  int? totalViews;

  AnalyticsData({this.totalVideos, this.totalViews});

  AnalyticsData.fromJson(Map<String, dynamic> json) {
    if (json['totalVideos'] != null) {
      totalVideos = <VideosData>[];
      json['totalVideos'].forEach((v) {
        totalVideos!.add(VideosData.fromJson(v));
      });
    }
    totalViews = json['totalViews'];
  }
}
