import 'package:flutter/cupertino.dart';
import 'package:mapman/utils/constants/images.dart';

class HomeController extends ChangeNotifier {
  int _currentPage = 0;

  int get currentPage => _currentPage;

  set setCurrentPage(int value) {
    _currentPage = value;
    notifyListeners();
  }

  double _nearByShopHeight = 0.0;

  double get nearByShopHeight => _nearByShopHeight;

  set setNearByShopHeight(double value) {
    _nearByShopHeight = value;
    notifyListeners();
  }

  final List<String> _categories = [
    'Theater',
    'Restaurant',
    'Hospital',
    'Bars',
    'Grocery',
    'Textile',
    'Resort',
    'Bunk',
    'Spa',
    'Hotel',
    'Others',
  ];

  List<String> get categories => _categories;
  final List<String> _categoriesImages = [
    AppIcons.theaterP,
    AppIcons.restaurantP,
    AppIcons.hospitalP,
    AppIcons.barsP,
    AppIcons.shoppingP,
    AppIcons.uniformP,
    AppIcons.beachP,
    AppIcons.petrolP,
    AppIcons.spaP,
    AppIcons.hotelP,
    AppIcons.othersP,
  ];

  List<String> get categoriesImages => _categoriesImages;

  int _carousalCurrentIndex = 0;

  int get carousalCurrentIndex => _carousalCurrentIndex;

  void setCarousalIndex(int index) {
    _carousalCurrentIndex = index;
    notifyListeners();
  }

  int _homeBannerCurrentIndex = 0;

  int get homeBannerCurrentIndex => _homeBannerCurrentIndex;

  void setHomeBannerCurrentIndex(int index) {
    _homeBannerCurrentIndex = index;
    notifyListeners();
  }

  /// Notification

  bool _isEnableNotification = false;

  bool get isEnableNotification => _isEnableNotification;

  set setIsEnableNotification(bool value) {
    _isEnableNotification = value;
    notifyListeners();
  }

  bool _isSavedVideo = false;

  bool get isSavedVideo => _isSavedVideo;

  set setIsSavedVideo(bool value) {
    _isSavedVideo = value;
    notifyListeners();
  }

  bool _isVideoAlerts = false;

  bool get isVideoAlerts => _isVideoAlerts;

  set setIsVideoAlerts(bool value) {
    _isVideoAlerts = value;
    notifyListeners();
  }

  bool _isNewShopAlerts = false;

  bool get isNewShopAlerts => _isNewShopAlerts;

  set setIsNewShopAlerts(bool value) {
    _isNewShopAlerts = value;
    notifyListeners();
  }

  /// Viewed Video page
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
}
