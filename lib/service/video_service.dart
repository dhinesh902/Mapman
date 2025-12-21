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
    required VideosData videoData,
  }) async {
    final shopId = SessionManager.getShopId() ?? 0;
    try {
      final FormData formData = FormData.fromMap({
        'shopId': shopId,
        'video': await MultipartFile.fromFile(
          video.path,
          filename: video.path.split('/').last,
        ),
        'videoTitle': videoData.videoTitle,
        'shopName': videoData.shopName,
        'category': videoData.category,
        'description': videoData.description,
      });

      final response = await dio.post(
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

  Future<Map<String, dynamic>> updateMyVideo({
    required String token,
    required VideosData videosData,
  }) async {
    try {
      final response = await dio.post(
        ApiRoutes.updateVideoDetails,
        options: headerWithToken(token),
        data: {
          "videoId": videosData.id,
          "shopId": videosData.shopId,
          "videoTitle": videosData.videoTitle,
          "shopName": videosData.shopName,
          "category": videosData.category,
          "description": videosData.description,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> replaceMyVideo({
    required String token,
    required File video,
    required int videoId,
  }) async {
    try {
      final FormData formData = FormData.fromMap({
        'videoId': videoId,
        'video': await MultipartFile.fromFile(
          video.path,
          filename: video.path.split('/').last,
        ),
      });
      final response = await dio.post(
        ApiRoutes.replaceVideo,
        options: headerWithToken(token),
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> deleteMyVideo({
    required String token,
    required int videoId,
  }) async {
    try {
      final response = await dio.post(
        ApiRoutes.deleteVideo,
        options: headerWithToken(token),
        data: {"videoId": videoId},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> addViewedVideos({
    required String token,
    required int videoId,
  }) async {
    try {
      final response = await dio.post(
        ApiRoutes.viewedVideos,
        options: headerWithToken(token),
        data: {'videoId': videoId},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> getMyViewedVideos({
    required String token,
  }) async {
    try {
      final response = await dio.get(
        ApiRoutes.fetchMyViewedVideos,
        options: headerWithToken(token),
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> addSavedVideos({
    required String token,
    required int videoId,
  }) async {
    try {
      final response = await dio.post(
        ApiRoutes.saveOthersVideos,
        options: headerWithToken(token),
        data: {'videoId': videoId},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> getMySavedVideos({required String token}) async {
    try {
      final response = await dio.get(
        ApiRoutes.fetchMySavedVideos,
        options: headerWithToken(token),
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> getCategoryVideos({
    required String token,
  }) async {
    try {
      final response = await dio.get(
        ApiRoutes.getCategoryVideos,
        options: headerWithToken(token),
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> getAllVideos({
    required String token,
    required String category,
  }) async {
    try {
      final response = await dio.get(
        ApiRoutes.allVideos,
        options: headerWithToken(token),
        queryParameters: {'category': category},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> getShopById({
    required String token,
    required int shopId,
  }) async {
    try {
      final response = await dio.post(
        ApiRoutes.getShopById,
        options: headerWithToken(token),
        data: {'shopId': shopId},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> getVideoPoints({required String token}) async {
    try {
      final response = await dio.get(
        ApiRoutes.fetchPoints,
        options: headerWithToken(token),
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }
}
