import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/strings.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/main_dashboard/video/components/video_Dialogue.dart';
import 'package:mapman/views/main_dashboard/video/my_videos.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class ViewedVideos extends StatefulWidget {
  const ViewedVideos({super.key});

  @override
  State<ViewedVideos> createState() => _ViewedVideosState();
}

class _ViewedVideosState extends State<ViewedVideos> {
  late VideoController videoController;
  late TextEditingController searchController;

  @override
  void initState() {
    // TODO: implement initState
    videoController = context.read<VideoController>();
    searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getMyViewedVideos();
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    searchController.dispose();
    super.dispose();
  }

  Future<void> getMyViewedVideos() async {
    final response = await videoController.getMyViewedVideos();
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
                value: videoController.isViewedVideo,
                activeTrackColor: GenericColors.darkGreen,
                onChanged: (value) {
                  videoController.setIsViewedVideo = value;
                  VideoDialogues().showViewedVideoDialogue(
                    context,
                    turnOn: value,
                  );
                },
              ),
            ),
          ),
        ),
        body: Builder(
          builder: (context) {
            switch (videoController.viewedVideoData.status) {
              case Status.INITIAL:
                return CustomLoadingIndicator();
              case Status.LOADING:
                return CustomLoadingIndicator();
              case Status.COMPLETED:
                final viewedVideos = videoController.filteredViewedVideos;
                if (viewedVideos.isEmpty) {
                  return NoDataText(title: Strings.noDataFound);
                }
                return Column(
                  children: [
                    SizedBox(height: 20),
                    CustomSearchField(
                      controller: searchController,
                      hintText: 'Search by Video title',
                      onChanged: (value) {
                        videoController.filterViewedVideosByTitle(value!);
                      },
                      clearOnTap: () {
                        searchController.clear();
                        videoController.filterViewedVideosByTitle('');
                      },
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: viewedVideos.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Stack(
                              children: [
                                ViewedVideoCard(
                                  videoUrl:
                                      '${ApiRoutes.baseUrl}${viewedVideos[index].video ?? ''}',
                                  isBookMark: videoController.bookmarked[index],
                                  bookMarkOnTap: () {
                                    videoController.toggleBookmark(index);
                                  },
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: VideoTitleBlurContainer(
                                    isShopDetail: true,
                                    videosData: viewedVideos[index],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              case Status.ERROR:
                return CustomErrorTextWidget(
                  title: '${videoController.viewedVideoData.message}',
                );
            }
          },
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
  late final CachedVideoPlayerPlus _player;

  @override
  void initState() {
    super.initState();
    _player =
        CachedVideoPlayerPlus.networkUrl(
            Uri.parse(widget.videoUrl),
            invalidateCacheIfOlderThan: const Duration(minutes: 69),
          )
          ..initialize().then((_) {
            if (mounted) {
              setState(() {});
            }
          });
  }

  @override
  void dispose() {
    _player.dispose();
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
              child: _player.isInitialized
                  ? VideoPlayer(_player.controller)
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
