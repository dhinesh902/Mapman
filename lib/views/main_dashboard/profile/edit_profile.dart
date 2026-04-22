import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/model/profile_model.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
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
    phoneNumberController.text = profileData.phone?.split('91').last ?? '';
    emailAddressController.text = profileData.email ?? '';
    stateController.text = profileData.state ?? '';
    selectedState = profileData.state;
    selectedDistrict = profileData.district;
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

  String formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return DateFormat.jm().format(dt);
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
                              return CustomNetworkImage(
                                imageUrl: widget.profileData.profilePic ?? '',
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
                Row(
                  children: [
                    Expanded(
                      child: Autocomplete<String>(
                        initialValue:
                            TextEditingValue(text: stateController.text),
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return stateData.keys.where((String option) {
                            return option.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            );
                          });
                        },
                        onSelected: (String selection) {
                          setState(() {
                            selectedState = selection;
                            stateController.text = selection;
                            selectedDistrict = null;
                            districtController.clear();
                            districts = List<String>.from(
                              stateData[selection] ?? [],
                            );
                          });
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                              return CustomTextField(
                                controller: controller,
                                focusNode: focusNode,
                                onChanged: (val) =>
                                    stateController.text = val as String,
                                title: 'State',
                                hintText: "Select State",
                                inputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please select state";
                                  }
                                  return null;
                                },
                              );
                            },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                color: AppColors.whiteText,
                                constraints: const BoxConstraints(
                                  maxHeight: 200,
                                ),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final String option = options.elementAt(
                                      index,
                                    );
                                    return ListTile(
                                      title: Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.darkText,
                                        ),
                                      ),
                                      onTap: () => onSelected(option),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Autocomplete<String>(
                        initialValue:
                            TextEditingValue(text: districtController.text),
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return districts.where((String option) {
                            return option.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            );
                          });
                        },
                        onSelected: (String selection) {
                          setState(() {
                            selectedDistrict = selection;
                            districtController.text = selection;
                          });
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                              return CustomTextField(
                                controller: controller,
                                focusNode: focusNode,
                                onChanged: (val) =>
                                    districtController.text = val as String,
                                title: 'District',
                                hintText: "Select District",
                                inputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please select district";
                                  }
                                  return null;
                                },
                              );
                            },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                color: AppColors.whiteText,
                                width: MediaQuery.of(context).size.width * 0.5,
                                constraints: const BoxConstraints(
                                  maxHeight: 200,
                                ),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final String option = options.elementAt(
                                      index,
                                    );
                                    return ListTile(
                                      title: Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.darkText,
                                        ),
                                      ),
                                      onTap: () => onSelected(option),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
