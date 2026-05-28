import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoCacheManager {
  static const int _maxThumbnailEntries = 100;
  static final Map<String, Uint8List> _thumbnailCache = <String, Uint8List>{};
  static SharedPreferences? _prefs;

  // ── Initialization of SharedPreferences & Legacy Cleanup ────────────────
  static Future<void> init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final keys = _prefs!.getKeys();
      // Remove all legacy thumb_path keys from SharedPreferences to clear metadata
      for (final key in keys) {
        if (key.startsWith('thumb_path_')) {
          _prefs!.remove(key);
        }
      }
      // Delete any leftover physical webp files in system temporary directory
      await cleanStaleThumbnails(maxAgeHours: 0);
      debugPrint('🎬 In-memory video thumbnail cache initialized. Legacy disk files/metadata purged.');
    } catch (e) {
      debugPrint('VideoCacheManager.init error: $e');
    }
  }

  // ── Thumbnail in-memory cache getters & setters ────────────────────────
  static Uint8List? getCachedThumbnail(String videoUrl) {
    // 1. Check in-memory cache (extremely fast)
    final data = _thumbnailCache[videoUrl];
    if (data != null) {
      // Move to end to mark as recently used (LRU)
      _thumbnailCache.remove(videoUrl);
      _thumbnailCache[videoUrl] = data;
      return data;
    }
    return null;
  }

  static void cacheThumbnail(String videoUrl, Uint8List data) {
    // Evict oldest entry in memory when at capacity (LRU)
    if (_thumbnailCache.length >= _maxThumbnailEntries) {
      final oldestKey = _thumbnailCache.keys.first;
      _thumbnailCache.remove(oldestKey);
    }
    _thumbnailCache[videoUrl] = data;
  }

  /// Removes a single entry from the cache
  static void evictThumbnail(String videoUrl) {
    _thumbnailCache.remove(videoUrl);
  }

  // ── Stale-thumbnail disk cleanup ───────────────────────────────────────
  /// Deletes .webp thumbnail files in the system temp directory.
  static Future<void> cleanStaleThumbnails({int maxAgeHours = 0}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (!tempDir.existsSync()) return;

      final now = DateTime.now();
      final cutoff = now.subtract(Duration(hours: maxAgeHours));

      for (final entity in tempDir.listSync(followLinks: false)) {
        if (entity is! File) continue;
        final name = entity.path.split(Platform.pathSeparator).last.toLowerCase();
        // Touch .webp thumbnail files
        if (!name.endsWith('.webp')) continue;
        try {
          final stat = entity.statSync();
          if (maxAgeHours == 0 || stat.modified.isBefore(cutoff)) {
            entity.deleteSync();
          }
        } catch (_) {}
      }
      debugPrint('🧹 Stale thumbnail files cleaned up');
    } catch (e) {
      debugPrint('cleanStaleThumbnails error: $e');
    }
  }

  // ── Legacy API ──────────────────────────────────────────────────────────
  static Future<void> clearAppCache() async {
    _thumbnailCache.clear();
    await cleanStaleThumbnails(maxAgeHours: 0); // wipe all webp thumbnails
  }
}
