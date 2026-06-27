import 'dart:io';

import 'package:mapman/model/home_model.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/handlers/api_response.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
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

  late ApiResponse<VersionData> _apiResponse;

  Future<void> _checkForAppUpdate() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      String? latestVersion = "";
      bool forceUpdate = false;

      try {
        _apiResponse = await context.read<HomeController>().getVersion();

        final forceUpdateStr = _apiResponse.data?.forceUpdate?.toLowerCase();
        forceUpdate = forceUpdateStr == 'true' || forceUpdateStr == '1';

        if (_apiResponse.status == Status.COMPLETED) {
          latestVersion = Platform.isIOS
              ? _apiResponse.data?.iosVersion?.toString()
              : _apiResponse.data?.androidVersion?.toString();
        }
      } catch (e) {
        debugPrint('Failed to fetch latest version: $e');
      }
      print('----------------------------------$currentVersion');
      print('----------------------------------$latestVersion');
      if (currentVersion != latestVersion && mounted) {
        showDialog(
          context: context,
          barrierDismissible: !forceUpdate,
          useRootNavigator: true,
          builder: (BuildContext context) {
            Widget dialogContent;

            if (Platform.isIOS) {
              dialogContent = CupertinoAlertDialog(
                title: HeaderTextBlack(
                  title: '${_apiResponse.data?.updateTitle}',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                content: HeaderTextBlack(
                  title: '${_apiResponse.data?.updateMessage}',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                actions: [
                  if (!forceUpdate)
                    CupertinoDialogAction(
                      child: BodyTextColors(
                        title: 'Later',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: GenericColors.darkRed,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showSuccessDialogIfNeeded();
                      },
                    ),
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: HeaderTextPrimary(
                      title: 'Update',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    onPressed: () async {
                      final Uri uri = Uri.parse(
                        "${_apiResponse.data?.iosStoreUrl}",
                      );
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
                ],
              );
            } else {
              dialogContent = Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 24,
                    left: 24,
                    right: 24,
                    bottom: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeaderTextBlack(
                        title: "${_apiResponse.data?.updateTitle}",
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(height: 16),
                      BodyTextColors(
                        title: "${_apiResponse.data?.updateMessage}",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!forceUpdate) ...[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showSuccessDialogIfNeeded();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF00875F),
                              ),
                              child: const Text(
                                'No thanks',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          ElevatedButton(
                            onPressed: () async {
                              final Uri uri = Uri.parse(
                                "${_apiResponse.data?.androidStoreUrl}",
                              );
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00875F),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text(
                              'Update',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.black12, height: 1),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Image.network(
                            'https://cdn-icons-png.flaticon.com/128/12942/12942208.png',
                            height: 24,
                            width: 24,
                          ),
                          const SizedBox(width: 8),
                          const BodyTextColors(
                            title: 'Google Play',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }

            return PopScope(
              canPop: !forceUpdate,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
              },
              child: dialogContent,
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
