import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:mapman/model/single_shop_detaildata.dart';
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
  int _isViewedVideo = 0;

  int get isViewedVideo => _isViewedVideo;

  void loadViewedVideoStatus() {
    _isViewedVideo = SessionManager.getViewedVideoStatus();
    notifyListeners();
  }

  Future<void> setIsViewedVideo(int value) async {
    _isViewedVideo = value;
    await SessionManager.setViewedVideoStatus(status: value);
    notifyListeners();
  }

  List<bool> bookmarked = [];

  void initializeBookmarks(List<VideosData> videos) {
    bookmarked = videos.map((video) => video.savedAlready == true).toList();
    notifyListeners();
  }

  bool toggleBookmark(int index) {
    bookmarked[index] = !bookmarked[index];
    notifyListeners();
    return bookmarked[index];
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

  String _selectedCategory = '';

  String get selectedCategory => _selectedCategory;

  set setSelectedCategory(String value) {
    _selectedCategory = value;
    notifyListeners();
  }

  /// -------------------------- API FUNCTIONS --------------------------
  ApiResponse _apiResponse = ApiResponse.initial(Strings.noDataFound);

  ApiResponse get response => _apiResponse;

  ApiResponse _coinResponse = ApiResponse.initial(Strings.noDataFound);

  ApiResponse get coinResponse => _coinResponse;

  ApiResponse _addCoinResponse = ApiResponse.initial(Strings.noDataFound);

  ApiResponse get addCoinResponse => _addCoinResponse;

  /// My Videos
  ApiResponse<List<VideosData>> _myVideosData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<List<VideosData>> get myVideosData => _myVideosData;

  /// Viewed Videos
  ApiResponse<List<VideosData>> _viewedVideoData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<List<VideosData>> get viewedVideoData => _viewedVideoData;

  /// Search state
  List<VideosData> _filteredViewedVideos = [];
  bool _isSearching = false;

  List<VideosData> get filteredViewedVideos =>
      _isSearching ? _filteredViewedVideos : (_viewedVideoData.data ?? []);

  /// Saved Videos
  ApiResponse<List<VideosData>> _savedVideoData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<List<VideosData>> get savedVideoData => _savedVideoData;

  /// Category Videos
  ApiResponse<List<CategoryVideosData>> _categoryVideoData =
      ApiResponse.initial(Strings.noDataFound);

  ApiResponse<List<CategoryVideosData>> get categoryVideoData =>
      _categoryVideoData;

  /// All Videos
  ApiResponse<List<VideosData>> _allVideosData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<List<VideosData>> get allVideosData => _allVideosData;

  /// Shop detail
  ApiResponse<SingleShopDetailData> _singleShopDetailData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<SingleShopDetailData> get singleShopDetailData =>
      _singleShopDetailData;

  /// video by id detail
  ApiResponse<VideosData> _videoByIdData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<VideosData> get videoByIdData => _videoByIdData;

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

  Future<ApiResponse> updateMyVideo({required VideosData videosData}) async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await videoService.updateMyVideo(
        token: token,
        videosData: videosData,
      );
      _apiResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }

  Future<ApiResponse> replaceMyVideo({
    required File video,
    required int videoId,
  }) async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await videoService.replaceMyVideo(
        token: token,
        video: video,
        videoId: videoId,
      );
      _apiResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }

  Future<ApiResponse> deleteMyVideo({required int videoId}) async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await videoService.deleteMyVideo(
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

  Future<ApiResponse<List<VideosData>>> getMyViewedVideos({
    bool removeBookMark = true,
  }) async {
    if (removeBookMark) {
      _viewedVideoData = ApiResponse.loading(Strings.loading);
      notifyListeners();
    }
    try {
      final String token = SessionManager.getToken() ?? '';
      final response = await videoService.getMyViewedVideos(token: token);
      final List list = response[Keys.data] ?? [];
      final List<VideosData> videos = list
          .map((e) => VideosData.fromJson(e as Map<String, dynamic>))
          .toList();
      _viewedVideoData = ApiResponse.completed(videos);
      _filteredViewedVideos.clear();
      _isSearching = false;
      initializeBookmarks(videos);
    } catch (e) {
      _viewedVideoData = ApiResponse.error(e.toString());
    }

    notifyListeners();
    return _viewedVideoData;
  }

  void filterViewedVideosByTitle(String query) {
    if (query.trim().isEmpty) {
      _isSearching = false;
      _filteredViewedVideos.clear();
    } else {
      _isSearching = true;
      _filteredViewedVideos = (_viewedVideoData.data ?? [])
          .where(
            (video) => (video.videoTitle ?? '').toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .toList();
    }
    notifyListeners();
  }

  Future<ApiResponse> addSavedVideos({
    required int videoId,
    required String status,
  }) async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await videoService.addSavedVideos(
        token: token,
        videoId: videoId,
        status: status,
      );
      _apiResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }

  Future<ApiResponse<List<VideosData>>> getMySavedVideos({
    bool removeBookMark = true,
  }) async {
    if (removeBookMark) {
      _savedVideoData = ApiResponse.loading(Strings.loading);
      notifyListeners();
    }
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await videoService.getMySavedVideos(token: token);
      final data = response[Keys.data];
      if (data != null && data is List) {
        _savedVideoData = ApiResponse.completed(
          data
              .map((e) => VideosData.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
        initializeBookmarks(_savedVideoData.data ?? []);
      } else {
        _savedVideoData = ApiResponse.completed([]);
      }
    } catch (e) {
      _savedVideoData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _savedVideoData;
  }

  Future<ApiResponse<List<CategoryVideosData>>> getCategoryVideos() async {
    _categoryVideoData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await videoService.getCategoryVideos(token: token);
      final data = response[Keys.data];
      if (data != null && data is List) {
        _categoryVideoData = ApiResponse.completed(
          data
              .map(
                (e) => CategoryVideosData.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        );
      } else {
        _categoryVideoData = ApiResponse.completed([]);
      }
    } catch (e) {
      _categoryVideoData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _categoryVideoData;
  }

  Future<ApiResponse<List<VideosData>>> getAllVideos({
    required String category,
  }) async {
    _allVideosData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await videoService.getAllVideos(
        token: token,
        category: category,
      );
      final data = response[Keys.data];
      if (data != null && data is List) {
        _allVideosData = ApiResponse.completed(
          data
              .map((e) => VideosData.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      } else {
        _allVideosData = ApiResponse.completed([]);
      }
    } catch (e) {
      _allVideosData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _allVideosData;
  }

  Future<ApiResponse<SingleShopDetailData>> getShopById({
    required int shopId,
  }) async {
    _singleShopDetailData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await videoService.getShopById(
        token: token,
        shopId: shopId,
      );
      final data = response[Keys.data];
      if (data != null && (data as Map).isNotEmpty) {
        _singleShopDetailData = ApiResponse.completed(
          SingleShopDetailData.fromJson(data as Map<String, dynamic>),
        );
      } else {
        _singleShopDetailData = ApiResponse.completed(null);
      }
    } catch (e) {
      _singleShopDetailData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _singleShopDetailData;
  }

  Future<ApiResponse> getVideoPoints() async {
    _coinResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await videoService.getVideoPoints(token: token);
      _coinResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _coinResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _coinResponse;
  }

  Future<ApiResponse> addVideoPoints() async {
    _addCoinResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await videoService.addVideoPoints(token: token);
      _addCoinResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _addCoinResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _addCoinResponse;
  }

  Future<ApiResponse<VideosData>> getVideoById({required int videoId}) async {
    _videoByIdData = ApiResponse.loading(Strings.loading);
    notifyListeners();

    try {
      final token = SessionManager.getToken() ?? '';
      final response = await videoService.geVideoById(
        token: token,
        videoId: videoId,
      );
      if (response[Keys.data] is List) {
        _videoByIdData = ApiResponse.completed(null);
      } else {
        final Map<String, dynamic> data =
            response[Keys.data] as Map<String, dynamic>;
        final video = VideosData.fromJson(data);
        _videoByIdData = ApiResponse.completed(video);
      }
    } catch (e) {
      _videoByIdData = ApiResponse.error(e.toString());
    }

    notifyListeners();
    return _videoByIdData;
  }
}
