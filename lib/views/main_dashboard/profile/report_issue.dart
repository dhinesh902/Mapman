import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:mapman/views/widgets/custom_drop_downs.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:provider/provider.dart';

class ReportIssue extends StatefulWidget {
  const ReportIssue({super.key});

  @override
  State<ReportIssue> createState() => _ReportIssueState();
}

class _ReportIssueState extends State<ReportIssue> {
  final formKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();
  final emailController = TextEditingController();
  String? selectedCategory;
  File? selectedScreenshot;
  bool isSubmitting = false;

  final List<String> categories = [
    'Login Button Not working',
    'Mobile Login Error',
    'Page Not Loading',
    'Shop Listing / Editing',
    'UI/Display problem',
    'Others',
  ];

  @override
  void dispose() {
    descriptionController.dispose();
    emailController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> submitReport() async {
    setState(() {
      isSubmitting = true;
    });

    final profileController = context.read<ProfileController>();
    final response = await profileController.reportIssue(
      issueType: selectedCategory ?? '',
      description: descriptionController.text.trim(),
      image: selectedScreenshot,
      email: emailController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      isSubmitting = false;
    });

    if (response.status == Status.COMPLETED) {
      await CustomDialogues.showReportSuccessConfirmDialog(context);
      if (!mounted) return;
      context.pop();
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
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: const ActionBar(title: 'Report an Issue', isCenterTitle: false),
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            children: [
              const SizedBox(height: 10),

              // Issue Type / Dropdown
              CustomDropDownField(
                title: 'Issue Type',
                dropdownValue: selectedCategory,
                items: categories,
                hintText: 'Select A Category',
                onChanged: (val) {
                  setState(() {
                    selectedCategory = val;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a category";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Description
              CustomTextField(
                controller: descriptionController,
                title: 'Description',
                hintText: 'Describe The Issue',
                maxLines: 4,
                inputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please describe the issue";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Attach a Screenshot (Optional)
              AttachScreenshotWidget(
                selectedImage: selectedScreenshot,
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
                onClear: () {
                  setState(() {
                    selectedScreenshot = null;
                  });
                },
              ),
              const SizedBox(height: 15),

              // Your Email (Optional)
              CustomTextField(
                controller: emailController,
                title: 'Your Email (Optional)',
                hintText: 'So We Can Follow Up',
                inputType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                inputAction: TextInputAction.done,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!isValidEmail(value.trim())) {
                      return "Please enter a valid email address";
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Submit Button
              isSubmitting
                  ? const ButtonProgressBar()
                  : CustomFullButton(
                      title: 'Submit Report',
                      isDialogue: true,
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          submitReport();
                        }
                      },
                    ),

              const SizedBox(height: 20),

              // Footer Text
              Center(
                child: BodyTextColors(
                  title: 'We review all reports within 24–48 hours.',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 30),
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
        setState(() {
          selectedScreenshot = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }
}

class AttachScreenshotWidget extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const AttachScreenshotWidget({
    super.key,
    required this.selectedImage,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 2,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              BodyTextColors(
                title: 'Attach a screenshot (Optional)',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade700,
              ),
            ],
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: selectedImage == null ? onTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              width: double.infinity,
              child: selectedImage == null
                  ? Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.gallery,
                          height: 18,
                          width: 18,
                          colorFilter: const ColorFilter.mode(
                            Color(0Xff1f1f1f1f),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: BodyTextColors(
                            title: 'Png Or Jpeg Upto 5Mb',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0Xff1f1f1f1f),
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                            image: DecorationImage(
                              image: FileImage(selectedImage!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 90,
                          top: 0,
                          bottom: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 150,
                                child: BodyTextColors(
                                  title: selectedImage!.path
                                      .split(Platform.pathSeparator)
                                      .last,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkText,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 5),
                              GestureDetector(
                                onTap: onClear,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    BodyTextColors(
                                      title: 'Remove',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
