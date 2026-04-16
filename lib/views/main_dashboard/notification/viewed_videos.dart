import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/home_controller.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/keys.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/main_dashboard/video/components/video_Dialogue.dart';
import 'package:mapman/views/main_dashboard/video/my_videos.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ViewedVideos extends StatefulWidget {
  const ViewedVideos({super.key});

  @override
  State<ViewedVideos> createState() => _ViewedVideosState();
}

class _ViewedVideosState extends State<ViewedVideos> {
  final ScrollController scrollController = ScrollController();

  late VideoController videoController;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();

    videoController = context.read<VideoController>();
    searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      videoController.resetViewedVideosPagination();
      videoController.loadViewedVideoStatus();
      await _getMyViewedVideos();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _getMyViewedVideos() async {
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

  Future<void> addSavedVideos({
    required int videoId,
    required String status,
  }) async {
    CustomDialogues.showLoadingDialogue(context);

    final response = await videoController.addSavedVideos(
      videoId: videoId,
      status: status,
    );

    if (!mounted) return;

    Navigator.pop(context);

    if (response.status == Status.COMPLETED) {
      CustomToast.show(context, title: 'Video unsaved successfully');

      await videoController.getMyViewedVideos(removeBookMark: false);
    } else {
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

    final videos = videoController.filteredViewedVideos.isNotEmpty
        ? videoController.filteredViewedVideos
        : videoController.viewedVideoData.data ?? [];

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
                value: videoController.isViewedVideo == 1,
                activeTrackColor: GenericColors.darkGreen,
                onChanged: (value) async {
                  final int status = value ? 1 : 0;
                  await videoController.setIsViewedVideo(status);
                  if (!context.mounted) return;

                  VideoDialogues().showViewedVideoDialogue(
                    context,
                    turnOn: status,
                  );
                },
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),

            CustomSearchField(
              controller: searchController,
              hintText: 'Search by Video title',
              onChanged: (value) {
                videoController.filterViewedVideosByTitle(value ?? '');
              },
              clearOnTap: () {
                searchController.clear();
                videoController.filterViewedVideosByTitle('');
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Builder(
                builder: (context) {
                  switch (videoController.viewedVideoData.status) {
                    case Status.INITIAL:
                    case Status.LOADING:
                      return const CustomLoadingIndicator();

                    case Status.COMPLETED:
                      if (videos.isEmpty) {
                        return EmptyDataContainer(
                          top: 20,
                          children: [
                            Image.asset(
                              AppIcons.viewedVideoEmptyP,
                              height: 130,
                              width: 130,
                            ),
                            const SizedBox(height: 20),
                            const BodyTextColors(
                              title: 'No viewed videos',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              textAlign: TextAlign.center,
                              color: AppColors.lightGreyHint,
                            ),
                            const SizedBox(height: 15),
                            TextButton(
                              onPressed: () {
                                context.read<HomeController>().setCurrentPage =
                                    2;
                                context.goNamed(
                                  AppRoutes.mainDashboard,
                                  extra: false,
                                );
                              },
                              child: const HeaderTextPrimary(
                                title: 'Start Watching Videos & Earn Rewards',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                textDecoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
                              ),
                            ),
                          ],
                        );
                      }

                      return NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (videoController.isSearching) return false;

                          if (videoController.isFetchingMoreViewedVideos ||
                              !videoController.hasMoreViewedVideos) {
                            return false;
                          }

                          final bool isAtBottom =
                              scrollInfo.metrics.pixels >=
                              scrollInfo.metrics.maxScrollExtent - 150;

                          if (scrollInfo is ScrollEndNotification &&
                              isAtBottom) {
                            videoController.loadMoreViewedVideos();
                          }

                          return false;
                        },
                        child: ListView.builder(
                          controller: scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          itemCount:
                              videos.length +
                              (videoController.isFetchingMoreViewedVideos
                                  ? 1
                                  : 0),

                          itemBuilder: (context, index) {
                            if (index == videos.length) {
                              return const MoreLoadingContainer();
                            }
                            final video = videos[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Stack(
                                children: [
                                  ViewedVideoCard(
                                    videoUrl:
                                        '${ApiRoutes.baseUrl}${video.video ?? ''}',
                                    isBookMark:
                                        videoController.bookmarked[index],
                                    bookMarkOnTap: () async {
                                      final isBookmarked = videoController
                                          .toggleBookmark(index);

                                      await addSavedVideos(
                                        videoId: video.id ?? 0,
                                        status: isBookmarked
                                            ? 'active'
                                            : 'inactive',
                                      );
                                    },
                                    onTap: () {
                                      context.pushNamed(
                                        AppRoutes.singleVideoScreen,
                                        extra: {
                                          Keys.videosData: videos,
                                          Keys.isMyVideos: false,
                                          Keys.initialIndex: index,
                                        },
                                      );
                                    },
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: VideoTitleBlurContainer(
                                      isShopDetail: true,
                                      videosData: video,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );

                    case Status.ERROR:
                      return CustomErrorTextWidget(
                        title: '${videoController.viewedVideoData.message}',
                      );
                  }
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
    required this.onTap,
  });

  final String videoUrl;
  final bool isViews, isBookMark;
  final VoidCallback bookMarkOnTap, onTap;

  @override
  State<ViewedVideoCard> createState() => _ViewedVideoCardState();
}

class _ViewedVideoCardState extends State<ViewedVideoCard> {
  VideoPlayerController? _player;
  bool _initialized = false;
  bool _error = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Lazy init via VisibilityDetector
  }

  Future<void> _initController() async {
    if (_player != null || _error || !mounted) return;
    try {
      _player = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );
      
      await _player!.initialize();
      
      if (mounted) {
        setState(() {
          _initialized = true;
        });

      }
    } catch (e) {
      debugPrint('Viewed video init error: $e');
      if (mounted) {
        setState(() {
          _error = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    _player = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('viewed_video_${widget.videoUrl}'),
      onVisibilityChanged: (visibilityInfo) {
        if (!mounted) return;
        
        final bool isVisible = visibilityInfo.visibleFraction > 0.1;
        _isVisible = isVisible;

        if (isVisible) {
          if (!_initialized && !_error) {
            _initController();
          }
        } else {
          // Check if the current route is still active (not covered by another screen)
          final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;

          if (isCurrentRoute) {
            // We are on top but scrolled off screen - dispose to save memory
            if (_initialized) {
              _player?.pause();
              _player?.dispose();
              _player = null;
              _initialized = false;
            }
          } else {
            // We are covered by another screen (like SingleVideoScreen)
            // Just pause the video but keep it initialized for quick return
            _player?.pause();
          }
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          height: 174,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: _initialized && _player != null
                      ? VideoPlayer(_player!)
                      : _error
                          ? Container(
                              color: AppColors.bgGrey,
                              child: const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.white24,
                                  size: 30,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.bgGrey,
                              child: const Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white24,
                                  ),
                                ),
                              ),
                            ),
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
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.scaffoldBackground,
                      ),
                      child: Center(
                        child: widget.isBookMark
                            ? Image.asset(
                                AppIcons.bookmarkP,
                                height: 20,
                                width: 20,
                              )
                            : const Icon(
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
        ),
      ),
    );
  }
}
