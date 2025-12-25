import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapman/model/home_model.dart';
import 'package:mapman/model/notification_model.dart';
import 'package:mapman/model/shop_search_data.dart';
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

  String? _searchCategory;

  String? get searchCategory => _searchCategory;

  set setSearchCategory(String? value) {
    _searchCategory = value;
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

  bool _isShowAddNewCategory = false;

  bool get isShowAddNewCategory => _isShowAddNewCategory;

  set setIsShowAddNewCategory(bool value) {
    _isShowAddNewCategory = value;
    notifyListeners();
  }

  /// Notification
  NotificationPreferenceData _initialPreferenceData =
      NotificationPreferenceData();

  NotificationPreferenceData _preferenceData = NotificationPreferenceData();

  NotificationPreferenceData get preferenceData => _preferenceData;

  void initPreferences(NotificationPreferenceData data) {
    _preferenceData = NotificationPreferenceData(
      enableNotifications: data.enableNotifications,
      savedVideo: data.savedVideo,
      newVideo: data.newVideo,
      newShop: data.newShop,
    );

    _initialPreferenceData = NotificationPreferenceData(
      enableNotifications: data.enableNotifications,
      savedVideo: data.savedVideo,
      newVideo: data.newVideo,
      newShop: data.newShop,
    );

    notifyListeners();
  }

  void updatePreferences({
    int? enableNotifications,
    int? savedVideo,
    int? newVideo,
    int? newShop,
  }) {
    _preferenceData.enableNotifications =
        enableNotifications ?? _preferenceData.enableNotifications;

    _preferenceData.savedVideo = savedVideo ?? _preferenceData.savedVideo;

    _preferenceData.newVideo = newVideo ?? _preferenceData.newVideo;

    _preferenceData.newShop = newShop ?? _preferenceData.newShop;

    notifyListeners();
  }

  bool get hasUnsavedChanges {
    return _preferenceData.enableNotifications !=
            _initialPreferenceData.enableNotifications ||
        _preferenceData.savedVideo != _initialPreferenceData.savedVideo ||
        _preferenceData.newVideo != _initialPreferenceData.newVideo ||
        _preferenceData.newShop != _initialPreferenceData.newShop;
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

  List<Category> _homeCategories = [];

  List<Category> get homeCategories => _homeCategories;

  /// Add response

  ApiResponse _apiResponse = ApiResponse.initial(Strings.noDataFound);

  ApiResponse get apiResponse => _apiResponse;

  /// Home data
  ApiResponse<HomeData> _homeData = ApiResponse.initial(Strings.noDataFound);

  ApiResponse<HomeData> get homeData => _homeData;

  ///Maps Data
  ApiResponse<List<ShopSearchData>> _shopSearchData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<List<ShopSearchData>> get shopSearchData => _shopSearchData;

  ApiResponse<List<ShopSearchData>> _nearByShopData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<List<ShopSearchData>> get nearByShopData => _nearByShopData;

  ///Notification data
  ApiResponse<NotificationPreferenceData> _notificationPreferenceData =
      ApiResponse.initial(Strings.noDataFound);

  ApiResponse<NotificationPreferenceData> get notificationPreferenceData =>
      _notificationPreferenceData;

  ApiResponse<List<NotificationsData>> _notificationsData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<List<NotificationsData>> get notificationsData =>
      _notificationsData;

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
          .where(
            (item) =>
                (item.categoryName?.isNotEmpty ?? false) &&
                item.categoryName!.toLowerCase() != 'others',
          )
          .map((item) => item.categoryName!)
          .toList();

      _homeCategories = (_homeData.data?.category ?? [])
          .where(
            (item) =>
                item.categoryType?.toLowerCase() == 'default' ||
                item.categoryName?.toLowerCase() == 'others',
          )
          .toList();
    } catch (e) {
      _homeData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _homeData;
  }

  Future<ApiResponse<List<ShopSearchData>>> getSearchShops({
    required String input,
  }) async {
    _shopSearchData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await homeService.getSearchShops(
        token: token,
        input: input,
      );
      final shopList = (response[Keys.data] as List)
          .map((e) => ShopSearchData.fromJson(e as Map<String, dynamic>))
          .toList();
      _shopSearchData = ApiResponse.completed(shopList);
    } catch (e) {
      _shopSearchData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _shopSearchData;
  }

  Future<Position> _getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> filterNearbyShops() async {
    _nearByShopData = ApiResponse.loading(Strings.loading);
    notifyListeners();

    try {
      final position = await _getCurrentLocation();
      final List<ShopSearchData> allShops = shopSearchData.data ?? [];

      final List<ShopSearchData> nearbyShops = allShops.where((shop) {
        final double? lat = double.tryParse(shop.lat ?? '');
        final double? lng = double.tryParse(shop.long ?? '');
        return lat != null && lng != null;
      }).toList();

      nearbyShops.sort((a, b) {
        final double latA = double.parse(a.lat!);
        final double lngA = double.parse(a.long!);

        final double latB = double.parse(b.lat!);
        final double lngB = double.parse(b.long!);

        final double distanceA = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          latA,
          lngA,
        );

        final double distanceB = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          latB,
          lngB,
        );

        return distanceA.compareTo(distanceB);
      });

      _nearByShopData = ApiResponse.completed(nearbyShops);
    } catch (e) {
      _nearByShopData = ApiResponse.error(e.toString());
    }

    notifyListeners();
  }

  /// Notification data
  Future<ApiResponse> addNotificationPreference({
    required NotificationPreferenceData preference,
  }) async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await homeService.addNotificationPreference(
        token: token,
        preference: preference,
      );
      _apiResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }

  Future<ApiResponse<NotificationPreferenceData>>
  getNotificationPreference() async {
    _notificationPreferenceData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await homeService.getNotificationPreference(
        token: token,
      );
      _notificationPreferenceData = ApiResponse.completed(
        NotificationPreferenceData.fromJson(
          response[Keys.data] as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      _notificationPreferenceData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _notificationPreferenceData;
  }

  Future<ApiResponse<List<NotificationsData>>> getNotifications() async {
    _notificationsData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final String token = SessionManager.getToken() ?? '';
      final response = await homeService.getNotifications(token: token);
      final List list = response[Keys.data] as List;
      final List<NotificationsData> notifications = list
          .map((e) => NotificationsData.fromJson(e))
          .toList();
      _notificationsData = ApiResponse.completed(notifications);
    } catch (e) {
      _notificationsData = ApiResponse.error(e.toString());
    }

    notifyListeners();
    return _notificationsData;
  }

  Future<ApiResponse> getNotificationCount() async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final String token = SessionManager.getToken() ?? '';
      final response = await homeService.getNotificationCount(token: token);
      _apiResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    notifyListeners();
    return _apiResponse;
  }

  /// Add Shop Category
  Future<ApiResponse> addNewCategory({required String categoryName}) async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await homeService.addNewCategory(
        token: token,
        categoryName: categoryName,
      );
      _apiResponse = ApiResponse.completed(response[Keys.data]);
      await getHome();
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }
}
