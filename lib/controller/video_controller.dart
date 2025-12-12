import 'package:flutter/cupertino.dart';

class VideoController extends ChangeNotifier {
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
}
