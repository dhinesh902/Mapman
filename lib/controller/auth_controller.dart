import 'package:flutter/cupertino.dart';
import 'package:mapman/service/auth_service.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/keys.dart';
import 'package:mapman/utils/constants/strings.dart';
import 'package:mapman/utils/handlers/api_response.dart';
import 'package:mapman/utils/storage/session_manager.dart';

class AuthController extends ChangeNotifier {
  final AuthService authService = AuthService();

  bool _isShowSplashAnimation = false;

  bool get isShowSplashAnimation => _isShowSplashAnimation;

  void setSplashAnimation(bool value) {
    _isShowSplashAnimation = value;
    notifyListeners();
  }

  final List<String> _loginImages = [
    AppIcons.login1P,
    AppIcons.login2P,
    AppIcons.login3P,
    AppIcons.login4P,
    AppIcons.login5P,
    AppIcons.login6P,
    AppIcons.login7P,
    AppIcons.login8P,
    AppIcons.login9P,
    AppIcons.login10P,
    AppIcons.login11P,
    AppIcons.login4P,
    AppIcons.login12P,
    AppIcons.login13P,
    AppIcons.login5P,
    AppIcons.login14P,
    AppIcons.login15P,
    AppIcons.login7P,
  ];

  List<String> get loginImages => _loginImages;

  final PageController pageController = PageController();

  /// Login page page view

  int _currentPage = 0;

  int get currentPage => _currentPage;

  void jumpTo(int page) {
    _currentPage = page;
    pageController.jumpToPage(page);
    notifyListeners();
  }

  Future<void> animateTo(int page) async {
    _currentPage = page;
    await pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  void onPageChanged(int page) {
    _currentPage = page;
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  /// --------------------------- API CONNECTIONS ---------------------------

  ApiResponse _apiResponse = ApiResponse.initial(Strings.noDataFound);

  ApiResponse get apiResponse => _apiResponse;

  Future<ApiResponse> sendOTP({required String phoneNumber}) async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final response = await authService.sendOTP(phoneNumber: phoneNumber);
      _apiResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }

  Future<ApiResponse> verifyOTP({
    required String phoneNumber,
    required int otp,
  }) async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final response = await authService.verifyOTP(
        phoneNumber: phoneNumber,
        otp: otp,
      );
      final String token = response[Keys.data][Keys.token] ?? '';
      final int userId = response[Keys.data][Keys.userId] ?? '';
      await SessionManager.setToken(token: token);
      await SessionManager.setUserId(userId: userId);
      _apiResponse = ApiResponse.completed(response[Keys.data]);
      await addFcmToken();
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }

  Future<ApiResponse> logout() async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await authService.logout(token: token);
      _apiResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }

  Future<ApiResponse> deleteAccount() async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final response = await authService.deleteAccount(token: token);
      _apiResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }

  Future<ApiResponse> addFcmToken() async {
    _apiResponse = ApiResponse.loading(Strings.loading);
    notifyListeners();
    try {
      final token = SessionManager.getToken() ?? '';
      final fcmToken = SessionManager.getDeviceId() ?? '';
      final response = await authService.addFcmToken(
        token: token,
        fcmToken: fcmToken,
      );
      _apiResponse = ApiResponse.completed(response[Keys.data]);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
    return _apiResponse;
  }
}
