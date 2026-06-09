import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LoopedMediaPreview extends StatefulWidget {
  final String mediaUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const LoopedMediaPreview({
    super.key,
    required this.mediaUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<LoopedMediaPreview> createState() => _LoopedMediaPreviewState();
}

class _LoopedMediaPreviewState extends State<LoopedMediaPreview> {
  CachedVideoPlayerPlus? _cachedPlayer;
  bool _isVideo = false;
  bool _isInitialized = false;
  bool _isVisible = false;

  static const _categoryCacheKey = 'category_media_cache';
  static final CacheManager _gifCacheManager = CacheManager(
    Config(
      _categoryCacheKey,
      stalePeriod: const Duration(days: 3),
      maxNrOfCacheObjects: 100,
      repo: JsonCacheInfoRepository(databaseName: _categoryCacheKey),
    ),
  );

  @override
  void initState() {
    super.initState();
    _checkMediaType();
  }

  @override
  void didUpdateWidget(covariant LoopedMediaPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaUrl != widget.mediaUrl) {
      _disposeVideo();
      _checkMediaType();
    }
  }

  void _checkMediaType() {
    final path = widget.mediaUrl.toLowerCase();
    _isVideo = path.contains('.mp4') ||
        path.contains('.mov') ||
        path.contains('.m3u8') ||
        path.contains('/video/');

    if (_isVideo) {
      _initVideo();
    } else {
      _isInitialized = true;
    }
  }

  Future<void> _initVideo() async {
    if (widget.mediaUrl.isEmpty) return;

    final player = CachedVideoPlayerPlus.networkUrl(
      Uri.parse(widget.mediaUrl),
      invalidateCacheIfOlderThan: const Duration(days: 3),
    );

    _cachedPlayer = player;

    try {
      await player.initialize();
      if (!mounted) {
        _disposeVideo();
        return;
      }
      final controller = player.controller;
      await controller.setLooping(true);
      await controller.setVolume(0.0);
      setState(() {
        _isInitialized = true;
      });

      if (_isVisible) {
        controller.play();
      }
    } catch (e) {
      debugPrint('Error initializing video preview: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _isVideo = false; // fallback to static image on error
        });
      }
    }
  }

  void _disposeVideo() {
    final player = _cachedPlayer;
    _cachedPlayer = null;
    _isInitialized = false;
    if (player != null) {
      try {
        if (player.isInitialized) {
          player.controller.pause();
        }
        player.dispose();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaUrl.isEmpty) {
      return widget.errorWidget ?? const Center(child: Icon(Icons.error));
    }

    final key = ValueKey(widget.mediaUrl);

    Widget child;
    if (_isVideo) {
      final player = _cachedPlayer;
      if (_isInitialized && player != null && player.isInitialized) {
        final controller = player.controller;
        child = FittedBox(
          fit: widget.fit,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        );
      } else {
        child = widget.placeholder ?? const Center(child: CircularProgressIndicator(strokeWidth: 2));
      }
    } else {
      // GIF/Image mode: Downsample to actual render width using memCacheWidth/Height
      child = CachedNetworkImage(
        imageUrl: widget.mediaUrl,
        cacheManager: _gifCacheManager,
        fit: widget.fit,
        memCacheWidth: 350, // Resizes large GIFs to 350px width during decode, saving massive RAM!
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, __) => widget.placeholder ?? const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (_, __, ___) => widget.errorWidget ?? const Center(child: Icon(Icons.error)),
      );
    }

    return VisibilityDetector(
      key: key,
      onVisibilityChanged: (visibilityInfo) {
        if (!mounted || !_isVideo) return;
        final visible = visibilityInfo.visibleFraction > 0.1;
        if (visible != _isVisible) {
          _isVisible = visible;
          final player = _cachedPlayer;
          if (player != null && player.isInitialized) {
            if (_isVisible) {
              player.controller.play();
            } else {
              player.controller.pause();
            }
          }
        }
      },
      child: child,
    );
  }
}
