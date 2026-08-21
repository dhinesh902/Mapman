import 'package:flutter/cupertino.dart';
import 'package:mapman/model/offers_model.dart';
import 'package:mapman/service/offer_service.dart';
import 'package:mapman/utils/constants/keys.dart';
import 'package:mapman/utils/constants/strings.dart';
import 'package:mapman/utils/handlers/api_response.dart';
import 'package:mapman/utils/storage/session_manager.dart';

class OfferController extends ChangeNotifier {
  final OfferService offerService = OfferService();

  ApiResponse _apiResponse = ApiResponse.initial(Strings.noDataFound);

  ApiResponse get apiResponse => _apiResponse;

  ApiResponse<List<BannerData>> _bannerData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<List<BannerData>> get bannerData => _bannerData;

  Future<ApiResponse> manageBannerImage({required BannerData banner}) async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await offerService.manageBannerImage(
        token: token,
        banner: banner,
      );
      _apiResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }

  Future<ApiResponse<List<BannerData>>> getShopBanners({required int shopId}) async {
    _bannerData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await offerService.getShopBanners(token: token, shopId: shopId);
      final bannerData = (response[Keys.data] as List)
          .map((e) => BannerData.fromJson(e))
          .toList();
      _bannerData = ApiResponse.completed(bannerData);
    } catch (e) {
      _bannerData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _bannerData;
  }

  Future<ApiResponse> deleteBanner({
    required int bannerId,
    required int shopId,
  }) async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await offerService.deleteBanner(
        token: token,
        bannerId: bannerId,
        shopId: shopId,
      );
      _apiResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }

  ApiResponse<List<OfferData>> _offerData = ApiResponse.initial(
    Strings.noDataFound,
  );

  ApiResponse<List<OfferData>> get offerData => _offerData;

  Future<ApiResponse> manageOffers({required Map<String, dynamic> data}) async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await offerService.manageOffers(
        token: token,
        data: data,
      );
      _apiResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }

  Future<ApiResponse<List<OfferData>>> getShopOffers({required int shopId}) async {
    _offerData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await offerService.fetchShopOffers(token: token, shopId: shopId);
      final list = (response[Keys.data] as List)
          .map((e) => OfferData.fromJson(e))
          .toList();
      _offerData = ApiResponse.completed(list);
    } catch (e) {
      _offerData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _offerData;
  }

  Future<ApiResponse> deleteOffer({
    required int offerId,
    required int shopId,
  }) async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await offerService.deleteOffers(
        token: token,
        offerId: offerId,
        shopId: shopId,
      );
      _apiResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }

  ApiResponse<List<ColorsData>> _colorsData = ApiResponse.initial(
    Strings.noDataFound,
  );
  ApiResponse<List<ColorsData>> get colorsData => _colorsData;

  Future<ApiResponse<List<ColorsData>>> fetchColors() async {
    _colorsData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await offerService.fetchColors(token: token);
      final list = (response[Keys.data] as List)
          .map((e) => ColorsData.fromJson(e))
          .toList();
      _colorsData = ApiResponse.completed(list);
    } catch (e) {
      _colorsData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _colorsData;
  }

  ApiResponse<List<IllustrationsData>> _illustrationsData = ApiResponse.initial(
    Strings.noDataFound,
  );
  ApiResponse<List<IllustrationsData>> get illustrationsData => _illustrationsData;

  Future<ApiResponse<List<IllustrationsData>>> fetchIllustrations() async {
    _illustrationsData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await offerService.fetchIllustrations(token: token);
      final list = (response[Keys.data] as List)
          .map((e) => IllustrationsData.fromJson(e))
          .toList();
      _illustrationsData = ApiResponse.completed(list);
    } catch (e) {
      _illustrationsData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _illustrationsData;
  }

  Future<ApiResponse> manageBannerText({required Map<String, dynamic> body}) async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await offerService.manageBannerText(
        token: token,
        body: body,
      );
      _apiResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }

  ApiResponse<List<OffersData>> _allOffersData = ApiResponse.initial(
    Strings.noDataFound,
  );
  ApiResponse<List<OffersData>> get allOffersData => _allOffersData;

  Future<ApiResponse<List<OffersData>>> fetchAllOffers() async {
    _allOffersData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await offerService.fetchAllOffers(token: token);
      final list = (response[Keys.data] as List)
          .map((e) => OffersData.fromJson(e))
          .toList();
      _allOffersData = ApiResponse.completed(list);
    } catch (e) {
      _allOffersData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _allOffersData;
  }

  Future<ApiResponse> offerStatusOpen({required int offerId}) async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await offerService.offerStatusOpen(
        token: token,
        offerId: offerId,
      );
      _apiResponse = ApiResponse.completed(response[Keys.data] ?? response['message']);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }

  ApiResponse<List<String>> _monthlyBannersData = ApiResponse.initial(Strings.noDataFound);
  ApiResponse<List<String>> get monthlyBannersData => _monthlyBannersData;

  Future<ApiResponse<List<String>>> fetchMonthlyBanners({required String month}) async {
    _monthlyBannersData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await offerService.fetchMonthlyBanners(
        token: token,
        month: month,
      );
      final list = (response[Keys.data] as List).map((e) => e.toString()).toList();
      _monthlyBannersData = ApiResponse.completed(list);
    } catch (e) {
      _monthlyBannersData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _monthlyBannersData;
  }

  ApiResponse<AvailableSlotModel> _dayBannersData = ApiResponse.initial(Strings.noDataFound);
  ApiResponse<AvailableSlotModel> get dayBannersData => _dayBannersData;

  Future<ApiResponse<AvailableSlotModel>> fetchDayBanners({required String date}) async {
    _dayBannersData = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await offerService.fetchDayBanners(
        token: token,
        date: date,
      );
      final data = AvailableSlotModel.fromJson(response);
      _dayBannersData = ApiResponse.completed(data);
    } catch (e) {
      _dayBannersData = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _dayBannersData;
  }
}
