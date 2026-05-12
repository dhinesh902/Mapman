import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class VideoCacheManager {
  /// Clears the temporary/cache directory of the app.
  /// Standard video_player buffers network streams into this directory,
  /// so clearing it frees up all of that space.
  static Future<void> clearAppCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        // We use delete instead of deleteSync to keep the operation asynchronous and non-blocking
        await tempDir.delete(recursive: true);
        debugPrint('App temporary cache cleared successfully.');
      }
    } catch (e) {
      debugPrint('Error clearing app cache: $e');
    }
  }
}
