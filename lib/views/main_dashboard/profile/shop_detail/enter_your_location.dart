import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete/google_places_autocomplete.dart';
import 'package:lottie/lottie.dart';
import 'package:mapman/controller/place_controller.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/constants/themes.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class EnterYourLocation extends StatefulWidget {
  const EnterYourLocation({super.key});

  @override
  State<EnterYourLocation> createState() => _EnterYourLocationState();
}

class _EnterYourLocationState extends State<EnterYourLocation> {
  late PlaceController placeController;
  late VoidCallback _placeListener;

  GoogleMapController? _mapController;

  LatLng? _currentLatLng;
  LatLng? _lastFetchedLatLng;

  bool _ignoreNextCameraIdle = false;
  Timer? _idleDebounce;

  @override
  void initState() {
    super.initState();
    placeController = context.read<PlaceController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      placeController.resetAddress();
      await placeController.getCurrentLocation();

      final latLng = placeController.currentLocationLatLng.data;
      if (latLng != null) {
        _currentLatLng = latLng;
        _fetchAddressOnce(latLng);
      }
    });

    _placeListener = () {
      final details = placeController.placeDetails;
      if (details?.location != null) {
        final latLng = LatLng(details!.location!.lat, details.location!.lng);
        _moveCameraFromSearch(latLng);
      }
    };

    placeController.addListener(_placeListener);
  }

  @override
  void dispose() {
    placeController.removeListener(_placeListener);
    _idleDebounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    placeController = context.watch<PlaceController>();
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(title: 'Enter your Location'),
        body: Builder(
          builder: (context) {
            switch (placeController.currentLocationLatLng.status) {
              case Status.INITIAL:
              case Status.LOADING:
                return const CustomLoadingIndicator();
              case Status.COMPLETED:
                final state = placeController.currentLocationLatLng;
                final initial = state.data!;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(initial.latitude, initial.longitude),
                        zoom: 15,
                        tilt: 65,
                        bearing: 30,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      buildingsEnabled: true,
                      compassEnabled: false,
                      onMapCreated: (c) {
                        _mapController = c;
                      },
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * .55,
                      ),
                      onCameraMove: (position) {
                        if (placeController.placeDetails != null) {
                          placeController.resetAddress();
                        }
                        _currentLatLng = position.target;
                      },

                      onCameraIdle: _handleCameraIdle,
                    ),

                    /// LOTTIE ANIMATION
                    IgnorePointer(
                      child: Lottie.asset(
                        AppAnimations.locationPin,
                        height: 80,
                      ),
                    ),

                    /// SEARCH BAR
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: CustomSearchField(
                        controller: TextEditingController(),
                        hintText: 'Search by location name',
                        ontTap: () async {
                          FocusScope.of(context).unfocus();

                          await context.pushNamed(AppRoutes.searchLocation);

                          if (!context.mounted) return;
                          FocusScope.of(context).unfocus();
                        },
                        clearOnTap: () {},
                      ),
                    ),

                    Positioned(
                      bottom: 15,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _goToMyCurrentLocation,
                              icon: const Icon(Icons.my_location),
                              label: const HeaderTextBlack(
                                title: "Current Location",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                elevation: 4,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          LocationPickContainerDrag(
                            address: placeController.loadingAddress
                                ? 'Loading...'
                                : placeController.currentAddress,
                            latLng: _currentLatLng ?? initial,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              case Status.ERROR:
                return CustomErrorTextWidget(
                  title: placeController.currentLocationLatLng.message ?? '',
                );
            }
          },
        ),
      ),
    );
  }

  Future<void> _moveCameraFromSearch(LatLng latLng) async {
    if (_mapController == null) return;

    _ignoreNextCameraIdle = true;
    _currentLatLng = latLng;

    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: latLng, zoom: 16)),
    );

    _fetchAddressOnce(latLng);
  }

  Future<void> _goToMyCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permission permanently denied');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 16,
          tilt: 0,
          bearing: 0,
        ),
      ),
    );
  }

  void _handleCameraIdle() {
    if (_ignoreNextCameraIdle) {
      _ignoreNextCameraIdle = false;
      return;
    }

    _idleDebounce?.cancel();
    _idleDebounce = Timer(const Duration(milliseconds: 500), () {
      if (_currentLatLng != null) {
        _fetchAddressOnce(_currentLatLng!);
      }
    });
  }

  void _fetchAddressOnce(LatLng latLng) {
    if (_lastFetchedLatLng == latLng) return;

    _lastFetchedLatLng = latLng;
    placeController.fetchAddress(latLng: latLng);
  }
}

class LocationPickContainerPrediction extends StatelessWidget {
  const LocationPickContainerPrediction({super.key, required this.prediction});

  final Prediction prediction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Themes.searchFieldDecoration(borderRadius: 6),
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Container(
            height: 25,
            width: double.maxFinite,
            padding: EdgeInsets.only(left: 15),
            decoration: BoxDecoration(
              color: GenericColors.lightPrimary.withValues(alpha: .5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: BodyTextColors(
              title: 'Shop Location will be pin here',
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: GenericColors.darkGeryHeading,
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.fromLTRB(15, 15, 15, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(AppIcons.mapP, height: 24, width: 24),
                    SizedBox(width: 15),
                    Expanded(
                      child: HeaderTextBlack(
                        title: prediction.title?.capitalize() ?? '',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                BodyTextHint(
                  title: prediction.description?.capitalize() ?? '',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                SizedBox(height: 10),
                CustomFullButton(
                  title: 'Confirm & Proceed',
                  onTap: () async {
                    context.read<PlaceController>().setConfirmedPrediction =
                        prediction;
                    await CustomDialogues.showSuccessDialog(
                      context,
                      title: 'SuccessFully Updated!',
                      body: 'Your location updated successfully!',
                    );
                    if (!context.mounted) return;
                    context.pop();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LocationPickContainerDrag extends StatelessWidget {
  const LocationPickContainerDrag({
    super.key,
    required this.address,
    required this.latLng,
  });

  final String address;
  final LatLng latLng;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Themes.searchFieldDecoration(borderRadius: 6),
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Container(
            height: 25,
            width: double.maxFinite,
            padding: EdgeInsets.only(left: 15),
            decoration: BoxDecoration(
              color: GenericColors.lightPrimary.withValues(alpha: .5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: BodyTextColors(
              title: 'Shop Location will be pin here',
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: GenericColors.darkGeryHeading,
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.fromLTRB(15, 15, 15, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(AppIcons.mapP, height: 24, width: 24),
                    SizedBox(width: 15),
                    Expanded(
                      child: HeaderTextBlack(
                        title: 'Shop Name',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                BodyTextHint(
                  title: address,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                SizedBox(height: 10),
                CustomFullButton(
                  title: 'Confirm & Proceed',
                  onTap: () async {
                    context.read<PlaceController>().setShopAddress = {
                      'address': address,
                      'latLong': latLng,
                    };
                    await CustomDialogues.showSuccessDialog(
                      context,
                      title: 'SuccessFully Updated!',
                      body: 'Your location updated successfully!',
                    );
                    if (!context.mounted) return;
                    context.pop();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class LocationAutoCompleteSearchField extends StatelessWidget {
//   const LocationAutoCompleteSearchField({
//     super.key,
//     required this.placeController,
//   });
//
//   final PlaceController placeController;
//
//   @override
//   Widget build(BuildContext context) {
//     final prediction = context.watch<PlaceController>().predictions;
//     return Autocomplete<Prediction>(
//       displayStringForOption: (Prediction option) =>
//           option.title ?? option.description ?? "",
//       optionsBuilder: (TextEditingValue textValue) {
//         if (textValue.text.isEmpty) {
//           return const Iterable<Prediction>.empty();
//         }
//         final query = textValue.text.toLowerCase();
//         return prediction.where((p) {
//           final title = (p.title ?? "").toLowerCase();
//           final desc = (p.description ?? "").toLowerCase();
//           return title.contains(query) || desc.contains(query);
//         });
//       },
//       onSelected: (Prediction value) {
//         placeController.setSelectedPrediction = value;
//         FocusScope.of(context).unfocus();
//       },
//       fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 15),
//           child: CustomSearchField(
//             controller: controller,
//             focusNode: focusNode,
//             hintText: 'Location Search by Name',
//             clearOnTap: () {
//               controller.clear();
//               placeController.clearPredictions();
//               placeController.setSelectedPrediction = null;
//             },
//             onChanged: (value) {
//               if (value != null && value.isNotEmpty) {
//                 placeController.getPredictions(value);
//               } else {
//                 placeController.clearPredictions();
//               }
//             },
//           ),
//         );
//       },
//       optionsViewBuilder:
//           (context, AutocompleteOnSelected<Prediction> onSelected, options) {
//             return Align(
//               alignment: Alignment.topCenter,
//               child: Material(
//                 color: Colors.white,
//                 elevation: 4,
//                 borderRadius: BorderRadius.circular(10),
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width - 20,
//                   child: Builder(
//                     builder: (context) {
//                       if (context
//                           .watch<PlaceController>()
//                           .isPredictionLoading) {
//                         return const Padding(
//                           padding: EdgeInsets.symmetric(vertical: 20),
//                           child: Center(
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           ),
//                         );
//                       }
//                       return ListView.builder(
//                         padding: const EdgeInsets.symmetric(vertical: 5),
//                         shrinkWrap: true,
//                         itemCount: options.length,
//                         itemBuilder: (context, index) {
//                           final item = options.elementAt(index);
//                           return InkWell(
//                             onTap: () async {
//                               onSelected(item);
//                               await context
//                                   .read<PlaceController>()
//                                   .fetchPlaceDetails(
//                                     item.placeId ?? '',
//                                     context,
//                                   );
//                               await SessionManager().addPlaceDetail(
//                                 CustomPrediction(
//                                   title: item.title,
//                                   placeId: item.placeId,
//                                   description: item.description,
//                                 ),
//                               );
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.all(12),
//                               child: Row(
//                                 children: [
//                                   Image.asset(
//                                     AppIcons.mapP,
//                                     height: 25,
//                                     width: 25,
//                                   ),
//                                   const SizedBox(width: 15),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         HeaderTextBlack(
//                                           title: item.title ?? "",
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                         const SizedBox(height: 4),
//                                         BodyTextHint(
//                                           title: item.description ?? "",
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.w400,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             );
//           },
//     );
//   }
// }

// class LocationAutoCompleteSearchField extends StatelessWidget {
//   const LocationAutoCompleteSearchField({
//     super.key,
//     required this.placeController,
//   });
//
//   final PlaceController placeController;
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<PlaceController>(
//       builder: (context, placeCtrl, _) {
//         return Autocomplete<Prediction>(
//           displayStringForOption: (Prediction option) =>
//               option.title ?? option.description ?? "",
//
//           optionsBuilder: (TextEditingValue textValue) {
//             if (textValue.text.isEmpty) {
//               return const Iterable<Prediction>.empty();
//             }
//             return placeCtrl.predictions;
//           },
//
//           onSelected: (Prediction value) {
//             placeCtrl.setSelectedPrediction = value;
//             FocusScope.of(context).unfocus();
//           },
//
//           fieldViewBuilder:
//               (context, textController, focusNode, onFieldSubmitted) {
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 15),
//                   child: CustomSearchField(
//                     controller: textController,
//                     focusNode: focusNode,
//                     hintText: 'Location Search by Name',
//                     clearOnTap: () {
//                       textController.clear();
//                       placeCtrl.clearPredictions();
//                       placeCtrl.setSelectedPrediction = null;
//                       placeCtrl.setIsCameraMode = false;
//                     },
//                     onChanged: (value) {
//                       placeCtrl.getPredictions(value!);
//                     },
//                   ),
//                 );
//               },
//           optionsViewBuilder:
//               (
//                 context,
//                 AutocompleteOnSelected<Prediction> onSelected,
//                 options,
//               ) {
//                 return Align(
//                   alignment: Alignment.topCenter,
//                   child: Material(
//                     elevation: 4,
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                     child: SizedBox(
//                       width: MediaQuery.of(context).size.width - 20,
//                       child: Builder(
//                         builder: (_) {
//                           if (placeCtrl.isPredictionLoading) {
//                             return SizedBox(
//                               height: 150,
//                               child: const Padding(
//                                 padding: EdgeInsets.symmetric(vertical: 20),
//                                 child: CustomLoadingIndicator(
//                                   strokeWidth: 6,
//                                   height: 40,
//                                 ),
//                               ),
//                             );
//                           }
//
//                           return ListView.builder(
//                             padding: const EdgeInsets.symmetric(vertical: 5),
//                             shrinkWrap: true,
//                             itemCount: options.length,
//                             itemBuilder: (context, index) {
//                               final item = options.elementAt(index);
//
//                               return InkWell(
//                                 onTap: () async {
//                                   onSelected(item);
//
//                                   await placeCtrl.fetchPlaceDetails(
//                                     item.placeId ?? '',
//                                   );
//
//                                   await SessionManager().addPlaceDetail(
//                                     CustomPrediction(
//                                       title: item.title,
//                                       placeId: item.placeId,
//                                       description: item.description,
//                                     ),
//                                   );
//                                 },
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(12),
//                                   child: Row(
//                                     children: [
//                                       Image.asset(
//                                         AppIcons.mapP,
//                                         height: 25,
//                                         width: 25,
//                                       ),
//                                       const SizedBox(width: 15),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             HeaderTextBlack(
//                                               title: item.title ?? "",
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                             const SizedBox(height: 4),
//                                             BodyTextHint(
//                                               title: item.description ?? "",
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w400,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 );
//               },
//         );
//       },
//     );
//   }
// }
