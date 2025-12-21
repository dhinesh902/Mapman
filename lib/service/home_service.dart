import 'package:dio/dio.dart';
import 'package:mapman/model/notification_model.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/utils/handlers/api_exception.dart';

class HomeService extends ApiRoutes {
  Future<Map<String, dynamic>> getHome({required String token}) async {
    try {
      final response = await dio.get(
        ApiRoutes.home,
        options: headerWithToken(token),
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> getSearchShops({
    required String token,
    required String input,
  }) async {
    try {
      final response = await dio.get(
        ApiRoutes.searchShops,
        options: headerWithToken(token),
        queryParameters: {'input': input},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> addNotificationPreference({
    required String token,
    required NotificationPreferenceData preference,
  }) async {
    try {
      final response = await dio.post(
        ApiRoutes.notificationPreference,
        options: headerWithToken(token),
        data: {
          "enableNotifications": preference.enableNotifications,
          "savedVideo": preference.savedVideo,
          "newVideo": preference.newVideo,
          "newShop": preference.newShop,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> getNotificationPreference({
    required String token,
  }) async {
    try {
      final response = await dio.get(
        ApiRoutes.fetchNotificationPreference,
        options: headerWithToken(token),
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }
}
