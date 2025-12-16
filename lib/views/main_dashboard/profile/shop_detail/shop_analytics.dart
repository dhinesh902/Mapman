import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/constants/themes.dart';
import 'package:mapman/views/main_dashboard/video/my_videos.dart';
import 'package:mapman/views/widgets/action_bar.dart';

class ShopAnalytics extends StatefulWidget {
  const ShopAnalytics({super.key});

  @override
  State<ShopAnalytics> createState() => _ShopAnalyticsState();
}

class _ShopAnalyticsState extends State<ShopAnalytics> {
  List<String> videoUrls = [
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
  ];

  @override
  Widget build(BuildContext context) {
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

          Positioned.fill(
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
                            count: '32',
                            icon: AppIcons.videoClipP,
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: AnalyticsTopContainer(
                            title: 'Views',
                            count: '2,00,426',
                            icon: AppIcons.eyeViewP,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: videoUrls.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.only(bottom: 20),
                      itemBuilder: (context, index) {
                        return Container(
                          height: 174,
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
                                    extra: videoUrls[index],
                                  );
                                },
                                child: MyVideoContainer(
                                  videoUrl: videoUrls[index],
                                  isViews: false,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: VideoTitleBlurContainer(isViews: true,title: 'Video Title',),
                              ),
                            ],
                          ),
                        );
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
  });

  final String title, count, icon;

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
              Expanded(
                child: HeaderTextBlack(
                  title: count,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Image.asset(icon, height: 24, width: 24),
            ],
          ),
        ],
      ),
    );
  }
}
