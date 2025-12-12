import 'package:flutter/cupertino.dart';
import 'package:mapman/utils/constants/images.dart';

class AuthController extends ChangeNotifier {
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

  /// ----------------------------- Login Page view -----------------------------

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

  /// ----------------------------- Login Page view -----------------------------
}
