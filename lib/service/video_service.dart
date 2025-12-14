import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/utils/storage/session_manager.dart';

class VideoService extends ApiRoutes {
  Future<Map<String, dynamic>> uploadMyVideos({
    required String token,
    required File video,
    required MyVideosData videoData,
  }) async {
    try {
      final FormData formData = FormData.fromMap({
        'shopId': SessionManager.getShopId() ?? 0,
        'video': await MultipartFile.fromFile(
          video.path,
          filename: video.path.split('/').last,
        ),
        'videoTitle': videoData.videoTitle,
        'shopName': videoData.shopName,
        'category': videoData.category,
        'description': videoData.description,
      });

      final response = await dio.get(
        ApiRoutes.videoRegister,
        options: headerWithToken(token),
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> getMyVideos({required String token}) async {
    try {
      final response = await dio.get(
        ApiRoutes.myVideos,
        options: headerWithToken(token),
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }
}
