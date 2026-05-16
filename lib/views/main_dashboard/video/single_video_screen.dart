import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/views/main_dashboard/video/components/video_Dialogue.dart';
import 'package:mapman/views/main_dashboard/video/components/video_shop_dialogue.dart';
import 'package:mapman/views/widgets/custom_launchers.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:mapman/utils/storage/video_cache_manager.dart';

class SingleVideoScreen extends StatefulWidget {
  const SingleVideoScreen({
    super.key,
    required this.videosData,
    required this.isMyVideos,
    this.initialIndex = 0,
  });

  final List<VideosData> videosData;
  final bool isMyVideos;
  final int initialIndex;

  @override
  State<SingleVideoScreen> createState() => _SingleVideoScreenState();
}

class _SingleVideoScreenState extends State<SingleVideoScreen>
    with WidgetsBindingObserver {
  late VideoController videoController;
  final Map<int, VideoPlayerController> _controllers = {};

  // State variables
  int _currentIndex = 0;
  late PageController _pageController;
  bool _isDisposed = false;
  bool _isAdvancing = false;
  Timer? _debounceTimer;
  bool _hasShownLastVideoToast = false;
  bool _isInitialized = false;
  double _progress = 0.0;
  final Map<int, bool> _watchedMap = {};
  final Map<int, bool> _apiCallInProgress = {};
  final Map<int, bool> _completedVideos = {};
  final Map<int, ValueNotifier<bool>> _bookmarkMap = {};
  final Set<int> _initializingIndices = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    videoController = context.read<VideoController>();

    final initialIndex = widget.initialIndex.clamp(
      0,
      widget.videosData.length - 1,
    );
    _currentIndex = initialIndex;
    _pageController = PageController(initialPage: initialIndex);

    for (final video in widget.videosData) {
      final id = video.id ?? 0;
      _watchedMap[id] = video.watched == true;
      _apiCallInProgress[id] = false;
      _completedVideos[id] = false;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      videoController.loadViewedVideoStatus();
      _onPageChanged(initialIndex);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _disposeAllControllers();
    _pageController.dispose();
    for (final notifier in _bookmarkMap.values) {
      notifier.dispose();
    }
    VideoCacheManager.clearAppCache();
    super.dispose();
  }

  Future<void> _disposeAllControllers() async {
    for (final controller in _controllers.values) {
      await controller.dispose();
    }
    _controllers.clear();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed || !mounted) return;

    final controller = _controllers[_currentIndex];
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      if (state == AppLifecycleState.resumed) {
        if (!controller.value.isPlaying) {
          controller.play();
        }
      }
    } catch (e) {
      debugPrint('Error in didChangeAppLifecycleState: $e');
    }
  }

  Future<void> _initController(int index) async {
    if (_isDisposed ||
        index < 0 ||
        index >= widget.videosData.length ||
        _controllers.containsKey(index) ||
        _initializingIndices.contains(index)) {
      return;
    }

    _initializingIndices.add(index);

    final video = widget.videosData[index];
    final videoUrl = ApiRoutes.baseUrl + (video.video ?? '');

    try {
      debugPrint('🎬 Initializing video at index $index');
      final player = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: true,
          mixWithOthers: true,
        ),
      );

      await player.initialize();

      if (_isDisposed) {
        await player.dispose();
        return;
      }

      // If video is no longer needed (scrolled away), dispose it immediately
      if ((index - _currentIndex).abs() > 1) {
        debugPrint('⚠️ Video at index $index no longer needed, disposing...');
        await player.dispose();
        return;
      }

      _controllers[index] = player;

      if (index == _currentIndex) {
        _playVideo(index);
      } else {
        player
          ..setLooping(false)
          ..setVolume(0.0)
          ..pause();
      }
    } catch (e) {
      debugPrint('❌ Init failed for index $index: $e');
    } finally {
      _initializingIndices.remove(index);
    }
  }

  void _playVideo(int index) {
    final controller = _controllers[index];
    if (controller == null) return;

    // Ensure we don't have duplicate listeners
    controller.removeListener(_videoListener);

    controller
      ..setLooping(false)
      ..setVolume(1.0)
      ..seekTo(Duration.zero)
      ..addListener(_videoListener)
      ..play();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _disposeController(int index) async {
    if (_controllers.containsKey(index)) {
      debugPrint('🗑️ Disposing video at index $index');
      final player = _controllers.remove(index);
      if (player != null) {
        player.removeListener(_videoListener);
        await player.dispose();
      }
    }
  }

  Future<void> _manageControllers(int index) async {
    // Start preloading the next video asynchronously before awaiting the current video initialization.
    // This allows both videos to establish network handshakes and buffer in parallel!
    if (index + 1 < widget.videosData.length) {
      _initController(index + 1); // Preload next
    }

    // Initialize current video
    await _initController(index);

    // Dispose others
    final keysToRemove = _controllers.keys
        .where((key) => (key - index).abs() > 1)
        .toList();
    for (final key in keysToRemove) {
      await _disposeController(key);
    }
  }

  void _videoListener() {
    if (_isDisposed || !mounted) return;

    final player = _controllers[_currentIndex];
    if (player == null || !player.value.isInitialized) return;

    try {
      final value = player.value;
      final position = value.position;
      final duration = value.duration;

      if (duration.inMilliseconds > 0) {
        if (mounted && !_isDisposed) {
          setState(() {
            _progress = position.inMilliseconds / duration.inMilliseconds;
          });
        }
      }

      final videoId = widget.videosData[_currentIndex].id ?? 0;

      if ((_completedVideos[videoId] == false) &&
          position.inMilliseconds >= duration.inMilliseconds) {
        _completedVideos[videoId] = true;
        _handleVideoCompletion();
      }

      if (position.inMilliseconds < duration.inMilliseconds * 0.1) {
        _completedVideos[videoId] = false;
      }

      if (position >= duration &&
          _currentIndex < widget.videosData.length - 1) {
        _autoAdvanceToNext();
      }
    } catch (e) {
      debugPrint('Error in videoListener: $e');
    }
  }

  void _handleVideoCompletion() {
    if (_isDisposed) return;

    final videoId = widget.videosData[_currentIndex].id ?? 0;

    if (_watchedMap[videoId] == true ||
        _apiCallInProgress[videoId] == true ||
        _completedVideos[videoId] != true ||
        widget.isMyVideos ||
        videoController.isViewedVideo != 1) {
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      if (!_isDisposed && mounted) {
        _markVideoWatched(videoId);
      }
    });
  }

  Future<void> _markVideoWatched(int videoId) async {
    if (_watchedMap[videoId] == true ||
        _apiCallInProgress[videoId] == true ||
        videoController.isViewedVideo != 1 ||
        _isDisposed) {
      return;
    }

    _watchedMap[videoId] = true;
    _apiCallInProgress[videoId] = true;

    if (mounted) setState(() {});

    try {
      debugPrint('Video $videoId FULLY COMPLETED - Calling APIs...');

      if (videoController.isViewedVideo == 1) {
        await videoController.addViewedVideos(videoId: videoId);
        debugPrint('addViewedVideos SUCCESS');
      }

      await Future.delayed(const Duration(milliseconds: 300));
      await videoController.addVideoPoints();
      await videoController.getVideoPoints();
      debugPrint('addVideoPoints SUCCESS');

      await Future.delayed(const Duration(milliseconds: 300));
      await videoController.getVideoPoints();
      debugPrint('getVideoPoints SUCCESS');
    } catch (e) {
      debugPrint('API Error video $videoId: $e');
    } finally {
      if (!_isDisposed) {
        _apiCallInProgress[videoId] = false;
      }
    }
  }

  void _autoAdvanceToNext() {
    if (_isDisposed ||
        _isAdvancing ||
        _currentIndex >= widget.videosData.length - 1) {
      if (!_hasShownLastVideoToast &&
          mounted &&
          _currentIndex >= widget.videosData.length - 1) {
        _hasShownLastVideoToast = true;
        CustomToast.show(
          context,
          title: 'Here the videos are over.',
          isError: false,
        );
      }
      return;
    }

    _isAdvancing = true;
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!_isDisposed && _pageController.hasClients) {
        _pageController
            .nextPage(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            )
            .then((_) {
              if (mounted) {
                _isAdvancing = false;
              }
            });
      } else {
        _isAdvancing = false;
      }
    });
  }

  void _onPageChanged(int index) {
    if (_isDisposed) return;

    // Stop previous video
    if (_controllers.containsKey(_currentIndex)) {
      final oldController = _controllers[_currentIndex];
      if (oldController != null) {
        oldController.pause();
        oldController.setVolume(0.0);
        oldController.removeListener(_videoListener);
      }
    }

    _currentIndex = index;
    _isAdvancing = false;
    final newVideoId = widget.videosData[index].id ?? 0;
    _completedVideos[newVideoId] = false;

    // Check if the controller is already preloaded and initialized to avoid loading screen flicker!
    final bool alreadyInitialized = _controllers.containsKey(index) &&
        _controllers[index]!.value.isInitialized;
    _isInitialized = alreadyInitialized;
    _progress = alreadyInitialized
        ? (_controllers[index]!.value.position.inMilliseconds /
            _controllers[index]!.value.duration.inMilliseconds.clamp(1, double.infinity))
        : 0;

    setState(() {});

    _manageControllers(index);

    // If controller is already initialized (preloaded), play it immediately
    if (_controllers.containsKey(index)) {
      _playVideo(index);
    }

    if (index == widget.videosData.length - 1 && !_hasShownLastVideoToast) {
      _hasShownLastVideoToast = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isDisposed) {
          CustomToast.show(
            context,
            title: 'This is the last video',
            isError: false,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundDark,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.videosData.length,
        onPageChanged: _onPageChanged,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          final video = widget.videosData[index];
          final videoId = video.id ?? index;

          if (!_bookmarkMap.containsKey(videoId)) {
            _bookmarkMap[videoId] = ValueNotifier(video.savedAlready ?? false);
          }
          final bookmarkNotifier = _bookmarkMap[videoId]!;

          final shouldShowVideo =
              _controllers[index] != null &&
              _controllers[index]!.value.isInitialized &&
              _isInitialized;

          return Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  final controller = _controllers[index];
                  if (controller == null || !controller.value.isInitialized) {
                    return;
                  }

                  controller.value.isPlaying
                      ? controller.pause()
                      : controller.play();
                  setState(() {});
                },
                child: shouldShowVideo
                    ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controllers[index]!.value.size.width,
                          height: _controllers[index]!.value.size.height,
                          child: RepaintBoundary(
                            child: VideoPlayer(_controllers[index]!),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.scaffoldBackgroundDark,
                        child: const Center(child: CustomLoadingIndicator()),
                      ),
              ),

              if (shouldShowVideo)
                Center(
                  child: AnimatedOpacity(
                    opacity: _controllers[index]!.value.isPlaying ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primaryBorder, Colors.black38],
                        ),
                      ),
                      child: Icon(
                        _controllers[index]!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 30,
                        color: AppColors.whiteText,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 0,
                left: 10,
                right: 10,
                child: SafeArea(
                  child: Row(
                    children: [
                      BlurBackButton(onTap: () => context.pop()),
                      const Spacer(),
                      ShopDetailsButton(
                        onTap: () {
                          try {
                            final controller = _controllers[index];
                            if (controller != null &&
                                controller.value.isInitialized) {
                              controller.pause();
                            }
                          } catch (e) {
                            debugPrint('Error pausing player: $e');
                          }
                          context.pushNamed(
                            AppRoutes.shopDetail,
                            extra: video.shopId,
                          );
                        },
                      ),
                      if (!widget.isMyVideos) ...[
                        SizedBox(width: 15),
                        RewardContainer(
                          onTap: () {
                            VideoDialogues().showRewardsDialogue(
                              context,
                              isEarnCoins: true,
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomBar(
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: _progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(
                          GenericColors.darkGreen,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.whiteText,
                              GenericColors.lightPrimary,
                            ],
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: InkWell(
                                          onTap: () {
                                            try {
                                              final controller =
                                                  _controllers[index];
                                              if (controller != null &&
                                                  controller
                                                      .value
                                                      .isInitialized) {
                                                controller.pause();
                                              }
                                            } catch (e) {
                                              debugPrint(
                                                'Error pausing player: $e',
                                              );
                                            }
                                            context.pushNamed(
                                              AppRoutes.shopDetail,
                                              extra: video.shopId,
                                            );
                                          },
                                          child: HeaderTextBlack(
                                            title:
                                                video.shopName?.capitalize() ??
                                                '',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            textDecoration:
                                                TextDecoration.underline,
                                            decorationColor: AppColors.darkText,
                                            maxLines: 2,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      if (_watchedMap[videoId] == true &&
                                          !widget.isMyVideos)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Center(
                                            child: BodyTextColors(
                                              title: 'Watched',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.whiteText,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  SizedBox(height: 8),
                                  BodyTextHint(
                                    title:
                                        video.description?.capitalize() ?? '',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // SizedBox(height: 8),
                                  // BodyTextHint(
                                  //   title: '+91 ${video.whatsappNumber}',
                                  //   fontSize: 12,
                                  //   fontWeight: FontWeight.w400,
                                  // ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (!widget.isMyVideos) ...[
                              Row(
                                children: [
                                  CircleContainer(
                                    onTap: () async {
                                      await CustomLaunchers.openWhatsApp(
                                        phoneNumber: '${video.whatsappNumber}',
                                      );
                                    },
                                    child: Image.asset(
                                      AppIcons.whatsappP,
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                                  SizedBox(width: 10),

                                  ValueListenableBuilder<bool>(
                                    valueListenable: bookmarkNotifier,
                                    builder: (_, isActive, __) {
                                      return CircleContainer(
                                        onTap: () async {
                                          VideoShopDialogue()
                                              .showSaveOrRemoveVideoDialogue(
                                                context,
                                                isRemoveShop: isActive,
                                                onTap: () async {
                                                  final newVal = !isActive;
                                                  bookmarkNotifier.value =
                                                      newVal;
                                                  await videoController
                                                      .addSavedVideos(
                                                        videoId: video.id ?? 0,
                                                        status: newVal
                                                            ? 'active'
                                                            : 'inactive',
                                                      );
                                                  await context
                                                      .read<ProfileController>()
                                                      .saveShop(
                                                        shopId:
                                                            video.shopId ?? 0,
                                                        status: newVal
                                                            ? 'active'
                                                            : 'inactive',
                                                      );
                                                },
                                              );
                                        },
                                        child: isActive
                                            ? Image.asset(
                                                AppIcons.bookmarkP,
                                                height: 30,
                                              )
                                            : const Icon(
                                                Icons.bookmark_border,
                                                size: 30,
                                              ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Container(child: child);
    } else {
      return SafeArea(child: child);
    }
  }
}

class BlurBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const BlurBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: AppColors.whiteText.withValues(alpha: 0.2),
              border: Border.all(
                color: AppColors.whiteText.withValues(alpha: .2),
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Colors.black, size: 24),
          ),
        ),
      ),
    );
  }
}

/// Shop Detail Button

class ShopDetailsButton extends StatefulWidget {
  final VoidCallback onTap;

  const ShopDetailsButton({super.key, required this.onTap});

  @override
  State<ShopDetailsButton> createState() => _ShopDetailsButtonState();
}

class _ShopDetailsButtonState extends State<ShopDetailsButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            height: 30,
            width: 108,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                transform: GradientRotation(_controller.value * 2 * 3.14159),
                colors: [GenericColors.lightGreen, GenericColors.lightOrange],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(AppIcons.videoShop),
                  const SizedBox(width: 5),
                  BodyTextColors(
                    title: "Shop Details",
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: AppColors.whiteText,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ShopShopButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const ShopShopButton({super.key, required this.onTap, required this.child});

  @override
  State<ShopShopButton> createState() => _ShopShopButtonState();
}

class _ShopShopButtonState extends State<ShopShopButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            height: 41,
            width: 41,
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                transform: GradientRotation(_controller.value * 2 * 3.14159),
                colors: [Colors.green, Colors.amber],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.circular(30),
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Shop Location Button

class ShopLocationButton extends StatefulWidget {
  final VoidCallback onTap;

  const ShopLocationButton({super.key, required this.onTap});

  @override
  State<ShopLocationButton> createState() => _ShopLocationButtonState();
}

class _ShopLocationButtonState extends State<ShopLocationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            height: 30,
            width: 118,
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                transform: GradientRotation(_controller.value * 2 * 3.14159),
                colors: [AppColors.primary, AppColors.whiteText],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: GenericColors.lightOrange,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppIcons.videoShop,
                    colorFilter: ColorFilter.mode(
                      AppColors.darkText,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 5),
                  HeaderTextBlack(
                    title: "Shop Location",
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RewardContainer extends StatelessWidget {
  const RewardContainer({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        width: 106,
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
                Image.asset(AppIcons.rupeeCoinP, height: 20, width: 20),
                SizedBox(width: 5),
                Consumer<VideoController>(
                  builder: (context, videoController, child) {
                    return HeaderTextBlack(
                      title:
                          (videoController.coinResponse.data ??
                                  videoController.coinsCount)
                              .toString(),
                      fontSize: 14,
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
              child: Center(child: Lottie.asset(AppAnimations.confetti)),
            ),
          ],
        ),
      ),
    );
  }
}

class CircleContainer extends StatelessWidget {
  const CircleContainer({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          border: Border.all(color: GenericColors.borderGrey),
          shape: BoxShape.circle,
          color: AppColors.scaffoldBackground,
        ),
        child: Center(child: child),
      ),
    );
  }
}
