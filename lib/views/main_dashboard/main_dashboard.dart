import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mapman/controller/home_controller.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/main_dashboard/home/home.dart';
import 'package:mapman/views/main_dashboard/map/maps.dart';
import 'package:mapman/views/main_dashboard/profile/add_shop_detail.dart';
import 'package:mapman/views/main_dashboard/profile/profile.dart';
import 'package:mapman/views/main_dashboard/video/videos.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:provider/provider.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  late HomeController homeController;
  final List<Widget> _pages = [Home(), Maps(), Videos(), Profile()];

  @override
  void initState() {
    homeController = context.read<HomeController>();
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
    return CustomSafeArea(
      color: getBackgroundColor(
        homeController.currentPage,
        context.watch<VideoController>().currentVideoIndex,
      ),
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        body: _pages[homeController.currentPage],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: InkWell(
          onTap: () async {
            await showAddShopDetail(context);
          },
          child: Container(
            height: 68,
            width: 68,
            padding: EdgeInsets.all(4),
            margin: EdgeInsets.fromLTRB(3, 2, 3, 0),
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
          ),
        ),
        bottomNavigationBar: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBottomNavigationBar.builder(
              height: 65,
              itemCount: 4,
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
                      color: isActive ? AppColors.darkText : AppColors.darkGrey,
                    ),
                  ],
                );
              },
              backgroundColor: AppColors.scaffoldBackground,
              borderColor: AppColors.primaryBorder,
              activeIndex: homeController.currentPage,
              gapLocation: GapLocation.center,
              notchSmoothness: NotchSmoothness.defaultEdge,
              elevation: 0,
              onTap: (index) {
                homeController.setCurrentPage = index;
              },
            ),
            Positioned(
              bottom: 1,
              child: HeaderTextPrimary(
                title: "Upload",
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
