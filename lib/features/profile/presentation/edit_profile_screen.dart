import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_link_button.dart';
import '../../../core/widgets/app_pill_field.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../data/pear_repository.dart';
import 'profile_widgets.dart';

/// Name and photo (Figma "name", 2269:6584).
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _name = TextEditingController(text: PearScope.read(context).me.name);
  late String? _photo = PearScope.read(context).me.avatarUrl;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _changed {
    final me = PearScope.read(context).me;
    final name = _name.text.trim();
    return (name.isNotEmpty && name != me.name) || _photo != me.avatarUrl;
  }

  Future<void> _changePhoto() async {
    final source = await showAppSheet<ImageSource>(
      context,
      builder: (context) => AppSheetFrame(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppSheetHeader(title: 'Change photo'),
            const SizedBox(height: 24),
            Center(
              child: AppLinkButton(
                label: 'Choose from library',
                color: AppColors.body1,
                leadingIcon:
                    SvgPicture.asset(AppIcons.gallery, width: 18, height: 18),
                onPressed: () =>
                    Navigator.of(context).pop(ImageSource.gallery),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: AppLinkButton(
                label: 'Take a photo',
                color: AppColors.body1,
                leadingIcon:
                    SvgPicture.asset(AppIcons.camera, width: 18, height: 18),
                onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
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
          content: Text(
            'Couldn’t open photos. Check the app’s permissions.',
          ),
        ),
      );
    }
  }

  void _save() {
    final name = _name.text.trim();
    PearScope.read(context).updateProfile(
      name: name.isEmpty ? null : name,
      avatarUrl: _photo,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      actions: [
        AppButton(label: 'Save', onPressed: _changed ? _save : null),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: SizedBox.square(
              dimension: 85,
              child: Stack(
                children: [
                  AppAvatar(
                    name: _name.text,
                    imageUrl: _photo,
                    size: 85,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surfaceForeground,
                          width: 2,
                        ),
                      ),
                      child: SvgPicture.asset(
                        AppIcons.camera,
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          AppColors.textOnButton,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: AppLinkButton(label: 'Change photo', onPressed: _changePhoto),
          ),
          const SizedBox(height: 24),
          AppPillField(
            label: 'Name',
            hint: 'Your name',
            controller: _name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.name],
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (_changed) _save();
            },
          ),
        ],
      ),
    );
  }
}
