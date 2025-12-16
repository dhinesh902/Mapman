import 'package:dio/dio.dart';
import 'package:mapman/utils/constants/keys.dart';

abstract class ApiRoutes {
  static final BaseOptions options = BaseOptions(
    baseUrl: baseUrl,
    contentType: 'application/json',
  );

  final Dio dio;

  ApiRoutes()
    : dio = Dio(
        BaseOptions(baseUrl: baseUrl, contentType: 'application/json'),
      ) {
    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  Options headerWithToken(String token) {
    return Options(headers: {Keys.userToken: token});
  }

  static const String baseUrl = 'https://2sdfshx9-3000.inc1.devtunnels.ms';

  static const String sendOTP = '/shop/auth/sendOtp';
  static const String verifyOTP = '/shop/auth/verifyOtp';
  static const String logout = '/shop/auth/logout';
  static const String addFcmToken = '/member/addFcmToken';
  static const String updateProfile = '/shop/updateProfile';
  static const String getProfile = '/shop/getProfile';
  static const String shopRegister = '/shop/shopRegister';
  static const String home = '/shop/home';
  static const String fetchShop = '/shop/fetchShop';
  static const String videoRegister = '/shop/videoRegister';
  static const String myVideos = '/shop/myVideos';
  static const String viewedVideos = '/shop/viewedVideos';
  static const String fetchMyViewedVideos = '/shop/fetchMyViewedVideos';
  static const String updateVideoDetails = '/shop/updateVideoDetails';
  static const String replaceVideo = '/shop/replaceVideo';
  static const String deleteVideo = '/shop/deleteVideo';
  static const String saveOthersVideos = '/shop/saveOthersVideos';
  static const String fetchMySavedVideos = '/shop/fetchMySavedVideos';
  static const String getCategoryVideos = '/shop/getCategoryVideos';
  static const String allVideos = '/shop/allVideos';
  static const String analytics = '/shop/analytics';
}
