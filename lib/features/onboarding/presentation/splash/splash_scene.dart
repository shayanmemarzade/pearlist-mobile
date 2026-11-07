import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import 'splash_timeline.dart';

/// One frame of the splash animation at time [t] (seconds).
///
/// Everything is laid out on the 393 x 852 design canvas, exactly as in the
/// Figma frame, and the canvas is scaled to cover the screen.
class SplashScene extends StatelessWidget {
  const SplashScene({super.key, required this.t});

  final double t;

  static const double canvasWidth = 393.333;
  static const double canvasHeight = 852;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: canvasWidth,
            height: canvasHeight,
            child: MediaQuery.withNoTextScaling(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _glow(),
                  _branch(),
                  _pear(),
                  _card(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- glow
  Widget _glow() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _GlowPainter(
          opacity: SplashTimeline.glowOpacity.at(t),
          scale: SplashTimeline.glowScale.at(t),
        ),
      ),
    );
  }

  // -------------------------------------------------------------- branch
  Widget _branch() {
    final opacity = SplashTimeline.branchOpacity.at(t).clamp(0.0, 1.0);
    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(0, SplashTimeline.branchDy.at(t)),
          child: const _CanvasSvg('assets/splash/branch.svg'),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- pear
  static const _pearPivot = Offset(196.667, 366.667);
  static const _cut = 196.5; // x of the vertical split line
  static const _leftPivot = Offset(175.58, 374.60);
  static const _rightPivot = Offset(216.78, 374.55);

  Widget _pear() {
    final opacity = SplashTimeline.pearOpacity.at(t).clamp(0.0, 1.0);
    final split = SplashTimeline.split.at(t);

    final Widget fruit;
    if (split <= 0) {
      fruit = const _CanvasSvg('assets/splash/pear.svg');
    } else {
      final angle = SplashTimeline.splitAngleDeg * split * math.pi / 180;
      final dx = SplashTimeline.splitDx * split;
      final dy = SplashTimeline.splitDy * split;
      fruit = Stack(
        children: [
          _half(left: true, dx: -dx, dy: dy, angle: -angle),
          _half(left: false, dx: dx, dy: dy, angle: angle),
        ],
      );
    }

    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
        child: Transform(
          transform: _scaleAbout(
            _pearPivot,
            SplashTimeline.pearScale.at(t),
            dy: SplashTimeline.pearDy.at(t),
          ),
          child: Stack(
            children: [
              const _CanvasSvg('assets/splash/stem.svg'),
              // The stem stays on the branch; only the fruit splits.
              Positioned.fill(child: fruit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _half({
    required bool left,
    required double dx,
    required double dy,
    required double angle,
  }) {
    final pivot = left ? _leftPivot : _rightPivot;
    return Positioned.fill(
      child: Transform(
        transform: Matrix4.translationValues(dx, dy, 0)
          ..multiply(Matrix4.translationValues(pivot.dx, pivot.dy, 0))
          ..multiply(Matrix4.rotationZ(angle))
          ..multiply(Matrix4.translationValues(-pivot.dx, -pivot.dy, 0)),
        child: ClipRect(
          clipper: _HalfClipper(left: left, cut: _cut),
          child: const _CanvasSvg('assets/splash/pear.svg'),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- card
  static const _cardRect = Rect.fromLTWH(114.17, 328.5, 164, 163);

  Widget _card() {
    final opacity = SplashTimeline.cardOpacity.at(t).clamp(0.0, 1.0);
    if (opacity <= 0) return const SizedBox.shrink();
    return Positioned.fromRect(
      rect: _cardRect,
      child: Opacity(
        opacity: opacity,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.translationValues(0, SplashTimeline.cardDy.at(t), 0)
            ..multiply(Matrix4.diagonal3Values(
              SplashTimeline.cardScale.at(t),
              SplashTimeline.cardScale.at(t),
              1,
            )),
          child: _GroceryCard(t: t),
        ),
      ),
    );
  }

  static Matrix4 _scaleAbout(Offset pivot, double s, {double dy = 0}) {
    return Matrix4.translationValues(pivot.dx, pivot.dy + dy, 0)
      ..multiply(Matrix4.diagonal3Values(s, s, 1))
      ..multiply(Matrix4.translationValues(-pivot.dx, -pivot.dy, 0));
  }
}

/// An SVG that covers the whole design canvas (all splash SVGs share the
/// canvas coordinate system, so they line up without extra positioning).
class _CanvasSvg extends StatelessWidget {
  const _CanvasSvg(this.asset);

  final String asset;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: SplashScene.canvasWidth,
      height: SplashScene.canvasHeight,
      fit: BoxFit.fill,
    );
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  const _HalfClipper({required this.left, required this.cut});

  final bool left;
  final double cut;

  @override
  Rect getClip(Size size) => left
      ? Rect.fromLTRB(0, 0, cut, size.height)
      : Rect.fromLTRB(cut, 0, size.width, size.height);

  @override
  bool shouldReclip(_HalfClipper old) => old.left != left || old.cut != cut;
}

class _GlowPainter extends CustomPainter {
  _GlowPainter({required this.opacity, required this.scale});

  final double opacity;
  final double scale;

  static const _center = Offset(195.8, 386.3);
  static const _radius = 140.17;
  static const _color = Color(0xFFF8EDE4);

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final r = _radius * scale;
    final a = opacity.clamp(0.0, 1.0);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          _color.withValues(alpha: a),
          _color.withValues(alpha: a),
          _color.withValues(alpha: 0),
        ],
        stops: const [0, 0.21, 1],
      ).createShader(Rect.fromCircle(center: _center, radius: r));
    canvas.drawCircle(_center, r, paint);
  }

  @override
  bool shouldRepaint(_GlowPainter old) =>
      old.opacity != opacity || old.scale != scale;
}

// ------------------------------------------------------------ grocery card
class _GroceryCard extends StatelessWidget {
  const _GroceryCard({required this.t});

  final double t;

  static const _items = ['Oat milk', 'Sourdough', 'Pears ×4'];
  static const _textDark = Color(0xFF131514);
  static const _textGrey = Color(0xFF767877);

  TextStyle _body({Color color = _textDark}) => GoogleFonts.interTight(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.28,
        color: color,
      );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color(0x11000000),
            offset: Offset(0, 2),
            blurRadius: 4.3,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Title (two lines, baselines 20px apart).
          Positioned(left: 14.14, top: 13.27, child: Text('Weekly', style: _body())),
          Positioned(left: 14.14, top: 33.27, child: Text('groceries', style: _body())),
          // Shared-with avatars.
          const Positioned(
            left: 128.16 - 9,
            top: 31.83 - 9,
            child: _Avatar(background: Color(0xFFDBEBDE)),
          ),
          const Positioned(
            left: 139.5 - 9,
            top: 31.83 - 9,
            child: _Avatar(background: Color(0xFFF7ECDF), ring: true),
          ),
          Positioned(left: 124.97, top: 24.14, child: _letter('L', const Color(0xFF3D6448))),
          Positioned(left: 137.39, top: 24.14, child: _letter('J', const Color(0xFF856742))),
          for (var i = 0; i < _items.length; i++) ..._row(i),
        ],
      ),
    );
  }

  Widget _letter(String s, Color color) => Text(
        s,
        style: GoogleFonts.interTight(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      );

  List<Widget> _row(int i) {
    final checked = SplashTimeline.checkOpacity(t, i);
    final scale = SplashTimeline.checkScale(t, i);
    final fade = SplashTimeline.checkTextFade(t, i);
    final color = Color.lerp(_textDark, _textGrey, fade)!;
    final cy = 72.87 + 33 * i;
    const cx = 25.88;

    return [
      // Unchecked ring, fades out as the check fills in.
      Positioned(
        left: cx - 10.5,
        top: cy - 10.5,
        child: Opacity(
          opacity: 1 - checked,
          child: const CustomPaint(size: Size(21, 21), painter: _RingPainter()),
        ),
      ),
      if (checked > 0)
        Positioned(
          left: cx - 10.6,
          top: cy - 10.6,
          child: Opacity(
            opacity: checked,
            child: Transform.scale(
              scale: scale,
              child: const CustomPaint(size: Size(21.2, 21.2), painter: _CheckPainter()),
            ),
          ),
        ),
      Positioned(
        left: 46.16,
        top: 64.27 + 33 * i,
        child: Text(
          _items[i],
          style: _body(color: color).copyWith(
            decoration: checked > 0 ? TextDecoration.lineThrough : TextDecoration.none,
            decorationColor: color.withValues(alpha: checked),
          ),
        ),
      ),
    ];
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.background, this.ring = false});

  final Color background;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: ring
            ? Border.all(
                color: Colors.white,
                width: 1,
                strokeAlign: BorderSide.strokeAlignCenter,
              )
            : null,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      size.center(Offset.zero),
      9.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15
        ..color = const Color(0xFFBDBEBF),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => false;
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawCircle(c, 10.6, Paint()..color = const Color(0xFF486A48));
    final tick = Path()
      ..moveTo(c.dx - 4.6, c.dy + 0.5)
      ..lineTo(c.dx - 1.6, c.dy + 3.5)
      ..lineTo(c.dx + 4.5, c.dy - 2.6);
    canvas.drawPath(
      tick,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter old) => false;
}
