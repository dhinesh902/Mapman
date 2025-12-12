import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/auth_controller.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
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

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      context.go('/main_dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: authController.isShowSplashAnimation
            ? Container(
                height: double.maxFinite,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE7F1FF),
                      Color(0xFFB5D4FF),
                      Color(0xFF7BB2FF),
                      Color(0xFF4A90FF),
                    ],
                    stops: const [0.0, 0.35, 0.65, 1.0],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      bottom: MediaQuery.of(context).size.height / 2.2,
                      child: Image.asset(
                        AppIcons.splashLogoP,
                        height: 120,
                        width: 120,
                      ),
                    ),
                    Positioned(
                      bottom: MediaQuery.of(context).size.height / 2.5,
                      child: HeaderTextBlack(
                        title: "Map Man",
                        fontSize: 48,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : HeaderTextPrimary(
                title: "Map Man",
                fontSize: 56,
                fontWeight: FontWeight.w600,
              ),
      ),
    );
  }
}
