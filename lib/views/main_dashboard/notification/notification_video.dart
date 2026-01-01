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
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/main_dashboard/video/components/video_Dialogue.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_launchers.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

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

  CachedVideoPlayerPlus? _player;
  late final ValueNotifier<bool> bookMarkNotifier;

  bool _isInitialized = false;
  bool _isCompleted = false;
  bool _hasBeenFullyWatched = false;
  late bool isMyVideos;

  double _progress = 0.0;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  VideosData videosData = VideosData();

  @override
  void initState() {
    super.initState();

    isMyVideos = widget.isMyVideos;
    bookMarkNotifier = ValueNotifier(false);

    WidgetsBinding.instance.addObserver(this);

    videoController = context.read<VideoController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      videoController.loadViewedVideoStatus();
      getVideoById();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized || _player == null) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _player!.controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      _player!.controller.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_player != null && _isInitialized) {
      _player!.controller.removeListener(_videoListener);
      _player!.dispose();
    }
    bookMarkNotifier.dispose();
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
    if (_isInitialized && _player != null) {
      _player!.controller.removeListener(_videoListener);
      await _player!.dispose();
    }

    _hasBeenFullyWatched = false;
    _isCompleted = false;

    _player = CachedVideoPlayerPlus.networkUrl(
      Uri.parse(ApiRoutes.baseUrl + (videosData.video ?? '')),
      videoPlayerOptions: VideoPlayerOptions(
        allowBackgroundPlayback: false,
        mixWithOthers: false,
      ),
    );

    try {
      await _player!.initialize();
      if (!mounted) return;

      _player!.controller
        ..addListener(_videoListener)
        ..setLooping(true)
        ..setVolume(1.0)
        ..play();

      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Video init error: $e');
    }
  }

  // void _videoListener() {
  //   if (!_isInitialized) return;
  //
  //   final controller = _player.controller;
  //   final value = controller.value;
  //
  //   if (!value.isInitialized) return;
  //
  //   final position = value.position;
  //   final duration = value.duration;
  //
  //   if (!_isCompleted &&
  //       duration != Duration.zero &&
  //       position >= duration - const Duration(milliseconds: 300)) {
  //     _isCompleted = true;
  //
  //     if (!isMyVideos && videoController.isViewedVideo == 1) {
  //       addViewedVideos();
  //     }
  //     getVideoPoints();
  //   }
  //
  //   if (position <= const Duration(milliseconds: 200)) {
  //     _isCompleted = false;
  //   }
  // }

  void _videoListener() {
    if (!_isInitialized || _player == null) return;

    final controller = _player!.controller;
    final value = controller.value;

    if (!value.isInitialized) return;

    final position = value.position;
    final duration = value.duration;

    if (duration.inMilliseconds > 0) {
      setState(() {
        _currentPosition = position;
        _totalDuration = duration;
        _progress = position.inMilliseconds / duration.inMilliseconds;
      });
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

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
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
      backgroundColor: AppColors.scaffoldBackgroundDark,
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
              return Stack(
                children: [
                  Container(
                    child: (_player != null && _player!.isInitialized)
                        ? ClipRRect(child: VideoPlayer(_player!.controller))
                        : CustomLoadingIndicator(),
                  ),
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
                                _player!.controller.pause();
                              }
                              context.pushNamed(
                                AppRoutes.shopDetail,
                                extra: videosData.shopId,
                              );
                            },
                          ),
                          if (!isMyVideos) ...[
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
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.all(15),
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
                            child: Column(
                              children: [
                                LinearProgressIndicator(
                                  value: _progress.clamp(0.0, 1.0),
                                  minHeight: 4,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation(
                                    AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      _formatTime(_currentPosition),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _formatTime(_totalDuration),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () {
                                        if (_player != null && _isInitialized) {
                                          setState(() {
                                            _player!.controller.value.isPlaying
                                                ? _player!.controller.pause()
                                                : _player!.controller.play();
                                          });
                                        }
                                      },
                                      child: Icon(
                                        (_player != null &&
                                                _isInitialized &&
                                                _player!
                                                    .controller
                                                    .value
                                                    .isPlaying)
                                            ? Icons.pause_circle_filled
                                            : Icons.play_circle_fill,
                                        size: 36,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
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
                                                      _player!.controller
                                                          .pause();
                                                    }
                                                    context.pushNamed(
                                                      AppRoutes.shopDetail,
                                                      extra: videosData.shopId,
                                                    );
                                                  },
                                                  child: HeaderTextBlack(
                                                    title:
                                                        videosData.shopName
                                                            ?.capitalize() ??
                                                        '',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                    textDecoration:
                                                        TextDecoration
                                                            .underline,
                                                    decorationColor:
                                                        AppColors.darkText,
                                                    maxLines: 2,
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
                                          BodyTextHint(
                                            title:
                                                videosData.description
                                                    ?.capitalize() ??
                                                '',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            maxLines: 4,
                                          ),
                                          SizedBox(height: 8),
                                          BodyTextHint(
                                            title:
                                                '+91 ${videosData.whatsappNumber}',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
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
                                              await CustomLaunchers.openWhatsApp(
                                                phoneNumber: '9025821501',
                                              );
                                            },
                                            child: Image.asset(
                                              AppIcons.whatsappP,
                                              height: 30,
                                              width: 30,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          ValueListenableBuilder(
                                            valueListenable: bookMarkNotifier,
                                            builder: (context, isActive, _) {
                                              return CircleContainer(
                                                onTap: () async {
                                                  final bool newStatus =
                                                      !isActive;
                                                  bookMarkNotifier.value =
                                                      newStatus;
                                                  await videoController
                                                      .addSavedVideos(
                                                        videoId:
                                                            videosData.id ?? 0,
                                                        status: newStatus
                                                            ? 'active'
                                                            : 'inactive',
                                                      );
                                                },

                                                child: isActive
                                                    ? Image.asset(
                                                        AppIcons.bookmarkP,
                                                        height: 30,
                                                        width: 30,
                                                      )
                                                    : Icon(
                                                        Icons
                                                            .bookmark_border_outlined,
                                                        size: 30,
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
                              ],
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
