import 'dart:io';
import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:video_player/video_player.dart';

class AppVideoController {
  final int index;
  final String videoUrl;

  BetterPlayerController? betterPlayerController;
  VideoPlayerController? videoPlayerController;

  bool get isIOS => Platform.isIOS;

  AppVideoController({required this.index, required this.videoUrl});

  Future<void> initialize({required VoidCallback onInitialized}) async {
    if (isIOS) {
      try {
        videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
        );
        await videoPlayerController!.initialize();
        videoPlayerController!.setLooping(true);
        onInitialized();
      } catch (e) {
        debugPrint('iOS Video init error: $e');
      }
    } else {
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
          minBufferMs: 500,
          maxBufferMs: 30000,
          bufferForPlaybackMs: 100,
          bufferForPlaybackAfterRebufferMs: 500,
        ),
      );

      betterPlayerController = BetterPlayerController(
        const BetterPlayerConfiguration(
          autoPlay: false,
          looping: true,
          fit: BoxFit.contain,
          expandToFill: false,
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

      betterPlayerController!.addEventsListener((event) {
        if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
          onInitialized();
        }
      });
    }
  }

  bool get isInitialized {
    if (isIOS) {
      return videoPlayerController?.value.isInitialized ?? false;
    } else {
      return betterPlayerController?.videoPlayerController?.value.initialized ??
          false;
    }
  }

  bool get isPlaying {
    if (isIOS) {
      return videoPlayerController?.value.isPlaying ?? false;
    } else {
      return betterPlayerController?.videoPlayerController?.value.isPlaying ??
          false;
    }
  }

  Duration get position {
    if (isIOS) {
      return videoPlayerController?.value.position ?? Duration.zero;
    } else {
      return betterPlayerController?.videoPlayerController?.value.position ??
          Duration.zero;
    }
  }

  Duration? get duration {
    if (isIOS) {
      return videoPlayerController?.value.duration;
    } else {
      return betterPlayerController?.videoPlayerController?.value.duration;
    }
  }

  Size get size {
    if (isIOS) {
      return videoPlayerController?.value.size ?? const Size(1080, 1920);
    } else {
      return betterPlayerController?.videoPlayerController?.value.size ??
          const Size(1080, 1920);
    }
  }

  void addListener(VoidCallback listener) {
    if (isIOS) {
      videoPlayerController?.addListener(listener);
    } else {
      betterPlayerController?.videoPlayerController?.addListener(listener);
    }
  }

  void removeListener(VoidCallback listener) {
    if (isIOS) {
      videoPlayerController?.removeListener(listener);
    } else {
      betterPlayerController?.videoPlayerController?.removeListener(listener);
    }
  }

  void play() {
    if (isIOS) {
      videoPlayerController?.play();
    } else {
      betterPlayerController?.play();
    }
  }

  void pause() {
    if (isIOS) {
      videoPlayerController?.pause();
    } else {
      betterPlayerController?.pause();
    }
  }

  void seekTo(Duration position) {
    if (isIOS) {
      videoPlayerController?.seekTo(position);
    } else {
      betterPlayerController?.seekTo(position);
    }
  }

  void setVolume(double volume) {
    if (isIOS) {
      videoPlayerController?.setVolume(volume);
    } else {
      betterPlayerController?.setVolume(volume);
    }
  }

  void dispose() {
    if (isIOS) {
      videoPlayerController?.dispose();
    } else {
      betterPlayerController?.dispose(forceDispose: true);
    }
  }
}
