import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:mapman/utils/constants/images.dart';

// class LocationIconService {
//   static final LocationIconService _instance = LocationIconService._internal();
//
//   factory LocationIconService() => _instance;
//
//   LocationIconService._internal();
//
//   BitmapDescriptor? _cachedIcon;
//
//   final String _iconUrl = 'https://cdn-icons-png.flaticon.com/128/10726/10726411.png';
//
//   Future<BitmapDescriptor> getMarkerIcon() async {
//     if (_cachedIcon != null) return _cachedIcon!;
//
//     try {
//       final response = await Dio().get<Uint8List>(
//         _iconUrl,
//         options: Options(responseType: ResponseType.bytes),
//       );
//
//       if (response.statusCode == 200 && response.data != null) {
//         _cachedIcon = await _resizeMarker(response.data!, 75, 75);
//         return _cachedIcon!;
//       } else {
//         throw Exception("Failed to load icon: ${response.statusCode}");
//       }
//     } catch (e) {
//       debugPrint("Error loading common marker icon: $e");
//       return BitmapDescriptor.defaultMarker;
//     }
//   }
//
//   Future<BitmapDescriptor> _resizeMarker(Uint8List data, int width,
//       int height) async {
//     final image = img.decodeImage(data);
//     if (image == null) return BitmapDescriptor.defaultMarker;
//
//     final resized = img.copyResize(image, width: width, height: height);
//     final resizedData = Uint8List.fromList(img.encodePng(resized));
//     return BitmapDescriptor.fromBytes(resizedData);
//   }
// }
class LocationIconService {
  static final LocationIconService _instance = LocationIconService._internal();

  factory LocationIconService() => _instance;

  LocationIconService._internal();

  // Future<BitmapDescriptor> getMarkerIcon() async {
  //   if (_cachedIcon != null) return _cachedIcon!;
  //
  //   try {
  //     final response = await Dio().get<Uint8List>(
  //       _iconUrl,
  //       options: Options(responseType: ResponseType.bytes),
  //     );
  //
  //     if (response.statusCode == 200 && response.data != null) {
  //       _cachedIcon = await _resizeMarker(response.data!, 75, 75);
  //       return _cachedIcon!;
  //     } else {
  //       throw Exception("Failed to load icon: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     debugPrint("Error loading common marker icon: $e");
  //     return BitmapDescriptor.defaultMarker;
  //   }
  // }

  final Map<String, BitmapDescriptor> _iconCache = {};

  final Map<String, String> _iconMap = {
    'theater': AppIcons.theatersMap,
    'restaurant': AppIcons.resortsMap,
    'hospital': AppIcons.hospitalsMap,
    'bars': AppIcons.barsMap,
    'grocery': AppIcons.groceryMap,
    'textile': AppIcons.textilesMap,
    'resort': AppIcons.resortsMap,
    'bunk': AppIcons.petrolBunkMap,
    'spa': AppIcons.spaMap,
    'hotels': AppIcons.hotelsMap,
    'others': AppIcons.othersMap,
  };

  Future<BitmapDescriptor> getMarkerIcon({required String category}) async {
    final key = category.toLowerCase().trim();

    if (_iconCache.containsKey(key)) {
      return _iconCache[key]!;
    }

    try {
      final assetPath = _iconMap[key];

      if (assetPath == null) {
        return BitmapDescriptor.defaultMarker;
      }

      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List resizedBytes = _resizeImage(
        data.buffer.asUint8List(),
        75,
        85,
      );

      final icon = BitmapDescriptor.fromBytes(resizedBytes);
      _iconCache[key] = icon;

      return icon;
    } catch (e) {
      final ByteData data = await rootBundle.load(AppIcons.othersMap);

      final Uint8List resizedBytes = _resizeImage(
        data.buffer.asUint8List(),
        60,
        75,
      );

      final BitmapDescriptor icon = BitmapDescriptor.fromBytes(resizedBytes);

      _iconCache[key] = icon;

      return icon;
    }
  }

  /// Resize image bytes
  Uint8List _resizeImage(Uint8List data, int width, int height) {
    final image = img.decodeImage(data);
    if (image == null) return data;

    final resized = img.copyResize(image, width: width, height: height);
    return Uint8List.fromList(img.encodePng(resized));
  }
}
