import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapman/controller/auth_controller.dart';
import 'package:mapman/controller/home_controller.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/model/profile_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/utils/storage/session_manager.dart';
import 'package:mapman/views/auth_screens/onboard.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:phone_number_hint/phone_number_hint.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:smart_auth/smart_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final ScrollController _scrollController = ScrollController();

  bool _scrollingDown = true;

  List<Widget> screens = [
    MobileOrGoogleSignIn(),
    MobileNumberScreen(),
    OTPScreen(),
    ProfileUpdation(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
      final profile = context.read<ProfileController>().profileData.data;
      if (profile != null &&
          (profile.userName == null ||
              profile.userName!.isEmpty ||
              profile.district == null ||
              profile.district!.isEmpty ||
              profile.state == null ||
              profile.state!.isEmpty)) {
        context.read<AuthController>().jumpTo(3);
      }
    });
  }

  void _startAutoScroll() async {
    while (mounted) {
      if (!_scrollController.hasClients) continue;
      final max = _scrollController.position.maxScrollExtent;
      final min = _scrollController.position.minScrollExtent;
      if (_scrollingDown) {
        await _scrollController.animateTo(
          max,
          duration: const Duration(seconds: 4),
          curve: Curves.linear,
        );
      } else {
        await _scrollController.animateTo(
          min,
          duration: const Duration(seconds: 4),
          curve: Curves.linear,
        );
      }
      _scrollingDown = !_scrollingDown;
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    return CustomSafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalHeight = constraints.maxHeight;
          final gridHeight = totalHeight * 0.55;
          final pageViewHeight = totalHeight * 0.45;
          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: gridHeight,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1,
                                mainAxisExtent: 135,
                              ),
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: authController.loginImages.length,
                          itemBuilder: (_, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                authController.loginImages[index],
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),

                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: BlurContainer(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: pageViewHeight,
                    child: PageView.builder(
                      controller: authController.pageController,
                      itemCount: screens.length,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: authController.onPageChanged,
                      itemBuilder: (context, index) => screens[index],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Mobile Or Google Sign

class MobileOrGoogleSignIn extends StatefulWidget {
  const MobileOrGoogleSignIn({super.key});

  @override
  State<MobileOrGoogleSignIn> createState() => _MobileOrGoogleSignInState();
}

class _MobileOrGoogleSignInState extends State<MobileOrGoogleSignIn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBackgroundDark,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Image.asset(AppIcons.mapmanP, fit: BoxFit.cover),
                ),
                HeaderTextBlack(
                  title: 'Map Man',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            SizedBox(height: 15),
            CustomOutlineButtonWithImage(
              title: 'Continue with Mobile',
              isGoogle: false,
              icon: AppIcons.phoneP,
              onTap: () {
                context.read<AuthController>().animateTo(1);
              },
            ),

            SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: Divider(color: GenericColors.borderGrey)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: BodyTextHint(
                    title: 'OR',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Expanded(child: Divider(color: GenericColors.borderGrey)),
              ],
            ),
            SizedBox(height: 15),
            CustomOutlineButtonWithImage(
              title: 'Continue with Google',
              icon: AppIcons.google,
              onTap: () {
                CustomToast.show(
                  context,
                  title: 'This feature is currently unavailable',
                  isError: true,
                );
              },
            ),
            SizedBox(height: 20),
            BodyTextHint(
              title: 'By Continuing you agree to Mapman',
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
            SizedBox(height: 15),
            InkWell(
              onTap: () {
                context.pushNamed(AppRoutes.termsAndConditions);
              },
              child: HeaderTextPrimary(
                title: 'Terms and Conditions',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                textDecoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mobile Number Screen

class MobileNumberScreen extends StatefulWidget {
  const MobileNumberScreen({super.key});

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {
  late AuthController authController;

  final FocusNode _focusNode = FocusNode();
  final _phoneNumberHintPlugin = PhoneNumberHint();

  late TextEditingController mobileNumberController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    authController = context.read<AuthController>();
    mobileNumberController = TextEditingController();
    getPhoneNumber();
    super.initState();
  }

  @override
  void dispose() {
    mobileNumberController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> getPhoneNumber() async {
    if (!Platform.isAndroid) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _focusNode.requestFocus();
      });
      return;
    }
    String? result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      result = await _phoneNumberHintPlugin.requestHint() ?? '';
      if (result.isNotEmpty) {
        mobileNumberController.text = formatPhoneNumberWithoutCountryCode(
          result,
        );
      }
    } on PlatformException {
      result = 'Failed to get hint.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      if (result != null && result.isEmpty) {
        Future.delayed(Duration(milliseconds: 500), () {
          _focusNode.requestFocus();
        });
      }
    });
  }

  String formatPhoneNumberWithoutCountryCode(String phone) {
    String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 10) {
      digits = digits.substring(digits.length - 10);
    }
    return digits;
  }

  Future<void> sendOTP() async {
    final response = await authController.sendOTP(
      phoneNumber: '91${mobileNumberController.text.trim()}',
    );
    if (!mounted) return;
    if (response.status == Status.COMPLETED) {
      if (!mounted) return;
      SessionManager.setMobile(phone: mobileNumberController.text.trim());
      CustomToast.show(context, title: '${response.data}');
      context.read<AuthController>().animateTo(2);
    } else {
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
    }
  }

  // Future<void> sendOTP() async {
  //   final response = await authController.sendMailOTP(
  //     email: emailController.text.trim(),
  //   );
  //   if (!mounted) return;
  //   if (response.status == Status.COMPLETED) {
  //     if (!mounted) return;
  //     SessionManager.setEmail(email: emailController.text.trim());
  //     CustomToast.show(context, title: '${response.data}');
  //     context.read<AuthController>().animateTo(2);
  //   } else {
  //     ExceptionHandler.handleUiException(
  //       context: context,
  //       status: response.status,
  //       message: response.message,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    authController = context.watch<AuthController>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      color: AppColors.scaffoldBackgroundDark,
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AuthBackButton(),
                  SizedBox(width: 30),
                  HeaderTextBlack(
                    title: 'Back',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              SizedBox(height: 30),

              CustomMobileNumberTextField(
                controller: mobileNumberController,
                textInputType: TextInputType.phone,
                maxLength: 10,
                focusNode: _focusNode,
                autofillHints: const [AutofillHints.telephoneNumber],
                prefixWidget: SvgPicture.asset(AppIcons.mobile),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter mobile number";
                  }
                  if (value.length != 10) {
                    return "Please enter 10 digit mobile number";
                  }
                  return null;
                },
              ),

              SizedBox(height: 50),
              Center(
                child: authController.apiResponse.status == Status.LOADING
                    ? ButtonProgressBar(isLogin: true)
                    : AuthButton(
                        title: 'Get OTP',
                        onTap: () async {
                          if (formKey.currentState!.validate()) {
                            await sendOTP();
                          }
                        },
                      ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// OTP screen

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late final SmsRetriever smsRetriever;

  late AuthController authController;
  final formKey = GlobalKey<FormState>();
  late TextEditingController otpController;

  Timer? _timer;
  int _remainingTime = 60;

  @override
  void initState() {
    // TODO: implement initState
    authController = context.read<AuthController>();
    otpController = TextEditingController();
    startTimer();

    smsRetriever = SmsRetrieverImpl(SmartAuth.instance);
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  void startTimer() {
    _timer?.cancel();
    _remainingTime = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  final defaultPinTheme = PinTheme(
    width: 50,
    height: 50,
    textStyle: GoogleFonts.outfit(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.darkText,
    ),
    decoration: BoxDecoration(
      border: Border.all(color: GenericColors.borderGrey, width: 1),
      shape: BoxShape.circle,
    ),
  );

  Future<void> verifyOTP() async {
    final mobile = SessionManager.getMobile();
    final otpText = otpController.text.trim();

    if (otpText.isEmpty || int.tryParse(otpText) == null) {
      ExceptionHandler.handleUiException(
        context: context,
        status: Status.ERROR,
        message: "Invalid OTP",
      );
      return;
    }

    final response = await authController.verifyOTP(
      phoneNumber: '91$mobile',
      otp: int.parse(otpText),
    );

    if (!mounted) return;

    if (response.status != Status.COMPLETED) {
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
      return;
    }

    final profileResponse = await context
        .read<ProfileController>()
        .getProfile();

    if (!mounted) return;

    if (profileResponse.status != Status.COMPLETED) {
      authController.animateTo(3);
      return;
    }

    final profile = profileResponse.data;

    final isProfileIncomplete =
        (profile?.userName?.isEmpty ?? true) ||
        (profile?.district?.isEmpty ?? true) ||
        (profile?.state?.isEmpty ?? true);

    if (isProfileIncomplete) {
      authController.animateTo(3);
    } else {
      context.read<HomeController>().setCurrentPage = 0;
      context.goNamed(AppRoutes.mainDashboard, extra: true);
    }
  }

  // Future<void> verifyEmailOtp() async {
  //   final email = SessionManager.getEmail() ?? '';
  //   final response = await authController.verifyEmailOtp(
  //     email: email,
  //     otp: int.parse(otpController.text.trim()),
  //   );
  //   if (!mounted) return;
  //   if (response.status == Status.COMPLETED) {
  //     context.read<HomeController>().setCurrentPage = 0;
  //     context.goNamed(AppRoutes.mainDashboard, extra: true);
  //   } else {
  //     ExceptionHandler.handleUiException(
  //       context: context,
  //       status: response.status,
  //       message: response.message,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    authController = context.watch<AuthController>();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      color: AppColors.scaffoldBackgroundDark,
      child: Form(
        key: formKey,
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AuthBackButton(),
                SizedBox(width: 30),
                HeaderTextBlack(
                  title: 'Enter Otp Code',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            SizedBox(height: 30),
            Pinput(
              length: 6,
              controller: otpController,
              autofocus: true,
              smsRetriever: smsRetriever,
              autofillHints: const [AutofillHints.oneTimeCode],
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              defaultPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color: GenericColors.borderGrey),
                ),
              ),
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
              ),
              preFilledWidget: SvgPicture.asset(AppIcons.pinput),
              errorTextStyle: AppTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: Colors.red.shade700,
              ).textStyle,
              onCompleted: (pin) {
                if (formKey.currentState!.validate()) {
                  verifyOTP();
                }
              },
              onChanged: (value) {},
              onSubmitted: (value) {},
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter OTP';
                } else if (value.length != 6) {
                  return 'Please enter 6 digit OTP';
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            Row(
              children: [
                SizedBox(width: 10),
                BodyTextColors(
                  title: '00:${_remainingTime.toString().padLeft(2, '0')}',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: GenericColors.darkRed,
                ),
                Spacer(),
                InkWell(
                  onTap: _remainingTime == 0
                      ? () async {
                          final phone = SessionManager.getMobile() ?? '';
                          final response = await authController.sendOTP(
                            phoneNumber: '91$phone',
                          );
                          if (!context.mounted) return;
                          if (response.status == Status.COMPLETED) {
                            CustomToast.show(
                              context,
                              title: '${response.data}',
                            );
                            startTimer();
                          } else {
                            ExceptionHandler.handleUiException(
                              context: context,
                              status: response.status,
                              message: response.message,
                            );
                          }
                        }
                      : null,
                  child: BodyTextColors(
                    title: "Resend",
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    textDecoration: TextDecoration.underline,
                    decorationColor: _remainingTime == 0
                        ? AppColors.primary
                        : AppColors.darkGrey,
                    color: _remainingTime == 0
                        ? AppColors.primary
                        : AppColors.darkGrey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Center(
              child:
                  authController.verifyOTPResponse.status == Status.LOADING ||
                      context.watch<ProfileController>().profileData.status ==
                          Status.LOADING
                  ? ButtonProgressBar(isLogin: true)
                  : AuthButton(
                      title: 'Proceed',
                      onTap: () async {
                        if (formKey.currentState!.validate()) {
                          await verifyOTP();
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileUpdation extends StatefulWidget {
  const ProfileUpdation({super.key});

  @override
  State<ProfileUpdation> createState() => _ProfileUpdationState();
}

class _ProfileUpdationState extends State<ProfileUpdation> {
  Map<String, dynamic> stateData = {};

  List<String> districts = [];

  String? selectedState;
  String? selectedDistrict;

  late TextEditingController nameController;
  late TextEditingController districtController;
  late TextEditingController stateController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    nameController = TextEditingController();
    districtController = TextEditingController();
    stateController = TextEditingController();
    loadJson();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    stateController.dispose();
    districtController.dispose();
    super.dispose();
  }

  Future<void> loadJson() async {
    final String response = await rootBundle.loadString(
      'assets/india_states_districts.json',
    );
    final data = json.decode(response);
    if (mounted) setState(() => stateData = data);
  }

  Future<void> updateProfile() async {
    final profileController = context.read<ProfileController>();
    final ProfileData profile = ProfileData(
      userName: nameController.text.trim(),
      district: districtController.text.trim(),
      state: stateController.text.trim(),
      phone: SessionManager.getMobile(),
      country: "India",
    );
    final response = await profileController.updateProfile(
      profileData: profile,
      image: profileController.profileData.data?.profilePic ?? '/images',
    );
    if (!mounted) return;
    if (response.status == Status.COMPLETED) {
      context.read<HomeController>().setCurrentPage = 0;
      context.goNamed(AppRoutes.mainDashboard, extra: true);
    } else {
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      color: AppColors.scaffoldBackgroundDark,
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AuthBackButton(),
                  HeaderTextPrimary(
                    title: 'Profile Detail',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  SizedBox(width: 50),
                ],
              ),
              SizedBox(height: 20),
              CustomMobileNumberTextField(
                controller: nameController,
                hintText: "Enter Name",
                textInputType: TextInputType.text,
                inputAction:TextInputAction.next,
                prefixWidget: Image.asset(
                  AppIcons.personP,
                  height: 16,
                  color: AppColors.darkGrey,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter name";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Autocomplete<String>(
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
                      return CustomMobileNumberTextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (val) => stateController.text = val,
                        hintText: "Select State",
                        prefixWidget: SvgPicture.asset(
                          AppIcons.locationArrow,
                          colorFilter: ColorFilter.mode(
                            AppColors.darkGrey,
                            BlendMode.srcIn,
                          ),
                        ),
                        textInputType: TextInputType.text,
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
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final String option = options.elementAt(index);
                            return ListTile(
                              title: BodyTextColors(
                                title: option,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.darkText,
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
              SizedBox(height: 10),
              Autocomplete<String>(
                key: ValueKey(selectedState),
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
                      return CustomMobileNumberTextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (val) => districtController.text = val,
                        hintText: "Select District",
                        prefixWidget: SvgPicture.asset(
                          AppIcons.locationArrow,
                          colorFilter: ColorFilter.mode(
                            AppColors.darkGrey,
                            BlendMode.srcIn,
                          ),
                        ),
                        textInputType: TextInputType.text,
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
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final String option = options.elementAt(index);
                            return ListTile(
                              title: BodyTextColors(
                                title: option,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.darkText,
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

              SizedBox(height: 50),
              if (context.watch<ProfileController>().apiResponse.status ==
                  Status.LOADING)
                ButtonProgressBar(isLogin: true)
              else
                AuthButton(
                  title: 'Submit',
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
    );
  }
}

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    return GestureDetector(
      onTap: () {
        if (authController.currentPage == 1) {
          authController.animateTo(0);
        }
        if (authController.currentPage == 2) {
          authController.animateTo(1);
        }
        if (authController.currentPage == 3) {
          authController.animateTo(2);
        }
        if (authController.currentPage == 4) {
          authController.animateTo(1);
        }
      },
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadiusGeometry.circular(4),
          color: AppColors.scaffoldBackground,
        ),
        child: Center(
          child: SvgPicture.asset(AppIcons.arrowBack, height: 20, width: 20),
        ),
      ),
    );
  }
}

class CustomMobileNumberTextField extends StatelessWidget {
  const CustomMobileNumberTextField({
    super.key,
    required this.controller,
    this.validator,
    required this.prefixWidget,
    required this.textInputType,
    this.hintText,
    this.onTap,
    this.readOnly = false,
    this.suffixIcon,
    this.onChanged,
    this.focusNode,
    this.maxLength,
    this.inputAction = TextInputAction.done,
    this.autofillHints,
  });

  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final Widget prefixWidget;
  final TextInputType textInputType;
  final String? hintText;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final int? maxLength;
  final TextInputAction inputAction;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onTap: onTap,
      readOnly: readOnly,
      onChanged: onChanged,
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.darkText,
      ),
      maxLength: maxLength,
      keyboardType: textInputType,
      textInputAction: inputAction,
      autofillHints: autofillHints,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        border: InputBorder.none,
        isDense: true,
        hintText: hintText ?? "Enter Mobile Number",
        counterText: '',
        suffixIcon: suffixIcon,
        hintStyle: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.darkGrey,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: GenericColors.borderGrey, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: GenericColors.darkRed, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: GenericColors.borderGrey, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: GenericColors.borderGrey, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        errorStyle: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(25, 15, 0, 15),
          child: prefixWidget,
        ),
      ),
      validator: validator,
    );
  }
}

class SmsRetrieverImpl implements SmsRetriever {
  const SmsRetrieverImpl(this.smartAuth);

  final SmartAuth smartAuth;

  @override
  Future<void> dispose() {
    return smartAuth.removeUserConsentApiListener();
  }

  @override
  Future<String?> getSmsCode() async {
    final signature = await smartAuth.getAppSignature();
    debugPrint('App Signature: $signature');
    final res = await smartAuth.getSmsWithUserConsentApi();
    return res.data?.code;
  }

  @override
  bool get listenForMultipleSms => false;
}
