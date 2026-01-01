import 'dart:io';

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
      if (widget.isLogin) {
        CustomDialogues.showSuccessDialog(
          context,
          title: 'Login Successfully!!',
          body: 'Welcome back!!.Your login was successful!',
        );
      }
    });
    super.initState();
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

        // If not on home page, go to home
        if (homeController.currentPage != 0) {
          homeController.setCurrentPage = 0;
          return;
        }

        if (Platform.isIOS) return;

        final int viewedStatus = SessionManager.getRating();

        if (viewedStatus == 0) {
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
            onTap: () async {
              if (shopId != 0) {
                VideoDialogues().showVideoUploadDialogue(context);
              } else {
                await showAddShopDetail(context);
              }
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
                    "Maps",
                    "Video",
                    "Profile",
                  ];
                  final List<String> outlineIcons = [
                    AppIcons.homeOutline,
                    AppIcons.locationOutline,
                    AppIcons.videoOutline,
                    AppIcons.profileOutline,
                  ];
                  final List<String> fillIcons = [
                    AppIcons.homeFill,
                    AppIcons.locationFill,
                    AppIcons.videoFill,
                    AppIcons.profileFill,
                  ];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        isActive ? fillIcons[index] : outlineIcons[index],
                        height: 24,
                        width: 24,
                        colorFilter: ColorFilter.mode(
                          isActive ? AppColors.darkText : AppColors.darkGrey,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 4),
                      BodyTextColors(
                        title: labels[index],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? AppColors.darkText
                            : AppColors.darkGrey,
                      ),
                    ],
                  );
                },
                backgroundColor: AppColors.scaffoldBackground,
                borderColor: AppColors.primaryBorder,
                activeIndex: homeController.currentPage,
                gapLocation: GapLocation.center,
                notchSmoothness: NotchSmoothness.softEdge,
                elevation: 0,
                borderWidth: 1.5,
                onTap: (index) {
                  if (index == 1) {
                    homeController.setSearchCategory = 'all';
                    homeController.setIsShowAddNearBy = false;
                  }
                  homeController.setCurrentPage = index;
                },
              ),
              Positioned(
                bottom: 1,
                child: HeaderTextPrimary(
                  title: shopId != 0 ? "Upload" : "Create",
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
                GenericColors.darkYellow.withValues(alpha: .7),
                Color(0XFF0ACFFF),
                Color(0XFF04509B),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBorder.withOpacity(.4),
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
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(AppGifs.upload1, fit: BoxFit.cover),
                Image.asset(AppGifs.upload2, fit: BoxFit.cover),
                Center(child: SvgPicture.asset(AppIcons.telegram)),
              ],
            ),
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
