import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/model/profile_model.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/auth_screens/login_profile.dart';

import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key, required this.profileData});

  final ProfileData profileData;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final formKey = GlobalKey<FormState>();
  late ProfileController profileController;
  late TextEditingController userNameController,
      phoneNumberController,
      emailAddressController,
      stateController,
      districtController;

  Map<String, dynamic> stateData = {};
  String? selectedState;
  String? selectedDistrict;
  List<String> districts = [];

  final ValueNotifier<File?> profileImageNotifier = ValueNotifier(null);

  String? initialName;
  String? mobileNumber;
  String? initialEmail;
  String? initialState;
  String? initialDistrict;

  @override
  void initState() {
    // TODO: implement initState
    profileController = context.read<ProfileController>();
    userNameController = TextEditingController();
    phoneNumberController = TextEditingController();
    emailAddressController = TextEditingController();
    stateController = TextEditingController();
    districtController = TextEditingController();
    getProfileData();
    loadJson();
    super.initState();
  }

  Future<void> loadJson() async {
    final String response = await rootBundle.loadString(
      'assets/india_states_districts.json',
    );
    final data = json.decode(response);
    if (mounted) {
      setState(() {
        stateData = data;
        if (selectedState != null && stateData.containsKey(selectedState)) {
          districts = List<String>.from(stateData[selectedState] ?? []);
        }
      });
    }
  }

  @override
  void dispose() {
    userNameController.dispose();
    phoneNumberController.dispose();
    emailAddressController.dispose();
    stateController.dispose();
    districtController.dispose();
    profileImageNotifier.dispose();
    super.dispose();
  }

  void getProfileData() {
    final profileData = widget.profileData;
    userNameController.text = profileData.userName ?? '';
    phoneNumberController = TextEditingController(
      text: removeCountryCode(profileController.profileData.data?.phone),
    );

    emailAddressController.text = profileData.email ?? '';
    stateController.text = profileData.state ?? '';
    selectedState = (profileData.state?.isNotEmpty ?? false)
        ? profileData.state
        : null;
    selectedDistrict = (profileData.district?.isNotEmpty ?? false)
        ? profileData.district
        : null;
    districtController.text = profileData.district ?? '';

    if (selectedState != null && stateData.containsKey(selectedState)) {
      districts = List<String>.from(stateData[selectedState] ?? []);
    }

    ///initial data
    initialName = profileData.userName;
    mobileNumber = phoneNumberController.text;
    initialEmail = profileData.email;
    initialState = profileData.state;
    initialDistrict = profileData.district;
  }

  Future<void> updateProfile() async {
    final ProfileData profile = ProfileData(
      userName: userNameController.text.trim(),
      email: emailAddressController.text.trim(),
      phone: phoneNumberController.text.trim(),
      state: stateController.text.trim(),
      district: districtController.text.trim(),
      country: "India",
    );
    final response = await profileController.updateProfile(
      profileData: profile,
      image:
          profileImageNotifier.value ??
          (widget.profileData.profilePic ?? '/images'),
    );
    if (!mounted) return;
    if (response.status == Status.COMPLETED) {
      await CustomDialogues.showSuccessDialog(
        context,
        title: 'SuccessFully Updated!',
        body: 'Your profile updated successfully!',
      );
      if (!mounted) return;
      context.pop();
      await profileController.getProfile();
    } else {
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
    }
  }

  String removeCountryCode(String? phone) {
    if (phone == null || phone.isEmpty) return '';

    phone = phone.trim();

    if (phone.startsWith('+91')) {
      return phone.substring(3);
    }

    if (phone.startsWith('91') && phone.length > 10) {
      return phone.substring(2);
    }

    return phone;
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool hasChanges() {
    if (userNameController.text.trim() != initialName) return true;
    if (emailAddressController.text.trim() != initialEmail) return true;
    if (stateController.text.trim() != initialState) return true;
    if (districtController.text.trim() != initialDistrict) return true;
    if (profileImageNotifier.value != null) return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    profileController = context.watch<ProfileController>();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (!hasChanges()) {
          Navigator.pop(context);
          return;
        }

        await CustomDialogues().showUpdateReviewDialogue(
          context,
          onTap: () async {
            await updateProfile();
          },
        );
      },
      child: CustomSafeArea(
        child: Scaffold(
          backgroundColor: AppColors.scaffoldBackgroundDark,
          appBar: ActionBar(
            title: 'Edit Profile',
            onTap: () async {
              if (!hasChanges()) {
                Navigator.pop(context);
                return;
              }

              await CustomDialogues().showUpdateReviewDialogue(
                context,
                onTap: () async {
                  await updateProfile();
                },
              );
            },
          ),
          body: Form(
            key: formKey,
            child: ListView(
              padding: EdgeInsets.all(10),
              children: [
                Center(
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
                    child: Stack(
                      children: [
                        Container(
                          height: 125,
                          width: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.whiteText,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(4),
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
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CustomNetworkImage(
                                  imageUrl: widget.profileData.profilePic ?? '',
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
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
                      ],
                    ),
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
                  isReadOnly: true,
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
                SearchableDropdown(
                  title: "State",
                  hintText: "Select state",
                  items: stateData.keys.map((item) => item).toList(),
                  searchController: stateController,
                  value: selectedState,
                  onChanged: (value) {
                    setState(() {
                      selectedState = value;
                      stateController.text = value ?? '';

                      selectedDistrict = null;
                      districtController.clear();

                      districts = List<String>.from(stateData[value] ?? []);
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select state';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                SearchableDropdown(
                  title: "District",
                  hintText: "Select district",
                  items: districts,
                  value: selectedDistrict,
                  searchController: districtController,
                  onChanged: (value) {
                    setState(() {
                      selectedDistrict = value;
                      districtController.text = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select district';
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
                SizedBox(height: 30),
                if (profileController.apiResponse.status == Status.LOADING)
                  ButtonProgressBar()
                else
                  CustomFullButton(
                    title: 'Update Profile',
                    isDialogue: true,
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        await updateProfile();
                      }
                    },
                  ),
                SizedBox(height: 30),
              ],
            ),
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
