import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
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
import 'package:mapman/utils/storage/video_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  // State variables
  int _currentIndex = 0;
  late PageController _pageController;
  bool _isDisposed = false;
  Timer? _debounceTimer;
  Timer? _preloadTimer;
  Timer? _playDebounceTimer;
  bool _hasShownLastVideoToast = false;

  // ValueNotifiers — no full-screen setState for progress or play state
  final ValueNotifier<double> _progressNotifier = ValueNotifier(0.0);
  final ValueNotifier<bool> _isPlayingNotifier = ValueNotifier(false);

  // Per-index readiness notifier: flips true when the controller at that index
  // becomes initialized. Drives a cell-only rebuild so the video surface
  // appears without a full-screen setState.
  final Map<int, ValueNotifier<bool>> _readyMap = {};

  // Per-index first frame rendered notifier: flips true when the video has
  // decoded and rendered its first frame (position > 0). Drives a smooth
  // thumbnail fadeout transition.
  final Map<int, ValueNotifier<bool>> _firstFrameRenderedMap = {};

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

    // Proactively initialize the first video immediately to start buffering
    _initController(initialIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      videoController.loadViewedVideoStatus();
      if (!_isDisposed) {
        _onPageChanged(initialIndex);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _preloadTimer?.cancel();
    _playDebounceTimer?.cancel();
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
    for (final notifier in _firstFrameRenderedMap.values) {
      notifier.dispose();
    }
    _cleanTempFilesAsync();
    super.dispose();
  }

  void _removeVideoListener(int index) {
    final listener = _activeListeners.remove(index);
    if (listener != null) {
      final player = _controllers[index];
      if (player != null) {
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
    if (controller == null) return;

    final videoPlayerController = controller.videoPlayerController;
    if (videoPlayerController == null) return;

    try {
      if (!videoPlayerController.value.initialized) return;

      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive) {
        if (videoPlayerController.value.isPlaying) {
          controller.pause();
          _isPlayingNotifier.value = false;
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
    final String videoPath = video.video ?? '';
    final String videoUrl = videoPath.startsWith('http')
        ? videoPath
        : '${ApiRoutes.baseUrl}$videoPath';

    try {
      debugPrint('🎬 Initializing video at index $index: $videoUrl');

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

      final player = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: false,
          looping: true,
          fit: BoxFit.cover,
          // Reels style should fill screen
          expandToFill: true,
          aspectRatio: 9 / 16,
          handleLifecycle: false,
          autoDispose: false,
          allowedScreenSleep: false,
          controlsConfiguration: const BetterPlayerControlsConfiguration(
            showControls: false,
            loadingWidget: SizedBox.shrink(),
          ),
          errorBuilder: (context, errorMessage) {
            return Container(
              color: AppColors.scaffoldBackgroundDark,
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 40,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Video resolution exceeds device capabilities or format not supported.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.lightGreyHint,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        betterPlayerDataSource: dataSource,
      );

      // Async gap check: If the user scrolled away and this index is no longer inside
      // the active window [currentIndex - 1, currentIndex + 1], dispose it immediately.
      if (_isDisposed ||
          index < _currentIndex - 1 ||
          index > _currentIndex + 1) {
        player.dispose(forceDispose: true);
        return;
      }

      _controllers[index] = player;

      // Listen to player initialization events
      player.addEventsListener((event) {
        if (_isDisposed || !mounted || _controllers[index] != player) {
          return;
        }

        if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
          _readyMap[index] ??= ValueNotifier(false);
          _readyMap[index]!.value = true;

          if (index == _currentIndex) {
            _schedulePlayVideo(index);
          } else {
            try {
              player.pause();
            } catch (_) {}
          }
        }
      });
    } catch (e) {
      debugPrint('❌ Init failed for index $index: $e');
    } finally {
      _initializingIndices.remove(index);
    }
  }

  void _schedulePlayVideo(int index) {
    _playDebounceTimer?.cancel();
    _playDebounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (!_isDisposed && _currentIndex == index) {
        _playVideo(index);
      }
    });
  }

  Future<void> _playVideo(int index) async {
    final controller = _controllers[index];
    if (controller == null) return;

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

    // Signal readiness
    _readyMap[index] ??= ValueNotifier(false);
    _readyMap[index]!.value = true;

    _firstFrameRenderedMap[index] ??= ValueNotifier(false);

    _isPlayingNotifier.value = true;
  }

  Future<void> _disposeController(int index) async {
    if (_controllers.containsKey(index)) {
      debugPrint('🗑️ Disposing video at index $index');
      _removeVideoListener(index);
      final player = _controllers.remove(index);
      if (player != null) {
        try {
          player.pause();
        } catch (_) {}
        try {
          player.dispose(forceDispose: true);
        } catch (_) {}
      }
    }
  }

  void _preloadNeighbors(int index) {
    // Preload next video for seamless scrolling forward
    if (index + 1 < widget.videosData.length) {
      _initController(index + 1);
    }
    // Preload previous video for seamless scrolling backward
    if (index - 1 >= 0) {
      _initController(index - 1);
    }
  }

  void _disposeFarControllers(int index) {
    final farIndices = _controllers.keys
        .where((idx) => idx < index - 1 || idx > index + 1)
        .toList();
    for (final idx in farIndices) {
      _disposeController(idx);
    }
  }

  void _videoListener(int index) {
    if (_isDisposed || !mounted) return;
    if (index != _currentIndex) return;

    final player = _controllers[index];
    if (player == null) return;

    final videoPlayerController = player.videoPlayerController;
    if (videoPlayerController == null) return;

    try {
      if (!videoPlayerController.value.initialized) return;

      final value = videoPlayerController.value;
      final position = value.position;
      final duration = value.duration;

      // Update progress via ValueNotifier (no setState rebuild)
      if (duration != null && duration.inMilliseconds > 0) {
        _progressNotifier.value =
            position.inMilliseconds / duration.inMilliseconds;
      }

      // Update play state notifier
      _isPlayingNotifier.value = value.isPlaying;

      // Transition check: Mark first frame as rendered once the playback position advances past zero.
      if (position > Duration.zero) {
        _firstFrameRenderedMap[index] ??= ValueNotifier(false);
        if (!_firstFrameRenderedMap[index]!.value) {
          _firstFrameRenderedMap[index]!.value = true;
        }
      }

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

    _currentIndex = index;

    // Reset notifiers for the new active video
    _progressNotifier.value = 0.0;
    _isPlayingNotifier.value = false;

    // Force thumbnail to show for the new active video until first frame renders
    _firstFrameRenderedMap[index] ??= ValueNotifier(false);
    _firstFrameRenderedMap[index]!.value = false;

    // Pause and reset all other controllers
    _controllers.forEach((idx, controller) {
      if (idx != index) {
        try {
          controller.pause();
          controller.seekTo(Duration.zero);
          controller.setVolume(0.0);
        } catch (_) {}
        _removeVideoListener(idx);
        _firstFrameRenderedMap[idx]?.value = false;
      }
    });

    // Safely check if the controller is already preloaded and initialized
    final controller = _controllers[index];
    final bool alreadyInitialized =
        controller != null &&
        controller.videoPlayerController != null &&
        controller.videoPlayerController!.value.initialized;

    if (alreadyInitialized) {
      _schedulePlayVideo(index);
    } else {
      _readyMap[index] ??= ValueNotifier(false);
      _readyMap[index]!.value = false;
      _initController(index);
    }

    // Schedule preloading of neighbors with a short delay to prioritize active video network traffic
    _preloadTimer?.cancel();
    _preloadTimer = Timer(const Duration(milliseconds: 300), () {
      if (!_isDisposed && _currentIndex == index) {
        _preloadNeighbors(index);
      }
    });

    // Clean up far controllers and temporary segment files
    _disposeFarControllers(index);
    _cleanTempFilesAsync();

    final newVideoId = widget.videosData[index].id ?? 0;
    _completedVideos[newVideoId] = false;

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

  void _cleanTempFilesAsync() {
    Future.microtask(() async {
      try {
        final tempDir = await getTemporaryDirectory();
        if (tempDir.existsSync()) {
          final entities = tempDir.listSync(followLinks: false);
          for (final entity in entities) {
            if (entity is File) {
              final path = entity.path.toLowerCase();
              if (path.contains('thumb') ||
                  path.endsWith('.webp') ||
                  path.endsWith('.jpg') ||
                  path.endsWith('.jpeg') ||
                  path.contains('video') ||
                  path.endsWith('.tmp')) {
                try {
                  await entity.delete();
                } catch (_) {}
              }
            }
          }
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkText,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.videosData.length,
        onPageChanged: _onPageChanged,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          final video = widget.videosData[index];
          final videoId = video.id ?? index;
          final String videoPath = video.video ?? '';
          final String videoUrl = videoPath.startsWith('http')
              ? videoPath
              : '${ApiRoutes.baseUrl}$videoPath';
          final String? videoThumbnail = video.thumbnail;
          final cachedThumbnail = VideoCacheManager.getCachedThumbnail(
            videoUrl,
          );

          if (!_bookmarkMap.containsKey(videoId)) {
            _bookmarkMap[videoId] = ValueNotifier(video.savedAlready ?? false);
          }
          final bookmarkNotifier = _bookmarkMap[videoId]!;

          _readyMap[index] ??= ValueNotifier(false);
          final readyNotifier = _readyMap[index]!;

          _firstFrameRenderedMap[index] ??= ValueNotifier(false);
          final firstFrameNotifier = _firstFrameRenderedMap[index]!;

          return ValueListenableBuilder<bool>(
            valueListenable: readyNotifier,
            builder: (context, isReady, _) {
              final controller = _controllers[index];
              final bool isControllerValid = controller != null;

              final bool initiallyReady =
                  isControllerValid &&
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
                  // Video surface (renders below the thumbnail)
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
                        ? Center(
                            child: AspectRatio(
                              aspectRatio: videoWidth / videoHeight,
                              child: BetterPlayer(controller: controller!),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Thumbnail and loading overlay (renders on top of video surface)
                  ValueListenableBuilder<bool>(
                    valueListenable: firstFrameNotifier,
                    builder: (context, firstFrameRendered, _) {
                      final showThumbnail =
                          !effectivelyReady || !firstFrameRendered;
                      return IgnorePointer(
                        ignoring: !showThumbnail,
                        child: AnimatedOpacity(
                          opacity: showThumbnail ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            color: AppColors.darkText,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (videoThumbnail != null &&
                                    videoThumbnail.isNotEmpty)
                                  CachedNetworkImage(
                                    imageUrl: videoThumbnail.startsWith('http')
                                        ? videoThumbnail
                                        : '${ApiRoutes.baseUrl}$videoThumbnail',
                                    fit: BoxFit.contain,
                                    placeholder: (_, __) =>
                                        cachedThumbnail != null
                                        ? Image.memory(
                                            cachedThumbnail,
                                            fit: BoxFit.contain,
                                          )
                                        : const SizedBox.shrink(),
                                    errorWidget: (_, __, ___) =>
                                        cachedThumbnail != null
                                        ? Image.memory(
                                            cachedThumbnail,
                                            fit: BoxFit.contain,
                                          )
                                        : const SizedBox.shrink(),
                                  )
                                else if (cachedThumbnail != null)
                                  Image.memory(
                                    cachedThumbnail,
                                    fit: BoxFit.contain,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
                                      AppColors.primaryBorder.withValues(
                                        alpha: .8,
                                      ),
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
                                minHeight: 3,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.darkGrey,
                                ),
                              );
                            },
                          ),
                          ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                              child: Container(
                                padding: const EdgeInsets.all(15),
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
                                                  child: BodyTextColors(
                                                    title:
                                                        video.shopName
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
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              if (_watchedMap[videoId] ==
                                                      true &&
                                                  !widget.isMyVideos)
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
                                                video.description
                                                    ?.capitalize() ??
                                                '',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    if (!widget.isMyVideos) ...[
                                      Row(
                                        children: [
                                          CircleContainer(
                                            onTap: () async {
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
                                            child: Icon(
                                              Icons.info,
                                              color: AppColors.primary,
                                              size: 25,
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
                                                          final newVal =
                                                              !isActive;
                                                          bookmarkNotifier
                                                                  .value =
                                                              newVal;
                                                          await videoController
                                                              .addSavedVideos(
                                                                videoId:
                                                                    video.id ??
                                                                    0,
                                                                status: newVal
                                                                    ? 'active'
                                                                    : 'inactive',
                                                              );
                                                          await profileController
                                                              .saveShop(
                                                                shopId:
                                                                    video
                                                                        .shopId ??
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
                                                        height: 25,
                                                      )
                                                    : const Icon(
                                                        Icons.bookmark_border,
                                                        size: 25,
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
            },
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
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: AppColors.whiteText.withValues(alpha: 0.2),
              border: Border.all(
                color: AppColors.whiteText.withValues(alpha: .2),
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Colors.black, size: 20),
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
  const CircleContainer({
    super.key,
    required this.child,
    required this.onTap,
    this.height = 40,
  });

  final Widget child;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        width: height,
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
