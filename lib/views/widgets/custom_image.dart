import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/constants/themes.dart';

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.placeHolderHeight = 36,
    this.isProfile = false,
  });

  final String imageUrl;
  final double placeHolderHeight;
  final bool isProfile;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: ApiRoutes.baseUrl + imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: GenericColors.placeHolderGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.hardEdge,
          child: Center(
            child: isProfile
                ? Image.asset(AppIcons.profilePlaceholderP)
                : SvgPicture.asset(AppIcons.galleryPlaceholder),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return Container(
          decoration: BoxDecoration(
            color: GenericColors.placeHolderGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.hardEdge,
          child: Center(
            child: isProfile
                ? Image.asset(AppIcons.profilePlaceholderP)
                : SvgPicture.asset(AppIcons.galleryPlaceholder),
          ),
        );
      },
    );
  }
}

class PlaceHolderContainer extends StatelessWidget {
  const PlaceHolderContainer({super.key, this.isText = false});

  final bool isText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(AppIcons.galleryPlaceholder),
          if (isText) ...[
            SizedBox(height: 10),
            BodyTextHint(
              title: 'Add shop Image',
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
          ],
        ],
      ),
    );
  }
}

class CustomImageCropper {
  static Future<CroppedFile?> cropImage(
    String imagePath, {
    bool isProfile = false,
  }) async {
    try {
      return await ImageCropper().cropImage(
        sourcePath: imagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Mapman',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: AppColors.whiteText,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            cropStyle: isProfile ? CropStyle.circle : CropStyle.rectangle,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }
}

class CustomImagePicker {
  static Future<void> showImagePicker(
    BuildContext context, {
    required VoidCallback cameraOnTap,
    required VoidCallback galleryOnTap,
  }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                width: MediaQuery.of(context).size.width,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: Themes.searchFieldDecoration(),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        visualDensity: VisualDensity(vertical: -2),
                        leading: SvgPicture.asset(
                          AppIcons.camera,
                          colorFilter: ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        title: HeaderTextBlack(
                          title: 'Take Picture',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        onTap: cameraOnTap,
                      ),
                      ListTile(
                        visualDensity: VisualDensity(vertical: -2),
                        leading: SvgPicture.asset(
                          AppIcons.gallery,
                          colorFilter: ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        title: HeaderTextBlack(
                          title: 'Choose Photo',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        onTap: galleryOnTap,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
