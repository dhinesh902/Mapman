import 'dart:async';

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
import 'package:mapman/utils/constants/themes.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  late HomeController homeController;

  final ValueNotifier<ShopSearchData?> tapNotifier = ValueNotifier(null);
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  GoogleMapController? _mapController;
  late DraggableScrollableController sheetController;

  String? _mapStyle;

  /// Current Location notifier

  StreamSubscription<Position>? _positionStream;
  LatLng? currentLatLng;

  bool _movedToCurrentLocation = false;

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
      await getSearchShops();
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

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50, // ✔ realistic value
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (position) {
            currentLatLng = LatLng(position.latitude, position.longitude);

            if (!_movedToCurrentLocation && _mapController != null) {
              _movedToCurrentLocation = true;
              _mapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: currentLatLng!, zoom: 15.5),
                ),
              );
            }

            if (mounted) setState(() {});
          },
        );
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

    if (currentLatLng != null && !_movedToCurrentLocation) {
      _movedToCurrentLocation = true;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng!, 15.5),
      );
    }
  }

  Future<void> getSearchShops() async {
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
    'hotels',
    'others',
  ];

  Future<Set<Marker>> loadMarkers() async {
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

      final icon = await LocationIconService().getMarkerIcon(
        category: category,
      );

      markerSet.add(
        Marker(
          markerId: MarkerId(shop.id?.toString() ?? 'marker_$i'),
          position: LatLng(
            double.parse(shop.lat.toString()),
            double.parse(shop.long.toString()),
          ),
          icon: icon,
          onTap: () {
            tapNotifier.value = shop;
          },
        ),
      );
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
                  FutureBuilder<Set<Marker>>(
                    future: loadMarkers(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return GoogleMap(
                        initialCameraPosition: _kGooglePlex,
                        markers: snapshot.data!,
                        circles: _getLocationCircle(),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: false,
                        buildingsEnabled: true,
                        padding: const EdgeInsets.only(top: 70),
                        onMapCreated: onMapCreated,
                      );
                    },
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

              return shopName.contains(query) || address.contains(query);
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
  const LocationShopContainer({
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
          context.pushNamed(AppRoutes.shopDetail, extra: searchData.id);
        },
        child: Container(
          decoration: Themes.searchFieldDecoration(borderRadius: 6),
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Container(
                height: 80,
                width: 112,
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusGeometry.circular(10),
                ),
                clipBehavior: Clip.hardEdge,
                child: CustomNetworkImage(imageUrl: searchData.shopImage ?? ''),
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
}
