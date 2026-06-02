import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/keys.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/main_dashboard/video/my_videos.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class AllVideos extends StatefulWidget {
  const AllVideos({super.key});

  @override
  State<AllVideos> createState() => _AllVideosState();
}

class _AllVideosState extends State<AllVideos> {
  final ScrollController _scrollController = ScrollController();

  late VideoController videoController;

  @override
  void initState() {
    super.initState();

    videoController = context.read<VideoController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getInitialVideos();
    });
  }

  Future<void> _getInitialVideos() async {
    videoController.resetAllVideosPagination();
    await videoController.getAllVideos(
      category: videoController.selectedCategory.toLowerCase(),
      page: 1,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    videoController = context.watch<VideoController>();

    return CustomSafeArea(
      color: AppColors.whiteText,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: AppColors.whiteText,
          surfaceTintColor: AppColors.whiteText,
          leading: InkWell(
            onTap: () {
              context.pop();
            },
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.whiteText,
                border: Border.all(color: GenericColors.borderGrey),
              ),
              child: Center(child: SvgPicture.asset(AppIcons.backIcon)),
            ),
          ),
          title: HeaderTextBlack(
            title: videoController.allVideosData.status == Status.COMPLETED
                ? '${videoController.selectedCategory} Videos'
                      '${videoController.allVideosData.data!.isNotEmpty ? ' (${videoController.allVideosData.data!.length})' : ''}'
                : '.....',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          actions: [
            // GestureDetector(
            //   onTap: () {
            //     VideoDialogues().showRewardsDialogue(
            //       context,
            //       isEarnCoins: true,
            //     );
            //   },
            //   child: Container(
            //     height: 40,
            //     width: 90,
            //     decoration: BoxDecoration(
            //       color: AppColors.scaffoldBackground,
            //       border: Border.all(color: GenericColors.darkYellow),
            //       borderRadius: BorderRadiusGeometry.circular(20),
            //     ),
            //     child: Stack(
            //       alignment: Alignment.center,
            //       children: [
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             Image.asset(AppIcons.rupeeCoinP, height: 34, width: 34),
            //             SizedBox(width: 5),
            //             Builder(
            //               builder: (context) {
            //                 if (videoController.coinResponse.status ==
            //                         Status.INITIAL ||
            //                     videoController.coinResponse.status ==
            //                         Status.LOADING) {
            //                   return HeaderTextBlack(
            //                     title: '...',
            //                     fontSize: 16,
            //                     fontWeight: FontWeight.w300,
            //                   );
            //                 }
            //                 return HeaderTextBlack(
            //                   title:
            //                       '${videoController.coinResponse.data ?? 0}',
            //                   fontSize: 16,
            //                   fontWeight: FontWeight.w300,
            //                 );
            //               },
            //             ),
            //           ],
            //         ),
            //         Positioned(
            //           top: 0,
            //           left: 0,
            //           right: 0,
            //           child: Center(
            //             child: Lottie.asset(AppAnimations.confetti),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            SizedBox(width: 10),
          ],
        ),
        body: Builder(
          builder: (context) {
            switch (videoController.allVideosData.status) {
              case Status.INITIAL:
              case Status.LOADING:
                return const CustomLoadingIndicator();

              case Status.COMPLETED:
                final allVideo = videoController.allVideosData.data ?? [];

                if (allVideo.isEmpty) {
                  return EmptyDataContainer(
                    top: 100,
                    children: [
                      Image.asset(
                        AppIcons.allVideoEmptyP,
                        height: 100,
                        width: 100,
                      ),
                      const SizedBox(height: 20),
                      BodyTextColors(
                        title: 'No videos uploaded yet',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightGreyHint,
                      ),
                    ],
                  );
                }

                return ParticularShopVideoList(
                  videosData: allVideo,
                  videoController: videoController,
                  scrollController: _scrollController,
                );

              case Status.ERROR:
                return CustomErrorTextWidget(
                  title: videoController.allVideosData.message ?? '',
                );
            }
          },
        ),
      ),
    );
  }
}

class ParticularShopVideoList extends StatelessWidget {
  const ParticularShopVideoList({
    super.key,
    required this.videosData,
    required this.videoController,
    required this.scrollController,
  });

  final List<VideosData> videosData;
  final VideoController videoController;
  final ScrollController scrollController;

  String formatViewCount(int count) {
    if (count >= 1000000) {
      double res = count / 1000000;
      return res == res.toInt()
          ? '${res.toInt()}M'
          : '${res.toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      double res = count / 1000;
      return res == res.toInt()
          ? '${res.toInt()}K'
          : '${res.toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (videoController.isFetchingMoreAllVideos ||
            !videoController.hasMoreAllVideos) {
          return false;
        }

        final isAtBottom =
            scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent - 150;

        if (scrollInfo is ScrollEndNotification && isAtBottom) {
          videoController.loadMoreAllVideos(
            category: videoController.selectedCategory.toLowerCase(),
          );
        }

        return false;
      },
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(2, 2, 2, 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final video = videosData[index];
                return GestureDetector(
                  onTap: () {
                    context.pushNamed(
                      AppRoutes.singleVideoScreen,
                      extra: {
                        Keys.videosData: videosData,
                        Keys.isMyVideos: false,
                        Keys.initialIndex: index,
                      },
                    );
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MyVideoContainer(
                        videoUrl: (video.video ?? ''),
                        isViews: false,
                        isShowPlayButton: false,
                        isAllVideos: true,
                      ),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.4),
                                    Colors.white.withValues(alpha: 0.1),
                                  ],
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.play_arrow,
                                size: 26,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (video.watched ?? false)
                        Positioned(
                          top: 10,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1DB954),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const BodyTextColors(
                              title: "Watched",
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppIcons.eye,
                              height: 12,
                              width: 12,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            BodyTextColors(
                              title: formatViewCount(
                                video.viewCount ?? video.views ?? 0,
                              ),
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }, childCount: videosData.length),
            ),
          ),
          if (videoController.isFetchingMoreAllVideos)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: MoreLoadingContainer(),
              ),
            ),
        ],
      ),
    );
  }
}

