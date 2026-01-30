import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/main_dashboard/video/components/video_Dialogue.dart';
import 'package:mapman/views/main_dashboard/video/my_videos.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await videoController.getVideoPoints();
        if (videoController.currentVideoIndex == 1) {
          await getMyVideos();
        }
        if (videoController.currentVideoIndex == 0) {
          await getCategoryVideos();
        }
      } catch (e) {
        debugPrint('Error in Videos initState: $e');
      }
    });
    super.initState();
  }

  Future<void> getMyVideos() async {
    final response = await videoController.getMyVideos();
    if (!mounted) return;
    if (response.status == Status.ERROR) {
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
    }
  }

  Future<void> getCategoryVideos() async {
    final response = await videoController.getCategoryVideos();
    if (!mounted) return;
    if (response.status == Status.ERROR) {
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
    }
  }

  Future<void> getAllVideos({required String category}) async {
    final response = await videoController.getAllVideos(category: category);
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
                        VideoDialogues().showRewardsDialogue(
                          context,
                          isEarnCoins: true,
                        );
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
                                Builder(
                                  builder: (context) {
                                    if (videoController.coinResponse.status ==
                                            Status.INITIAL ||
                                        videoController.coinResponse.status ==
                                            Status.LOADING) {
                                      return HeaderTextBlack(
                                        title: '...',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300,
                                      );
                                    }
                                    return HeaderTextBlack(
                                      title:
                                          '${videoController.coinResponse.data ?? 0}',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    );
                                  },
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
                          onTap: () async {
                            videoController.setCurrentVideoIndex = 0;
                            await getCategoryVideos();
                          },
                        ),
                      ),
                      Expanded(
                        child: VideoHeadingContainer(
                          title: 'My Videos',
                          icon: AppIcons.videoAppP,
                          isActive: videoController.currentVideoIndex == 1,
                          isLeft: false,
                          onTap: () async {
                            videoController.setCurrentVideoIndex = 1;
                            await getMyVideos();
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
          if (videoController.currentVideoIndex == 0) ...[
            SizedBox(height: 15),
            Expanded(
              child: Builder(
                builder: (context) {
                  switch (videoController.categoryVideoData.status) {
                    case Status.INITIAL:
                      return CustomLoadingIndicator();
                    case Status.LOADING:
                      return CustomLoadingIndicator();
                    case Status.COMPLETED:
                      return AllVideosCard(
                        categoryVideoData:
                            videoController.categoryVideoData.data ?? [],
                      );
                    case Status.ERROR:
                      return CustomErrorTextWidget(
                        title: '${videoController.categoryVideoData.message}',
                      );
                  }
                },
              ),
            ),
          ],

          /// MY VIDEOS
          if (videoController.currentVideoIndex == 1) ...[
            Builder(
              builder: (context) {
                switch (videoController.myVideosData.status) {
                  case Status.INITIAL:
                    return Flexible(child: CustomLoadingIndicator());
                  case Status.LOADING:
                    return Flexible(child: CustomLoadingIndicator());
                  case Status.COMPLETED:
                    final videoData = videoController.myVideosData.data ?? [];
                    if (videoData.isNotEmpty) {
                      return Flexible(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  HeaderTextBlack(
                                    title: 'Total Videos (${videoData.length})',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      context.pushNamed(
                                        AppRoutes.uploadVideo,
                                        extra: VideosData(),
                                      );
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
                            Flexible(child: MyVideos(myVideos: videoData)),
                          ],
                        ),
                      );
                    } else {
                      return NoVideoContainer();
                    }
                  case Status.ERROR:
                    return CustomErrorTextWidget(
                      title: '${videoController.myVideosData.message}',
                    );
                }
              },
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

class AllVideosCard extends StatelessWidget {
  const AllVideosCard({super.key, required this.categoryVideoData});

  final List<CategoryVideosData> categoryVideoData;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 206,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 100),
      itemCount: categoryVideoData.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () async {
            context.read<VideoController>().setSelectedCategory =
                categoryVideoData[index].categoryName?.capitalize() ?? '';
            context.pushNamed(AppRoutes.allVideos);
          },
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.scaffoldBackgroundDark,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 163,
                  child: Stack(
                    children: [
                      CustomNetworkImage(
                        imageUrl:
                            (categoryVideoData[index].categoryVideo ?? ''),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: VideoPausePlayCircleContainer(
                            icon: Icons.play_arrow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 43,
                  color: Colors.black,
                  child: Center(
                    child: BodyTextColors(
                      title:
                          categoryVideoData[index].categoryName?.capitalize() ??
                          '',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
