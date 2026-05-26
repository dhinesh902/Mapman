import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class VideoCacheManager {
  // ── Thumbnail in-memory LRU cache ──────────────────────────────────────
  // Capped at [_maxThumbnailEntries] to prevent unbounded memory growth when
  // a user has hundreds of videos. When the cap is reached the oldest entry
  // is evicted (LinkedHashMap insertion-order trick).
  static const int _maxThumbnailEntries = 100;
  static final Map<String, String> _thumbnailPathCache =
      <String, String>{};

  static String? getCachedThumbnail(String videoUrl) {
    final path = _thumbnailPathCache[videoUrl];
    if (path != null) {
      // Re-insert to mark as recently used (LRU)
      _thumbnailPathCache.remove(videoUrl);
      _thumbnailPathCache[videoUrl] = path;
    }
    return path;
  }

  static void cacheThumbnail(String videoUrl, String path) {
    // Evict oldest entry when at capacity
    if (_thumbnailPathCache.length >= _maxThumbnailEntries) {
      final oldestKey = _thumbnailPathCache.keys.first;
      _thumbnailPathCache.remove(oldestKey);
    }
    _thumbnailPathCache[videoUrl] = path;
  }

  /// Removes a single entry from the in-memory cache (e.g. after a video is
  /// deleted by the user).
  static void evictThumbnail(String videoUrl) {
    _thumbnailPathCache.remove(videoUrl);
  }

  // ── Stale-thumbnail disk cleanup ───────────────────────────────────────
  /// Deletes .webp thumbnail files in the system temp directory that are
  /// older than [maxAgeHours] hours.  Safe to call periodically (e.g. on
  /// app resume or after navigating away from the video feed).
  /// Does NOT touch HLS/ExoPlayer segment caches.
  static Future<void> cleanStaleThumbnails({int maxAgeHours = 24}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (!tempDir.existsSync()) return;

      final now = DateTime.now();
      final cutoff = now.subtract(Duration(hours: maxAgeHours));

      for (final entity in tempDir.listSync(followLinks: false)) {
        if (entity is! File) continue;
        final name = entity.path.split(Platform.pathSeparator).last.toLowerCase();
        // Only touch .webp thumbnail files we generated
        if (!name.endsWith('.webp')) continue;
        try {
          final stat = entity.statSync();
          if (stat.modified.isBefore(cutoff)) {
            entity.deleteSync();
          }
        } catch (_) {}
      }
      debugPrint('🧹 Stale thumbnails cleaned (older than ${maxAgeHours}h)');
    } catch (e) {
      debugPrint('cleanStaleThumbnails error: $e');
    }
  }

  // ── Legacy API (kept for compatibility, no longer wipes everything) ─────
  /// Prefer [cleanStaleThumbnails] instead.  This method now only removes
  /// stale .webp thumbnails to avoid wiping ExoPlayer streaming cache.
  static Future<void> clearAppCache() async {
    await cleanStaleThumbnails(maxAgeHours: 0); // wipe all webp thumbnails
  }
}
