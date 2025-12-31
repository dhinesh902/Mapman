import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapman/model/analytics_model.dart';
import 'package:mapman/model/profile_model.dart';
import 'package:mapman/model/shop_detail_model.dart';
import 'package:mapman/service/profile_service.dart';
import 'package:mapman/utils/constants/keys.dart';
import 'package:mapman/utils/constants/strings.dart';
import 'package:mapman/utils/handlers/api_response.dart';
import 'package:mapman/utils/storage/session_manager.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService profileService = ProfileService();

  bool _isActive = false;

  bool get isActive => _isActive;

  set setIsActive(bool value) {
    _isActive = value;
    notifyListeners();
  }

  bool _isActiveWhatsappNumber = false;

  bool get isActiveWhatsappNumber => _isActiveWhatsappNumber;

  set setIsActiveWhatsappNumber(bool value) {
    _isActiveWhatsappNumber = value;
    notifyListeners();
  }

  /// SHOP DETAILS UPDATE

  LatLng? _selectedLatLong;

  LatLng? get selectedLatLong => _selectedLatLong;

  set setSelectedLatLong(LatLng? value) {
    _selectedLatLong = value;
    notifyListeners();
  }

  List<String?> _shopImages = List.generate(4, (index) => null);

  List<String?> get shopImages => _shopImages;

  set setShopImages(List<String?> value) {
    _shopImages = value;
    notifyListeners();
  }

  void removeShopImageAt(int index) {
    if (index < 0 || index >= _shopImages.length) return;
    _shopImages[index] = null;
    notifyListeners();
  }

  /// ----------------------------- API FUNCTIONS -----------------------------

  ApiResponse _apiResponse = ApiResponse.initial(Strings.noDataFound);

  ApiResponse get apiResponse => _apiResponse;

  ApiResponse _deleteShopResponse = ApiResponse.initial(Strings.noDataFound);

  ApiResponse get deleteShopResponse => _deleteShopResponse;

  ApiResponse _deleteShopImageResponse = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse get deleteShopImageResponse => _deleteShopImageResponse;

  ApiResponse<ProfileData> _profileData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<ProfileData> get profileData => _profileData;

  ApiResponse<ShopDetailData> _shopDetailData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<ShopDetailData> get shopDetailData => _shopDetailData;

  ApiResponse<AnalyticsData> _analyticsData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<AnalyticsData> get analyticsData => _analyticsData;

  Future<ApiResponse<ProfileData>> getProfile() async {
    _profileData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await profileService.getProfile(token: token);
      if (response[Keys.data] != null) {
        _profileData = ApiResponse.completed(
          ProfileData.fromJson(response[Keys.data] as Map<String, dynamic>),
        );
      } else {
        _profileData = ApiResponse.completed(null);
      }
    } catch (e) {
      _profileData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _profileData;
  }

  Future<ApiResponse> updateProfile({
    required dynamic image,
    required ProfileData profileData,
  }) async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken()!;
      final response = await profileService.updateProfile(
        token: token,
        image: image,
        profileData: profileData,
      );
      _apiResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }

  Future<ApiResponse> registerShop({
    required ShopDetailImages shopImages,
    required ShopDetailData shopDetail,
  }) async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();

    try {
      final token = SessionManager.getToken() ?? '';

      final response = await profileService.registerShop(
        token: token,
        shopImages: shopImages,
        shopDetail: shopDetail,
      );

      _apiResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    notifyListeners();
    return _apiResponse;
  }

  Future<ApiResponse> deleteShopImage({
    required int shopId,
    required String input,
  }) async {
    _deleteShopImageResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await profileService.deleteShopImage(
        token: token,
        shopId: shopId,
        input: input,
      );
      _deleteShopImageResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _deleteShopImageResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _deleteShopImageResponse;
  }

  Future<ApiResponse> deleteShop({required int shopId}) async {
    _deleteShopResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await profileService.deleteShop(
        token: token,
        shopId: shopId,
      );
      _deleteShopResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _deleteShopResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _deleteShopResponse;
  }

  Future<ApiResponse<ShopDetailData?>> getShopDetail() async {
    _shopDetailData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await profileService.getShopDetail(token: token);
      final data = response[Keys.data];
      if (data != null && data is Map<String, dynamic>) {
        _shopDetailData = ApiResponse.completed(ShopDetailData.fromJson(data));
        SessionManager.setShopId(shopId: _shopDetailData.data?.id ?? 0);
        SessionManager.setShopName(
          shopName: _shopDetailData.data?.shopName ?? '',
        );
        SessionManager.setShopCategory(
          shopCategory: _shopDetailData.data?.category ?? '',
        );
      } else {
        SessionManager.setShopId(shopId: 0);
        _shopDetailData = ApiResponse.completed(null);
      }
    } catch (e) {
      _shopDetailData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _shopDetailData;
  }

  Future<ApiResponse<AnalyticsData?>> getAnalytics() async {
    _analyticsData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await profileService.getAnalytics(token: token);
      final data = response[Keys.data];
      if (data != null && data is Map<String, dynamic>) {
        _analyticsData = ApiResponse.completed(AnalyticsData.fromJson(data));
      } else {
        _analyticsData = ApiResponse.completed(null);
      }
    } catch (e) {
      _analyticsData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _analyticsData;
  }
}
