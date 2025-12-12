import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapman/controller/home_controller.dart';
import 'package:mapman/service/location_icon_service.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/constants/themes.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  late HomeController homeController;
  final ValueNotifier<bool> tapNotifier = ValueNotifier(false);
  GoogleMapController? _mapController;

  late DraggableScrollableController sheetController;

  BitmapDescriptor? customIcon;
  String? _mapStyle;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(10.9974, 76.9589),
    zoom: 14.4746,
  );

  List<LatLng> coimbatoreLatLngs = [
    LatLng(11.0168, 76.9558),
    LatLng(11.0180, 76.9725),
    LatLng(11.0103, 76.9470),
    LatLng(11.0300, 76.9420),
    LatLng(10.9993, 76.9680),
    LatLng(11.0410, 76.9230),
    LatLng(10.9925, 76.9610),
    LatLng(11.0525, 76.9850),
    LatLng(11.0050, 77.0070),
    LatLng(11.0302, 77.0055),
  ];

  @override
  void initState() {
    super.initState();
    sheetController = DraggableScrollableController();

    homeController = context.read<HomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.setNearByShopHeight = 0.18;
    });
    loadMapStyle();
    loadIcon();
  }

  Future<void> loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/map_style.json');
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_mapStyle != null) {
      _mapController!.setMapStyle(_mapStyle!);
    }
  }

  Future<void> loadIcon() async {
    customIcon = await LocationIconService().getMarkerIcon();
    if (mounted) setState(() {});
  }

  Set<Marker> get markers {
    if (customIcon == null) return {};

    return coimbatoreLatLngs.asMap().entries.map((entry) {
      int index = entry.key;
      LatLng position = entry.value;

      return Marker(
        markerId: MarkerId("marker_$index"),
        position: position,
        icon: customIcon!,
        onTap: () {
          tapNotifier.value = true;
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    homeController = context.watch<HomeController>();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            child: GoogleMap(
              mapType: MapType.terrain,
              initialCameraPosition: _kGooglePlex,
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: onMapCreated,
            ),
          ),

          Positioned(
            top: 15,
            left: 0,
            right: 0,
            child: CustomSearchField(
              controller: TextEditingController(),
              hintText: 'Search shop',
              clearOnTap: () {},
            ),
          ),

          ValueListenableBuilder(
            valueListenable: tapNotifier,
            builder: (context, isTap, _) {
              if (isTap) {
                return Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: LocationShopContainer(),
                );
              }
              return SizedBox.shrink();
            },
          ),

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
                        padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
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
                                title: 'Near By Theaters',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            ClearCircleContainer(
                              onTap: () {
                                tapNotifier.value = false;
                                sheetController.animateTo(
                                  0.0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 360,
                        child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: 10,
                                top: index == 0 ? 5 : 0,
                              ),
                              child: LocationShopContainer(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LocationShopContainer extends StatelessWidget {
  const LocationShopContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: Themes.searchFieldDecoration(borderRadius: 5),
        padding: EdgeInsets.all(10),
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
              child: CustomNetworkImage(
                imageUrl:
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS9oBl8oMj8unCKsHx9WuzVKgxc34HJnei-Qw&s',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BodyTextColors(
                    title: 'Kasi Theatre',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.lightDarkText,
                  ),
                  SizedBox(height: 10),
                  BodyTextHint(
                    title: 'Ashok pillar, chennai',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  BodyTextHint(
                    title: '1.2km Away',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
