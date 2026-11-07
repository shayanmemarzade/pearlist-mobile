import 'package:flutter/animation.dart';

/// Timeline of the splash animation, measured frame-by-frame from the
/// designer's video (Figma node 2492:11066).
///
/// All times are in seconds, all distances in logical pixels of the
/// 393 x 852 design canvas. Every eased property was fitted to the video with
/// a cubic-bezier curve, so the motion matches the original.
class Prop {
  const Prop(this.t0, this.t1, this.v0, this.v1, this.curve);

  final double t0;
  final double t1;
  final double v0;
  final double v1;
  final Curve curve;

  double at(double t) {
    if (t <= t0) return v0;
    if (t >= t1) return v1;
    return v0 + (v1 - v0) * curve.transform((t - t0) / (t1 - t0));
  }
}

abstract final class SplashTimeline {
  /// Total length of the splash before handing over to the Welcome screen.
  static const double duration = 2.8;

  // 1. Branch with leaves: fades in while settling down ~24px.
  static const branchOpacity =
      Prop(0.000, 0.472, 0, 1, Cubic(0.280, 0.788, 0.327, 0.901));
  static const branchDy =
      Prop(0.000, 0.646, -23.985, 0, Cubic(0.229, 0.862, 0.253, 0.960));

  // 2. Soft peach glow behind the pear: grows and brightens.
  static const glowOpacity =
      Prop(-0.027, 0.919, 0, 1, Cubic(0.486, 0.451, 0.000, 0.332));
  static const glowScale =
      Prop(0.100, 0.788, 0.592, 1, Cubic(0.005, 0.286, 0.089, 0.536));

  // 3. Pear (with stem) drops in, overshoots a little and settles.
  static const pearOpacity =
      Prop(0.248, 0.493, 0, 1, Cubic(0.458, 0.719, 0.699, 0.838));
  static const pearScale =
      Prop(-0.113, 0.992, 0.678, 1, Cubic(0.552, 1.185, 0.416, 1.020));
  static const pearDy =
      Prop(0.267, 0.888, -54.695, 0, Cubic(0.255, 1.078, 0.398, 1.222));

  // 4. Pear splits into two halves that slide apart and tilt outwards.
  static const split =
      Prop(1.030, 1.473, 0, 1, Cubic(0.507, 0.000, 0.174, 0.901));
  static const splitDx = 24.77; // per half, outwards
  static const splitDy = 9.27; // per half, downwards
  static const splitAngleDeg = 7.3; // per half, each tilts away from the cut

  // 5. Grocery card pops in.
  static const cardOpacity =
      Prop(1.351, 1.485, 0, 1, Cubic(0.157, 0.104, 0.360, 0.926));
  static const cardScale =
      Prop(1.352, 1.583, 0.279, 1, Cubic(0.317, 1.070, 0.432, 1.035));
  static const cardDy =
      Prop(1.386, 1.544, 11.141, 0, Cubic(0.000, 0.697, 0.426, 1.135));

  // 6. Items get checked one after another.
  static const firstCheck = 1.655;
  static const checkInterval = 0.254;
  static double checkStart(int index) => firstCheck + index * checkInterval;

  static double checkOpacity(double t, int index) {
    final t0 = checkStart(index);
    return Prop(t0, t0 + 0.065, 0, 1, Curves.linear).at(t);
  }

  /// Pop: 0.6 -> 1.073 (overshoot) -> 1.0.
  static double checkScale(double t, int index) {
    final t0 = checkStart(index);
    if (t < t0 + 0.145) {
      return Prop(t0, t0 + 0.145, 0.6, 1.073, Curves.easeOut).at(t);
    }
    return Prop(t0 + 0.145, t0 + 0.28, 1.073, 1.0, Curves.easeInOut).at(t);
  }

  /// 0 = dark text, 1 = greyed out.
  static double checkTextFade(double t, int index) {
    final t0 = checkStart(index);
    return Prop(t0, t0 + 0.3, 0, 1, Curves.easeOut).at(t);
  }
}
