import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
        if (videoController.currentVideoIndex == 1) {
          await getMyVideos();
        }
        if (videoController.currentVideoIndex == 0) {
          await getCategoryVideos();
        }
        await videoController.getVideoPoints();
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
            height: 80,
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
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 220,
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
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
                          isVideo: true,
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
                          isVideo: true,
                          onTap: () async {
                            videoController.setCurrentVideoIndex = 1;
                            await getMyVideos();
                          },
                        ),
                      ),
                    ],
                  ),
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
                    height: 40,
                    width: 90,
                    margin: EdgeInsets.only(bottom: 15),
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
    this.isVideo = false,
  });

  final String title, icon;
  final bool isActive;
  final bool isLeft;
  final VoidCallback onTap;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isVideo ? 40 : 44,
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
            Image.asset(icon, height: 16, width: 16),
            const SizedBox(width: 10),
            BodyTextColors(
              title: title,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isActive ? AppColors.whiteText : AppColors.bgGrey,
            ),
          ],
        ),
      ),
    );
  }
}

// class AllVideosCard extends StatelessWidget {
//   const AllVideosCard({super.key, required this.categoryVideoData});
//
//   final List<CategoryVideosData> categoryVideoData;
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         mainAxisExtent: 206,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       padding: const EdgeInsets.fromLTRB(10, 0, 10, 100),
//       itemCount: categoryVideoData.length,
//       itemBuilder: (context, index) {
//         return InkWell(
//           onTap: () async {
//             context.read<VideoController>().setSelectedCategory =
//                 categoryVideoData[index].categoryName?.capitalize() ?? '';
//             context.pushNamed(AppRoutes.allVideos);
//           },
//           child: Container(
//             clipBehavior: Clip.hardEdge,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               color: AppColors.scaffoldBackgroundDark,
//             ),
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 163,
//                   child: Stack(
//                     children: [
//                       CustomNetworkImage(
//                         imageUrl:
//                             (categoryVideoData[index].categoryVideo ?? ''),
//                       ),
//                       Positioned.fill(
//                         child: Center(
//                           child: VideoPausePlayCircleContainer(
//                             icon: Icons.play_arrow,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   height: 43,
//                   color: Colors.black,
//                   child: Center(
//                     child: BodyTextColors(
//                       title:
//                           categoryVideoData[index].categoryName?.capitalize() ??
//                           '',
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class AllVideosCard extends StatelessWidget {
//   const AllVideosCard({super.key, required this.categoryVideoData});
//
//   final List<CategoryVideosData> categoryVideoData;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(10, 0, 10, 100),
//       child: SingleChildScrollView(
//         child: StaggeredGrid.count(
//           crossAxisCount: 4,
//           mainAxisSpacing: 5,
//           crossAxisSpacing: 5,
//           children: List.generate(categoryVideoData.length, (index) {
//             int row = index ~/ 2; // each row has 2 items
//             bool isEvenRow = row % 2 == 0;
//
//             bool isBigTile =
//                 (isEvenRow && index % 2 == 0) || // left big
//                     (!isEvenRow && index % 2 == 1);  // right big
//
//             return StaggeredGridTile.count(
//               crossAxisCellCount: isBigTile ? 3 : 1,
//               mainAxisCellCount: 2,
//               child: InkWell(
//                 onTap: () {
//                   context.read<VideoController>().setSelectedCategory =
//                       categoryVideoData[index].categoryName?.capitalize() ?? '';
//                   context.pushNamed(AppRoutes.allVideos);
//                 },
//                 child: Container(
//                   clipBehavior: Clip.hardEdge,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                   child: Stack(
//                     children: [
//                       /// IMAGE
//                       Positioned.fill(
//                         child: CustomNetworkImage(
//                           imageUrl:
//                               categoryVideoData[index].categoryVideo ?? '',
//                         ),
//                       ),
//
//                       /// GRADIENT
//                       Positioned.fill(
//                         child: DecoratedBox(
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment.topCenter,
//                               end: Alignment.bottomCenter,
//                               colors: [
//                                 Colors.transparent,
//                                 AppColors.darkText.withValues(alpha: 0.05),
//                                 AppColors.darkText.withValues(alpha: 0.3),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       /// TEXT
//                       Center(
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(20),
//                           child: BackdropFilter(
//                             filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withValues(alpha: .25),
//                                 borderRadius: BorderRadius.circular(20),
//                                 border: Border.all(
//                                   color: Colors.white.withValues(alpha: .2),
//                                   width: 1,
//                                 ),
//                               ),
//                               child: BodyTextColors(
//                                 title:
//                                     categoryVideoData[index].categoryName
//                                         ?.capitalize() ??
//                                     '',
//                                 color: AppColors.whiteText,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }

class AllVideosCard extends StatelessWidget {
  const AllVideosCard({super.key, required this.categoryVideoData});

  final List<CategoryVideosData> categoryVideoData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: SingleChildScrollView(
        child: StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          children: _buildGridItems(context),
        ),
      ),
    );
  }

  List<Widget> _buildGridItems(BuildContext context) {
    List<Widget> tiles = [];
    int i = 0;
    int row = 0;

    while (i < categoryVideoData.length) {
      bool isOddRow = row % 2 == 0;

      if (isOddRow) {
        bool isLeftBig = (row ~/ 2) % 3 == 0;

        if (i < categoryVideoData.length) {
          tiles.add(
            StaggeredGridTile.count(
              crossAxisCellCount: isLeftBig ? 3 : 1,
              mainAxisCellCount: 2,
              child: _buildItem(context, i),
            ),
          );
          i++;
        }

        if (i < categoryVideoData.length) {
          tiles.add(
            StaggeredGridTile.count(
              crossAxisCellCount: isLeftBig ? 1 : 3,
              mainAxisCellCount: 2,
              child: _buildItem(context, i),
            ),
          );
          i++;
        }
      } else {
        tiles.add(
          StaggeredGridTile.count(
            crossAxisCellCount: 4,
            mainAxisCellCount: 2,
            child: _buildItem(context, i),
          ),
        );
        i++;
      }

      row++;
    }

    tiles.add(
      const StaggeredGridTile.count(
        crossAxisCellCount: 4,
        mainAxisCellCount: 1.2,
        child: SizedBox(),
      ),
    );

    return tiles;
  }

  Widget _buildItem(BuildContext context, int index) {
    final data = categoryVideoData[index];

    return InkWell(
      onTap: () {
        context.read<VideoController>().setSelectedCategory =
            categoryVideoData[index].categoryName?.capitalize() ?? '';
        context.pushNamed(AppRoutes.allVideos);
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomNetworkImage(imageUrl: data.categoryVideo ?? ''),
            ),

            /// GLASS TEXT
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: BodyTextColors(
                      title: data.categoryName?.capitalize() ?? '',
                      color: AppColors.whiteText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
