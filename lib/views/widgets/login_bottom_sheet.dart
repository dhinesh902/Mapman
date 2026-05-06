import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
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
import 'package:mapman/views/auth_screens/login.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:phone_number_hint/phone_number_hint.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:smart_auth/smart_auth.dart';

class LoginBottomSheet {
  static Future<dynamic> showLoginBottomSheet(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const LoginBottomSheetContent(),
        );
      },
    );
  }
}

class LoginBottomSheetContent extends StatefulWidget {
  const LoginBottomSheetContent({super.key});

  @override
  State<LoginBottomSheetContent> createState() => _LoginBottomSheetContentState();
}

class _LoginBottomSheetContentState extends State<LoginBottomSheetContent> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBackgroundDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkGrey.withValues(alpha: .5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(
              height: 320,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                  });
                },
                children: [
                  MobileNumberScreen(
                    onOtpSent: _nextPage,
                  ),
                  OTPScreen(
                    onBack: _previousPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MobileNumberScreen extends StatefulWidget {
  final VoidCallback onOtpSent;
  const MobileNumberScreen({super.key, required this.onOtpSent});

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
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
      return;
    }
    String? result;
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
    if (!mounted) return;
    setState(() {
      if (result != null && result.isEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
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
      widget.onOtpSent();
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
              const SizedBox(height: 20),
              const HeaderTextBlack(
                title: 'MapMan',
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 30),
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
              const SizedBox(height: 50),
              Center(
                child: authController.apiResponse.status == Status.LOADING
                    ? const ButtonProgressBar(isLogin: true)
                    : AuthButton(
                        title: 'Get OTP',
                        onTap: () async {
                          if (formKey.currentState!.validate()) {
                            await sendOTP();
                          }
                        },
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// OTP screen

class OTPScreen extends StatefulWidget {
  final VoidCallback onBack;
  const OTPScreen({super.key, required this.onBack});

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
      Navigator.pop(context);
      return;
    }

    final profile = profileResponse.data;

    final isProfileIncomplete =
        (profile?.userName?.isEmpty ?? true) ||
        (profile?.district?.isEmpty ?? true) ||
        (profile?.state?.isEmpty ?? true);

    if (isProfileIncomplete) {
      Navigator.pop(context);
      context.goNamed(AppRoutes.loginProfile);
    } else {
      context.read<HomeController>().setCurrentPage = 0;
      Navigator.pop(context, true);
      context.goNamed(AppRoutes.mainDashboard, extra: true);
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
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: widget.onBack,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: AppColors.scaffoldBackground,
                    ),
                    child: Center(
                      child: SvgPicture.asset(AppIcons.arrowBack, height: 20, width: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                const HeaderTextBlack(
                  title: 'Enter Otp Code',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            const SizedBox(height: 30),
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
            const SizedBox(height: 15),
            Row(
              children: [
                const SizedBox(width: 10),
                BodyTextColors(
                  title: '00:${_remainingTime.toString().padLeft(2, '0')}',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: GenericColors.darkRed,
                ),
                const Spacer(),
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
            const SizedBox(height: 40),
            Center(
              child:
                  authController.verifyOTPResponse.status == Status.LOADING ||
                          context.watch<ProfileController>().profileData.status ==
                              Status.LOADING
                      ? const ButtonProgressBar(isLogin: true)
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
