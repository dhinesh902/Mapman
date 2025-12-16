import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mapman/controller/home_controller.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/model/shop_detail_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/main_dashboard/profile/shop_detail/register_shop_detail.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:mapman/views/widgets/custom_drop_downs.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:mapman/views/widgets/custom_time_picker.dart';
import 'package:provider/provider.dart';

class EditShopDetail extends StatefulWidget {
  const EditShopDetail({super.key, required this.shopDetailData});

  final ShopDetailData shopDetailData;

  @override
  State<EditShopDetail> createState() => _EditShopDetailState();
}

class _EditShopDetailState extends State<EditShopDetail> {
  late ProfileController profileController;
  late HomeController homeController;

  late ShopDetailData shopDetailData;

  final formKey = GlobalKey<FormState>();
  late TextEditingController shopNameController,
      descriptionController,
      locationController,
      openTimeController,
      phoneNumberController,
      shopNumberController,
      closeTimeController;

  final ValueNotifier<File?> shopImageNotifier = ValueNotifier(null);

  final ValueNotifier<Map<String, File?>> shopImagesNotifier = ValueNotifier({
    "photo1": null,
    "photo2": null,
    "photo3": null,
    "photo4": null,
  });

  @override
  void initState() {
    // TODO: implement initState
    shopDetailData = widget.shopDetailData;
    homeController = context.read<HomeController>();
    profileController = context.read<ProfileController>();
    shopNameController = TextEditingController();
    descriptionController = TextEditingController();
    phoneNumberController = TextEditingController();
    shopNumberController = TextEditingController();
    locationController = TextEditingController();
    openTimeController = TextEditingController();
    closeTimeController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.setSelectedLatLong = null;
      getShopDetails();
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    shopNameController.dispose();
    descriptionController.dispose();
    phoneNumberController.dispose();
    locationController.dispose();
    openTimeController.dispose();
    closeTimeController.dispose();
    shopNumberController.dispose();
    shopImagesNotifier.dispose();

    super.dispose();
  }

  void getShopDetails() {
    shopNameController.text = shopDetailData.shopName ?? '';
    descriptionController.text = shopDetailData.description ?? '';
    phoneNumberController.text = shopDetailData.registerNumber ?? '';
    shopNumberController.text = shopDetailData.shopNumber ?? '';
    locationController.text = shopDetailData.address ?? '';
    openTimeController.text = shopDetailData.openTime ?? '';
    closeTimeController.text = shopDetailData.closeTime ?? '';
    homeController.setSelectedCategory = shopDetailData.category ?? '';
    profileController.setShopImages = [
      shopDetailData.image1,
      shopDetailData.image2,
      shopDetailData.image3,
      shopDetailData.image4,
    ];
  }

  Future<void> updateShopDetail() async {
    final shopImages = ShopDetailImages(
      shopImage: shopDetailData.shopImage == null
          ? shopImageNotifier.value
          : null,
      image1: profileController.shopImages[0] == null
          ? shopImagesNotifier.value['photo1']
          : null,
      image2: profileController.shopImages[1] == null
          ? shopImagesNotifier.value['photo2']
          : null,
      image3: profileController.shopImages[2] == null
          ? shopImagesNotifier.value['photo3']
          : null,
      image4: profileController.shopImages[3] == null
          ? shopImagesNotifier.value['photo4']
          : null,
    );

    final lat =
        shopDetailData.lat ??
        profileController.selectedLatLong?.latitude.toString();

    final lng =
        shopDetailData.long ??
        profileController.selectedLatLong?.longitude.toString();

    final shopDetail = ShopDetailData(
      shopName: shopNameController.text.trim(),
      category: homeController.category,
      description: descriptionController.text.trim(),
      address: locationController.text.trim(),
      registerNumber: phoneNumberController.text.trim(),
      shopNumber: shopNumberController.text.trim(),
      openTime: openTimeController.text.trim(),
      closeTime: closeTimeController.text.trim(),
      lat: lat ?? '',
      long: lng ?? '',
    );

    final response = await profileController.registerShop(
      shopImages: shopImages,
      shopDetail: shopDetail,
    );
    if (!mounted) return;
    if (response.status == Status.COMPLETED) {
      await CustomDialogues.showSuccessDialog(
        context,
        title: 'Successfully Updated!',
        body: 'Your shop details have been updated successfully.',
      );
      if (!mounted) return;
      context.pop();
      await profileController.getShopDetail();
    } else {
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
    }
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return DateFormat.jm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    homeController = context.watch<HomeController>();
    profileController = context.watch<ProfileController>();
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(
          title: 'Edit Shop Details',
          action: TextButton(
            onPressed: () {
              context.pushNamed(AppRoutes.analytics);
            },
            child: Row(
              children: [
                SvgPicture.asset(
                  AppIcons.eye,
                  height: 12,
                  colorFilter: ColorFilter.mode(
                    GenericColors.darkGreen,
                    BlendMode.srcIn,
                  ),
                ),
                BodyTextColors(
                  title: 'analytics',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: GenericColors.darkGreen,
                  textDecoration: TextDecoration.underline,
                  decorationColor: GenericColors.darkGreen,
                ),
              ],
            ),
          ),
        ),
        body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.all(10),
            children: [
              Center(
                child: Container(
                  height: 125,
                  width: 160,
                  decoration: BoxDecoration(
                    color: GenericColors.placeHolderGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: ValueListenableBuilder(
                    valueListenable: shopImageNotifier,
                    builder: (context, file, _) {
                      if (file != null) {
                        return Image.file(File(file.path), fit: BoxFit.cover);
                      }
                      return CustomNetworkImage(
                        imageUrl: shopDetailData.shopImage ?? '',
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              CustomTextField(
                controller: shopNameController,
                title: 'Shop Name',
                hintText: 'Enter shop name',
                inputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter shop name";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              CustomDropDownField(
                title: "Category",
                dropdownValue: homeController.category,
                items: homeController.categories,
                onChanged: (value) {
                  homeController.setSelectedCategory = value;
                },
                hintText: "Select category",
                validator: (value) {
                  if (value == null) {
                    return "Please select category";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              CustomTextField(
                controller: locationController,
                title: 'Location',
                hintText: 'Drop Your Location',
                inputAction: TextInputAction.done,
                onTap: () async {
                  final result = await context.pushNamed(
                    AppRoutes.enterLocation,
                  );
                  if (result != null && result is Map) {
                    final String address = result['address'] as String;
                    final LatLng latLng = result['latlong'] as LatLng;
                    locationController.text = address;
                    profileController.setSelectedLatLong = latLng;
                  }
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter shop address";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              CustomTextField(
                controller: descriptionController,
                title: 'Description',
                hintText: 'Enter description',
                inputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter description";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              CustomTextField(
                controller: phoneNumberController,
                title: 'Register Number',
                hintText: 'Enter register number',
                inputType: TextInputType.number,
                maxLength: 10,
                inputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter register number";
                  }
                  if (value.length != 10) {
                    return "Please enter 10 register number";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              CustomTextField(
                controller: shopNumberController,
                isSameRegisterNumber: true,
                inputType: TextInputType.number,
                maxLength: 10,
                isActive: profileController.isActive,
                onChanged: (value) {
                  profileController.setIsActive = value!;
                },
                title: 'Public/Shop Contact Number',
                hintText: 'Enter shop contact number',
                inputAction: TextInputAction.done,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter shop contact number";
                  }
                  if (value.length != 10) {
                    return "Please enter 10 digit phone number";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: openTimeController,
                      title: 'Open time',
                      suffixIcon: CupertinoIcons.clock,
                      inputAction: TextInputAction.done,
                      hintText: 'Select time',
                      isReadOnly: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please select open time";
                        }
                        return null;
                      },
                      onTap: () async {
                        TimeOfDay? pickedTime =
                            await CustomTimePicker.pickReturnTime(context);
                        if (pickedTime != null) {
                          openTimeController.text = formatTimeOfDay(pickedTime);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: CustomTextField(
                      controller: closeTimeController,
                      suffixIcon: CupertinoIcons.clock,
                      title: 'Close time',
                      hintText: 'Select time',
                      inputAction: TextInputAction.done,
                      isReadOnly: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please select close time";
                        }
                        return null;
                      },
                      onTap: () async {
                        TimeOfDay? pickedTime =
                            await CustomTimePicker.pickReturnTime(context);
                        if (pickedTime != null) {
                          closeTimeController.text = formatTimeOfDay(
                            pickedTime,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              CustomContainer(
                title: 'Upload Photo (You can upto 2 photos)',
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ValueListenableBuilder<Map<String, File?>>(
                    valueListenable: shopImagesNotifier,
                    builder: (context, map, child) {
                      final file1 = map["photo1"];
                      final file2 = map["photo2"];
                      final file3 = map["photo3"];
                      final file4 = map["photo4"];
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: PhotoContainer(
                                  image: profileController.shopImages[0],
                                  file: file1,
                                  clearOnTap: () {
                                    profileController.removeShopImageAt(0);
                                    removeImage('photo1');
                                  },
                                  onTap: () {
                                    CustomImagePicker.showImagePicker(
                                      context,
                                      cameraOnTap: () {
                                        _pickImage(
                                          'photo1',
                                          ImageSource.camera,
                                        );
                                        Navigator.pop(context);
                                      },
                                      galleryOnTap: () {
                                        _pickImage(
                                          'photo1',
                                          ImageSource.gallery,
                                        );
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: PhotoContainer(
                                  image: profileController.shopImages[1],
                                  file: file2,
                                  clearOnTap: () {
                                    profileController.removeShopImageAt(1);
                                    removeImage('photo2');
                                  },
                                  onTap: () {
                                    CustomImagePicker.showImagePicker(
                                      context,
                                      cameraOnTap: () {
                                        _pickImage(
                                          'photo2',
                                          ImageSource.camera,
                                        );
                                        Navigator.pop(context);
                                      },
                                      galleryOnTap: () {
                                        _pickImage(
                                          'photo2',
                                          ImageSource.gallery,
                                        );
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: PhotoContainer(
                                  image: profileController.shopImages[2],
                                  file: file3,
                                  clearOnTap: () {
                                    profileController.removeShopImageAt(2);
                                    removeImage('photo3');
                                  },
                                  onTap: () {
                                    CustomImagePicker.showImagePicker(
                                      context,
                                      cameraOnTap: () {
                                        _pickImage(
                                          'photo3',
                                          ImageSource.camera,
                                        );
                                        Navigator.pop(context);
                                      },
                                      galleryOnTap: () {
                                        _pickImage(
                                          'photo3',
                                          ImageSource.gallery,
                                        );
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: PhotoContainer(
                                  image: profileController.shopImages[3],
                                  file: file4,
                                  clearOnTap: () {
                                    profileController.removeShopImageAt(3);
                                    removeImage('photo4');
                                  },
                                  onTap: () {
                                    CustomImagePicker.showImagePicker(
                                      context,
                                      cameraOnTap: () {
                                        _pickImage(
                                          'photo4',
                                          ImageSource.camera,
                                        );
                                        Navigator.pop(context);
                                      },
                                      galleryOnTap: () {
                                        _pickImage(
                                          'photo4',
                                          ImageSource.gallery,
                                        );
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            profileController.apiResponse.status == Status.LOADING
                ? ButtonProgressBar()
                : CustomFullButton(
                    title: 'Update Shop details',
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        await updateShopDetail();
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void removeImage(String photoKey) {
    shopImagesNotifier.value = {...shopImagesNotifier.value, photoKey: null};
  }

  Future<void> _pickImage(String photoKey, ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final croppedFile = await CustomImageCropper.cropImage(pickedFile.path);
        if (croppedFile != null) {
          shopImagesNotifier.value = {
            ...shopImagesNotifier.value,
            photoKey: File(croppedFile.path),
          };
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }
}
