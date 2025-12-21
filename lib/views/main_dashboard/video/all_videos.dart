import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/keys.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/views/main_dashboard/video/my_videos.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class AllVideos extends StatelessWidget {
  const AllVideos({super.key, required this.categoryVideoData});

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
            context.read<VideoController>().setShowParticularShopVideos = true;
            context.read<VideoController>().setSelectedCategory =
                categoryVideoData[index].categoryName?.capitalize() ?? '';
            await context.read<VideoController>().getAllVideos(
              category: categoryVideoData[index].categoryName!.toLowerCase(),
            );
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

class VideoContainer extends StatefulWidget {
  const VideoContainer({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<VideoContainer> createState() => _VideoContainerState();
}

class _VideoContainerState extends State<VideoContainer>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        _controller
          ..setLooping(true)
          ..setVolume(0)
          ..play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      height: 163,
      child: Stack(
        children: [
          Positioned.fill(
            child: _controller.value.isInitialized
                ? ClipRRect(child: VideoPlayer(_controller))
                : Container(color: AppColors.bgGrey),
          ),

          Positioned.fill(
            child: Center(
              child: VideoPausePlayCircleContainer(icon: Icons.play_arrow),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ParticularShopVideoList extends StatelessWidget {
  const ParticularShopVideoList({super.key, required this.videosData});

  final List<VideosData> videosData;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: videosData.length,
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        return Container(
          height: 174,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
          margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Stack(
            children: [
              InkWell(
                onTap: () {
                  context.pushNamed(
                    AppRoutes.singleVideoScreen,
                    extra: {
                      Keys.videosData: videosData[index],
                      Keys.isMyVideos: false,
                    },
                  );
                },
                child: MyVideoContainer(
                  videoUrl: ApiRoutes.baseUrl + (videosData[index].video ?? ''),
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
      },
    );
  }
}
