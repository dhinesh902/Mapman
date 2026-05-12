import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/auth_controller.dart';
import 'package:mapman/controller/home_controller.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/model/profile_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
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

  late TextEditingController userNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController emailAddressController;
  late TextEditingController stateController;
  late TextEditingController districtController;

  Map<String, dynamic> stateData = {};
  String? selectedState;
  String? selectedDistrict;
  List<String> districts = [];

  @override
  void initState() {
    super.initState();

    profileController = context.read<ProfileController>();

    userNameController = TextEditingController(
      text: profileController.profileData.data?.userName ?? '',
    );

    phoneNumberController = TextEditingController(
      text: removeCountryCode(profileController.profileData.data?.phone),
    );

    emailAddressController = TextEditingController(
      text: profileController.profileData.data?.email ?? '',
    );

    stateController = TextEditingController(
      text: profileController.profileData.data?.state ?? '',
    );

    districtController = TextEditingController(
      text: profileController.profileData.data?.district ?? '',
    );

    selectedState = stateController.text.isNotEmpty
        ? stateController.text
        : null;

    selectedDistrict = districtController.text.isNotEmpty
        ? districtController.text
        : null;

    loadJson();
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

  Future<void> loadJson() async {
    final response = await rootBundle.loadString(
      'assets/india_states_districts.json',
    );

    final data = json.decode(response);

    if (!mounted) return;

    setState(() {
      stateData = data;

      if (selectedState != null && stateData.containsKey(selectedState)) {
        districts = List<String>.from(stateData[selectedState]);
      }
    });
  }

  @override
  void dispose() {
    userNameController.dispose();
    phoneNumberController.dispose();
    emailAddressController.dispose();
    stateController.dispose();
    districtController.dispose();
    super.dispose();
  }

  Future<void> updateProfile() async {
    final profile = ProfileData(
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
      context.goNamed(AppRoutes.mainDashboard, extra: true);
    } else {
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
    }
  }

  Future<bool> checkEmailExists() async {
    final response = await context.read<AuthController>().checkEmailExists(
      email: emailAddressController.text.trim(),
    );
    if (!mounted) return false;
    if (response.status == Status.COMPLETED) {
      CustomToast.show(context, title: '${response.data}', isError: true);
      return false;
    } else {
      return true;
    }
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
        appBar: ActionBar(
          title: 'Profile Details',
          isCenterTitle: true,
          isLoginProfile: true,
        ),
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 20),

              CustomTextField(
                controller: userNameController,
                title: 'User Name',
                inputAction: TextInputAction.done,
                hintText: 'Enter user name',
                validator: (value) => value!.isEmpty ? "Enter user name" : null,
              ),

              const SizedBox(height: 15),

              CustomTextField(
                controller: phoneNumberController,
                isReadOnly: true,
                inputType: TextInputType.number,
                inputAction: TextInputAction.done,
                maxLength: 10,
                title: 'Register Number',
                hintText: 'Phone number',
                validator: (value) {
                  if (value!.isEmpty) return "Enter phone number";
                  if (value.length != 10) return "Enter 10 digit number";
                  return null;
                },
              ),

              const SizedBox(height: 15),

              Autocomplete<String>(
                initialValue: TextEditingValue(text: stateController.text),
                optionsBuilder: (value) {
                  if (value.text.isEmpty) return const Iterable.empty();

                  return stateData.keys.where(
                    (state) =>
                        state.toLowerCase().contains(value.text.toLowerCase()),
                  );
                },
                onSelected: (selection) {
                  setState(() {
                    selectedState = selection;
                    stateController.text = selection;
                    selectedDistrict = null;
                    districtController.clear();
                    districts = List<String>.from(stateData[selection] ?? []);
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, _) {
                  return CustomTextField(
                    controller: controller,
                    focusNode: focusNode,
                    inputAction: TextInputAction.done,
                    title: 'State',
                    hintText: 'Select State',
                    onChanged: (val) => stateController.text = val as String,
                    validator: (value) =>
                        value!.isEmpty ? "Select state" : null,
                  );
                },
              ),
              const SizedBox(height: 15),
              Autocomplete<String>(
                initialValue: TextEditingValue(text: districtController.text),
                optionsBuilder: (value) {
                  if (value.text.isEmpty) return const Iterable.empty();

                  return districts.where(
                    (district) => district.toLowerCase().contains(
                      value.text.toLowerCase(),
                    ),
                  );
                },
                onSelected: (selection) {
                  setState(() {
                    selectedDistrict = selection;
                    districtController.text = selection;
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, _) {
                  return CustomTextField(
                    controller: controller,
                    focusNode: focusNode,
                    inputAction: TextInputAction.done,
                    title: 'District',
                    hintText: 'Select District',
                    onChanged: (val) => districtController.text = val as String,
                    validator: (value) =>
                        value!.isEmpty ? "Select district" : null,
                  );
                },
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: emailAddressController,
                title: 'Email Address',
                hintText: 'Enter email',
                inputType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                validator: (value) {
                  if (value!.isEmpty) return "Enter email";
                  if (!isValidEmail(value.trim())) {
                    return "Invalid email";
                  }
                  return null;
                },
                inputAction: TextInputAction.done,
              ),

              const SizedBox(height: 40),

              profileController.apiResponse.status == Status.LOADING ||
                      context.watch<AuthController>().apiResponse.status ==
                          Status.LOADING
                  ? const ButtonProgressBar()
                  : CustomFullButton(
                      title: 'Update Profile',
                      isDialogue: true,
                      onTap: () async {
                        if (formKey.currentState!.validate()) {
                          bool isEmailExists = await checkEmailExists();
                          if (isEmailExists) {
                            context.read<HomeController>().setCurrentPage = 0;
                            await updateProfile();
                          }
                        }
                      },
                    ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
