import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;

class LocationIconService {
  static final LocationIconService _instance = LocationIconService._internal();

  factory LocationIconService() => _instance;

  LocationIconService._internal();

  BitmapDescriptor? _cachedIcon;

  final String _iconUrl = 'https://cdn-icons-png.flaticon.com/128/10726/10726411.png';

  Future<BitmapDescriptor> getMarkerIcon() async {
    if (_cachedIcon != null) return _cachedIcon!;

    try {
      final response = await Dio().get<Uint8List>(
        _iconUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null) {
        _cachedIcon = await _resizeMarker(response.data!, 75, 75);
        return _cachedIcon!;
      } else {
        throw Exception("Failed to load icon: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error loading common marker icon: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }

  Future<BitmapDescriptor> _resizeMarker(Uint8List data, int width,
      int height) async {
    final image = img.decodeImage(data);
    if (image == null) return BitmapDescriptor.defaultMarker;

    final resized = img.copyResize(image, width: width, height: height);
    final resizedData = Uint8List.fromList(img.encodePng(resized));
    return BitmapDescriptor.fromBytes(resizedData);
  }
}
