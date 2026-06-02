import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mapman/controller/home_controller.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/storage/session_manager.dart';
import 'package:mapman/views/main_dashboard/home/home.dart';
import 'package:mapman/views/main_dashboard/map/maps.dart';
import 'package:mapman/views/main_dashboard/profile/add_shop_detail.dart';
import 'package:mapman/views/main_dashboard/profile/profile.dart';
import 'package:mapman/views/main_dashboard/video/components/video_Dialogue.dart';
import 'package:mapman/views/main_dashboard/video/videos.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:mapman/views/widgets/login_bottom_sheet.dart';
import 'package:provider/provider.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key, this.isLogin = false});

  final bool isLogin;

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  late HomeController homeController;
  final List<Widget> _pages = [Home(), Maps(), Videos(), Profile()];

  DateTime? _lastBackPressed;

  @override
  void initState() {
    homeController = context.read<HomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForAppUpdate();
    });
    super.initState();
  }

  Future<void> _checkForAppUpdate() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      String latestVersion = currentVersion;

      try {
        final response = await Dio().get('${ApiRoutes.baseUrl}/app/version');
        if (response.statusCode == 200 && response.data != null) {
          latestVersion = response.data['version']?.toString() ?? currentVersion;
        }
      } catch (e) {
        debugPrint('Failed to fetch latest version: $e');
      }

      if (currentVersion != latestVersion && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A2D32), Color(0xFF131417)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.system_update_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    HeaderTextPrimary(
                      title: 'New Update Available',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    BodyTextColors(
                      title: 'We have just released a new version of the app. Please update to get the latest features and improvements.',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              _showSuccessDialogIfNeeded();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white30,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: BodyTextColors(
                                title: 'Later',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final String url = Platform.isAndroid 
                                  ? "https://play.google.com/store/apps/details?id=com.mapman.mapman"
                                  : "https://apps.apple.com/app/idYOUR_APP_ID";
                              final Uri uri = Uri.parse(url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4CAF50).withValues(alpha: .4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: BodyTextColors(
                                title: 'Update Now',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        _showSuccessDialogIfNeeded();
      }
    } catch (e) {
      _showSuccessDialogIfNeeded();
    }
  }

  void _showSuccessDialogIfNeeded() {
    if (widget.isLogin && mounted) {
      CustomDialogues.showSuccessDialog(
        context,
        title: 'Login Successfully!!',
        body: 'Welcome back!!.Your login was successful!',
      );
    }
  }

  Color getBackgroundColor(int currentPage, int currentVideoIndex) {
    if (currentPage == 2 && currentVideoIndex == 0) {
      return AppColors.lightViolet;
    }
    if (currentPage == 0 || (currentPage == 2 && currentVideoIndex != 1)) {
      return AppColors.scaffoldBackground;
    }
    return AppColors.scaffoldBackgroundDark;
  }

  @override
  Widget build(BuildContext context) {
    homeController = context.watch<HomeController>();
    final shopId = SessionManager.getShopId();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (homeController.currentPage != 0) {
          homeController.setCurrentPage = 0;
          return;
        }
        if (Platform.isIOS) return;
        final bool viewedStatus = SessionManager.getRating();
        if (!viewedStatus) {
          CustomDialogues().showRatingDialog(context);
          return;
        }
        final now = DateTime.now();
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;
          CustomToast.show(context, title: 'Press back again to exit');
        } else {
          SystemNavigator.pop();
        }
      },

      child: CustomSafeArea(
        color: getBackgroundColor(
          homeController.currentPage,
          context.watch<VideoController>().currentVideoIndex,
        ),
        child: Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          body: _pages[homeController.currentPage],
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: InkWell(
            onTap: () {
              homeController.setSearchCategory = 'all';
              homeController.setIsShowAddNearBy = false;
              homeController.getSearchShops(input: 'all');
              homeController.setCurrentPage = 1;
            },

            child: AnimatedGradientCircle(),
          ),
          bottomNavigationBar: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBottomNavigationBar.builder(
                height: 65,
                itemCount: 4,
                notchMargin: 8,
                rightCornerRadius: 6,
                leftCornerRadius: 6,
                gapWidth: 100,
                tabBuilder: (int index, bool isActive) {
                  final List<String> labels = [
                    "Home",
                    (shopId != null && shopId != 0) ? "Upload" : "Register",
                    "Video",
                    "Profile",
                  ];
                  final List<String> outlineIcons = [
                    AppIcons.homeOutline,
                    AppIcons.add,
                    AppIcons.videoOutline,
                    AppIcons.profileOutline,
                  ];
                  final List<String> fillIcons = [
                    AppIcons.homeFill,
                    AppIcons.add,
                    AppIcons.videoFill,
                    AppIcons.profileFill,
                  ];
                  bool isTabActive = index == 1 ? false : isActive;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        isTabActive ? fillIcons[index] : outlineIcons[index],
                        height: 24,
                        width: 24,
                        colorFilter: ColorFilter.mode(
                          isTabActive ? AppColors.darkText : AppColors.darkGrey,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 4),
                      BodyTextColors(
                        title: labels[index],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isTabActive
                            ? AppColors.darkText
                            : AppColors.darkGrey,
                      ),
                    ],
                  );
                },
                backgroundColor: AppColors.scaffoldBackground,
                borderColor: AppColors.primaryBorder,
                activeIndex: homeController.currentPage == 1
                    ? -1
                    : homeController.currentPage,
                gapLocation: GapLocation.center,
                notchSmoothness: NotchSmoothness.softEdge,
                elevation: 0,
                borderWidth: 1.5,
                onTap: (index) async {
                  if (index == 1) {
                    final token = SessionManager.getToken();
                    if (token != null) {
                      int? shopId = SessionManager.getShopId();
                      if (shopId != 0) {
                        VideoDialogues().showVideoUploadDialogue(context);
                      } else {
                        await showAddShopDetail(context);
                      }
                    } else {
                      await LoginBottomSheet.showLoginBottomSheet(context);
                    }
                  } else {
                    homeController.setCurrentPage = index;
                  }
                },
              ),
              Positioned(
                top: 45,
                child: HeaderTextPrimary(
                  title: "Maps",
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UploadFloatingActionButton extends StatelessWidget {
  const UploadFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: 56,
      padding: EdgeInsets.all(4),
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        border: Border.all(
          color: AppColors.primaryBorder.withValues(alpha: .1),
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBorder,
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: GenericColors.uploadPrimary,
        ),
        child: Center(child: SvgPicture.asset(AppIcons.telegram)),
      ),
    );
  }
}

class AnimatedGradientCircle extends StatefulWidget {
  const AnimatedGradientCircle({super.key});

  @override
  State<AnimatedGradientCircle> createState() => _AnimatedGradientCircleState();
}

class _AnimatedGradientCircleState extends State<AnimatedGradientCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          height: 65,
          width: 65,
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.fromLTRB(3, 2, 3, 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              startAngle: 0,
              endAngle: 3.14 * 2,
              transform: GradientRotation(_controller.value * 3.14 * 2),
              colors: [
                Color(0XFF04509B),
                GenericColors.homeTopPrimary,
                Color(0XFF0ACFFF),
                Color(0XFF04509B),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBorder.withValues(alpha: .4),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.whiteText,
            ),
            child: Center(child: Image.asset(AppGifs.uploadArrow, height: 23)),
          ),
        );
      },
    );
  }
}

// child: Container(
//   height: 65,
//   width: 65,
//   padding: EdgeInsets.all(4),
//   margin: EdgeInsets.fromLTRB(3, 2, 3, 0),
//   decoration: BoxDecoration(
//     color: AppColors.scaffoldBackground,
//     gradient: LinearGradient(
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//       colors: [
//         Color(0XFF04509B),
//         Color(0XFF0ACFFF),
//         GenericColors.darkYellow,
//       ],
//     ),
//     border: Border.all(
//       color: AppColors.primaryBorder.withValues(alpha: .1),
//     ),
//     shape: BoxShape.circle,
//     boxShadow: [
//       BoxShadow(
//         color: AppColors.primaryBorder,
//         spreadRadius: 1,
//         blurRadius: 2,
//         offset: Offset(0, 4),
//       ),
//     ],
//   ),
//   child: Container(
//     width: double.maxFinite,
//     height: double.maxFinite,
//     decoration: BoxDecoration(
//       shape: BoxShape.circle,
//       color: AppColors.whiteText,
//     ),
//     child: Stack(
//       fit: StackFit.expand,
//       children: [
//         Image.asset(AppGifs.upload1),
//         Center(child: SvgPicture.asset(AppIcons.telegram)),
//         Image.asset(AppGifs.upload2),
//       ],
//     ),
//   ),
// ),
