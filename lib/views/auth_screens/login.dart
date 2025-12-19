import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapman/controller/auth_controller.dart';
import 'package:mapman/controller/home_controller.dart';
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
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:phone_number_hint/phone_number_hint.dart';

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
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
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
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(AppIcons.manLocation),
                SizedBox(width: 10),
                HeaderTextBlack(
                  title: 'Map Man',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            SizedBox(height: 15),
            CustomOutlineButtonWithImage(
              title: 'Continue with Google',
              icon: AppIcons.google,
              onTap: () {},
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
              title: 'Continue with Mobile',
              isGoogle: false,
              icon: AppIcons.phoneP,
              onTap: () {
                context.read<AuthController>().animateTo(1);
              },
            ),
            SizedBox(height: 15),
            BodyTextHint(
              title: 'By Continuing you agree to Mapman',
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
            SizedBox(height: 10),
            InkWell(
              onTap: () {},
              child: HeaderTextPrimary(
                title: 'Terms and Conditions',
                fontSize: 12,
                fontWeight: FontWeight.w400,
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
    // TODO: implement dispose
    mobileNumberController.dispose();
    super.dispose();
  }

  Future<void> getPhoneNumber() async {
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
      phoneNumber: '+91-${mobileNumberController.text.trim()}',
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

  @override
  Widget build(BuildContext context) {
    authController = context.watch<AuthController>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
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
                  title: 'Back',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            SizedBox(height: 30),
            CustomMobileNumberTextField(
              controller: mobileNumberController,
              focusNode: _focusNode,
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
            SizedBox(height: 70),
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
          ],
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
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _remainingTime = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            timer.cancel();
          }
        });
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
    final response = await authController.verifyOTP(
      phoneNumber: '+91-$mobile',
      otp: int.parse(otpController.text.trim()),
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
              length: 4,
              controller: otpController,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              defaultPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color: GenericColors.borderGrey),
                ),
              ),
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
              onChanged: (value) {},
              onSubmitted: (value) {},
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter OTP';
                } else if (value.length != 4) {
                  return 'Please enter 4 digit OTP';
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            Row(
              children: [
                SizedBox(width: 10),
                BodyTextColors(
                  title: '00.$_remainingTime',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: GenericColors.darkRed,
                ),
                Spacer(),
                InkWell(
                  onTap: _remainingTime == 0 ? () {} : null,
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
              child: authController.apiResponse.status == Status.LOADING
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
    required this.focusNode,
  });

  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLength: 10,
      focusNode: focusNode,
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.darkText,
      ),
      keyboardType: TextInputType.number,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        border: InputBorder.none,
        isDense: true,
        hintText: "Enter Phone Number",
        counterText: '',
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
          borderSide: BorderSide(color: GenericColors.borderGrey, width: 1),
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
          child: SvgPicture.asset(AppIcons.mobile),
        ),
      ),
      validator: validator,
    );
  }
}
