import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/keys.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/main_dashboard/video/my_videos.dart';
import 'package:mapman/views/widgets/action_bar.dart';
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
      videoController.resetAllVideosPagination();
      _getInitialVideos();
    });

    _scrollController.addListener(_onScroll);
  }

  Future<void> _getInitialVideos() async {
    await videoController.getAllVideos(
      category: videoController.selectedCategory.toLowerCase(),
      page: 1,
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      videoController.loadMoreAllVideos(
        category: videoController.selectedCategory.toLowerCase(),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    videoController = context.watch<VideoController>();

    return CustomSafeArea(
      color: AppColors.scaffoldBackgroundDark,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(
          isCenterTitle: false,
          title: videoController.allVideosData.status == Status.COMPLETED
              ? '${videoController.selectedCategory} Videos'
                    '${videoController.allVideosData.data!.isNotEmpty ? ' (${videoController.allVideosData.data!.length})' : ''}'
              : '.....',
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        videoController.resetAllVideosPagination();
        await videoController.getAllVideos(
          category: videoController.selectedCategory.toLowerCase(),
          page: 1,
        );
      },
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        itemCount:
            videosData.length +
            (videoController.isFetchingMoreAllVideos ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < videosData.length) {
            return Container(
              height: 174,
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
              child: Stack(
                children: [
                  InkWell(
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
                    child: MyVideoContainer(
                      videoUrl:
                          ApiRoutes.baseUrl + (videosData[index].video ?? ''),
                      isViews: false,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: VideoTitleBlurContainer(
                      isWatched: videosData[index].watched ?? false,
                      videosData: videosData[index],
                    ),
                  ),
                ],
              ),
            );
          }

          return const MoreLoadingContainer();
        },
      ),
    );
  }
}

//class VideoContainer extends StatefulWidget {
//   const VideoContainer({super.key, required this.videoUrl});
//
//   final String videoUrl;
//
//   @override
//   State<VideoContainer> createState() => _VideoContainerState();
// }
//
// class _VideoContainerState extends State<VideoContainer> {
//   late VideoPlayerController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
//       ..initialize().then((_) {
//         if (!mounted) return;
//         _controller
//           ..setLooping(true)
//           ..setVolume(0)
//           ..play();
//         setState(() {});
//       });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 163,
//       child: Stack(
//         children: [
//           Positioned.fill(
//             child: _controller.value.isInitialized
//                 ? ClipRRect(child: VideoPlayer(_controller))
//                 : Container(color: AppColors.bgGrey),
//           ),
//
//           Positioned.fill(
//             child: Center(
//               child: VideoPausePlayCircleContainer(icon: Icons.play_arrow),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
