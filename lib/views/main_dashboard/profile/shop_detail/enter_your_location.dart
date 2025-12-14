import 'package:dynamic_marker/dynamic_marker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete/google_places_autocomplete.dart';
import 'package:lottie/lottie.dart';
import 'package:mapman/controller/place_controller.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/constants/themes.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/utils/storage/session_manager.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
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
  late TextEditingController searchController;

  GoogleMapController? _controller;
  late VoidCallback _placeListener;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();

    placeController = context.read<PlaceController>();
    searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      placeController.setSelectedPrediction = null;
      getCurrentLocation();
    });

    _placeListener = () {
      if (!mounted) return;
      final details = placeController.placeDetails;
      if (details != null && details.location != null) {
        final latLng = LatLng(details.location!.lat, details.location!.lng);
        _animateToSelectedPlace(latLng);
      }
    };
    placeController.addListener(_placeListener);
  }

  @override
  void dispose() {
    placeController.removeListener(_placeListener);
    _controller?.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> getCurrentLocation() async {
    await placeController.getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    placeController = context.watch<PlaceController>();

    final details = placeController.placeDetails;

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
                final latLong = placeController.currentLocationLatLng.data;

                final initialLat = details?.location?.lat ?? latLong!.latitude;
                final initialLng = details?.location?.lng ?? latLong!.longitude;

                return Stack(
                  children: [
                    DynamicMarkerGoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(initialLat, initialLng),
                        zoom: 13,
                      ),
                      onMapCreated: (c) {
                        if (!mounted) return;
                        _controller = c;
                        _updateMarkerPosition(LatLng(initialLat, initialLng));
                      },
                      dynamicMarkers: [
                        DynamicMarker(
                          position: LatLng(initialLat, initialLng),
                          anchor: Alignment.bottomCenter,
                          child: Lottie.asset(
                            AppAnimations.location,
                            height: 200,
                          ),
                        ),
                      ],
                    ),

                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: LocationAutoCompleteSearchField(
                        placeController: placeController,
                      ),
                    ),

                    if (placeController.selectedPrediction != null)
                      Positioned(
                        bottom: 15,
                        left: 0,
                        right: 0,
                        child: LocationPickContainer(
                          prediction: placeController.selectedPrediction!,
                        ),
                      ),
                  ],
                );

              case Status.ERROR:
                return CustomErrorTextWidget(
                  title: '${placeController.currentLocationLatLng.message}',
                );
            }
          },
        ),
      ),
    );
  }

  Future<void> _animateToSelectedPlace(LatLng latLng) async {
    if (!mounted || _controller == null) return;

    await _controller!.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: latLng, zoom: 16)),
    );

    _scheduleMarkerUpdate(latLng);
  }

  void _scheduleMarkerUpdate(LatLng latLng) {
    if (_isUpdating) return;

    _isUpdating = true;

    Future.microtask(() async {
      await _updateMarkerPosition(latLng);
      _isUpdating = false;
    });
  }

  Future<void> _updateMarkerPosition(LatLng latLng) async {
    if (!mounted || _controller == null) return;
    await _controller!.getScreenCoordinate(latLng);
  }
}

class LocationAutoCompleteSearchField extends StatelessWidget {
  const LocationAutoCompleteSearchField({
    super.key,
    required this.placeController,
  });

  final PlaceController placeController;

  @override
  Widget build(BuildContext context) {
    final prediction = context.watch<PlaceController>().predictions;
    return Autocomplete<Prediction>(
      displayStringForOption: (Prediction option) =>
          option.title ?? option.description ?? "",
      optionsBuilder: (TextEditingValue textValue) {
        if (textValue.text.isEmpty) {
          return const Iterable<Prediction>.empty();
        }
        final query = textValue.text.toLowerCase();
        return prediction.where((p) {
          final title = (p.title ?? "").toLowerCase();
          final desc = (p.description ?? "").toLowerCase();
          return title.contains(query) || desc.contains(query);
        });
      },
      onSelected: (Prediction value) {
        placeController.setSelectedPrediction = value;
        FocusScope.of(context).unfocus();
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: CustomSearchField(
            controller: controller,
            focusNode: focusNode,
            hintText: 'Location Search by Name',
            clearOnTap: () {
              controller.clear();
              placeController.clearPredictions();
              placeController.setSelectedPrediction = null;
            },
            onChanged: (value) {
              if (value != null && value.isNotEmpty) {
                placeController.getPredictions(value);
              } else {
                placeController.clearPredictions();
              }
            },
          ),
        );
      },
      optionsViewBuilder:
          (context, AutocompleteOnSelected<Prediction> onSelected, options) {
            return Align(
              alignment: Alignment.topCenter,
              child: Material(
                color: Colors.white,
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 20,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final item = options.elementAt(index);
                      return InkWell(
                        onTap: () async {
                          onSelected(item);
                          await context
                              .read<PlaceController>()
                              .fetchPlaceDetails(item.placeId ?? '', context);
                          await SessionManager().addPlaceDetail(
                            CustomPrediction(
                              title: item.title,
                              placeId: item.placeId,
                              description: item.description,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Image.asset(AppIcons.mapP, height: 25, width: 25),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    HeaderTextBlack(
                                      title: item.title ?? "",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    const SizedBox(height: 4),
                                    BodyTextHint(
                                      title: item.description ?? "",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
    );
  }
}

class LocationPickContainer extends StatelessWidget {
  const LocationPickContainer({super.key, required this.prediction});

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
                  onTap: () {
                    context.read<PlaceController>().setConfirmedPrediction =
                        prediction;
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
