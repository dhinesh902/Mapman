import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_thumbnail_video/src/image_format.dart';
import 'package:get_thumbnail_video/src/video_thumbnail_method_channel.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelVideoThumbnail platform = MethodChannelVideoThumbnail();
  const MethodChannel channel = MethodChannel('video_thumbnail');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      final m = methodCall.method;
      final a = Map<String, dynamic>.from(methodCall.arguments as Map);

      return '$m=${a["video"]}:${a["path"]}:${a["format"]}:${a["maxh"]}:${a["quality"]}';
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('thumbnailData', () async {
    final XFile result = await VideoThumbnail.thumbnailFile(
      video: 'video',
      thumbnailPath: 'path',
      imageFormat: ImageFormat.JPEG,
      maxWidth: 123,
      maxHeight: 123,
      quality: 45,
    );

    expect(result.path, 'file=video:path:0:123:45');
  });
}
