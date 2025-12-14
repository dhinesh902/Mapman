import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:mapman/model/home_model.dart';
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

  ApiResponse<List<MyVideosData>> _myVideosData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<List<MyVideosData>> get myVideosData => _myVideosData;

  Future<ApiResponse> uploadMyVideos({
    required File video,
    required MyVideosData videoData,
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

  Future<ApiResponse<List<MyVideosData>>> getMyVideos() async {
    _myVideosData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await videoService.getMyVideos(token: token);
      final data = response[Keys.data];
      if (data != null && data is List) {
        _myVideosData = ApiResponse.completed(
          data
              .map((e) => MyVideosData.fromJson(e as Map<String, dynamic>))
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
}
