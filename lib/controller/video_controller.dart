import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/service/video_service.dart';
import 'package:mapman/utils/constants/keys.dart';
import 'package:mapman/utils/constants/strings.dart';
import 'package:mapman/utils/handlers/api_response.dart';
import 'package:mapman/utils/storage/session_manager.dart';

class VideoController extends ChangeNotifier {
  final VideoService videoService = VideoService();

  bool _isVideoFileSize = false;

  bool get isVideoFileSize => _isVideoFileSize;

  set setVideoFileSize(bool value) {
    _isVideoFileSize = value;
    notifyListeners();
  }

  /// Viewed Video
  bool _isViewedVideo = true;

  bool get isViewedVideo => _isViewedVideo;

  set setIsViewedVideo(bool value) {
    _isViewedVideo = value;
    notifyListeners();
  }

  List<bool> bookmarked = [];

  void initializeBookmarks(int length) {
    bookmarked = List.generate(length, (index) => true);
    notifyListeners();
  }

  void toggleBookmark(int index) {
    bookmarked[index] = !bookmarked[index];
    notifyListeners();
  }

  /// video

  int _currentVideoIndex = 0;

  int get currentVideoIndex => _currentVideoIndex;

  set setCurrentVideoIndex(int value) {
    _currentVideoIndex = value;
    notifyListeners();
  }

  int _currentShopDetailIndex = 0;

  int get currentShopDetailIndex => _currentShopDetailIndex;

  set setCurrentShopDetailIndex(int value) {
    _currentShopDetailIndex = value;
    notifyListeners();
  }

  bool _isShowParticularShopVideos = false;

  bool get isShowParticularShopVideos => _isShowParticularShopVideos;

  set setShowParticularShopVideos(bool value) {
    _isShowParticularShopVideos = value;
    notifyListeners();
  }

  String? _selectedVideoCategory;

  String? get selectedVideoCategory => _selectedVideoCategory;

  set setSelectedVideoCategory(String? value) {
    _selectedVideoCategory = value;
    notifyListeners();
  }

  /// -------------------------- API FUNCTIONS --------------------------
  ApiResponse _apiResponse = ApiResponse.initial(Strings.noDataFound);

  ApiResponse get response => _apiResponse;

  /// My Videos
  ApiResponse<List<VideosData>> _myVideosData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<List<VideosData>> get myVideosData => _myVideosData;

  /// Viewed Videos
  ApiResponse<List<ViewedVideoData>> _viewedVideoData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<List<ViewedVideoData>> get viewedVideoData => _viewedVideoData;

  List<ViewedVideoData> _filteredViewedVideos = [];

  List<ViewedVideoData> get filteredViewedVideos =>
      _filteredViewedVideos.isNotEmpty
      ? _filteredViewedVideos
      : (_viewedVideoData.data ?? []);

  Future<ApiResponse> uploadMyVideos({
    required File video,
    required VideosData videoData,
  }) async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await videoService.uploadMyVideos(
        token: token,
        video: video,
        videoData: videoData,
      );
      _apiResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }

  Future<ApiResponse<List<VideosData>>> getMyVideos() async {
    _myVideosData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await videoService.getMyVideos(token: token);
      final data = response[Keys.data];
      if (data != null && data is List) {
        _myVideosData = ApiResponse.completed(
          data
              .map((e) => VideosData.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      } else {
        _myVideosData = ApiResponse.completed([]);
      }
    } catch (e) {
      _myVideosData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _myVideosData;
  }

  Future<ApiResponse> addViewedVideos({required int videoId}) async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await videoService.addViewedVideos(
        token: token,
        videoId: videoId,
      );
      _apiResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }

  Future<ApiResponse<List<ViewedVideoData>>> getMyViewedVideos() async {
    _viewedVideoData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await videoService.getMyViewedVideos(token: token);
      final data = response[Keys.data];
      if (data != null && data is List) {
        _viewedVideoData = ApiResponse.completed(
          data
              .map((e) => ViewedVideoData.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
        initializeBookmarks(_viewedVideoData.data?.length ?? 0);
      } else {
        _viewedVideoData = ApiResponse.completed([]);
      }
    } catch (e) {
      _viewedVideoData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _viewedVideoData;
  }

  void filterViewedVideosByTitle(String query) {
    if (query.isEmpty) {
      _filteredViewedVideos = [];
    } else {
      _filteredViewedVideos = _viewedVideoData.data!
          .where(
            (video) => (video.videoTitle ?? '').toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .toList();
    }
    notifyListeners();
  }
}
