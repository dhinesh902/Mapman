import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class VideoCacheManager {
  /// Clears the temporary video cache of the app.
  /// Standard video_player buffers network streams into this directory,
  /// so clearing it frees up all of that space without storing videos locally.
  static Future<void> clearAppCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        final list = tempDir.listSync();
        for (final entity in list) {
          final name = entity.path.split(Platform.pathSeparator).last.toLowerCase();
          // Preserve CachedNetworkImage / flutter_cache_manager image cache folders
          if (!name.contains('libcachedimagedata') &&
              !name.contains('cache') &&
              !name.contains('image')) {
            try {
              if (entity is File) {
                await entity.delete();
              } else if (entity is Directory) {
                await entity.delete(recursive: true);
              }
            } catch (_) {}
          }
        }
        debugPrint('App temporary video streaming cache cleared successfully.');
      }
    } catch (e) {
      debugPrint('Error clearing app video cache: $e');
    }
  }
}

