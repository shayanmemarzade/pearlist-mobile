import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_link_button.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart';
import '../domain/sign_up_draft.dart';
import 'email_screen.dart';

/// Sign up — profile photo (Figma 2184:6384).
class ProfilePhotoScreen extends StatefulWidget {
  const ProfilePhotoScreen({super.key, required this.draft});

  final SignUpDraft draft;

  @override
  State<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  final _picker = ImagePicker();
  late String? _photo = widget.draft.photoPath;

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );
      if (file != null && mounted) setState(() => _photo = file.path);
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn’t open photos. Check the app’s permissions.'),
        ),
      );
    }
  }

  void _next({required bool skip}) {
    widget.draft.photoPath = skip ? null : _photo;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => EmailScreen(draft: widget.draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = _photo;
    return OnboardingScaffold(
      onSkip: () => _next(skip: true),
      actions: [
        AppButton(
          label: 'Continue',
          onPressed: photo == null ? null : () => _next(skip: false),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OnboardingHeader(
            title: 'Add a profile photo',
            description: 'A face next to each item helps everyone see who '
                'added what.',
          ),
          const SizedBox(height: 32),
          Center(
            child: SizedBox.square(
              dimension: 170,
              child: Stack(
                children: [
                  Semantics(
                    label: photo == null ? 'No profile photo' : 'Profile photo',
                    image: true,
                    child: ClipOval(
                      child: Container(
                        width: 170,
                        height: 170,
                        color: AppColors.surfacePrimaryLight,
                        alignment: Alignment.center,
                        child: photo == null
                            ? SvgPicture.asset(
                                AppIcons.user68,
                                width: 68,
                                height: 68,
                              )
                            : Image.file(
                                File(photo),
                                width: 170,
                                height: 170,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Tooltip(
                      message: 'Choose a photo',
                      child: Material(
                        color: AppColors.buttonPrimary,
                        shape: const CircleBorder(
                          side: BorderSide(
                            color: AppColors.surfaceForeground,
                            width: 2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _pick(ImageSource.gallery),
                          child: SizedBox.square(
                            dimension: 34,
                            child: Center(
                              child: SvgPicture.asset(
                                AppIcons.addWhite,
                                width: 18,
                                height: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: AppLinkButton(
              label: 'Choose from library',
              color: AppColors.body1,
              leadingIcon:
                  SvgPicture.asset(AppIcons.gallery, width: 18, height: 18),
              onPressed: () => _pick(ImageSource.gallery),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: AppLinkButton(
              label: 'Take a photo',
              color: AppColors.body1,
              leadingIcon:
                  SvgPicture.asset(AppIcons.camera, width: 18, height: 18),
              onPressed: () => _pick(ImageSource.camera),
            ),
          ),
        ],
      ),
    );
  }
}
