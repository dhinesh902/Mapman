import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapman/controller/home_controller.dart';
import 'package:mapman/model/shop_search_data.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/service/location_icon_service.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/strings.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
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
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  GoogleMapController? _mapController;
  late DraggableScrollableController sheetController;

  double _currentZoom = 14.5;

  String? _mapStyle;

  /// Current Location notifier

  StreamSubscription<Position>? _positionStream;
  LatLng? currentLatLng;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(10.9974, 76.9589),
    zoom: 14.5,
  );

  @override
  void initState() {
    super.initState();

    sheetController = DraggableScrollableController();
    homeController = context.read<HomeController>();

    /// current location listen
    startLocationListening();

    /// Map data show only streets
    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyle = string;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      homeController.setNearByShopHeight = 0.18;
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
          CameraPosition(target: currentLatLng!, zoom: 15.5),
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
    final response = await homeController.getSearchShops(
      input: homeController.searchCategory ?? 'all',
    );

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
    await _generateMarkers();
  }

  Future<void> _generateMarkers() async {
    final response = homeController.shopSearchData;
    if (response.status != Status.COMPLETED || response.data == null) return;

    for (var shop in response.data!) {
      final id = shop.id?.toString();
      if (id != null && !_customMarkers.containsKey(id)) {
        final icon = await createMarkerWithLabel(
          text: shop.shopName?.capitalize() ?? '',
          category: shop.category?.toLowerCase().trim() ?? 'others',
        );
        _customMarkers[id] = icon;
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

    // Load category icon
    final assetPath = _getIconPath(category);
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 60,
      targetHeight: 70,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ui.Image iconImage = fi.image;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(text: "${text.capitalize()}\n"),
          TextSpan(
            text: category.capitalize(),
            style: AppTextStyle(
              fontSize: 28,
              color: Colors.black54,
              fontWeight: FontWeight.normal,
            ).textStyle,
          ),
        ],
        style: AppTextStyle(
          fontSize: 30,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ).textStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final double labelPadding = 15.0;
    final double labelWidth = textPainter.width + (labelPadding * 2);
    final double labelHeight = textPainter.height + 10;
    final double iconWidth = iconImage.width.toDouble();
    final double iconHeight = iconImage.height.toDouble();

    final double totalWidth = labelWidth > iconWidth ? labelWidth : iconWidth;
    final double totalHeight = labelHeight + iconHeight + 5;

    final double labelX = (totalWidth - labelWidth) / 2;
    final double iconX = (totalWidth - iconWidth) / 2;

    // Draw label bubble
    final paint = Paint()..color = Colors.white;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(labelX, 0, labelWidth, labelHeight),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, paint);

    // Draw shadow/border for bubble
    final borderPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rect, borderPaint);

    // Draw text
    textPainter.paint(canvas, Offset(labelX + labelPadding, 5));

    // Draw icon
    canvas.drawImage(iconImage, Offset(iconX, labelHeight + 5), Paint());

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(totalWidth.toInt(), totalHeight.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  String _getIconPath(String category) {
    switch (category.toLowerCase().trim()) {
      case 'theater':
        return AppIcons.theatersMap;
      case 'restaurant':
        return AppIcons.resortsMap;
      case 'hospital':
        return AppIcons.hospitalsMap;
      case 'bars':
        return AppIcons.barsMap;
      case 'grocery':
        return AppIcons.groceryMap;
      case 'textile':
        return AppIcons.textilesMap;
      case 'resort':
        return AppIcons.resortsMap;
      case 'bunk':
        return AppIcons.petrolBunkMap;
      case 'spa':
        return AppIcons.spaMap;
      case 'hotel':
        return AppIcons.hotelsMap;
      default:
        return AppIcons.othersMap;
    }
  }

  final List<String> _iconMap = [
    'theater',
    'restaurant',
    'hospital',
    'bars',
    'grocery',
    'textile',
    'resort',
    'bunk',
    'spa',
    'hotel',
    'others',
  ];

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

    final Set<Marker> markerSet = {};

    for (int i = 0; i < response.data!.length; i++) {
      final shop = response.data![i];

      final String rawCategory =
          shop.category?.toLowerCase().trim() ?? 'others';
      final String category = _iconMap.contains(rawCategory)
          ? rawCategory
          : 'others';

      final baseIcon = LocationIconService().getMarkerIconSync(
        category: category,
      );

      try {
        final double? lat = double.tryParse(shop.lat.toString());
        final double? long = double.tryParse(shop.long.toString());

        if (lat != null && long != null) {
          markerSet.add(
            Marker(
              markerId: MarkerId(shop.id?.toString() ?? 'marker_$i'),
              position: LatLng(lat, long),

              icon: _customMarkers[shop.id?.toString()] ?? baseIcon,

              onTap: () {
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
      elevation: 6,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Image.network(icon, height: 20, color: Colors.black54),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    homeController = context.watch<HomeController>();
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
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                    buildingsEnabled: true,
                    padding: const EdgeInsets.only(top: 70, bottom: 100),
                    onMapCreated: onMapCreated,
                  ),
                  Positioned(
                    right: 16,
                    bottom: 100,
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
                        child: LocationShopContainer(
                          searchData: shop,
                          distance: distanceBetweenLatLong(
                            latitude: double.parse(shop.lat.toString()),
                            longitude: double.parse(shop.long.toString()),
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
                                        onTap: () {
                                          tapNotifier.value = null;
                                          sheetController.animateTo(
                                            0.0,
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeOut,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Builder(
                                  builder: (context) {
                                    switch (homeController
                                        .shopSearchData
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
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: 10,
                                                  top: index == 0 ? 5 : 0,
                                                ),
                                                child: LocationShopContainer(
                                                  searchData: shop,
                                                  distance:
                                                      distanceBetweenLatLong(
                                                        latitude: double.parse(
                                                          shop.lat.toString(),
                                                        ),
                                                        longitude: double.parse(
                                                          shop.long.toString(),
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
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CustomSearchField(
                controller: textController,
                hintText: 'Search shop',
                focusNode: focusNode,
                ontTap: () {
                  tapNotifier.value = null;
                  sheetController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                  setState(() {});
                },
                clearOnTap: () {
                  textController.clear();
                  tapNotifier.value = null;
                  sheetController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
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
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            double.parse(shop.lat.toString()),
            double.parse(shop.long.toString()),
          ),
          zoom: 17,
          tilt: 45,
        ),
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
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          final token = SessionManager.getToken();
          if (token == null || token.isEmpty) {
            LoginBottomSheet.showLoginBottomSheet(context);
          } else {
            context.pushNamed(AppRoutes.shopDetail, extra: searchData.id);
          }
        },
        child: Container(
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
        ),
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
    "bars":
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
    return iconImageMap[category] ??
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_x6m1vACqgzs9-dxIZq-d6JYFbkJHkvdpCw&s";
  }
}
