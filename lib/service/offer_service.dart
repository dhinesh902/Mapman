import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mapman/model/offers_model.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/utils/handlers/api_exception.dart';

class OfferService extends ApiRoutes {
  Future<Map<String, dynamic>> manageBannerImage({
    required String token,
    required BannerData banner,
  }) async {
    try {
      final formData = FormData.fromMap({
        "type": banner.type,
        'image': (banner.image is File)
            ? await MultipartFile.fromFile(
                banner.image.path,
                filename: banner.image.path.split('/').last,
              )
            : null,
        "shopId": banner.shopId,
        "bannerType": banner.bannerType,
        "bannerId": banner.id,
      });
      if (banner.bannerSchedule != null) {
        for (var i = 0; i < banner.bannerSchedule!.length; i++) {
          formData.fields.add(MapEntry('bannerSchedule', banner.bannerSchedule![i]));
        }
      }
      final response = await dio.post(
        ApiRoutes.manageBannerImage,
        options: headerWithToken(token),
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> getShopBanners({
    required String token,
    required int shopId,
  }) async {
    try {
      final response = await dio.get(
        ApiRoutes.fetchShopBanners,
        options: headerWithToken(token),
        queryParameters: {"shopId": shopId},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> deleteBanner({
    required String token,
    required int bannerId,
    required int shopId,
  }) async {
    try {
      final response = await dio.post(
        ApiRoutes.deleteBanner,
        options: headerWithToken(token),
        data: {"bannerId": bannerId, "shopId": shopId, "status": "inactive"},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> manageOffers({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.post(
        ApiRoutes.manageOffers,
        options: headerWithToken(token),
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> fetchShopOffers({
    required String token,
    required int shopId,
  }) async {
    try {
      final response = await dio.get(
        ApiRoutes.fetchShopOffers,
        options: headerWithToken(token),
        queryParameters: {"shopId": shopId},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> deleteOffers({
    required String token,
    required int offerId,
    required int shopId,
  }) async {
    try {
      final response = await dio.post(
        ApiRoutes.deleteOffers,
        options: headerWithToken(token),
        data: {"offerId": offerId, "shopId": shopId, "status": "inactive"},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> fetchColors({required String token}) async {
    try {
      final response = await dio.get(
        ApiRoutes.fetchColors,
        options: headerWithToken(token),
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> fetchIllustrations({
    required String token,
  }) async {
    try {
      final response = await dio.get(
        ApiRoutes.fetchIllustrations,
        options: headerWithToken(token),
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> manageBannerText({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    try {
      debugPrint('manageBannerText BODY: $body');
      final response = await dio.post(
        ApiRoutes.manageBannerText,
        options: headerWithToken(token),
        data: body,
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> fetchAllOffers({required String token}) async {
    try {
      final response = await dio.get(
        ApiRoutes.fetchAllOffers,
        options: headerWithToken(token),
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> offerStatusOpen({
    required String token,
    required int offerId,
  }) async {
    try {
      final response = await dio.get(
        ApiRoutes.offerStatusOpen,
        options: headerWithToken(token),
        queryParameters: {"offerId": offerId},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> fetchMonthlyBanners({
    required String token,
    required String month,
  }) async {
    try {
      final response = await dio.get(
        ApiRoutes.fetchMonthlyBanners,
        options: headerWithToken(token),
        queryParameters: {"month": month},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }

  Future<Map<String, dynamic>> fetchDayBanners({
    required String token,
    required String date,
  }) async {
    try {
      final response = await dio.get(
        ApiRoutes.fetchDayBanners,
        options: headerWithToken(token),
        queryParameters: {"date": date},
      );
      return response.data;
    } on DioException catch (e) {
      throw ExceptionHandler.handleApiException(e);
    }
  }
}
