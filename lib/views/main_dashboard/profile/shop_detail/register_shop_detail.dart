import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
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
  final formKey = GlobalKey<FormState>();
  late ProfileController profileController;
  late TextEditingController shopNameController,
      descriptionController,
      locationController,
      openTimeController,
      closeTimeController;

  final ValueNotifier<Map<String, File?>> profileImageNotifier = ValueNotifier({
    "photo1": null,
    "photo2": null,
  });

  @override
  void initState() {
    // TODO: implement initState
    profileController = context.read<ProfileController>();
    shopNameController = TextEditingController();
    descriptionController = TextEditingController();
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
    locationController.dispose();
    openTimeController.dispose();
    closeTimeController.dispose();

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
        appBar: ActionBar(title: 'Register Shop Details'),
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
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: openTimeController,
                    title: 'Open time',
                    suffixIcon: CupertinoIcons.clock,
                    inputAction: TextInputAction.done,
                    hintText: 'Select time',
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
                    return Row(
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
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomFullButton(
          title: 'Update Shop details',
          onTap: () {},
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

class PhotoContainer extends StatelessWidget {
  const PhotoContainer({
    super.key,
    required this.file,
    required this.image,
    required this.onTap,
    required this.clearOnTap,
  });

  final File? file;
  final String image;
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
                return PlaceHolderContainer();
              },
            ),
          ),
        ),
        if (file != null) ...[
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
