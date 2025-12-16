import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/utils/storage/session_manager.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:mapman/views/widgets/custom_drop_downs.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:mapman/views/widgets/custom_time_picker.dart';
import 'package:provider/provider.dart';

class RegisterShopDetail extends StatefulWidget {
  const RegisterShopDetail({super.key});

  @override
  State<RegisterShopDetail> createState() => _RegisterShopDetailState();
}

class _RegisterShopDetailState extends State<RegisterShopDetail> {
  late HomeController homeController;
  late ProfileController profileController;

  final formKey = GlobalKey<FormState>();
  late TextEditingController shopNameController,
      descriptionController,
      locationController,
      openTimeController,
      phoneNumberController,
      shopNumberController,
      closeTimeController;

  final ValueNotifier<File?> shopImageNotifier = ValueNotifier(null);
  final ValueNotifier<bool> shopImageValidator = ValueNotifier<bool>(false);

  final ValueNotifier<Map<String, File?>> shopImagesNotifier = ValueNotifier({
    "photo1": null,
    "photo2": null,
    "photo3": null,
    "photo4": null,
  });

  @override
  void initState() {
    // TODO: implement initState
    homeController = context.read<HomeController>();
    profileController = context.read<ProfileController>();

    shopNameController = TextEditingController();
    descriptionController = TextEditingController();
    phoneNumberController = TextEditingController(
      text: SessionManager.getMobile() ?? '',
    );
    shopNumberController = TextEditingController();
    locationController = TextEditingController();
    openTimeController = TextEditingController();
    closeTimeController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.setSelectedCategory = null;
      profileController.setSelectedLatLong = null;
      profileController.setIsActive = false;
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

  Future<void> registerShop() async {
    final shopImages = ShopDetailImages(
      shopImage: shopImageNotifier.value,
      image1: shopImagesNotifier.value['photo1'],
      image2: shopImagesNotifier.value['photo2'],
      image3: shopImagesNotifier.value['photo3'],
      image4: shopImagesNotifier.value['photo4'],
    );
    final shopDetail = ShopDetailData(
      shopName: shopNameController.text.trim(),
      category: homeController.category,
      description: descriptionController.text.trim(),
      address: locationController.text.trim(),
      registerNumber: phoneNumberController.text.trim(),
      shopNumber: shopNumberController.text.trim(),
      openTime: openTimeController.text.trim(),
      closeTime: closeTimeController.text.trim(),
      lat: '${profileController.selectedLatLong?.latitude}',
      long: '${profileController.selectedLatLong?.longitude}',
    );
    final response = await profileController.registerShop(
      shopImages: shopImages,
      shopDetail: shopDetail,
    );
    if (!mounted) return;
    if (response.status == Status.COMPLETED) {
      await CustomDialogues.showSuccessDialog(
        context,
        title: 'SuccessFully Updated!',
        body: 'Your shop has been registered successfully',
      );
      if (!mounted) return;
      context.pop();
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
        appBar: ActionBar(title: 'Register Shop Details'),
        body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.all(10),
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    CustomImagePicker.showImagePicker(
                      context,
                      cameraOnTap: () {
                        _pickShopImage(ImageSource.camera);
                        Navigator.pop(context);
                      },
                      galleryOnTap: () {
                        _pickShopImage(ImageSource.gallery);
                        Navigator.pop(context);
                      },
                    );
                  },
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
                        return PlaceHolderContainer(isText: true);
                      },
                    ),
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
                  if (value) {
                    shopNumberController.text =
                        SessionManager.getMobile() ?? '';
                  } else {
                    shopNumberController.clear();
                  }
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
                                  image: "",
                                  file: file1,
                                  clearOnTap: () {
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
                                  image: "",
                                  file: file2,
                                  clearOnTap: () {
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
                                  image: "",
                                  file: file3,
                                  clearOnTap: () {
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
                                  image: "",
                                  file: file4,
                                  clearOnTap: () {
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
                        await registerShop();
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

  Future<void> _pickShopImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final croppedFile = await CustomImageCropper.cropImage(pickedFile.path);
        if (croppedFile != null) {
          shopImageNotifier.value = File(croppedFile.path);
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }
}

class PhotoContainer extends StatelessWidget {
  const PhotoContainer({
    super.key,
    required this.file,
    required this.image,
    required this.onTap,
    required this.clearOnTap,
  });

  final File? file;
  final String? image;
  final VoidCallback onTap, clearOnTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: file == null ? onTap : null,
          child: Container(
            height: 126,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: GenericColors.placeHolderGrey,
              borderRadius: BorderRadiusGeometry.circular(5),
            ),
            child: Builder(
              builder: (context) {
                if (file != null) {
                  return Image.file(File(file!.path));
                }
                if (image != null) {
                  return CustomNetworkImage(imageUrl: image!);
                }
                return PlaceHolderContainer();
              },
            ),
          ),
        ),
        if (file != null || image != null) ...[
          Positioned(
            top: 0,
            right: 0,
            child: ClearCircleContainer(onTap: clearOnTap),
          ),
        ],
      ],
    );
  }
}
