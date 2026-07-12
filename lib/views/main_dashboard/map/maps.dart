import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapman/controller/home_controller.dart';
import 'package:mapman/model/shop_search_data.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/service/location_icon_service.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/strings.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/utils/handlers/api_response.dart';
import 'package:mapman/utils/storage/session_manager.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:mapman/views/widgets/login_bottom_sheet.dart';
import 'package:provider/provider.dart';

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  late HomeController homeController;

  final ValueNotifier<ShopSearchData?> tapNotifier = ValueNotifier(null);
  final Map<String, BitmapDescriptor> _customMarkers = {};
  final Map<String, BitmapDescriptor> _circularMarkers = {};
  bool _markersLoaded = false;
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  GoogleMapController? _mapController;
  late DraggableScrollableController sheetController;

  double _currentZoom = 12.5;
  bool isClicking = false;
  String? _mapStyle;

  ApiResponse<List<ShopSearchData>>? _lastShopSearchData;

  /// Current Location notifier

  StreamSubscription<Position>? _positionStream;
  LatLng? currentLatLng;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(10.9974, 76.9589),
    zoom: 12.5,
    tilt: 0,
    bearing: 0,
  );

  @override
  void initState() {
    super.initState();

    sheetController = DraggableScrollableController();
    homeController = context.read<HomeController>();

    /// Map data show only streets
    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyle = string;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      homeController.setNearByShopHeight = 0.18;

      /// Start location listening after the map widget is built
      /// so _mapController is available when _animateToCurrentLocation is called.
      startLocationListening();

      await Future.wait([
        LocationIconService().preloadAllIcons(),
        getSearchShops(),
      ]);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchFocusNode.dispose();
    _positionStream?.cancel();
    _mapController?.dispose();
    sheetController.dispose();
    tapNotifier.dispose();
    super.dispose();
  }

  /// Current Location notifier
  Future<void> startLocationListening() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return;
    }

    final Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
    if (lastKnownPosition != null) {
      currentLatLng = LatLng(
        lastKnownPosition.latitude,
        lastKnownPosition.longitude,
      );
      if (mounted) setState(() {});
      _animateToCurrentLocation();
    }

    try {
      final Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      currentLatLng = LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      );
      if (mounted) setState(() {});
      _animateToCurrentLocation();
    } catch (e) {
      debugPrint('Error getting current location: $e');
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (position) {
            currentLatLng = LatLng(position.latitude, position.longitude);
            if (mounted) setState(() {});
          },
        );
  }

  void _animateToCurrentLocation() {
    if (_mapController != null && currentLatLng != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLatLng!, zoom: 12.5),
        ),
      );
    }
  }

  /// Distance calculation
  double distanceBetweenLatLong({
    required double latitude,
    required double longitude,
  }) {
    if (currentLatLng == null) return 0.0;

    final meters = Geolocator.distanceBetween(
      currentLatLng!.latitude,
      currentLatLng!.longitude,
      latitude,
      longitude,
    );

    final km = meters / 1000;
    return double.parse(km.toStringAsFixed(1));
  }

  void onMapCreated(GoogleMapController controller) async {
    _mapController = controller;

    _mapStyle ??= await rootBundle.loadString('assets/map_style.json');

    controller.setMapStyle(_mapStyle);

    if (currentLatLng != null) {
      _animateToCurrentLocation();
    }
  }

  Future<void> getSearchShops() async {
    _customMarkers.clear();
    _circularMarkers.clear();
    _markersLoaded = false;
    final inputCategory =
        homeController.searchCategory?.toLowerCase() == 'others'
        ? 'all'
        : (homeController.searchCategory ?? 'all');
    final response = await homeController.getSearchShops(input: inputCategory);

    if (!mounted) return;

    if (response.status == Status.ERROR) {
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
      return;
    }

    await homeController.filterNearbyShops();

    if (currentLatLng == null && homeController.currentPosition != null) {
      if (mounted) {
        setState(() {
          currentLatLng = LatLng(
            homeController.currentPosition!.latitude,
            homeController.currentPosition!.longitude,
          );
        });
      }
    }

    if (sheetController.isAttached) {
      sheetController.animateTo(
        0.18,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    await _generateMarkers();
  }

  Future<void> _generateMarkers() async {
    final response = homeController.shopSearchData;
    if (response.status != Status.COMPLETED || response.data == null) return;

    _markersLoaded = true;

    final uniqueCategories = response.data!
        .map((s) => s.category?.toLowerCase().trim() ?? 'others')
        .toSet();
    uniqueCategories.add('others');
    for (var cat in uniqueCategories) {
      if (!_circularMarkers.containsKey(cat)) {
        _circularMarkers[cat] = await createCircularMarker(category: cat);
      }
    }

    if (mounted) setState(() {});

    int count = 0;

    for (var shop in response.data!) {
      final id = shop.id?.toString();

      final String category = shop.category?.toLowerCase().trim() ?? 'others';

      if (id != null && !_customMarkers.containsKey(id)) {
        final icon = await createMarkerWithLabel(
          text: shop.shopName?.capitalize() ?? '',
          category: category,
        );
        _customMarkers[id] = icon;
      }

      count++;
      // Batch processing: yield to UI thread every 15 markers to show them faster
      if (count % 15 == 0) {
        if (mounted) setState(() {});
        await Future.delayed(Duration.zero);
      }
    }
    if (mounted) setState(() {});
  }

  Future<BitmapDescriptor> createMarkerWithLabel({
    required String text,
    required String category,
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final String displayText = text.length > 20
        ? '${text.substring(0, 20)}...'
        : text;

    final Color categoryColor =
        _categoryColors[category] ?? _categoryColors['others']!;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(text: "${displayText.capitalize()}\n"),
          TextSpan(
            text: category.capitalize(),
            style: AppTextStyle(
              fontSize: 22,
              color: categoryColor,
              fontWeight: FontWeight.w600,
            ).textStyle,
          ),
        ],
        style: AppTextStyle(
          fontSize: 28,
          color: const Color(0xFF1A1A1A),
          fontWeight: FontWeight.w700,
        ).textStyle,
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Dimensions
    final double innerPaddingX = 14.0;
    final double innerPaddingY = 10.0;
    final double innerWidth = textPainter.width + (innerPaddingX * 2);
    final double innerHeight = textPainter.height + (innerPaddingY * 2);

    final double outerGap = 6.0;
    final double outerWidth = innerWidth + (outerGap * 2);
    final double outerHeight = innerHeight + (outerGap * 2);

    final double pointerWidth = 18.0;
    final double pointerHeight = 12.0;

    final double circleRadius = 14.0;
    final double circleGap = 8.0; // gap between pointer tip and circle

    // Padding for shadows
    final double shadowPadding = 20.0;

    final double totalWidth = outerWidth + (shadowPadding * 2);
    final double totalHeight =
        outerHeight +
        pointerHeight +
        circleGap +
        (circleRadius * 2) +
        (shadowPadding * 2);

    // Shift canvas to allow shadow drawing at left/top
    canvas.translate(shadowPadding, shadowPadding);

    /// OUTER BUBBLE PATH
    final double radiusVal = 8.0;
    final Radius radius = Radius.circular(radiusVal);

    final path = Path();
    path.moveTo(radiusVal, 0);
    // Top Edge
    path.lineTo(outerWidth - radiusVal, 0);
    // Top Right Curve
    path.arcToPoint(Offset(outerWidth, radiusVal), radius: radius);
    // Right Edge
    path.lineTo(outerWidth, outerHeight - radiusVal);
    // Bottom Right Curve
    path.arcToPoint(
      Offset(outerWidth - radiusVal, outerHeight),
      radius: radius,
    );

    // Pointer
    path.lineTo(outerWidth / 2 + (pointerWidth / 2), outerHeight);
    path.lineTo(outerWidth / 2, outerHeight + pointerHeight);
    path.lineTo(outerWidth / 2 - (pointerWidth / 2), outerHeight);

    // Bottom Edge
    path.lineTo(radiusVal, outerHeight);
    // Bottom Left Curve
    path.arcToPoint(Offset(0, outerHeight - radiusVal), radius: radius);
    // Left Edge
    path.lineTo(0, radiusVal);
    // Top Left Curve
    path.arcToPoint(Offset(radiusVal, 0), radius: radius);

    path.close();

    /// OUTER SHADOW
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.25), 8.0, false);

    /// OUTER WHITE FILL
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    /// INNER RECTANGLE PATH
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(outerGap, outerGap, innerWidth, innerHeight),
      const Radius.circular(6),
    );

    /// INNER RECTANGLE FILL (Lightened Category Color)
    final innerFillPaint = Paint()
      ..color = Color.lerp(categoryColor, Colors.white, 0.9)!
      ..style = PaintingStyle.fill;
    canvas.drawRRect(innerRect, innerFillPaint);

    /// INNER RECTANGLE BORDER
    final innerBorderPaint = Paint()
      ..color = categoryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawRRect(innerRect, innerBorderPaint);

    /// TEXT
    textPainter.paint(
      canvas,
      Offset(outerGap + innerPaddingX, outerGap + innerPaddingY),
    );

    /// SEPARATE CIRCLE
    final double circleCenterY =
        outerHeight + pointerHeight + circleGap + circleRadius;
    final double circleCenterX = outerWidth / 2;

    // Circle shadow
    final circlePath = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(circleCenterX, circleCenterY),
          radius: circleRadius,
        ),
      );
    canvas.drawShadow(
      circlePath,
      Colors.black.withValues(alpha: 0.35),
      6.0,
      false,
    );

    // Circle Fill
    final circlePaint = Paint()
      ..color = categoryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(circleCenterX, circleCenterY),
      circleRadius,
      circlePaint,
    );

    // Circle Border
    final circleBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(
      Offset(circleCenterX, circleCenterY),
      circleRadius,
      circleBorderPaint,
    );

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(totalWidth.toInt(), totalHeight.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  /// ONLY SMALL ROUND MARKER
  Future<BitmapDescriptor> createCircularMarker({
    required String category,
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    canvas.translate(2, 2);

    /// REDUCED SIZE
    final double circleRadius = 12.0;

    final double totalSize = (circleRadius * 2) + 4;

    /// Fill
    final circlePaint = Paint()
      ..color = _categoryColors[category] ?? _categoryColors['others']!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(circleRadius, circleRadius),
      circleRadius,
      circlePaint,
    );

    /// White Border
    final circleBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      Offset(circleRadius, circleRadius),
      circleRadius,
      circleBorderPaint,
    );

    final picture = pictureRecorder.endRecording();

    final img = await picture.toImage(totalSize.toInt(), totalSize.toInt());

    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  final List<String> _iconMap = [
    'theater',
    'restaurant',
    'hospital',
    'bar',
    'grocery',
    'textile',
    'resort',
    'bunk',
    'spa',
    'hotel',
    'jewellery',
    'furniture',
    'salons',
    'others',
  ];

  final Map<String, Color> _categoryColors = {
    'theater': Color(0xFFFF7043), // Purple
    'restaurant': Color(0xFF1E88E5), // Orange
    'hospital': Color(0xFFD32F2F), // Red
    'bar': Color(0xFF6D4C41), // Brown
    'grocery': Color(0xFF43A047), // Green
    'textile': Color(0xFFEC407A), // Pink
    'resort': Color(0xFF004D40), // Teal
    'bunk': Color(0xFFFFA000), // Amber
    'spa': Color(0xFFAD1457), // Rose Pink
    'hotel': Color(0xFF283593), // Deep Purple
    'jewellery': Color(0xFFFF7043), // Coral
    'furniture': Color(0xFF00ACC1), // Aqua Green
    'salons': Color(0xFF7CB342), // Lime Green
    'others': Color(0xFF7B1FA2), // Soft Brown
  };

  // Set<Marker> getMarkers() {
  //   final response = homeController.shopSearchData;
  //   if (response.status != Status.COMPLETED || response.data == null) {
  //     return {};
  //   }
  //
  //   final Set<Marker> markerSet = {};
  //
  //   for (int i = 0; i < response.data!.length; i++) {
  //     final shop = response.data![i];
  //
  //     final String rawCategory =
  //         shop.category?.toLowerCase().trim() ?? 'others';
  //     final String category = _iconMap.contains(rawCategory)
  //         ? rawCategory
  //         : 'others';
  //
  //     final icon = LocationIconService().getMarkerIconSync(category: category);
  //
  //     try {
  //       final double? lat = double.tryParse(shop.lat.toString());
  //       final double? long = double.tryParse(shop.long.toString());
  //
  //       if (lat != null && long != null) {
  //         markerSet.add(
  //           Marker(
  //             markerId: MarkerId(shop.id?.toString() ?? 'marker_$i'),
  //             position: LatLng(lat, long),
  //             icon: icon,
  //             onTap: () {
  //               tapNotifier.value = shop;
  //             },
  //           ),
  //         );
  //       }
  //     } catch (e) {
  //       debugPrint('Error parsing lat/long for shop ${shop.id}: $e');
  //     }
  //   }
  //   return markerSet;
  // }

  Set<Marker> getMarkers() {
    final response = homeController.shopSearchData;
    if (response.status != Status.COMPLETED || response.data == null) {
      return {};
    }

    if (!_markersLoaded) {
      return {};
    }

    final Set<Marker> markerSet = {};

    for (int i = 0; i < response.data!.length; i++) {
      final shop = response.data![i];

      final String rawCategory =
          shop.category?.toLowerCase().trim() ?? 'others';
      final String category = _iconMap.contains(rawCategory)
          ? rawCategory
          : 'others';

      final circularIcon =
          _circularMarkers[category] ??
          _circularMarkers['others'] ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

      try {
        final double? lat = double.tryParse(shop.lat.toString());
        final double? long = double.tryParse(shop.long.toString());

        if (lat != null && long != null) {
          markerSet.add(
            Marker(
              markerId: MarkerId(shop.id?.toString() ?? 'marker_$i'),
              position: LatLng(lat, long),
              consumeTapEvents: true,
              icon: _customMarkers[shop.id?.toString()] ?? circularIcon,

              onTap: () {
                setState(() {
                  _currentZoom = 18.5;
                });
                if (sheetController.isAttached) {
                  sheetController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
                if (!isClicking) {
                  _mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: LatLng(lat, long), zoom: 18.5),
                    ),
                  );
                }

                tapNotifier.value = shop;
              },
            ),
          );
        }
      } catch (e) {
        debugPrint('Error parsing lat/long for shop ${shop.id}: $e');
      }
    }

    return markerSet;
  }

  Set<Circle> _getLocationCircle() {
    if (currentLatLng == null) return {};

    return {
      Circle(
        circleId: const CircleId('current_location_circle'),
        center: currentLatLng!,
        radius: 100,
        fillColor: AppColors.primary.withValues(alpha: 0.15),
        strokeColor: AppColors.primary.withValues(alpha: 0.5),
        strokeWidth: 0,
      ),
    };
  }

  Future<void> _zoomIn() async {
    _currentZoom++;
    await _mapController?.animateCamera(CameraUpdate.zoomTo(_currentZoom));
  }

  Future<void> _zoomOut() async {
    _currentZoom--;
    await _mapController?.animateCamera(CameraUpdate.zoomTo(_currentZoom));
  }

  Widget _zoomButton({required String icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, const Color(0xFFF5F7FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: .8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .08),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: .10),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Container(
              height: 30,
              width: 30,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: .10),
              ),
              child: Image.network(icon, color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    homeController = context.watch<HomeController>();

    if (_lastShopSearchData != homeController.shopSearchData) {
      _lastShopSearchData = homeController.shopSearchData;
      if (homeController.shopSearchData.status == Status.COMPLETED) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _generateMarkers();
          }
        });
      }
    }

    if (homeController.currentPage != 1) {
      if (_searchFocusNode.hasFocus) {
        _searchFocusNode.unfocus();
      }
    }
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundDark,
      body: Builder(
        builder: (context) {
          switch (homeController.shopSearchData.status) {
            case Status.INITIAL:
            case Status.LOADING:
              return CustomLoadingIndicator();
            case Status.COMPLETED:
              return Stack(
                fit: StackFit.expand,
                children: [
                  GoogleMap(
                    initialCameraPosition: _kGooglePlex,
                    markers: getMarkers(),
                    circles: _getLocationCircle(),
                    markerType: GoogleMapMarkerType.marker,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    buildingsEnabled: true,
                    padding: EdgeInsets.only(
                      top:
                          (homeController.searchCategory == null ||
                              homeController.searchCategory == 'all')
                          ? 70
                          : 0,
                      bottom: 100,
                    ),
                    onMapCreated: onMapCreated,
                    onCameraMove: (CameraPosition position) {
                      if (_currentZoom != position.zoom) {
                        setState(() {
                          _currentZoom = position.zoom;
                        });
                      }
                    },
                  ),
                  Positioned(
                    right: 10,
                    top:
                        (homeController.searchCategory == null ||
                            homeController.searchCategory == 'all')
                        ? 80
                        : 10,
                    child: Column(
                      children: [
                        _zoomButton(
                          icon:
                              "https://cdn-icons-png.flaticon.com/128/13919/13919685.png",
                          onTap: _zoomIn,
                        ),
                        const SizedBox(height: 10),
                        _zoomButton(
                          icon:
                              "https://cdn-icons-png.flaticon.com/128/4674/4674428.png",
                          onTap: _zoomOut,
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            Position position =
                                await Geolocator.getCurrentPosition(
                                  desiredAccuracy: LocationAccuracy.high,
                                );

                            _mapController?.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(
                                    position.latitude,
                                    position.longitude,
                                  ),
                                  zoom: 18,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [Colors.white, const Color(0xFFF5F7FA)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: .9),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .08),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: .10,
                                  ),
                                  blurRadius: 18,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                height: 34,
                                width: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withValues(alpha: .18),
                                      AppColors.primary.withValues(alpha: .08),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.my_location_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 15,
                    left: 5,
                    right: 5,
                    child: shopAutoComplete(),
                  ),

                  ValueListenableBuilder<ShopSearchData?>(
                    valueListenable: tapNotifier,
                    builder: (_, shop, __) {
                      if (shop == null) return const SizedBox.shrink();
                      return Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          child: GestureDetector(
                            onTap: () {
                              final token = SessionManager.getToken();
                              if (token == null || token.isEmpty) {
                                LoginBottomSheet.showLoginBottomSheet(context);
                              } else {
                                context.pushNamed(
                                  AppRoutes.shopDetail,
                                  extra: shop.id,
                                );
                              }
                            },
                            child: LocationShopContainer(
                              searchData: shop,
                              distance: distanceBetweenLatLong(
                                latitude: double.parse(shop.lat.toString()),
                                longitude: double.parse(shop.long.toString()),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (homeController.isShowAddNearBy)
                    DraggableScrollableSheet(
                      controller: sheetController,
                      initialChildSize: homeController.nearByShopHeight,
                      minChildSize: 0.0,
                      maxChildSize: 0.65,
                      expand: false,
                      builder: (context, scrollController) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.scaffoldBackground,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    15,
                                    10,
                                    0,
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        AppIcons.nearByShopP,
                                        height: 24,
                                        width: 24,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: HeaderTextBlack(
                                          title:
                                              'Near By ${homeController.searchCategory.toString().capitalize()}',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      ClearCircleContainer(
                                        height: 24,
                                        onTap: () {
                                          tapNotifier.value = null;
                                          homeController.setIsShowAddNearBy =
                                              false;
                                          if (sheetController.isAttached) {
                                            sheetController.animateTo(
                                              0.0,
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeOut,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Builder(
                                  builder: (context) {
                                    switch (homeController
                                        .nearByShopData
                                        .status) {
                                      case Status.INITIAL:
                                      case Status.LOADING:
                                        return SizedBox(
                                          height: 200,
                                          child: CustomLoadingIndicator(),
                                        );
                                      case Status.COMPLETED:
                                        final nearByShops =
                                            homeController
                                                .nearByShopData
                                                .data ??
                                            [];
                                        if (nearByShops.isEmpty) {
                                          return SizedBox(
                                            height: 200,
                                            child: NoDataText(
                                              title: Strings.noDataFound,
                                            ),
                                          );
                                        }
                                        return SizedBox(
                                          height: 360,
                                          child: ListView.builder(
                                            itemCount: nearByShops.length,
                                            itemBuilder: (context, index) {
                                              final shop = nearByShops[index];
                                              return GestureDetector(
                                                onTap: () {
                                                  setState(
                                                    () => _currentZoom = 18.5,
                                                  );
                                                  _mapController?.animateCamera(
                                                    CameraUpdate.newCameraPosition(
                                                      CameraPosition(
                                                        target: LatLng(
                                                          double.parse(
                                                            shop.lat.toString(),
                                                          ),
                                                          double.parse(
                                                            shop.long
                                                                .toString(),
                                                          ),
                                                        ),
                                                        zoom: 18.5,
                                                      ),
                                                    ),
                                                  );
                                                  tapNotifier.value = shop;
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 10,
                                                    top: index == 0 ? 5 : 0,
                                                  ),
                                                  child: LocationShopContainer(
                                                    searchData: shop,
                                                    distance:
                                                        distanceBetweenLatLong(
                                                          latitude:
                                                              double.parse(
                                                                shop.lat
                                                                    .toString(),
                                                              ),
                                                          longitude:
                                                              double.parse(
                                                                shop.long
                                                                    .toString(),
                                                              ),
                                                        ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      case Status.ERROR:
                                        return SizedBox(
                                          height: 200,
                                          child: CustomErrorTextWidget(
                                            title:
                                                '${homeController.shopSearchData.message}',
                                          ),
                                        );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            case Status.ERROR:
              return CustomErrorTextWidget(
                title: '${homeController.shopSearchData.message}',
              );
          }
        },
      ),
    );
  }

  Widget shopAutoComplete() {
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        final response = controller.shopSearchData;
        if (response.status != Status.COMPLETED || response.data == null) {
          return const SizedBox.shrink();
        }
        final shops = response.data!;
        return RawAutocomplete<ShopSearchData>(
          textEditingController: searchController,
          focusNode: _searchFocusNode,
          optionsBuilder: (TextEditingValue value) {
            if (value.text.isEmpty) {
              return const Iterable<ShopSearchData>.empty();
            }
            return shops.where((shop) {
              final query = value.text.toLowerCase();

              final shopName = shop.shopName?.toLowerCase() ?? '';
              final address = shop.address?.toLowerCase() ?? '';
              final description = shop.description?.toLowerCase() ?? '';
              final category = shop.category?.toLowerCase() ?? '';

              return shopName.contains(query) ||
                  address.contains(query) ||
                  category.contains(query) ||
                  description.contains(query);
            });
          },

          fieldViewBuilder: (context, textController, focusNode, _) {
            if (controller.focusSearchOnMap) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (focusNode.canRequestFocus) {
                    focusNode.requestFocus();
                    controller.setFocusSearchOnMap = false;
                  }
                });
              });
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CustomSearchField(
                controller: textController,
                hintText: 'Search shop',
                focusNode: focusNode,
                ontTap: () {
                  tapNotifier.value = null;
                  if (sheetController.isAttached) {
                    sheetController.animateTo(
                      0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                  setState(() {});
                },
                clearOnTap: () {
                  textController.clear();
                  tapNotifier.value = null;
                  if (sheetController.isAttached) {
                    sheetController.animateTo(
                      0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                  setState(() {});
                },
              ),
            );
          },

          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topCenter,
              child: Material(
                elevation: 6,
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 25,
                  child: Builder(
                    builder: (context) {
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final shop = options.elementAt(index);

                          return ListTile(
                            title: HeaderTextBlack(
                              title: shop.shopName?.capitalize() ?? '',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: BodyTextHint(
                                title: shop.address?.capitalize() ?? '',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onTap: () => onSelected(shop),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 1,
                            thickness: 1,
                            indent: 12,
                            endIndent: 12,
                            color: Colors.grey.shade100,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },

          onSelected: (shop) {
            searchController.text = shop.shopName ?? '';
            _searchFocusNode.unfocus();
            _animateToShop(shop);
            // tapNotifier.value = shop;
            // sheetController.animateTo(
            //   0.25,
            //   duration: const Duration(milliseconds: 300),
            //   curve: Curves.easeOut,
            // );
          },
        );
      },
    );
  }

  void _animateToShop(ShopSearchData shop) {
    final double? lat = double.tryParse(shop.lat.toString());
    final double? long = double.tryParse(shop.long.toString());
    if (lat == null || long == null) {
      CustomToast.show(
        context,
        title: 'Invalid shop location coordinates',
        isError: true,
      );
      return;
    }
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, long), zoom: 17, tilt: 45),
      ),
    );
  }
}

class LocationShopContainer extends StatelessWidget {
  LocationShopContainer({
    super.key,
    required this.searchData,
    required this.distance,
  });

  final ShopSearchData searchData;
  final double distance;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.scaffoldBackground,
        border: Border.all(color: AppColors.primaryBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 80,
              width: 110,
              child: CustomNetworkImage(
                imageUrl:
                    searchData.shopImage ??
                    searchData.image1 ??
                    getUnKnownShopImages(
                      '${searchData.category?.toLowerCase()}',
                    ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BodyTextColors(
                  title: searchData.shopName?.capitalize() ?? '',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightDarkText,
                ),
                SizedBox(height: 10),
                BodyTextHint(
                  title: searchData.address?.capitalize() ?? '',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10),
                BodyTextHint(
                  title: '${distance.toStringAsFixed(1)} km Away',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final Map<String, String> iconImageMap = {
    "theater":
        "https://img.freepik.com/free-photo/3d-rendering-cinema-teather_23-2151169422.jpg?semt=ais_hybrid&w=740&q=80",
    "restaurant":
        "https://img.freepik.com/free-vector/cafe-restaurant-interior_107791-30184.jpg",
    "hospital":
        "https://static.vecteezy.com/system/resources/previews/005/317/601/non_2x/elderly-patient-in-front-the-hospital-vector.jpg",
    "bar":
        "https://img.freepik.com/free-vector/bar-table-pub-interior-cartoon-background_107791-28898.jpg?semt=ais_incoming&w=740&q=80",
    "grocery":
        "https://img.freepik.com/premium-photo/supermarket-business-vertical-poster-template_1257223-126129.jpg",
    "textile":
        "https://thumbs.dreamstime.com/b/fashion-store-interior-counter-mannequins-fashion-store-interior-counter-mannequins-hangers-showcase-191363271.jpg",
    "resort":
        "https://img.freepik.com/free-vector/outdoor-swimming-pool-colored-background-with-chaise-lounges-umbrella-palm-trees-cartoon-vector-illustration_1284-79719.jpg?semt=ais_hybrid&w=740&q=80",
    "bunk":
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRnf86j1Yv60Wd43cezQvFKwKABzdSvMctmig&s",
    "spa":
        "https://img.freepik.com/premium-vector/cosmetology-salon-flat-color-illustration-spa-massage-hair-removal-sugaring-services-skincare-procedures-equipment-2d-cartoon-interior-with-furniture-background_151150-2759.jpg",
    "hotel":
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR4DhNVE0f2RF1DAYAbz5GWoluf-fuMQ5SQUw&s",
  };

  String getUnKnownShopImages(String category) {
    return iconImageMap[category] ?? ApiRoutes.defaultShopImageUrl;
  }
}
