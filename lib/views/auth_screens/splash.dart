import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/auth_controller.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/keys.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/storage/session_manager.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.read<AuthController>().setSplashAnimation(true);
    });

    handleNavigation();
  }

  Future<void> handleNavigation() async {
    await Future.delayed(const Duration(seconds: 4));
    final isFirstTime = !(SessionManager.containsKey(key: Keys.isFirstTime));
    final hasToken = SessionManager.containsKey(key: Keys.token);
    if (!mounted) return;
    if (isFirstTime) {
      context.go('/onboard_screen');
    } else if (!hasToken) {
      context.go('/login');
    } else {
      context.go('/main_dashboard', extra: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: authController.isShowSplashAnimation
          ? SplashWithLogo()
          : Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1700),
                curve: Curves.easeInOutCubic,
                builder: (context, t, _) {
                  final screen = MediaQuery.of(context).size;

                  final width = lerpDouble(200, screen.width, t)!;
                  final height = lerpDouble(200, screen.height, t)!;

                  final borderRadius = BorderRadius.circular(
                    lerpDouble(100, 0, t)!,
                  );

                  final logoOpacity = t < 0.55
                      ? 1.0
                      : (1 - (t - 0.55) * 2).clamp(0.0, 1.0);

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: width,
                        height: height,
                        decoration: BoxDecoration(
                          borderRadius: borderRadius,
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF0BF1FF),
                              Color(0xFF08A1FF),
                              Color(0xFF0682FF),
                            ],
                          ),
                        ),
                      ),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Opacity(
                            opacity: logoOpacity,
                            child: Image.asset(
                              AppIcons.splashLogoP,
                              height: 100,
                              width: 100,
                            ),
                          ),
                          Opacity(
                            opacity: t > 0.7 ? (t - 0.7) * 3 : 0,
                            child: BodyTextColors(
                              title: 'Map Man',
                              fontSize: 50,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}

class SplashWithLogo extends StatelessWidget {
  const SplashWithLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size.height / 3,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: -600.0, end: 0.0),
              duration: Duration(seconds: 1),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: child,
                );
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    AppIcons.appLogoP,
                    fit: BoxFit.cover,
                    height: 200,
                    width: 200,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height / 2.75,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 600.0, end: 0.0),
              duration: Duration(seconds: 1),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: child,
                );
              },
              child: Center(
                child: HeaderTextBlack(
                  title: 'Map Man',
                  fontSize: 50,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
