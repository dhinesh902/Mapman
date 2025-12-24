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
  });

  final VideosData videosData;
  final bool isMyVideos;

  @override
  State<SingleVideoScreen> createState() => _SingleVideoScreenState();
}

class _SingleVideoScreenState extends State<SingleVideoScreen>
    with WidgetsBindingObserver {
  late VideoController videoController;

  late final CachedVideoPlayerPlus _player;
  late ValueNotifier<bool> bookMarkNotifier;

  bool _isInitialized = false;
  bool _isCompleted = false;
  late bool isMyVideos;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isMyVideos = widget.isMyVideos;
    bookMarkNotifier = ValueNotifier(widget.videosData.savedAlready ?? false);

    WidgetsBinding.instance.addObserver(this);
    videoController = context.read<VideoController>();

    _initializeVideo();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _player.controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      _player.controller.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.controller.removeListener(_videoListener);
    _player.dispose();
    bookMarkNotifier.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    _player = CachedVideoPlayerPlus.networkUrl(
      Uri.parse(ApiRoutes.baseUrl + (widget.videosData.video ?? '')),
      videoPlayerOptions: VideoPlayerOptions(
        allowBackgroundPlayback: false,
        mixWithOthers: false,
      ),
    );

    try {
      await _player.initialize();
      if (!mounted) return;

      _player.controller.addListener(_videoListener);

      _player.controller
        ..setLooping(true)
        ..setVolume(1.0)
        ..play();

      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Video init error: $e');
    }
  }

  void _videoListener() {
    final controller = _player.controller;

    if (!controller.value.isInitialized) return;

    final position = controller.value.position;
    final duration = controller.value.duration;

    if (!_isCompleted &&
        duration != Duration.zero &&
        position >= duration - const Duration(milliseconds: 300)) {
      _isCompleted = true;
      if (!isMyVideos) {
        addViewedVideos();
      }
    }

    if (position <= const Duration(milliseconds: 200)) {
      _isCompleted = false;
    }
  }

  Future<void> addViewedVideos() async {
    await videoController.addViewedVideos(videoId: widget.videosData.id ?? 0);
    await videoController.getVideoPoints();
  }

  @override
  Widget build(BuildContext context) {
    videoController = context.watch<VideoController>();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundDark,
      body: Stack(
        children: [
          Container(
            child: _player.isInitialized
                ? ClipRRect(child: VideoPlayer(_player.controller))
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
                      _player.controller.pause();
                      context.pushNamed(
                        AppRoutes.shopDetail,
                        extra: widget.videosData.shopId,
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
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.whiteText, GenericColors.lightPrimary],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: HeaderTextBlack(
                                  title:
                                      widget.videosData.shopName
                                          ?.capitalize() ??
                                      '',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  textDecoration: TextDecoration.underline,
                                  decorationColor: AppColors.darkText,
                                  maxLines: 2,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                              SizedBox(width: 10),
                              if (widget.videosData.watched == true &&
                                  !isMyVideos)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
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
                                widget.videosData.description?.capitalize() ??
                                '',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            maxLines: 4,
                          ),
                          SizedBox(height: 8),
                          BodyTextHint(
                            title: '+91 9791543759',
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
                                  bookMarkNotifier.value = !isActive;
                                  await videoController.addSavedVideos(
                                    videoId: widget.videosData.id ?? 0,
                                  );
                                },
                                child: isActive
                                    ? Image.asset(
                                        AppIcons.bookmarkP,
                                        height: 30,
                                        width: 30,
                                      )
                                    : Icon(
                                        Icons.bookmark_border_outlined,
                                        size: 30,
                                        color: AppColors.darkGrey,
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
