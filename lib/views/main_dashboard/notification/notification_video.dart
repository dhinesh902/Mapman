import 'dart:io';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/main_dashboard/video/single_video_screen.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_launchers.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:mapman/routes/api_routes.dart';

class NotificationVideoScreen extends StatefulWidget {
  const NotificationVideoScreen({
    super.key,
    required this.videosData,
    required this.isMyVideos,
  });

  final VideosData videosData;
  final bool isMyVideos;

  @override
  State<NotificationVideoScreen> createState() =>
      _NotificationVideoScreenState();
}

class _NotificationVideoScreenState extends State<NotificationVideoScreen>
    with WidgetsBindingObserver {
  late VideoController videoController;

  dynamic _player; // BetterPlayerController on Android, vp.VideoPlayerController on iOS
  late final ValueNotifier<bool> bookMarkNotifier;

  bool _isInitialized = false;
  bool _isCompleted = false;
  bool _hasBeenFullyWatched = false;
  late final bool isMyVideos;
  bool _isDisposed = false;

  double _progress = 0.0;

  VideosData videosData = VideosData();

  @override
  void initState() {
    super.initState();

    isMyVideos = widget.isMyVideos;
    bookMarkNotifier = ValueNotifier(false);

    WidgetsBinding.instance.addObserver(this);

    videoController = context.read<VideoController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      videoController.loadViewedVideoStatus();
      await getVideoById();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed || !_isInitialized || _player == null) return;

    try {
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive) {
        if (Platform.isAndroid) {
          (_player as BetterPlayerController).pause();
        } else {
          (_player as vp.VideoPlayerController).pause();
        }
      } else if (state == AppLifecycleState.resumed) {
        if (Platform.isAndroid) {
          (_player as BetterPlayerController).play();
        } else {
          (_player as vp.VideoPlayerController).play();
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);

    if (_player != null) {
      final p = _player;
      _player = null;
      try {
        if (Platform.isAndroid) {
          (p as BetterPlayerController).videoPlayerController?.removeListener(_videoListener);
        } else {
          (p as vp.VideoPlayerController).removeListener(_videoListener);
        }
      } catch (_) {}
      try {
        if (Platform.isAndroid) {
          (p as BetterPlayerController).pause();
        } else {
          (p as vp.VideoPlayerController).pause();
        }
      } catch (_) {}
      try {
        if (Platform.isAndroid) {
          (p as BetterPlayerController).dispose(forceDispose: true);
        } else {
          (p as vp.VideoPlayerController).dispose();
        }
      } catch (_) {}
    }

    bookMarkNotifier.dispose();
    // Do NOT call clearAppCache here — it forces all videos to re-buffer
    super.dispose();
  }

  Future<void> getVideoById() async {
    final response = await videoController.getVideoById(
      videoId: widget.videosData.id ?? 0,
    );

    if (!mounted) return;

    if (response.status == Status.COMPLETED && response.data != null) {
      videosData = response.data as VideosData;
      bookMarkNotifier.value = videosData.savedAlready ?? false;
      await _initializeVideo();
    } else {
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
    }
  }

  Future<void> _initializeVideo() async {
    if (_player != null) {
      if (Platform.isAndroid) {
        (_player as BetterPlayerController).dispose();
      } else {
        (_player as vp.VideoPlayerController).dispose();
      }
    }

    _isInitialized = false;
    _isCompleted = false;
    _hasBeenFullyWatched = false;
    _progress = 0.0;

    final videoPath = videosData.video;
    if (videoPath == null || videoPath.isEmpty) return;

    final String videoUrl = videoPath.startsWith('http')
        ? videoPath
        : '${ApiRoutes.baseUrl}$videoPath';

    try {
      if (Platform.isAndroid) {
        final isHls = videoUrl.contains('.m3u8');
        final isDash = videoUrl.contains('.mpd');

        final dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          videoUrl,
          videoFormat: isHls
              ? BetterPlayerVideoFormat.hls
              : (isDash ? BetterPlayerVideoFormat.dash : null),
          useAsmsSubtitles: false,
          useAsmsTracks: true,
          useAsmsAudioTracks: true,
          cacheConfiguration: const BetterPlayerCacheConfiguration(
            useCache: true,
            maxCacheSize: 300 * 1024 * 1024,
            maxCacheFileSize: 50 * 1024 * 1024,
          ),
          bufferingConfiguration: const BetterPlayerBufferingConfiguration(
            minBufferMs: 500, // Low buffer for fast startup
            maxBufferMs: 30000, // Large buffer for higher quality loading
            bufferForPlaybackMs: 100, // Instant playback threshold
            bufferForPlaybackAfterRebufferMs: 500,
          ),
        );

        _player = BetterPlayerController(
          const BetterPlayerConfiguration(
            autoPlay: true,
            looping: true,
            fit: BoxFit.cover,
            expandToFill: true,
            aspectRatio: 9 / 16,
            handleLifecycle: false,
            autoDispose: false,
            allowedScreenSleep: false,
            controlsConfiguration: BetterPlayerControlsConfiguration(
              showControls: false,
              loadingWidget: SizedBox.shrink(),
            ),
          ),
          betterPlayerDataSource: dataSource,
        );

        (_player as BetterPlayerController).addEventsListener((event) {
          if (!mounted || _isDisposed) return;
          if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
            if (!_isInitialized) {
              final videoPlayerController = (_player as BetterPlayerController).videoPlayerController;
              if (videoPlayerController != null) {
                try {
                  videoPlayerController.addListener(_videoListener);
                } catch (_) {}
              }
              if (mounted && !_isDisposed) {
                setState(() {
                  _isInitialized = true;
                });
              }
            }
          }
        });
      } else {
        // iOS: use standard VideoPlayerController
        final vpController = vp.VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        _player = vpController;

        await vpController.initialize();

        if (!mounted || _isDisposed) {
          vpController.dispose();
          return;
        }

        vpController.setLooping(true);
        vpController.addListener(_videoListener);
        vpController.play();

        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Video init error: $e');
    }
  }

  void _videoListener() {
    if (!mounted || _isDisposed || !_isInitialized || _player == null) return;

    try {
      if (Platform.isAndroid) {
        final videoPlayerController = (_player as BetterPlayerController).videoPlayerController;
        if (videoPlayerController == null || !videoPlayerController.value.initialized) return;

        final value = videoPlayerController.value;
        final duration = value.duration;
        final position = value.position;

        if (duration != null && duration.inMilliseconds > 0) {
          final newProgress = position.inMilliseconds / duration.inMilliseconds;
          if ((newProgress - _progress).abs() > 0.005) {
            if (mounted && !_isDisposed) {
              setState(() {
                _progress = newProgress.clamp(0.0, 1.0);
              });
            }
          }
        }

        if (!_isCompleted &&
            duration != null &&
            duration != Duration.zero &&
            position >= duration - const Duration(milliseconds: 300)) {
          _isCompleted = true;
          if (!_hasBeenFullyWatched) {
            _hasBeenFullyWatched = true;
            if (!isMyVideos && videoController.isViewedVideo == 1) {
              addViewedVideos();
            }
            getVideoPoints();
          }
        }

        if (position <= const Duration(milliseconds: 200)) {
          _isCompleted = false;
        }
      } else {
        final vpController = _player as vp.VideoPlayerController;
        if (!vpController.value.isInitialized) return;

        final value = vpController.value;
        final duration = value.duration;
        final position = value.position;

        if (duration.inMilliseconds > 0) {
          final newProgress = position.inMilliseconds / duration.inMilliseconds;
          if ((newProgress - _progress).abs() > 0.005) {
            if (mounted && !_isDisposed) {
              setState(() {
                _progress = newProgress.clamp(0.0, 1.0);
              });
            }
          }
        }

        if (!_isCompleted &&
            duration != Duration.zero &&
            position >= duration - const Duration(milliseconds: 300)) {
          _isCompleted = true;
          if (!_hasBeenFullyWatched) {
            _hasBeenFullyWatched = true;
            if (!isMyVideos && videoController.isViewedVideo == 1) {
              addViewedVideos();
            }
            getVideoPoints();
          }
        }

        if (position <= const Duration(milliseconds: 200)) {
          _isCompleted = false;
        }
      }
    } catch (_) {}
  }

  Future<void> addViewedVideos() async {
    await videoController.addViewedVideos(videoId: videosData.id ?? 0);
  }

  Future<void> getVideoPoints() async {
    await videoController.addVideoPoints();
    await videoController.getVideoPoints();
  }

  @override
  Widget build(BuildContext context) {
    videoController = context.watch<VideoController>();
    return Scaffold(
      backgroundColor: AppColors.darkText,
      appBar:
          (videoController.videoByIdData.status == Status.LOADING ||
              videoController.videoByIdData.data != null)
          ? null
          : ActionBar(title: ''),
      body: Builder(
        builder: (context) {
          switch (videoController.videoByIdData.status) {
            case Status.INITIAL:
            case Status.LOADING:
              return CustomLoadingIndicator();
            case Status.COMPLETED:
              if (videoController.videoByIdData.data == null) {
                return EmptyDataContainer(
                  children: [
                    Image.asset(AppIcons.videoClipP, height: 120, width: 120),
                    SizedBox(height: 20),
                    BodyTextColors(
                      title: 'This video no longer available!!',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightGreyHint,
                    ),
                  ],
                );
              }
              if (_player == null || !_isInitialized) {
                return Container(color: AppColors.darkText);
              }
              return Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (_player == null || !_isInitialized) return;
                      try {
                        if (Platform.isAndroid) {
                          final bpController = _player as BetterPlayerController;
                          final vpc = bpController.videoPlayerController;
                          if (vpc == null) return;
                          vpc.value.isPlaying ? bpController.pause() : bpController.play();
                        } else {
                          final vpController = _player as vp.VideoPlayerController;
                          vpController.value.isPlaying ? vpController.pause() : vpController.play();
                        }
                      } catch (_) {}
                      setState(() {});
                    },
                    child:
                        _player != null && _isInitialized
                        ? Platform.isIOS
                            ? AspectRatio(
                                aspectRatio: (() {
                                  final vpController = _player as vp.VideoPlayerController;
                                  final size = vpController.value.size;
                                  return (size.width > 0 && size.height > 0)
                                      ? size.width / size.height
                                      : 9 / 16;
                                })(),
                                child: vp.VideoPlayer(_player as vp.VideoPlayerController),
                              )
                            : FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: (_player as BetterPlayerController).videoPlayerController?.value.size?.width ?? 1080,
                                  height: (_player as BetterPlayerController).videoPlayerController?.value.size?.height ?? 1920,
                                  child: BetterPlayer(controller: _player as BetterPlayerController),
                                ),
                              )
                        : Container(
                            color: AppColors.scaffoldBackgroundDark,
                            child: const Center(
                              child: CustomLoadingIndicator(),
                            ),
                          ),
                  ),
                  if (_player != null && _isInitialized) ...[
                    Center(
                      child: AnimatedOpacity(
                        opacity: (() {
                          if (Platform.isAndroid) {
                            return ((_player as BetterPlayerController).videoPlayerController?.value.isPlaying ?? false) ? 0.0 : 1.0;
                          } else {
                            return (_player as vp.VideoPlayerController).value.isPlaying ? 0.0 : 1.0;
                          }
                        })(),
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
                            (() {
                              if (Platform.isAndroid) {
                                return ((_player as BetterPlayerController).videoPlayerController?.value.isPlaying ?? false)
                                    ? Icons.pause
                                    : Icons.play_arrow;
                              } else {
                                return (_player as vp.VideoPlayerController).value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow;
                              }
                            })(),
                            size: 30,
                            color: AppColors.whiteText,
                          ),
                        ),
                      ),
                    ),
                  ],
                  Positioned(
                    top: 0,
                    left: 10,
                    right: 10,
                    child: SafeArea(
                      child: Row(
                        children: [
                          BlurBackButton(
                            onTap: () {
                              context.pop();
                            },
                          ),
                          Spacer(),
                          ShopDetailsButton(
                            onTap: () {
                              if (_player != null && _isInitialized) {
                                _player!.pause();
                              }
                              context.pushNamed(
                                AppRoutes.shopDetail,
                                extra: videosData.shopId,
                              );
                            },
                          ),
                          // if (!isMyVideos) ...[
                          //   SizedBox(width: 15),
                          //   RewardContainer(
                          //     onTap: () {
                          //       VideoDialogues().showRewardsDialogue(
                          //         context,
                          //         isEarnCoins: true,
                          //       );
                          //     },
                          //   ),
                          // ],
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
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          LinearProgressIndicator(
                            value: _progress.clamp(0.0, 1.0),
                            minHeight: 4,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation(
                              GenericColors.darkGreen,
                            ),
                          ),
                          ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                              child: Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: AppColors.whiteText.withValues(
                                        alpha: 0.12,
                                      ),
                                      width: 1.0,
                                    ),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.whiteText.withValues(
                                        alpha: 0.10,
                                      ),
                                      GenericColors.lightPrimary.withValues(
                                        alpha: 0.05,
                                      ),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: InkWell(
                                                  onTap: () {
                                                    if (_player != null &&
                                                        _isInitialized) {
                                                      _player!.pause();
                                                    }
                                                    context.pushNamed(
                                                      AppRoutes.shopDetail,
                                                      extra: videosData.shopId,
                                                    );
                                                  },
                                                  child: BodyTextColors(
                                                    title:
                                                        videosData.shopName
                                                            ?.capitalize() ??
                                                        '',
                                                    fontSize: 16,
                                                    color: AppColors.whiteText,
                                                    fontWeight: FontWeight.w400,
                                                    textDecoration:
                                                        TextDecoration
                                                            .underline,
                                                    decorationColor:
                                                        AppColors.whiteText,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              if (videosData.watched == true &&
                                                  !isMyVideos)
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: BodyTextColors(
                                                      title: 'Watched',
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          AppColors.whiteText,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          BodyTextColors(
                                            title:
                                                videosData.description
                                                    ?.capitalize() ??
                                                '',
                                            fontSize: 12,
                                            color: AppColors.whiteText,
                                            fontWeight: FontWeight.w400,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    if (!isMyVideos) ...[
                                      Row(
                                        children: [
                                          CircleContainer(
                                            onTap: () async {
                                              if (_player != null &&
                                                  _isInitialized) {
                                                _player!.pause();
                                              }
                                              context.pushNamed(
                                                AppRoutes.shopDetail,
                                                extra: videosData.shopId,
                                              );
                                            },
                                            child: Icon(
                                              Icons.info,
                                              color: AppColors.primary,
                                              size: 25,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          ValueListenableBuilder<bool>(                                            valueListenable: bookMarkNotifier,
                                            builder: (context, isBookmarked, _) {
                                              return CircleContainer(
                                                onTap: () async {
                                                  final bool updatedStatus =
                                                      !isBookmarked;

                                                  // Optimistic UI update
                                                  bookMarkNotifier.value =
                                                      updatedStatus;

                                                  final profileController =
                                                      context
                                                          .read<
                                                            ProfileController
                                                          >();

                                                  try {
                                                    await videoController
                                                        .addSavedVideos(
                                                          videoId:
                                                              videosData.id ??
                                                              0,
                                                          status: updatedStatus
                                                              ? 'active'
                                                              : 'inactive',
                                                        );

                                                    await profileController
                                                        .saveShop(
                                                          shopId:
                                                              videosData
                                                                  .shopId ??
                                                              0,
                                                          status: updatedStatus
                                                              ? 'active'
                                                              : 'inactive',
                                                        );
                                                  } catch (e) {
                                                    bookMarkNotifier.value =
                                                        isBookmarked;
                                                  }
                                                },
                                                child: isBookmarked
                                                    ? Image.asset(
                                                        AppIcons.bookmarkP,
                                                        height: 25,
                                                        width: 25,
                                                      )
                                                    : const Icon(
                                                        Icons
                                                            .bookmark_border_outlined,
                                                        size: 25,
                                                        color:
                                                            AppColors.darkGrey,
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            case Status.ERROR:
              return CustomErrorTextWidget(
                title: '${videoController.videoByIdData.message}',
              );
          }
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
        height: 40,
        width: 40,
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
