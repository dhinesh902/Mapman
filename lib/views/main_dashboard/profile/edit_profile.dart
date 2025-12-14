import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final formKey = GlobalKey<FormState>();
  late ProfileController profileController;
  late TextEditingController userNameController,
      phoneNumberController,
      emailAddressController;

  final ValueNotifier<File?> profileImageNotifier = ValueNotifier(null);

  @override
  void initState() {
    // TODO: implement initState
    profileController = context.read<ProfileController>();
    userNameController = TextEditingController();
    phoneNumberController = TextEditingController();
    emailAddressController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    userNameController.dispose();
    phoneNumberController.dispose();
    emailAddressController.dispose();
    super.dispose();
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return DateFormat.jm().format(dt);
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    profileController = context.watch<ProfileController>();
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(title: 'Edit Profile'),
        body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.all(10),
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      height: 125,
                      width: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: ValueListenableBuilder(
                        valueListenable: profileImageNotifier,
                        builder: (context, file, _) {
                          if (file != null) {
                            return Image.file(
                              File(file.path),
                              fit: BoxFit.cover,
                            );
                          }
                          return const CustomNetworkImage(
                            imageUrl:
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQkAJEkJQ1WumU0hXNpXdgBt9NUKc0QDVIiaw&s',
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          CustomImagePicker.showImagePicker(
                            context,
                            cameraOnTap: () {
                              _pickImage(ImageSource.camera);
                              Navigator.pop(context);
                            },
                            galleryOnTap: () {
                              _pickImage(ImageSource.gallery);
                              Navigator.pop(context);
                            },
                          );
                        },
                        child: Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Center(
                            child: SvgPicture.asset(AppIcons.editOutline),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              CustomTextField(
                controller: userNameController,
                title: 'User Name',
                hintText: 'Enter user name',
                inputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter user name";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              CustomTextField(
                controller: phoneNumberController,
                inputType: TextInputType.number,
                maxLength: 10,
                title: 'Register Number',
                hintText: 'Enter register number',
                inputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter register phone number";
                  }
                  if (value.length != 10) {
                    return "Please enter 10 digit register phone number";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              CustomTextField(
                controller: emailAddressController,
                title: 'Email Address',
                hintText: 'Enter email address',
                inputType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                inputAction: TextInputAction.done,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter email address";
                  }
                  if (!isValidEmail(value.trim())) {
                    return "Please enter valid email address";
                  }
                  return null;
                },
              ),
              SizedBox(height: 50),
              CustomFullButton(
                title: 'Update Profile',
                isDialogue: true,
                onTap: () {
                  if (formKey.currentState!.validate()) {}
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final croppedFile = await CustomImageCropper.cropImage(pickedFile.path);
        if (croppedFile != null) {
          profileImageNotifier.value = File(croppedFile.path);
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }
}
