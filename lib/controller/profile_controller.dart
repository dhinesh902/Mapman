import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  ApiResponse<ProfileData> _profileData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<ProfileData> get profileData => _profileData;

  ApiResponse<ShopDetailData> _shopDetailData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<ShopDetailData> get shopDetailData => _shopDetailData;

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
      } else {
        _shopDetailData = ApiResponse.completed(null);
      }
    } catch (e) {
      _shopDetailData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _shopDetailData;
  }
}
