import 'package:dio/dio.dart';
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
}
