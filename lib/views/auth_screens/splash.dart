import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/auth_controller.dart';
import 'package:mapman/controller/profile_controller.dart';
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

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _slideController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    /// Logo Scale Animation
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutBack),
    );

    /// Fade Animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeIn));

    /// Logo Left -> Right Animation
    _logoSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.8), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutExpo),
        );

    /// Text Right -> Left Animation
    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(1.2, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _mainController.forward();

    Future.delayed(const Duration(milliseconds: 250), () {
      _slideController.forward();
    });

    handleNavigation();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> handleNavigation() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    context.read<AuthController>().setSplashAnimation(true);
    final isFirstTime = !(SessionManager.containsKey(key: Keys.isFirstTime));
    final hasToken = SessionManager.containsKey(key: Keys.token);
    final token = SessionManager.getToken();
    if (token != null) {
      await context.read<ProfileController>().getProfile();
    }
    if (!mounted) return;
    if (isFirstTime) {
      context.go('/onboard_screen');
    } else if (!hasToken) {
      context.go('/login');
    } else {
      final profile = context.read<ProfileController>().profileData.data;
      if (profile != null &&
          (profile.userName == null ||
              profile.userName!.isEmpty ||
              profile.district == null ||
              profile.district!.isEmpty ||
              profile.state == null ||
              profile.state!.isEmpty)) {
        context.go('/login_profile');
      } else {
        context.go('/main_dashboard', extra: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundDark,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                /// LOGO
                SlideTransition(
                  position: _logoSlideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 60),
                      child: Image.asset(
                        AppIcons.appLogoP,
                        height: 350,
                        width: 350,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                /// APP NAME
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.37,
                  child: SlideTransition(
                    position: _textSlideAnimation,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1200),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BodyTextColors(
                            title: "MAPMAN",
                            fontSize: 34,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0D1025),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: HeaderTextBlack(
                              title: '®',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                /// ANIMATED GRADIENT LINE
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.36,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1400),
                    tween: Tween(begin: 0.0, end: 150),
                    curve: Curves.easeOutCubic,
                    builder: (context, width, child) {
                      return Container(
                        width: width,
                        height: 2.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xFF42C7F4),
                              Color(0xFF2D7EF7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// TAGLINE
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.29,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.4),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _mainController,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: const BodyTextColors(
                        title: "FIND • EXPLORE • EARN",
                        fontSize: 18,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//
//     Future.delayed(const Duration(seconds: 2), () {
//       if (!mounted) return;
//       context.read<AuthController>().setSplashAnimation(true);
//     });
//
//     handleNavigation();
//   }
//
//   Future<void> handleNavigation() async {
//     await Future.delayed(const Duration(seconds: 4));
//     final isFirstTime = !(SessionManager.containsKey(key: Keys.isFirstTime));
//     final hasToken = SessionManager.containsKey(key: Keys.token);
//     final token = SessionManager.getToken();
//     if (token != null) {
//       await context.read<ProfileController>().getProfile();
//     }
//     if (!mounted) return;
//     if (isFirstTime) {
//       context.go('/onboard_screen');
//     } else if (!hasToken) {
//       context.go('/login');
//     } else {
//       final profile = context.read<ProfileController>().profileData.data;
//       if (profile != null &&
//           (profile.userName == null ||
//               profile.userName!.isEmpty ||
//               profile.district == null ||
//               profile.district!.isEmpty ||
//               profile.state == null ||
//               profile.state!.isEmpty)) {
//         context.go('/login_profile');
//       } else {
//         context.go('/main_dashboard', extra: false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final authController = context.watch<AuthController>();
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackground,
//       body: authController.isShowSplashAnimation
//           ? SplashWithLogo()
//           : Center(
//               child: TweenAnimationBuilder<double>(
//                 tween: Tween(begin: 0.0, end: 1.0),
//                 duration: const Duration(milliseconds: 1700),
//                 curve: Curves.easeInOutCubic,
//                 builder: (context, t, _) {
//                   final screen = MediaQuery.of(context).size;
//
//                   final width = lerpDouble(200, screen.width, t)!;
//                   final height = lerpDouble(200, screen.height, t)!;
//
//                   final borderRadius = BorderRadius.circular(
//                     lerpDouble(100, 0, t)!,
//                   );
//
//                   final logoOpacity = t < 0.55
//                       ? 1.0
//                       : (1 - (t - 0.55) * 2).clamp(0.0, 1.0);
//
//                   return Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       Container(
//                         width: width,
//                         height: height,
//                         decoration: BoxDecoration(
//                           borderRadius: borderRadius,
//                           gradient: const LinearGradient(
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                             colors: [
//                               Color(0xFF0BF1FF),
//                               Color(0xFF08A1FF),
//                               Color(0xFF0682FF),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Opacity(
//                             opacity: logoOpacity,
//                             child: Image.asset(
//                               AppIcons.splashLogoP,
//                               height: 100,
//                               width: 100,
//                             ),
//                           ),
//                           Opacity(
//                             opacity: t > 0.7 ? (t - 0.7) * 3 : 0,
//                             child: BodyTextColors(
//                               title: 'Map Man',
//                               fontSize: 50,
//                               fontWeight: FontWeight.w700,
//                               color: AppColors.darkText,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//     );
//   }
// }
//
// class SplashWithLogo extends StatelessWidget {
//   const SplashWithLogo({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Center(
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Positioned(
//             top: size.height / 3,
//             child: TweenAnimationBuilder<double>(
//               tween: Tween(begin: -600.0, end: 0.0),
//               duration: Duration(seconds: 1),
//               curve: Curves.easeOut,
//               builder: (context, value, child) {
//                 return Transform.translate(
//                   offset: Offset(0, value),
//                   child: child,
//                 );
//               },
//               child: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Image.asset(
//                     AppIcons.appLogoP,
//                     fit: BoxFit.cover,
//                     height: 200,
//                     width: 200,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: size.height / 2.75,
//             child: TweenAnimationBuilder<double>(
//               tween: Tween(begin: 600.0, end: 0.0),
//               duration: Duration(seconds: 1),
//               curve: Curves.easeOut,
//               builder: (context, value, child) {
//                 return Transform.translate(
//                   offset: Offset(0, value),
//                   child: child,
//                 );
//               },
//               child: Center(
//                 child: HeaderTextBlack(
//                   title: 'Map Man',
//                   fontSize: 50,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
