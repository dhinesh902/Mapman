import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoCacheManager {
  static const int _maxThumbnailEntries = 100;
  static final Map<String, String> _thumbnailPathCache = <String, String>{};
  static SharedPreferences? _prefs;

  // ── Initialization of SharedPreferences ───────────────────────────────
  static Future<void> init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.startsWith('thumb_path_')) {
          final videoUrl = key.replaceFirst('thumb_path_', '');
          final path = _prefs!.getString(key);
          if (path != null && File(path).existsSync()) {
            _thumbnailPathCache[videoUrl] = path;
          } else {
            _prefs!.remove(key); // Clean up invalid/stale entries
          }
        }
      }
      debugPrint('🎬 Persistent video thumbnails loaded: ${_thumbnailPathCache.length}');
    } catch (e) {
      debugPrint('VideoCacheManager.init error: $e');
    }
  }

  // ── Thumbnail in-memory & persistent cache getters ───────────────────────
  static String? getCachedThumbnail(String videoUrl) {
    // 1. Check in-memory cache first (extremely fast)
    var path = _thumbnailPathCache[videoUrl];
    if (path != null) {
      if (File(path).existsSync()) {
        // Move to end to mark as recently used (LRU)
        _thumbnailPathCache.remove(videoUrl);
        _thumbnailPathCache[videoUrl] = path;
        return path;
      } else {
        _thumbnailPathCache.remove(videoUrl);
        if (_prefs != null) {
          _prefs!.remove('thumb_path_$videoUrl');
        }
      }
    }

    // 2. Check SharedPreferences if in-memory cache missed (safety fallback)
    if (_prefs != null) {
      path = _prefs!.getString('thumb_path_$videoUrl');
      if (path != null) {
        if (File(path).existsSync()) {
          _thumbnailPathCache[videoUrl] = path;
          return path;
        } else {
          _prefs!.remove('thumb_path_$videoUrl');
        }
      }
    }
    return null;
  }

  static Future<void> cacheThumbnail(String videoUrl, String path) async {
    // Evict oldest entry in memory when at capacity (LRU)
    if (_thumbnailPathCache.length >= _maxThumbnailEntries) {
      final oldestKey = _thumbnailPathCache.keys.first;
      _thumbnailPathCache.remove(oldestKey);
    }
    _thumbnailPathCache[videoUrl] = path;

    // Persist to disk metadata via SharedPreferences asynchronously
    try {
      _prefs ??= await SharedPreferences.getInstance();
      if (_prefs != null) {
        await _prefs!.setString('thumb_path_$videoUrl', path);
      }
    } catch (e) {
      debugPrint('cacheThumbnail write error: $e');
    }
  }

  /// Removes a single entry from the cache
  static void evictThumbnail(String videoUrl) {
    _thumbnailPathCache.remove(videoUrl);
    if (_prefs != null) {
      _prefs!.remove('thumb_path_$videoUrl');
    }
  }

  // ── Stale-thumbnail disk cleanup ───────────────────────────────────────
  /// Deletes .webp thumbnail files in the system temp directory that are
  /// older than [maxAgeHours] hours.
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

  // ── Legacy API ──────────────────────────────────────────────────────────
  static Future<void> clearAppCache() async {
    await cleanStaleThumbnails(maxAgeHours: 0); // wipe all webp thumbnails
  }
}
