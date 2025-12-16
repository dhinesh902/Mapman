import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapman/controller/place_controller.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/utils/storage/session_manager.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class EnterLocation extends StatefulWidget {
  const EnterLocation({super.key});

  @override
  State<EnterLocation> createState() => _EnterLocationState();
}

class _EnterLocationState extends State<EnterLocation> {
  late PlaceController placeController;

  List<CustomPrediction> predictions = [];
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    placeController = context.read<PlaceController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      placeController.setConfirmedPrediction = null;
    });
    loadPredictions();
    super.initState();
  }

  Future<void> loadPredictions() async {
    predictions = await SessionManager().getPlaceDetails();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    placeController = context.watch<PlaceController>();
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(title: 'Enter your Location'),
        body: ListView(
          padding: EdgeInsets.all(10),
          children: [
            Container(
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadiusGeometry.circular(6),
              ),
              child: Column(
                children: [
                  LocationListTile(
                    title: 'Use My Current Location',
                    icon: AppIcons.mapP,
                    isArrow: true,
                    onTap: () async {
                      await showLocationDialogue(context);
                    },
                  ),
                  Divider(color: Colors.grey.shade200),
                  LocationListTile(
                    title: 'Add New Address',
                    icon: AppIcons.addIconP,
                    onTap: () async {
                      await showLocationDialogue(context);
                    },
                  ),
                ],
              ),
            ),
            if (placeController.confirmedPrediction != null) ...[
              SizedBox(height: 30),
              BodyTextColors(
                title: 'Saved Address',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.lightGreyHint,
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  borderRadius: BorderRadiusGeometry.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: HeaderTextBlack(
                            title:
                                placeController.confirmedPrediction?.title
                                    ?.capitalize() ??
                                "",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          height: 26,
                          padding: EdgeInsetsGeometry.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: GenericColors.lightPrimary.withValues(
                              alpha: .5,
                            ),
                            borderRadius: BorderRadiusGeometry.circular(4),
                          ),
                          child: Center(
                            child: HeaderTextPrimary(
                              title: 'Currently Selected',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            placeController.setConfirmedPrediction = null;
                          },
                          child: SvgPicture.asset(AppIcons.deleteFill),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    BodyTextHint(
                      title:
                          placeController.confirmedPrediction?.description
                              ?.capitalize() ??
                          "",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
            ],

            /// Search Results
            SizedBox(height: 30),
            BodyTextColors(
              title: 'Search Results',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.lightGreyHint,
            ),
            SizedBox(height: 8),
            Builder(
              builder: (context) {
                if (isLoading) {
                  return CustomLoadingIndicator(height: 40);
                }
                if (predictions.isEmpty) {
                  return NoDataText(title: "No result found");
                }
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: predictions.length,
                  itemBuilder: (context, index) {
                    final item = predictions[index];

                    return SearchResultContainer(
                      prediction: item,
                      onTap: () async {
                        final placeId = item.placeId;
                        if (placeId == null || placeId.isEmpty) {
                          CustomToast.show(
                            context,
                            title: 'Invalid place selected',
                          );
                          return;
                        }
                        await placeController.fetchPlaceDetails(
                          placeId,
                          context,
                        );
                        final location = placeController.placeDetails?.location;
                        final lat = location?.lat;
                        final lng = location?.lng;
                        if (!context.mounted) return;
                        if (lat == null || lng == null) {
                          CustomToast.show(
                            context,
                            title: 'Unable to get location',
                          );
                          return;
                        }
                        context.pop({
                          'address': item.description ?? '',
                          'latlong': LatLng(lat, lng),
                        });
                      },
                      clearOnTap: () async {
                        final placeId = item.placeId;
                        if (placeId != null) {
                          await SessionManager().removePlaceDetail(placeId);
                        }
                        if (!mounted) return;
                        setState(() {
                          if (index < predictions.length) {
                            predictions.removeAt(index);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
            SizedBox(height: 30),
            CustomFullButton(
              title: 'Save Location Details',
              isDialogue: true,
              onTap: () {
                final prediction = placeController.confirmedPrediction;
                if (prediction == null) {
                  CustomToast.show(
                    context,
                    title: 'Please select address',
                    isError: true,
                  );
                  return;
                }
                final lat =
                    placeController.placeDetails?.location?.lat ??
                    placeController.currentLocationLatLng.data?.latitude;

                final lng =
                    placeController.placeDetails?.location?.lng ??
                    placeController.currentLocationLatLng.data?.longitude;
                if (lat == null || lng == null) {
                  CustomToast.show(context, title: 'Unable to get location');
                  return;
                }
                context.pop({
                  'address': prediction.description ?? '',
                  'latlong': LatLng(lat, lng),
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LocationListTile extends StatelessWidget {
  const LocationListTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isArrow = false,
  });

  final String title, icon;
  final VoidCallback onTap;
  final bool isArrow;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Image.asset(icon, height: 24, width: 24),
      title: HeaderTextBlack(
        title: title,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      trailing: isArrow
          ? SvgPicture.asset(
              AppIcons.arrowForward,
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(Color(0XFFC2C4C5), BlendMode.srcIn),
            )
          : null,
    );
  }
}

Future<dynamic> showLocationDialogue(BuildContext context) async {
  if (Platform.isIOS) {
    return showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Image.asset(AppIcons.locationPinP, height: 80)),
              SizedBox(height: 10),
              HeaderTextBlack(
                title: 'Pin Your Location Correctly',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: BodyTextHint(
              title:
                  'Please pin your location appropriately to guarantee your shop\'s information are preserved correctly',
              fontSize: 12,
              fontWeight: FontWeight.w300,
              textAlign: TextAlign.start,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
                context.pushNamed(AppRoutes.enterYourLocation);
              },
              child: HeaderTextPrimary(
                title: "Yes, I Got It",
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  AppIcons.locationPinP,
                  height: 110,
                  width: 110,
                ),
              ),
              SizedBox(height: 20),
              HeaderTextBlack(
                title: 'Pin Your Location Correctly',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 10),
              BodyTextHint(
                title:
                    'Please pin your location appropriately to guarantee your shop\'s information are preserved correctly',
                fontSize: 12,
                fontWeight: FontWeight.w300,
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 30),
              CustomFullButton(
                title: 'Yes, I Got It',
                isDialogue: true,
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed(AppRoutes.enterYourLocation);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class SearchResultContainer extends StatelessWidget {
  const SearchResultContainer({
    super.key,
    required this.prediction,
    required this.clearOnTap,
    required this.onTap,
  });

  final CustomPrediction prediction;
  final VoidCallback clearOnTap, onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadiusGeometry.circular(4),
          color: AppColors.scaffoldBackground,
        ),
        margin: EdgeInsets.only(bottom: 10),
        child: ListTile(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 15),
              SvgPicture.asset(AppIcons.locationArrow),
              SizedBox(width: 10),
              Expanded(
                child: BodyTextColors(
                  title: prediction.title ?? '',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 15, top: 5),
            child: BodyTextHint(
              title: prediction.description ?? '',
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: InkWell(
            onTap: clearOnTap,
            child: SvgPicture.asset(AppIcons.clearOutline),
          ),
        ),
      ),
    );
  }
}
