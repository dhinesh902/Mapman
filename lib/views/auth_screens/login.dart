import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapman/controller/auth_controller.dart';
import 'package:mapman/controller/home_controller.dart';
import 'package:mapman/controller/profile_controller.dart';
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

  List<LoginStep> steps = [
    LoginStep.loginOptions,
    LoginStep.mobileInput,
    LoginStep.otp,
    LoginStep.changeNumber,
    LoginStep.emailVerification,
    LoginStep.checkMail,
    LoginStep.newPhone,
    LoginStep.verifyNewNumber,
    LoginStep.numberUpdated,
  ];

  Widget getScreen(LoginStep step) {
    switch (step) {
      case LoginStep.loginOptions:
        return MobileOrGoogleSignIn();
      case LoginStep.mobileInput:
        return MobileNumberScreen();
      case LoginStep.otp:
        return OTPScreen();
      case LoginStep.changeNumber:
        return ChangeNumber();
      case LoginStep.emailVerification:
        return EmailVerification();
      case LoginStep.checkMail:
        return CheckYourMail();
      case LoginStep.newPhone:
        return NewPhoneNumber();
      case LoginStep.verifyNewNumber:
        return VerifyNewNumber();
      case LoginStep.numberUpdated:
        return NumberUpdated();
    }
  }

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
                      itemCount: steps.length,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: authController.onPageChanged,
                      itemBuilder: (context, index) => getScreen(steps[index]),
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
            SizedBox(height: 20),
            CustomOutlineButtonWithImage(
              title: 'Continue with Mobile',
              isGoogle: false,
              icon: AppIcons.phoneP,
              onTap: () {
                context.read<AuthController>().animateTo(1);
              },
            ),
            if (Platform.isIOS) ...[
              const SizedBox(height: 15),
              CustomOutlineButtonWithImage(
                title: 'Continue as Guest',
                isGoogle: false,
                icon: AppIcons.personP,
                onTap: () {
                  context.read<HomeController>().setCurrentPage = 0;
                  context.goNamed(AppRoutes.mainDashboard, extra: false);
                },
              ),
            ],
            // SizedBox(height: 15),
            // Row(
            //   children: [
            //     Expanded(child: Divider(color: GenericColors.borderGrey)),
            //     Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 10),
            //       child: BodyTextHint(
            //         title: 'OR',
            //         fontSize: 14,
            //         fontWeight: FontWeight.w400,
            //       ),
            //     ),
            //     Expanded(child: Divider(color: GenericColors.borderGrey)),
            //   ],
            // ),
            // SizedBox(height: 15),
            // CustomOutlineButtonWithImage(
            //   title: 'Continue with Google',
            //   icon: AppIcons.google,
            //   onTap: () {
            //     CustomToast.show(
            //       context,
            //       title: 'This feature is currently unavailable',
            //       isError: true,
            //     );
            //   },
            // ),
            SizedBox(height: 30),
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
        if (mounted && authController.currentPage == 1) {
          _focusNode.requestFocus();
        }
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
          if (mounted && authController.currentPage == 1) {
            _focusNode.requestFocus();
          }
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
              Align(
                alignment: AlignmentGeometry.centerRight,
                child: TextButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    context.read<AuthController>().animateTo(3);
                  },
                  child: HeaderTextPrimary(
                    title: 'Last registered number?',
                    fontSize: 14,
                    textDecoration: TextDecoration.underline,
                    decorationColor: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
      context.goNamed(AppRoutes.loginProfile);
    } else {
      context.read<HomeController>().setCurrentPage = 0;
      context.goNamed(AppRoutes.mainDashboard, extra: true);
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
              length: 6,
              controller: otpController,
              autofocus: authController.currentPage == 2,
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

/// Change Number

class ChangeNumber extends StatefulWidget {
  const ChangeNumber({super.key});

  @override
  State<ChangeNumber> createState() => _ChangeNumberState();
}

class _ChangeNumberState extends State<ChangeNumber> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      color: AppColors.scaffoldBackgroundDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AuthBackButton(),
              SizedBox(width: 30),
              HeaderTextBlack(
                title: 'Change Number',
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              color: GenericColors.darkAmber.withValues(alpha: .1),
              border: Border.all(color: GenericColors.darkAmber),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsetsGeometry.all(15),
            child: Row(
              children: [
                Image.asset(AppIcons.padLockP, height: 30),
                SizedBox(width: 10),
                Flexible(
                  child: BodyTextHint(
                    title:
                        'Verify your identity first before changing your phone number.',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          BodyTextHint(
            title: 'Verify VIA',
            fontSize: 15,
            fontWeight: FontWeight.w300,
          ),
          SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              context.read<AuthController>().animateTo(4);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: GenericColors.borderGrey),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsetsGeometry.all(15),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: GenericColors.lightPrimary.withValues(alpha: .4),
                    ),
                    padding: EdgeInsets.all(15),
                    child: Image.asset(AppIcons.padMailP, height: 30),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: AppTextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkText,
                            ).textStyle,
                            children: [
                              TextSpan(text: 'Recover via Email'),
                              WidgetSpan(
                                child: Icon(
                                  Icons.keyboard_arrow_right,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        BodyTextHint(
                          title:
                              'Verification link sent to your registered email',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}

/// Email Verification

class EmailVerification extends StatefulWidget {
  const EmailVerification({super.key});

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController mailController;

  @override
  void initState() {
    // TODO: implement initState
    mailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    mailController.dispose();
    super.dispose();
  }

  Future<void> sendMailOTP() async {
    final response = await context.read<AuthController>().sendMailOTP(
      email: mailController.text.trim(),
    );
    if (!mounted) return;
    if (response.status == Status.COMPLETED) {
      if (!mounted) return;
      SessionManager.setEmail(email: mailController.text.trim());
      CustomToast.show(context, title: '${response.data}');
      context.read<AuthController>().animateTo(5);
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
      padding: EdgeInsets.symmetric(horizontal: 30),
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
                    title: 'Email Verification',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              SizedBox(height: 30),
              CustomMobileNumberTextField(
                controller: mailController,
                textInputType: TextInputType.emailAddress,
                hintText: "Enter Registered Email",
                autofillHints: const [AutofillHints.email],
                prefixWidget: Image.asset(AppIcons.gmailP, height: 16),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter email";
                  }
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return "Please enter valid email";
                  }
                  return null;
                },
              ),
              SizedBox(height: 50),
              context.watch<AuthController>().apiResponse.status ==
                      Status.LOADING
                  ? ButtonProgressBar()
                  : AuthButton(
                      title: 'Verify',
                      onTap: () async {
                        if (formKey.currentState!.validate()) {
                          await sendMailOTP();
                        }
                      },
                    ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}

/// Check Your Email

class CheckYourMail extends StatefulWidget {
  const CheckYourMail({super.key});

  @override
  State<CheckYourMail> createState() => _CheckYourMailState();
}

class _CheckYourMailState extends State<CheckYourMail> {
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

  Future<void> verifyEmailOtp() async {
    final email = SessionManager.getEmail() ?? '';
    final response = await authController.verifyEmailOtp(
      email: email,
      otp: int.parse(otpController.text.trim()),
    );
    if (!mounted) return;
    if (response.status == Status.COMPLETED) {
      context.read<AuthController>().animateTo(6);
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
                  title: 'Check Your Email',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: GenericColors.borderGrey),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: HeaderTextBlack(
                      title: 'Verification OTP Sent',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  HeaderTextPrimary(
                    title: SessionManager.getEmail() ?? '',
                    fontSize: 12,
                    textDecoration: TextDecoration.underline,
                    decorationColor: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Pinput(
              length: 6,
              controller: otpController,
              autofocus: authController.currentPage == 5,
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
                  verifyEmailOtp();
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
                          final email = SessionManager.getEmail() ?? '';
                          final response = await authController.sendMailOTP(
                            email: email,
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
                          await verifyEmailOtp();
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

/// New Phone Number

class NewPhoneNumber extends StatefulWidget {
  const NewPhoneNumber({super.key});

  @override
  State<NewPhoneNumber> createState() => _NewPhoneNumberState();
}

class _NewPhoneNumberState extends State<NewPhoneNumber> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController mobileNumberController;

  @override
  void initState() {
    // TODO: implement initState
    mobileNumberController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    mobileNumberController.dispose();
    super.dispose();
  }

  Future<void> updateSendOtp() async {
    final email = SessionManager.getEmail() ?? '';
    final response = await context.read<AuthController>().updateSendOtp(
      phone: '91${mobileNumberController.text.trim()}',
      email: email,
    );
    if (!mounted) return;
    if (response.status == Status.COMPLETED) {
      if (!mounted) return;
      SessionManager.setMobile(phone: mobileNumberController.text.trim());
      CustomToast.show(context, title: '${response.data}');
      context.read<AuthController>().animateTo(7);
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
                  title: 'New Phone Number',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: GenericColors.borderGrey),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.all(15),
              child: BodyTextHint(
                title: 'Identity verified ✅ Enter your new phone number below',
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 30),
            CustomMobileNumberTextField(
              controller: mobileNumberController,
              textInputType: TextInputType.phone,
              maxLength: 10,
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
            context.watch<AuthController>().apiResponse.status == Status.LOADING
                ? ButtonProgressBar()
                : Center(
                    child: AuthButton(
                      title: 'Get OTP',
                      onTap: () async {
                        if (formKey.currentState!.validate()) {
                          await updateSendOtp();
                        }
                      },
                    ),
                  ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

/// Verify New Number

class VerifyNewNumber extends StatefulWidget {
  const VerifyNewNumber({super.key});

  @override
  State<VerifyNewNumber> createState() => _VerifyNewNumberState();
}

class _VerifyNewNumberState extends State<VerifyNewNumber> {
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

  Future<void> updateVerifyOtp() async {
    final mobile = SessionManager.getMobile();
    final email = SessionManager.getEmail() ?? '';
    final otpText = otpController.text.trim();

    if (otpText.isEmpty || int.tryParse(otpText) == null) {
      ExceptionHandler.handleUiException(
        context: context,
        status: Status.ERROR,
        message: "Invalid OTP",
      );
      return;
    }

    final response = await authController.updateVerifyOtp(
      phone: '91$mobile',
      otp: int.parse(otpText),
      email: email,
    );
    if (!mounted) return;
    if (response.status == Status.COMPLETED) {
      CustomToast.show(context, title: 'OTP Verified Successfully');
      authController.animateTo(8);
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
                  title: 'Verify New Number',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: GenericColors.borderGrey),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: HeaderTextBlack(
                      title: '+91 ${SessionManager.getMobile()}',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Image.network(
                    'https://cdn-icons-png.flaticon.com/128/1040/1040228.png',
                    height: 10,
                  ),
                  SizedBox(width: 5),
                  HeaderTextPrimary(
                    title: 'Change Number',
                    fontSize: 12,
                    textDecoration: TextDecoration.underline,
                    decorationColor: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Pinput(
              length: 6,
              controller: otpController,
              autofocus: authController.currentPage == 7,
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
                  updateVerifyOtp();
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
                          final email = SessionManager.getEmail() ?? '';
                          final response = await authController.updateSendOtp(
                            phone: '91$phone',
                            email: email,
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
              child: authController.apiResponse.status == Status.LOADING
                  ? ButtonProgressBar()
                  : AuthButton(
                      title: 'Proceed',
                      onTap: () async {
                        if (formKey.currentState!.validate()) {
                          await updateVerifyOtp();
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

/// Number Updated

class NumberUpdated extends StatefulWidget {
  const NumberUpdated({super.key});

  @override
  State<NumberUpdated> createState() => _NumberUpdatedState();
}

class _NumberUpdatedState extends State<NumberUpdated> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      color: AppColors.scaffoldBackgroundDark,
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 30),
            Image.asset(AppIcons.checkedP, height: 60, width: 60),
            SizedBox(height: 20),
            HeaderTextBlack(
              title: 'Number Updated!',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 15),
            BodyTextHint(
              title: 'Your phone number has been successfully changed.',
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppIcons.padCallP, height: 18),
                  HeaderTextBlack(
                    title: '+91 ${SessionManager.getMobile()}',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            AuthButton(
              title: 'Go to Dashboard',
              onTap: () {
                context.read<HomeController>().setCurrentPage = 0;
                context.goNamed(AppRoutes.mainDashboard, extra: true);
              },
            ),
            SizedBox(height: 20),
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
        } else if (authController.currentPage == 2) {
          authController.animateTo(1);
        } else if (authController.currentPage == 3) {
          authController.animateTo(1);
        } else if (authController.currentPage > 3) {
          authController.animateTo(authController.currentPage - 1);
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
