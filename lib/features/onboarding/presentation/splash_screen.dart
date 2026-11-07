import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'splash/splash_scene.dart';
import 'splash/splash_timeline.dart';
import 'welcome_screen.dart';

/// Animated splash (Figma: "Welcome Screen" 2492:11066).
///
/// The designer's video is rebuilt natively: vector art traced from the video
/// (assets/splash/*.svg) animated with timings and easing curves measured
/// frame-by-frame. No video file is needed.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(
      milliseconds: (SplashTimeline.duration * 1000).round(),
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _goToWelcome();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // Make sure the SVGs are decoded before the first animated frame.
      await Future.wait([
        for (final a in const [
          'assets/splash/branch.svg',
          'assets/splash/pear.svg',
          'assets/splash/stem.svg',
        ])
          DefaultAssetBundle.of(context).loadString(a),
      ]);
      if (mounted) _controller.forward();
    });
  }

  void _goToWelcome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => SplashScene(
            t: _controller.value * SplashTimeline.duration,
          ),
        ),
      ),
    );
  }
}
