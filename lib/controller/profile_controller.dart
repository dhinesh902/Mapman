import 'package:flutter/cupertino.dart';
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

  Future<ApiResponse<ShopDetailData?>> getShopDetail() async {
    _shopDetailData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token not found');
      }
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
