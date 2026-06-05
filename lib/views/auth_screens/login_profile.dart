import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/home_controller.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/model/profile_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
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
              const SizedBox(height: 15),
              CustomTextField(
                controller: emailAddressController,
                title: 'Email Address',
                hintText: 'Enter email',
                inputType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                validator: (value) {
                  if (value != null && value.isNotEmpty && !isValidEmail(value.trim())) {
                    return "Invalid email";
                  }
                  return null;
                },
                inputAction: TextInputAction.done,
              ),
              const SizedBox(height: 40),
              profileController.apiResponse.status == Status.LOADING
                  ? const ButtonProgressBar()
                  : CustomFullButton(
                      title: 'Update Profile',
                      isDialogue: true,
                      onTap: () async {
                        if (formKey.currentState!.validate()) {
                          context.read<HomeController>().setCurrentPage = 0;
                          await updateProfile();
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

class SearchableDropdown extends StatelessWidget {
  final String title;
  final String hintText;
  final String? value;
  final List<String> items;
  final TextEditingController searchController;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const SearchableDropdown({
    super.key,
    required this.title,
    required this.hintText,
    required this.items,
    required this.searchController,
    required this.onChanged,
    this.value,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      title: title,
      child: DropdownButtonFormField2<String>(
        value: value,
        isExpanded: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: AppTextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ).textStyle,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFB3B5B7),
          ).textStyle,
          fillColor: AppColors.whiteText,
          filled: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: value == null ? 15 : 0,
            vertical: 15,
          ),
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
        items: items
            .map(
              (item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            )
            .toList(),
        validator: validator,
        onChanged: onChanged,
        dropdownStyleData: DropdownStyleData(
          decoration: BoxDecoration(color: AppColors.whiteText),
        ),
        dropdownSearchData: DropdownSearchData(
          searchController: searchController,
          searchInnerWidgetHeight: 60,
          searchInnerWidget: Container(
            height: 60,
            color: AppColors.whiteText,
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: searchController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                isDense: true,
                fillColor: AppColors.whiteText,
                filled: true,
                hintText: 'Search...',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SvgPicture.asset(
                    AppIcons.search,
                    colorFilter: ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                hintStyle: AppTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGrey,
                ).textStyle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: GenericColors.borderGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: GenericColors.borderGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          searchMatchFn: (item, searchValue) {
            return item.value!.toLowerCase().contains(
              searchValue.toLowerCase(),
            );
          },
        ),
        onMenuStateChange: (isOpen) {
          if (!isOpen) {
            searchController.clear();
          }
        },
      ),
    );
  }
}
