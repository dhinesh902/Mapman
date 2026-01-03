import 'dart:ui';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/views/main_dashboard/video/components/video_Dialogue.dart';
import 'package:mapman/views/widgets/custom_launchers.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

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

  CachedVideoPlayerPlus? _player;
  late PageController _pageController;

  int _currentIndex = 0;
  bool _isInitialized = false;
  bool _isCompleted = false;
  bool _isDisposed = false;
  bool _hasShownLastVideoToast = false;

  double _progress = 0.0;

  final Map<int, bool> _watchedMap = {};
  final Map<int, bool> _apiCallInProgress = {};

  /// Bookmark state per video
  final Map<int, ValueNotifier<bool>> _bookmarkMap = {};

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
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      videoController.loadViewedVideoStatus();
      _initializeVideo(initialIndex);
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _disposePlayer();
    _pageController.dispose();
    for (final notifier in _bookmarkMap.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_player == null || !_isInitialized || _isDisposed || !mounted) return;

    try {
      if (!_player!.controller.value.isInitialized) return;

      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive) {
        _player!.controller.pause();
      } else if (state == AppLifecycleState.resumed) {
        _player!.controller.play();
      }
    } catch (e) {
      debugPrint('Error in didChangeAppLifecycleState: $e');
    }
  }

  Future<void> _disposePlayer() async {
    if (_player != null) {
      try {
        try {
          _player!.controller.removeListener(_videoListener);
        } catch (e) {
          debugPrint('Error removing listener: $e');
        }

        try {
          if (_player!.controller.value.isInitialized) {
            _player!.controller.pause();
          }
        } catch (e) {
          debugPrint('Error pausing player: $e');
        }

        try {
          await _player!.dispose();
        } catch (e) {
          debugPrint('Error disposing player: $e');
        }
      } catch (e) {
        debugPrint('Error in disposePlayer: $e');
      } finally {
        _player = null;
        _isInitialized = false;
      }
    } else {
      _isInitialized = false;
    }
  }

  Future<void> _initializeVideo(int index) async {
    if (_isDisposed || index < 0 || index >= widget.videosData.length) return;

    await _disposePlayer();

    if (_isDisposed) return;

    final video = widget.videosData[index];
    _currentIndex = index;
    _isInitialized = false;
    _isCompleted = false;
    _progress = 0;

    setState(() {});

    try {
      _player = CachedVideoPlayerPlus.networkUrl(
        Uri.parse(ApiRoutes.baseUrl + (video.video ?? '')),
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: false,
          mixWithOthers: false,
        ),
      );

      await _player!.initialize();

      if (_isDisposed || !mounted) {
        await _disposePlayer();
        return;
      }

      if (_player == null || !_player!.controller.value.isInitialized) {
        await _disposePlayer();

        return;
      }

      _player!.controller
        ..setLooping(false)
        ..setVolume(1.0)
        ..addListener(_videoListener)
        ..play();

      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Video init error: $e');
      await _disposePlayer();
    }
  }

  void _videoListener() {
    if (_player == null || !_isInitialized || _isDisposed || !mounted) return;

    try {
      final value = _player!.controller.value;
      if (!value.isInitialized) return;

      final position = value.position;
      final duration = value.duration;

      if (duration.inMilliseconds > 0) {
        if (mounted && !_isDisposed) {
          setState(() {
            _progress = position.inMilliseconds / duration.inMilliseconds;
          });
        }
      }

      if (!_isCompleted &&
          duration.inMilliseconds > 0 &&
          position >= duration - const Duration(milliseconds: 500)) {
        _isCompleted = true;
        _handleVideoCompletion();
      }

      if (position <= const Duration(milliseconds: 200)) {
        _isCompleted = false;
      }

      if (duration.inMilliseconds > 0 &&
          position >= duration &&
          _currentIndex < widget.videosData.length - 1) {
        _autoAdvanceToNext();
      }
    } catch (e) {
      debugPrint('Error in videoListener: $e');
      if (_player != null && !_player!.controller.value.isInitialized) {
        _isInitialized = false;
      }
    }
  }

  // void _handleVideoCompletion() async {
  //   if (_isDisposed) return;
  //
  //   final video = widget.videosData[_currentIndex];
  //   final videoId = video.id ?? 0;
  //
  //   if (_watchedMap[videoId] != true &&
  //       !widget.isMyVideos &&
  //       videoController.isViewedVideo == 1 &&
  //       !(_apiCallInProgress[videoId] == true)) {
  //     _watchedMap[videoId] = true;
  //     _apiCallInProgress[videoId] = true;
  //
  //     _callVideoCompletionAPIs(videoId);
  //   }
  // }

  void _handleVideoCompletion() {
    if (_isDisposed) return;

    final video = widget.videosData[_currentIndex];
    final videoId = video.id ?? 0;
    if (_watchedMap[videoId] == true) return;
    if (_apiCallInProgress[videoId] == true) return;
    if (widget.isMyVideos || videoController.isViewedVideo != 1) return;
    _markVideoWatched(videoId);
  }

  // Future<void> _callVideoCompletionAPIs(int videoId) async {
  //   try {
  //     videoController.addViewedVideos(videoId: videoId);
  //
  //     await Future.delayed(const Duration(milliseconds: 300));
  //
  //     if (_isDisposed) return;
  //
  //     videoController.addVideoPoints();
  //
  //     await Future.delayed(const Duration(milliseconds: 300));
  //
  //     if (_isDisposed) return;
  //
  //     videoController.getVideoPoints();
  //   } catch (e) {
  //     debugPrint('Error in video completion APIs: $e');
  //   } finally {
  //     Future.delayed(const Duration(seconds: 5), () {
  //       if (!_isDisposed) {
  //         _apiCallInProgress.remove(videoId);
  //       }
  //     });
  //   }
  // }

  Future<void> _markVideoWatched(int videoId) async {
    _watchedMap[videoId] = true;
    _apiCallInProgress[videoId] = true;

    setState(() {});

    try {
      await videoController.addViewedVideos(videoId: videoId);
      await videoController.addVideoPoints();
      await videoController.getVideoPoints();
    } catch (e) {
      debugPrint('Watched API error: $e');
    } finally {
      _apiCallInProgress[videoId] = false;
    }
  }

  void _autoAdvanceToNext() {
    if (_isDisposed) return;

    if (_currentIndex >= widget.videosData.length - 1) {
      if (!_hasShownLastVideoToast && mounted) {
        _hasShownLastVideoToast = true;
        CustomToast.show(
          context,
          title: 'Here the videos are over.',
          isError: false,
        );
      }
      return;
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_isDisposed && _pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    if (_isDisposed || index == _currentIndex) return;
    _initializeVideo(index);

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
              index == _currentIndex && _player != null && _isInitialized;

          return Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (_player == null || !_isInitialized) return;
                  final controller = _player!.controller;
                  controller.value.isPlaying
                      ? controller.pause()
                      : controller.play();
                  setState(() {});
                },
                child:
                    shouldShowVideo &&
                        _player != null &&
                        _player!.controller.value.isInitialized
                    ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _player!.controller.value.size.width,
                          height: _player!.controller.value.size.height,
                          child: RepaintBoundary(
                            child: VideoPlayer(_player!.controller),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.scaffoldBackgroundDark,
                        child: const Center(child: CustomLoadingIndicator()),
                      ),
              ),

              if (_player != null && _isInitialized)
                Center(
                  child: AnimatedOpacity(
                    opacity: _player!.controller.value.isPlaying ? 0.0 : 1.0,
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
                        _player!.controller.value.isPlaying
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
                            if (_player != null &&
                                _player!.controller.value.isInitialized) {
                              _player!.controller.pause();
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

              /// BOTTOM CONTENT
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
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
                                              if (_player != null &&
                                                  _isInitialized &&
                                                  _player!
                                                      .controller
                                                      .value
                                                      .isInitialized) {
                                                _player!.controller.pause();
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
                                          final newVal = !isActive;
                                          bookmarkNotifier.value = newVal;
                                          await videoController.addSavedVideos(
                                            videoId: video.id ?? 0,
                                            status: newVal
                                                ? 'active'
                                                : 'inactive',
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
                HeaderTextBlack(
                  title: 'Rewards',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
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
