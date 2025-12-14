import 'package:dio/dio.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/utils/handlers/api_exception.dart';

class AuthService extends ApiRoutes {
  Future<Map<String, dynamic>> sendOTP({required String phoneNumber}) async {
    try {
      final response = await dio.post(
        ApiRoutes.sendOTP,
        data: {"phoneNumber": phoneNumber},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> verifyOTP({
    required String phoneNumber,
    required int otp,
  }) async {
    try {
      final response = await dio.post(
        ApiRoutes.verifyOTP,
        data: {"phoneNumber": phoneNumber, 'otp': otp},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> addFcmToken({
    required String token,
    required String fcmToken,
  }) async {
    try {
      final response = await dio.post(
        ApiRoutes.addFcmToken,
        options: headerWithToken(token),
        data: {"fcmToken": fcmToken},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }
}
