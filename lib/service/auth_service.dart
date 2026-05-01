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

  Future<Map<String, dynamic>> updateSendOtp({
    required String email,
    required String phone,
  }) async {
    try {
      final response = await dio.post(
        ApiRoutes.updateSendOtp,
        data: {"email": email, "phone": phone},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> updateVerifyOtp({
    required String email,
    required int otp,
    required String phone,
  }) async {
    try {
      final response = await dio.post(
        ApiRoutes.updateVerifyOtp,
        data: {"email": email, "otp": otp, "phone": phone},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> checkEmailExists({required String email}) async {
    try {
      final response = await dio.post(
        ApiRoutes.checkEmailExists,
        data: {"email": email},
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

  Future<Map<String, dynamic>> sendMailOTP({required String email}) async {
    try {
      final response = await dio.post(
        ApiRoutes.sendMailOTP,
        data: {"email": email},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required int otp,
  }) async {
    try {
      final response = await dio.post(
        ApiRoutes.verifyEmailOtp,
        data: {"email": email, 'otp': otp},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> logout({required String token}) async {
    try {
      final response = await dio.get(
        ApiRoutes.logout,
        options: headerWithToken(token),
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> deleteAccount({required String token}) async {
    try {
      final response = await dio.get(
        ApiRoutes.deleteAccount,
        options: headerWithToken(token),
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

  Future<Map<String, dynamic>> addReview({
    required String token,
    required int review,
  }) async {
    try {
      final response = await dio.post(
        ApiRoutes.addReview,
        options: headerWithToken(token),
        data: {"reviews": review},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }
}
