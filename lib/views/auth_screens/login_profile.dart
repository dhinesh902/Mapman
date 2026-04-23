import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/model/profile_model.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class LoginProfile extends StatefulWidget {
  const LoginProfile({super.key});

  @override
  State<LoginProfile> createState() => _LoginProfileState();
}

class _LoginProfileState extends State<LoginProfile> {
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

  @override
  void initState() {
    // TODO: implement initState
    profileController = context.read<ProfileController>();
    userNameController = TextEditingController();
    phoneNumberController = TextEditingController(
      text: profileController.profileData.data?.phone?.split('91').last ?? '',
    );
    emailAddressController = TextEditingController();
    stateController = TextEditingController();
    districtController = TextEditingController();
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
    emailAddressController.dispose();
    stateController.dispose();
    districtController.dispose();
    super.dispose();
  }

  Future<void> updateProfile() async {
    final ProfileData profile = ProfileData(
      userName: userNameController.text.trim(),
      email: emailAddressController.text.trim(),
      phone: profileController.profileData.data?.phone,
      state: stateController.text.trim(),
      district: districtController.text.trim(),
      country: "India",
    );
    final response = await profileController.updateProfile(
      profileData: profile,
      image: profileController.profileData.data?.profilePic ?? '/images',
    );
    if (!mounted) return;
    if (response.status == Status.COMPLETED) {
    } else {
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
    }
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    profileController = context.read<ProfileController>();
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(title: 'Profile Details', onTap: () {}),
        body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.all(10),
            children: [
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
              Autocomplete<String>(
                initialValue: TextEditingValue(text: stateController.text),
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
                    districts = List<String>.from(stateData[selection] ?? []);
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
                        width: MediaQuery.of(context).size.width,
                        color: AppColors.whiteText,
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final String option = options.elementAt(index);
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
              SizedBox(height: 15),
              Autocomplete<String>(
                initialValue: TextEditingValue(text: districtController.text),
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
                        width: MediaQuery.of(context).size.width,
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final String option = options.elementAt(index);
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
    );
  }
}
