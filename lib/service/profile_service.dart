import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mapman/model/profile_model.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/utils/handlers/api_exception.dart';

class ProfileService extends ApiRoutes {
  Future<Map<String, dynamic>> getProfile({required String token}) async {
    try {
      final response = await dio.get(
        ApiRoutes.getProfile,
        options: headerWithToken(token),
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required dynamic image,
    required ProfileData profileData,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'image': (image is String && image.startsWith('/images'))
            ? null
            : await MultipartFile.fromFile(
                image.path,
                filename: image.path.split('/').last,
              ),
        'userName': profileData.userName,
        'email': profileData.email,
      });

      final response = await dio.post(
        ApiRoutes.updateProfile,
        options: headerWithToken(token),
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> registerShop({
    required String token,
    required List<File> images,
  }) async {
    try {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('shopName', 'value'),
        MapEntry('category', 'value'),
      ]);

      final response = await dio.post(
        ApiRoutes.shopRegister,
        options: headerWithToken(token),
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> getShopDetail({required String token}) async {
    try {
      final response = await dio.get(
        ApiRoutes.fetchShop,
        options: headerWithToken(token),
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }
}
