import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/strings.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/constants/themes.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/main_dashboard/video/my_videos.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class ShopAnalytics extends StatefulWidget {
  const ShopAnalytics({super.key});

  @override
  State<ShopAnalytics> createState() => _ShopAnalyticsState();
}

class _ShopAnalyticsState extends State<ShopAnalytics> {
  late ProfileController profileController;

  @override
  void initState() {
    // TODO: implement initState
    profileController = context.read<ProfileController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAnalytics();
    });
    super.initState();
  }

  Future<void> getAnalytics() async {
    final response = await profileController.getAnalytics();
    if (!mounted) return;
    if (response.status == Status.ERROR) {
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    profileController = context.watch<ProfileController>();
    final videoData = profileController.analyticsData.data?.totalVideos ?? [];
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundDark,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(
                AppIcons.notificationTopCardP,
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ActionBarComponent(title: 'Shop Analytics'),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: AnalyticsTopContainer(
                            title: 'Total Videos',
                            count: '${videoData.length}',
                            icon: AppIcons.videoClipP,
                            isLoading:
                                profileController.analyticsData.status ==
                                Status.LOADING,
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: AnalyticsTopContainer(
                            title: 'Views',
                            count:
                                '${profileController.analyticsData.data?.totalViews ?? 0}',
                            icon: AppIcons.eyeViewP,
                            isLoading:
                                profileController.analyticsData.status ==
                                Status.LOADING,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        switch (profileController.analyticsData.status) {
                          case Status.INITIAL:
                            return CustomLoadingIndicator();
                          case Status.LOADING:
                            return CustomLoadingIndicator();
                          case Status.COMPLETED:
                            final videos =
                                profileController
                                    .analyticsData
                                    .data
                                    ?.totalVideos ??
                                [];
                            if (videos.isEmpty) {
                              return NoDataText(title: Strings.noDataFound);
                            } else {
                            return  ListView.builder(
                                itemCount: videos.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.only(bottom: 20),
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: 174,
                                    width: double.maxFinite,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                    child: Stack(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            context.pushNamed(
                                              AppRoutes.singleVideoScreen,
                                              extra: videos[index],
                                            );
                                          },
                                          child: MyVideoContainer(
                                            videoUrl:
                                            ApiRoutes.baseUrl +
                                                (videos[index].video ?? ''),
                                            isViews: false,
                                          ),
                                        ),
                                        // Positioned(
                                        //   bottom: 0,
                                        //   left: 0,
                                        //   right: 0,
                                        //   child: VideoTitleBlurContainer(
                                        //     isViews: true,
                                        //     videosData: videos[index],
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  );
                                },
                              );

                            }
                          case Status.ERROR:
                            return CustomErrorTextWidget(
                              title:
                                  '${profileController.analyticsData.message}',
                            );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticsTopContainer extends StatelessWidget {
  const AnalyticsTopContainer({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.isLoading,
  });

  final String title, count, icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: Themes.searchFieldDecoration(borderRadius: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BodyTextColors(
            title: title,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0XFF505050),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              if (isLoading)
                CustomLoadingIndicator(height: 25, strokeWidth: 4)
              else
                HeaderTextBlack(
                  title: count,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              Spacer(),
              Image.asset(icon, height: 24, width: 24),
            ],
          ),
        ],
      ),
    );
  }
}
