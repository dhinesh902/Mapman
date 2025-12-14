import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/main_dashboard/video/all_videos.dart';
import 'package:mapman/views/main_dashboard/video/components/video_Dialogue.dart';
import 'package:mapman/views/main_dashboard/video/my_videos.dart';
import 'package:provider/provider.dart';

class Videos extends StatefulWidget {
  const Videos({super.key});

  @override
  State<Videos> createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  late VideoController videoController;

  @override
  void initState() {
    // TODO: implement initState
    videoController = context.read<VideoController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    videoController = context.watch<VideoController>();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundDark,
      body: Column(
        children: [
          Container(
            height: 145,
            clipBehavior: Clip.hardEdge,
            decoration: videoController.currentVideoIndex == 1
                ? BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                    color: AppColors.scaffoldBackgroundDark,
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.lightViolet, AppColors.violet],
                    ),
                  ),
            child: Column(
              children: [
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 10),
                    Image.asset(
                      videoController.currentVideoIndex == 1
                          ? AppIcons.videographyP
                          : AppIcons.videoClipP,
                      height: 34,
                      width: 34,
                    ),
                    SizedBox(width: 15),
                    BodyTextColors(
                      title: 'Videos',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: videoController.currentVideoIndex == 1
                          ? AppColors.darkText
                          : AppColors.whiteText,
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        VideoDialogues().showRewardsDialogue(context);
                      },
                      child: Container(
                        height: 44,
                        width: 105,
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBackground,
                          border: Border.all(color: GenericColors.darkYellow),
                          borderRadius: BorderRadiusGeometry.circular(20),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppIcons.rupeeCoinP,
                                  height: 34,
                                  width: 34,
                                ),
                                SizedBox(width: 5),
                                HeaderTextBlack(
                                  title: '142',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                ),
                              ],
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Lottie.asset(AppAnimations.confetti),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                SizedBox(height: 30),
                Container(
                  height: 44,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.bgGrey, // background for outer
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: VideoHeadingContainer(
                          title: 'All Videos',
                          icon: AppIcons.p24,
                          isActive: videoController.currentVideoIndex == 0,
                          isLeft: true,
                          onTap: () {
                            videoController.setCurrentVideoIndex = 0;
                          },
                        ),
                      ),
                      Expanded(
                        child: VideoHeadingContainer(
                          title: 'My Videos',
                          icon: AppIcons.videoAppP,
                          isActive: videoController.currentVideoIndex == 1,
                          isLeft: false,
                          onTap: () {
                            videoController.setShowParticularShopVideos = false;
                            videoController.setCurrentVideoIndex = 1;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// ALL VIDEOS
          if (videoController.currentVideoIndex == 0 &&
              !videoController.isShowParticularShopVideos) ...[
            SizedBox(height: 15),
            Expanded(
              child: AllVideos(
                videoUrls: [
                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
                  "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
                  "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
                ],
              ),
            ),
          ],

          /// Particular Shop video list
          if (videoController.isShowParticularShopVideos) ...[
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 15),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      videoController.setShowParticularShopVideos = false;
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.scaffoldBackground,
                        border: Border.all(color: GenericColors.borderGrey),
                      ),
                      child: Center(child: SvgPicture.asset(AppIcons.backIcon)),
                    ),
                  ),
                  SizedBox(width: 10),
                  HeaderTextBlack(
                    title: 'Textiles Videos (12)',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ParticularShopVideoList(
                videoUrls: [
                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
                ],
              ),
            ),
          ],

          /// MY VIDEOS
          if (videoController.currentVideoIndex == 1) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HeaderTextBlack(
                    title: 'Total Videos (12)',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  InkWell(
                    onTap: () {
                      context.pushNamed(AppRoutes.uploadVideo);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(AppIcons.upload),
                        BodyTextColors(
                          title: 'Upload ',
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: GenericColors.darkGreen,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Flexible(
              child: MyVideos(
                videoUrls: [
                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class VideoHeadingContainer extends StatelessWidget {
  const VideoHeadingContainer({
    super.key,
    required this.title,
    required this.icon,
    required this.isActive,
    required this.isLeft,
    required this.onTap,
  });

  final String title, icon;
  final bool isActive;
  final bool isLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? AppColors.darkText : AppColors.whiteText,
          border: Border.all(color: AppColors.whiteText, width: 1),
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(isLeft ? 20 : 0),
            right: Radius.circular(isLeft ? 0 : 20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, height: 24, width: 24),
            const SizedBox(width: 10),
            BodyTextColors(
              title: title,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isActive ? AppColors.whiteText : AppColors.bgGrey,
            ),
          ],
        ),
      ),
    );
  }
}
