import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Round profile picture (Figma: "Avatar", 20–85px).
/// [imageUrl] is a web URL or a local file path (a photo picked during
/// sign-up). Falls back to the person's initial when there is no photo or
/// it fails to load.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 32,
    this.background = AppColors.surfacePrimaryLight,
    this.foreground = AppColors.textPrimary,
  });

  final String name;
  final String? imageUrl;
  final double size;

  /// Colours of the initial fallback.
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return Semantics(
      label: name,
      image: true,
      child: ClipOval(
        child: SizedBox.square(
          dimension: size,
          child: switch (url) {
            null => _initial(),
            final String u when u.startsWith('http') => Image.network(
                u,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _initial(),
              ),
            final String u => Image.file(
                File(u),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _initial(),
              ),
          },
        ),
      ),
    );
  }

  Widget _initial() {
    final trimmed = name.trim();
    final letter =
        trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
    return ColoredBox(
      color: background,
      child: Center(
        child: Text(
          letter,
          style: AppTextStyles.body2SemiBold.copyWith(
            color: foreground,
            fontSize: size * 0.42,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

/// Overlapping row of avatars (Figma: "Avatars", -4px overlap).
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.people,
    this.size = 32,
    this.overlap = 4,
  });

  final List<({String name, String? imageUrl})> people;
  final double size;
  final double overlap;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();
    final step = size - overlap;
    return SizedBox(
      width: size + step * (people.length - 1),
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < people.length; i++)
            Positioned(
              left: step * i,
              top: 0,
              child: AppAvatar(
                name: people[i].name,
                imageUrl: people[i].imageUrl,
                size: size,
              ),
            ),
        ],
      ),
    );
  }
}
