import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/place_controller.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/storage/session_manager.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class SearchLocation extends StatefulWidget {
  const SearchLocation({super.key});

  @override
  State<SearchLocation> createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  late TextEditingController searchController;
  late PlaceController placeController;
  late FocusNode focusNode;

  @override
  void initState() {
    // TODO: implement initState
    searchController = TextEditingController();
    focusNode = FocusNode();
    focusNode.requestFocus();
    placeController = context.read<PlaceController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      placeController.clearPredictions();
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    placeController = context.watch<PlaceController>();
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(title: 'Search Location'),
        body: Column(
          children: [
            SizedBox(height: 10),
            CustomSearchField(
              controller: searchController,
              hintText: 'search Location',
              onChanged: (value) {
                if (value!.isNotEmpty) {
                  placeController.getPredictions(value);
                } else {
                  placeController.clearPredictions();
                }
              },
              clearOnTap: () {
                searchController.clear();
                placeController.clearPredictions();
              },
            ),
            SizedBox(height: 15),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (placeController.predictions.isNotEmpty) {
                    return ListView.builder(
                      itemCount: placeController.predictions.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      itemBuilder: (context, index) {
                        final prediction = placeController.predictions[index];
                        return InkWell(
                          onTap: () async {
                            try {
                              CustomDialogues.showLoadingDialogue(context);
                              await placeController.fetchPlaceDetails(
                                prediction.placeId ?? '',
                              );
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              await SessionManager().addPlaceDetail(
                                CustomPrediction(
                                  title: prediction.title,
                                  placeId: prediction.placeId,
                                  description: prediction.description,
                                ),
                              );
                              if (!context.mounted) return;
                            } catch (_) {
                            } finally {
                              context.pop();
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 5),
                            decoration: BoxDecoration(
                              color: AppColors.scaffoldBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Image.asset(
                                    AppIcons.mapP,
                                    height: 25,
                                    width: 25,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        HeaderTextBlack(
                                          title: prediction.title ?? "",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        const SizedBox(height: 4),
                                        BodyTextHint(
                                          title: prediction.description ?? "",
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: BodyTextColors(
                        title: 'Start typing to search for places',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
