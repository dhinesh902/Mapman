import 'package:flutter/cupertino.dart';
import 'package:mapman/model/home_model.dart';
import 'package:mapman/service/home_service.dart';
import 'package:mapman/utils/constants/keys.dart';
import 'package:mapman/utils/constants/strings.dart';
import 'package:mapman/utils/handlers/api_response.dart';
import 'package:mapman/utils/storage/session_manager.dart';

class HomeController extends ChangeNotifier {
  final HomeService homeService = HomeService();
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



  String? _category;

  String? get category => _category;

  set setSelectedCategory(String? value) {
    _category = value;
    notifyListeners();
  }

  /// -------------------------- API FUNCTIONS --------------------------

  List<String> _categories = [];

  List<String> get categories => _categories;

  ApiResponse _apiResponse = ApiResponse.initial(Strings.noDataFound);

  ApiResponse get response => _apiResponse;

  ApiResponse<HomeData> _homeData = ApiResponse.initial(Strings.noDataFound);

  ApiResponse<HomeData> get homeData => _homeData;

  Future<ApiResponse<HomeData>> getHome() async {
    _homeData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await homeService.getHome(token: token);
      _homeData = ApiResponse.completed(
        HomeData.fromJson(response[Keys.data] as Map<String, dynamic>),
      );
      _categories = (_homeData.data?.category ?? [])
          .where((item) => item.categoryName?.isNotEmpty ?? false)
          .map((item) => item.categoryName!)
          .toList();
    } catch (e) {
      _homeData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _homeData;
  }
}
