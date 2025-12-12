import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapman/controller/home_controller.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/views/main_dashboard/video/my_videos.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class ViewedVideos extends StatefulWidget {
  const ViewedVideos({super.key});

  @override
  State<ViewedVideos> createState() => _ViewedVideosState();
}

class _ViewedVideosState extends State<ViewedVideos> {
  late HomeController homeController;
  List<String> videoUrls = [
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
  ];

  @override
  void initState() {
    // TODO: implement initState
    homeController = context.read<HomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.initializeBookmarks(videoUrls.length);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    homeController = context.watch<HomeController>();
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(
          title: 'Viewed Videos',
          action: Padding(
            padding: const EdgeInsets.only(right: 10, top: 10),
            child: Transform.scale(
              scaleX: .9,
              scaleY: 0.8,
              child: CupertinoSwitch(
                value: homeController.isViewedVideo,
                activeTrackColor: GenericColors.darkGreen,
                onChanged: (value) {
                  homeController.setIsViewedVideo = value;
                },
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 20),
            CustomSearchField(
              controller: TextEditingController(),
              hintText: 'Search by Video title',
              clearOnTap: () {},
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: videoUrls.length,
                shrinkWrap: true,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Stack(
                      children: [
                        ViewedVideoCard(
                          videoUrl: videoUrls[index],
                          isBookMark: homeController.bookmarked[index],
                          bookMarkOnTap: () {
                            homeController.toggleBookmark(index);
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: VideoTitleBlurContainer(isShopDetail: true),
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
    );
  }
}

class ViewedVideoCard extends StatefulWidget {
  const ViewedVideoCard({
    super.key,
    required this.videoUrl,
    this.isViews = true,
    required this.isBookMark,
    required this.bookMarkOnTap,
  });

  final String videoUrl;
  final bool isViews, isBookMark;
  final VoidCallback bookMarkOnTap;

  @override
  State<ViewedVideoCard> createState() => _ViewedVideoCardState();
}

class _ViewedVideoCardState extends State<ViewedVideoCard>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
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
      height: 174,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(6),
              child: _controller.value.isInitialized
                  ? VideoPlayer(_controller)
                  : Container(color: AppColors.bgGrey),
            ),
          ),
          Positioned(
            top: 45,
            left: 0,
            right: 0,
            child: Center(child: VideoPausePlayGradientCircleContainer()),
          ),
          if (widget.isViews) ...[
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: widget.bookMarkOnTap,
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.scaffoldBackground,
                  ),
                  child: Center(
                    child: widget.isBookMark
                        ? Image.asset(AppIcons.bookmarkP, height: 20, width: 20)
                        : Icon(
                            CupertinoIcons.bookmark,
                            size: 20,
                            color: AppColors.darkGrey,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
