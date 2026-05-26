import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:better_player_plus/better_player_plus.dart';
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
import 'package:mapman/views/main_dashboard/video/components/video_shop_dialogue.dart';
import 'package:mapman/views/widgets/custom_launchers.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

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
  final Map<int, BetterPlayerController> _controllers = {};
  final Map<int, VoidCallback> _activeListeners = {};
  final Set<BetterPlayerController> _disposedControllers = {};

  // State variables
  int _currentIndex = 0;
  late PageController _pageController;
  bool _isDisposed = false;
  Timer? _debounceTimer;
  bool _hasShownLastVideoToast = false;

  // ValueNotifiers — no full-screen setState for progress or play state
  final ValueNotifier<double> _progressNotifier = ValueNotifier(0.0);
  final ValueNotifier<bool> _isPlayingNotifier = ValueNotifier(false);

  // Per-index readiness notifier: flips true when the controller at that index
  // becomes initialized. Drives a cell-only rebuild so the video surface
  // appears without a full-screen setState.
  final Map<int, ValueNotifier<bool>> _readyMap = {};

  final Map<int, bool> _watchedMap = {};
  final Map<int, bool> _apiCallInProgress = {};
  final Map<int, bool> _completedVideos = {};
  final Map<int, ValueNotifier<bool>> _bookmarkMap = {};
  final Set<int> _initializingIndices = {};

  // Session token — incremented on every page change to cancel stale async ops
  int _sessionToken = 0;

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
    _progressNotifier.dispose();
    _isPlayingNotifier.dispose();
    for (final notifier in _bookmarkMap.values) {
      notifier.dispose();
    }
    for (final notifier in _readyMap.values) {
      notifier.dispose();
    }
    // Do NOT clear cache here — it forces all videos to re-download
    super.dispose();
  }

  void _removeVideoListener(int index) {
    final listener = _activeListeners.remove(index);
    if (listener != null) {
      final player = _controllers[index];
      if (player != null && !_disposedControllers.contains(player)) {
        final videoPlayerController = player.videoPlayerController;
        if (videoPlayerController != null) {
          try {
            videoPlayerController.removeListener(listener);
          } catch (_) {}
        }
      }
    }
  }

  Future<void> _disposeAllControllers() async {
    for (final index in _controllers.keys.toList()) {
      _removeVideoListener(index);
      final controller = _controllers[index];
      if (controller != null) {
        _disposedControllers.add(controller);
        try {
          controller.pause();
        } catch (_) {}
        try {
          controller.dispose(forceDispose: true);
        } catch (_) {}
      }
    }
    _controllers.clear();
    _activeListeners.clear();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed || !mounted) return;

    final controller = _controllers[_currentIndex];
    if (controller == null || _disposedControllers.contains(controller)) return;

    final videoPlayerController = controller.videoPlayerController;
    if (videoPlayerController == null) return;

    try {
      if (!videoPlayerController.value.initialized) return;

      if (state == AppLifecycleState.resumed) {
        if (!videoPlayerController.value.isPlaying) {
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

    // Capture the session token at the moment we start init.
    // If the user scrolls away, _sessionToken is incremented and we bail out.
    final mySession = _sessionToken;

    final video = widget.videosData[index];
    final String videoPath = video.video ?? '';
    final String videoUrl = videoPath.startsWith('http')
        ? videoPath
        : '${ApiRoutes.baseUrl}$videoPath';

    try {
      debugPrint(
        '🎬 Initializing progressive streaming video at index $index with URL: $videoUrl',
      );

      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        videoUrl,
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: true,
          maxCacheSize: 50 * 1024 * 1024,
          maxCacheFileSize: 10 * 1024 * 1024,
        ),
        bufferingConfiguration: const BetterPlayerBufferingConfiguration(
          minBufferMs: 2000,
          maxBufferMs: 10000,
          bufferForPlaybackMs: 1000,
          bufferForPlaybackAfterRebufferMs: 2000,
        ),
      );

      final player = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: false,
          looping: true,
          fit: BoxFit.cover,
          expandToFill: true,
          aspectRatio: 9 / 16,
          handleLifecycle: false,
          autoDispose: false,
          allowedScreenSleep: false,
          controlsConfiguration: const BetterPlayerControlsConfiguration(
            showControls: false,
          ),
        ),
        betterPlayerDataSource: dataSource,
      );

      // Bail out if user scrolled away before controller was even created
      if (mySession != _sessionToken || _isDisposed) {
        _disposedControllers.add(player);
        try {
          player.pause();
        } catch (_) {}
        try {
          player.dispose(forceDispose: true);
        } catch (_) {}
        return;
      }

      _controllers[index] = player;

      // Listen to events
      player.addEventsListener((event) {
        if (_isDisposed || !mounted || _disposedControllers.contains(player)) {
          return;
        }

        // Only guard against controller replacement for THIS index.
        // Do NOT check _sessionToken here — preloaded neighbor controllers
        // survive session bumps from later page changes and must still
        // auto-play when the user scrolls back to them.
        if (_controllers[index] != player) return;

        if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
          if (index == _currentIndex) {
            _playVideo(index);
          } else {
            try {
              player.pause();
            } catch (_) {}
          }
        }
      });

      // Post-async guard: session changed while awaiting
      if (mySession != _sessionToken || _isDisposed) {
        _disposedControllers.add(player);
        _controllers.remove(index);
        try {
          player.pause();
        } catch (_) {}
        try {
          player.dispose(forceDispose: true);
        } catch (_) {}
        return;
      }

      // If video is no longer needed (scrolled away), dispose it immediately
      if ((index - _currentIndex).abs() > 1) {
        debugPrint('⚠️ Video at index $index no longer needed, disposing...');
        _disposedControllers.add(player);
        _controllers.remove(index);
        try {
          player.pause();
        } catch (_) {}
        try {
          player.dispose(forceDispose: true);
        } catch (_) {}
        return;
      }
    } catch (e) {
      debugPrint('❌ Init failed for index $index: $e');
    } finally {
      _initializingIndices.remove(index);
    }
  }

  Future<void> _playVideo(int index) async {
    final controller = _controllers[index];
    if (controller == null || _disposedControllers.contains(controller)) return;

    final videoPlayerController = controller.videoPlayerController;
    if (videoPlayerController == null) return;
    if (!videoPlayerController.value.initialized) return;

    _removeVideoListener(index);

    void listener() => _videoListener(index);
    _activeListeners[index] = listener;

    try {
      videoPlayerController.addListener(listener);
    } catch (e) {
      debugPrint('Controller $index addListener failed: $e. Reinitializing...');
      _controllers.remove(index);
      _initController(index);
      return;
    }

    try {
      controller.setVolume(1.0);
    } catch (_) {}
    try {
      controller.play();
    } catch (_) {}

    // Signal readiness so the cell rebuilds and shows the video surface.
    _readyMap[index] ??= ValueNotifier(false);
    _readyMap[index]!.value = true;

    _isPlayingNotifier.value = true;
  }

  Future<void> _disposeController(int index) async {
    if (_controllers.containsKey(index)) {
      debugPrint('🗑️ Disposing video at index $index');
      _removeVideoListener(index);
      final player = _controllers.remove(index);
      if (player != null) {
        _disposedControllers.add(player);
        try {
          player.pause();
        } catch (_) {}
        try {
          player.dispose(forceDispose: true);
        } catch (_) {}
      }
    }
  }

  Future<void> _manageControllers(int index) async {
    if (index != _currentIndex || _isDisposed) return;

    // ── Current video FIRST ─────────────────────────────────────────────
    // Always initialize the current index before preloading neighbors so
    // the tapped/landed video starts buffering immediately without competing
    // with neighbor network requests.
    await _initController(index);

    if (index != _currentIndex || _isDisposed) return;

    // Safety net: already initialized but not playing (preloaded controller
    // that fired its initialized event before the user landed here).
    final currentController = _controllers[index];
    if (currentController != null &&
        !_disposedControllers.contains(currentController)) {
      final vpc = currentController.videoPlayerController;
      if (vpc != null && vpc.value.initialized && !vpc.value.isPlaying) {
        _playVideo(index);
      }
    }

    if (index != _currentIndex || _isDisposed) return;

    // ── Preload neighbors AFTER current has started buffering ───────────
    if (index + 1 < widget.videosData.length) {
      _initController(index + 1);
    }
    if (index - 1 >= 0) {
      _initController(index - 1);
    }

    if (index != _currentIndex || _isDisposed) return;

    // ── Dispose far controllers (distance > 1) ──────────────────────────
    final keysToRemove = _controllers.keys
        .where((key) => (key - index).abs() > 1)
        .toList();
    for (final key in keysToRemove) {
      await _disposeController(key);
    }
  }

  void _videoListener(int index) {
    if (_isDisposed || !mounted) return;
    if (index != _currentIndex) return;

    final player = _controllers[index];
    if (player == null || _disposedControllers.contains(player)) return;

    final videoPlayerController = player.videoPlayerController;
    if (videoPlayerController == null) {
      return;
    }

    try {
      if (!videoPlayerController.value.initialized) {
        return;
      }
      final value = videoPlayerController.value;
      final position = value.position;
      final duration = value.duration;

      // Update progress via ValueNotifier — no setState, no tree rebuild
      if (duration != null && duration.inMilliseconds > 0) {
        _progressNotifier.value =
            position.inMilliseconds / duration.inMilliseconds;
      }

      // Update play state notifier
      _isPlayingNotifier.value = value.isPlaying;

      final videoId = widget.videosData[_currentIndex].id ?? 0;

      if (duration != null &&
          (_completedVideos[videoId] == false) &&
          position.inMilliseconds >= duration.inMilliseconds) {
        _completedVideos[videoId] = true;
        _handleVideoCompletion();
      }

      if (duration != null &&
          position.inMilliseconds < duration.inMilliseconds * 0.1) {
        _completedVideos[videoId] = false;
      }

      // Removed manual seekTo+play loop: looping:true already handles this
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
    // No setState needed — watched badge re-reads _watchedMap on next build

    try {
      debugPrint('Video $videoId FULLY COMPLETED - Calling APIs...');

      if (videoController.isViewedVideo == 1) {
        await videoController.addViewedVideos(videoId: videoId);
        debugPrint('addViewedVideos SUCCESS');
      }
    } catch (e) {
      debugPrint('API Error video $videoId: $e');
    } finally {
      if (!_isDisposed) {
        _apiCallInProgress[videoId] = false;
      }
    }
  }

  void _onPageChanged(int index) {
    if (_isDisposed) return;

    // Invalidate all pending async inits started for the old page
    _sessionToken++;

    // Stop previous video
    if (_controllers.containsKey(_currentIndex)) {
      final oldController = _controllers[_currentIndex];
      if (oldController != null &&
          !_disposedControllers.contains(oldController)) {
        try {
          oldController.pause();
          oldController.setVolume(0.0);
        } catch (_) {}
        _removeVideoListener(_currentIndex);
      }
    }

    _currentIndex = index;
    final newVideoId = widget.videosData[index].id ?? 0;
    _completedVideos[newVideoId] = false;

    // Reset notifiers for new page
    _progressNotifier.value = 0.0;
    _isPlayingNotifier.value = false;
    // Reset readiness so the loading indicator shows while the new page
    // initializes (unless it is already preloaded).
    _readyMap[index] ??= ValueNotifier(false);
    _readyMap[index]!.value = false;

    // Safely check if the controller is already preloaded and initialized
    bool alreadyInitialized = false;

    try {
      final controller = _controllers[index];
      if (controller != null &&
          !_disposedControllers.contains(controller) &&
          controller.videoPlayerController != null) {
        final videoPlayerController = controller.videoPlayerController!;
        alreadyInitialized = videoPlayerController.value.initialized;
        if (alreadyInitialized) {
          final duration = videoPlayerController.value.duration;
          final position = videoPlayerController.value.position;
          if (duration != null && duration.inMilliseconds > 0) {
            _progressNotifier.value =
                position.inMilliseconds / duration.inMilliseconds;
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking initialization in _onPageChanged: $e');
      alreadyInitialized = false;
    }

    _manageControllers(index);

    // If controller is already initialized (preloaded), play it immediately
    if (alreadyInitialized) {
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

          // _readyMap drives a per-cell rebuild when the controller becomes
          // initialized — avoids a full-screen setState.
          _readyMap[index] ??= ValueNotifier(false);
          final readyNotifier = _readyMap[index]!;

          return ValueListenableBuilder<bool>(
            valueListenable: readyNotifier,
            builder: (context, isReady, _) {
              final controller = _controllers[index];
              final bool isControllerValid = controller != null &&
                  !_disposedControllers.contains(controller);

              // Check if controller is already initialized.
              final bool initiallyReady = isControllerValid &&
                  controller.videoPlayerController != null &&
                  controller.videoPlayerController!.value.initialized;

              final effectivelyReady = isReady || initiallyReady;
              bool shouldShowVideo = false;
              double videoWidth = 1080;
              double videoHeight = 1920;

              try {
                if (effectivelyReady &&
                    isControllerValid &&
                    controller.videoPlayerController != null) {
                  final vpc = controller.videoPlayerController!;
                  shouldShowVideo = vpc.value.initialized;
                  if (shouldShowVideo) {
                    videoWidth = vpc.value.size?.width ?? 1080;
                    videoHeight = vpc.value.size?.height ?? 1920;
                  }
                }
              } catch (_) {
                shouldShowVideo = false;
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (!isControllerValid) return;
                      final videoPlayerController =
                          controller.videoPlayerController;
                      if (videoPlayerController == null ||
                          !videoPlayerController.value.initialized) {
                        return;
                      }
                      try {
                        if (videoPlayerController.value.isPlaying) {
                          controller.pause();
                          _isPlayingNotifier.value = false;
                        } else {
                          controller.play();
                          _isPlayingNotifier.value = true;
                        }
                      } catch (_) {}
                    },
                    child: shouldShowVideo
                        ? FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: videoWidth,
                              height: videoHeight,
                              child: RepaintBoundary(
                                child: BetterPlayer(controller: controller!),
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.scaffoldBackgroundDark,
                            child: const Center(
                              child: CustomLoadingIndicator(),
                            ),
                          ),
                  ),

                  if (shouldShowVideo)
                    Center(
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isPlayingNotifier,
                        builder: (_, isPlaying, __) {
                          return GestureDetector(
                            onTap: () {
                              if (!isControllerValid) return;
                              final videoPlayerController =
                                  controller.videoPlayerController;
                              if (videoPlayerController == null ||
                                  !videoPlayerController.value.initialized) {
                                return;
                              }
                              try {
                                if (isPlaying) {
                                  controller.pause();
                                  _isPlayingNotifier.value = false;
                                } else {
                                  controller.play();
                                  _isPlayingNotifier.value = true;
                                }
                              } catch (_) {}
                            },
                            child: AnimatedOpacity(
                              opacity: isPlaying ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primaryBorder,
                                      Colors.black38,
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  size: 30,
                                  color: AppColors.whiteText,
                                ),
                              ),
                            ),
                          );
                        },
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
                                if (isControllerValid &&
                                    controller.videoPlayerController != null &&
                                    controller
                                        .videoPlayerController!
                                        .value
                                        .initialized) {
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
                          // if (!widget.isMyVideos) ...[
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
                        children: [
                          ValueListenableBuilder<double>(
                            valueListenable: _progressNotifier,
                            builder: (_, progress, __) {
                              return LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation(
                                  GenericColors.darkGreen,
                                ),
                              );
                            },
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
                                                try {
                                                  final controller =
                                                      _controllers[index];
                                                  if (controller != null &&
                                                      controller
                                                              .videoPlayerController !=
                                                          null &&
                                                      controller
                                                          .videoPlayerController!
                                                          .value
                                                          .initialized) {
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
                                                    video.shopName
                                                        ?.capitalize() ??
                                                    '',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                textDecoration:
                                                    TextDecoration.underline,
                                                decorationColor:
                                                    AppColors.darkText,
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
                                                borderRadius:
                                                    BorderRadius.circular(20),
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
                                            video.description?.capitalize() ??
                                            '',
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
                                            phoneNumber:
                                                '${video.whatsappNumber}',
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
                                                      final profileController =
                                                          context
                                                              .read<
                                                                ProfileController
                                                              >();
                                                      final newVal = !isActive;
                                                      bookmarkNotifier.value =
                                                          newVal;
                                                      await videoController
                                                          .addSavedVideos(
                                                            videoId:
                                                                video.id ?? 0,
                                                            status: newVal
                                                                ? 'active'
                                                                : 'inactive',
                                                          );
                                                      await profileController
                                                          .saveShop(
                                                            shopId:
                                                                video.shopId ??
                                                                0,
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
              ); // closes Stack
            }, // closes ValueListenableBuilder builder
          ); // closes ValueListenableBuilder
        },
      ),
    );
  } // end build()
} // end _SingleVideoScreenState

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
