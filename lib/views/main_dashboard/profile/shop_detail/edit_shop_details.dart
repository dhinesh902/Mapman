import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/model/shop_detail_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/main_dashboard/profile/shop_detail/register_shop_detail.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
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
  final formKey = GlobalKey<FormState>();
  late ProfileController profileController;
  late TextEditingController shopNameController,
      descriptionController,
      locationController,
      openTimeController,
      phoneNumberController,
      shopNumberController,
      closeTimeController;

  final ValueNotifier<Map<String, File?>> profileImageNotifier = ValueNotifier({
    "photo1": null,
    "photo2": null,
    "photo3": null,
    "photo4": null,
  });

  @override
  void initState() {
    // TODO: implement initState
    profileController = context.read<ProfileController>();
    shopNameController = TextEditingController();
    descriptionController = TextEditingController();
    phoneNumberController = TextEditingController();
    shopNumberController = TextEditingController();
    locationController = TextEditingController();
    openTimeController = TextEditingController();
    closeTimeController = TextEditingController();
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
    profileImageNotifier.dispose();

    super.dispose();
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return DateFormat.jm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
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
        body: ListView(
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
                child: PlaceHolderContainer(isText: true),
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
              dropdownValue: null,
              items: ["Bars", "Hospital"],
              onChanged: (value) {},
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
              onTap: () {
                context.pushNamed(AppRoutes.enterLocation);
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
                        closeTimeController.text = formatTimeOfDay(pickedTime);
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
                  valueListenable: profileImageNotifier,
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
                                      _pickImage('photo1', ImageSource.camera);
                                      Navigator.pop(context);
                                    },
                                    galleryOnTap: () {
                                      _pickImage('photo1', ImageSource.gallery);
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
                                      _pickImage('photo2', ImageSource.camera);
                                      Navigator.pop(context);
                                    },
                                    galleryOnTap: () {
                                      _pickImage('photo2', ImageSource.gallery);
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
                                      _pickImage('photo3', ImageSource.camera);
                                      Navigator.pop(context);
                                    },
                                    galleryOnTap: () {
                                      _pickImage('photo3', ImageSource.gallery);
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
                                      _pickImage('photo4', ImageSource.camera);
                                      Navigator.pop(context);
                                    },
                                    galleryOnTap: () {
                                      _pickImage('photo4', ImageSource.gallery);
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
        bottomNavigationBar: CustomFullButton(
          title: 'Update Shop details',
          onTap: () async {
            if (formKey.currentState!.validate()) {}
          },
        ),
      ),
    );
  }

  void removeImage(String photoKey) {
    profileImageNotifier.value = {
      ...profileImageNotifier.value,
      photoKey: null,
    };
  }

  Future<void> _pickImage(String photoKey, ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final croppedFile = await CustomImageCropper.cropImage(pickedFile.path);
        if (croppedFile != null) {
          profileImageNotifier.value = {
            ...profileImageNotifier.value,
            photoKey: File(croppedFile.path),
          };
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }
}
