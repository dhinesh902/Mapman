import 'package:dio/dio.dart';
import 'package:mapman/model/profile_model.dart';
import 'package:mapman/model/shop_detail_model.dart';
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

  Future<MultipartFile> _fileFromPath(String path) async {
    return MultipartFile.fromFile(path, filename: path.split('/').last);
  }

  Future<Map<String, dynamic>> registerShop({
    required String token,
    required ShopDetailImages shopImages,
    required ShopDetailData shopDetail,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'shopName': shopDetail.shopName,
        'category': shopDetail.category,
        'lat': shopDetail.lat,
        'long': shopDetail.long,
        'description': shopDetail.description,
        'openTime': shopDetail.openTime,
        'closeTime': shopDetail.closeTime,
        'address': shopDetail.address,
        'registerNumber': shopDetail.registerNumber,
        'shopNumber': shopDetail.shopNumber,
      };
      if (shopImages.shopImage != null) {
        data['shopImage'] = await _fileFromPath(shopImages.shopImage!.path);
      }
      if (shopImages.image1 != null) {
        data['image1'] = await _fileFromPath(shopImages.image1!.path);
      }
      if (shopImages.image2 != null) {
        data['image2'] = await _fileFromPath(shopImages.image2!.path);
      }
      if (shopImages.image3 != null) {
        data['image3'] = await _fileFromPath(shopImages.image3!.path);
      }
      if (shopImages.image4 != null) {
        data['image4'] = await _fileFromPath(shopImages.image4!.path);
      }
      final formData = FormData.fromMap(data);
      for (var field in formData.fields) {
        print('FIELD → ${field.key}: ${field.value}');
      }
      for (var file in formData.files) {
        print('FILE → ${file.key}: ${file.value.filename}');
      }

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
