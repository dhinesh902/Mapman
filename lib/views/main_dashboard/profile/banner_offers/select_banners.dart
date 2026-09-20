import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/offer_controller.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class SelectBanners extends StatefulWidget {
  const SelectBanners({super.key});

  @override
  State<SelectBanners> createState() => _SelectBannersState();
}

class _SelectBannersState extends State<SelectBanners> {
  late OfferController offerController;

  @override
  void initState() {
    // TODO: implement initState
    offerController = context.read<OfferController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      offerController.fetchBackgroundImageData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    offerController = context.watch<OfferController>();
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(title: "Select Banner"),
        body: Builder(
          builder: (context) {
            switch (offerController.backgroundImageData.status) {
              case Status.INITIAL:
              case Status.LOADING:
                return CustomLoadingIndicator();
              case Status.COMPLETED:
                final backgroundImage =
                    offerController.backgroundImageData.data ?? [];
                return GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    mainAxisExtent: 120,
                  ),
                  itemCount: backgroundImage.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        context.pop(
                          backgroundImage[index].backgroundImage ?? '',
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CustomNetworkImage(
                          imageUrl:
                              backgroundImage[index].backgroundImage ?? '',
                        ),
                      ),
                    );
                  },
                );
              case Status.ERROR:
                return CustomErrorTextWidget(
                  title: offerController.backgroundImageData.message ?? '',
                );
            }
          },
        ),
      ),
    );
  }
}
