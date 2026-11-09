import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// "Thanos snap": when [snapping] turns true the child crumbles into dust
/// that drifts up and to the right, sweeping left to right, then the space
/// it took up closes. [onSnapped] runs at the end — remove the item there.
///
/// [above] (e.g. the divider over a row) collapses with the child but
/// doesn't turn to dust. With "Remove animations" switched on in the OS,
/// [onSnapped] runs straight away.
class SnapAway extends StatefulWidget {
  const SnapAway({
    super.key,
    required this.snapping,
    required this.onSnapped,
    required this.child,
    this.above,
  });

  final bool snapping;
  final VoidCallback onSnapped;
  final Widget child;
  final Widget? above;

  /// Whole effect: dust, then the gap closing over the second half.
  static const Duration duration = Duration(milliseconds: 1100);

  /// When the gap starts closing, as a fraction of [duration]. Use it for
  /// anything that should close along with the row (e.g. a neighbour's
  /// divider).
  static const Curve collapseCurve =
      Interval(0.55, 1, curve: Curves.easeInOutCubic);

  @override
  State<SnapAway> createState() => _SnapAwayState();
}

class _SnapAwayState extends State<SnapAway>
    with SingleTickerProviderStateMixin {
  final _boundaryKey = GlobalKey();
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: SnapAway.duration);
  late final Animation<double> _size = Tween<double>(begin: 1, end: 0)
      .animate(CurvedAnimation(parent: _controller, curve: SnapAway.collapseCurve));

  OverlayEntry? _overlay;
  ui.Image? _image;
  bool _started = false;
  bool _hidden = false;

  @override
  void initState() {
    super.initState();
    if (widget.snapping) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    }
  }

  @override
  void didUpdateWidget(SnapAway oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.snapping && !_started) {
      // Let the row repaint first (e.g. with its box ticked).
      WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    }
  }

  @override
  void dispose() {
    _overlay?.remove();
    _image?.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_started || !mounted) return;
    _started = true;

    final render = _boundaryKey.currentContext?.findRenderObject();
    final overlayState = Overlay.maybeOf(context);
    final overlayBox = overlayState?.context.findRenderObject();
    if (MediaQuery.disableAnimationsOf(context) ||
        render is! RenderRepaintBoundary ||
        overlayState == null ||
        overlayBox is! RenderBox ||
        !render.hasSize) {
      widget.onSnapped();
      return;
    }

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final size = render.size;
    final origin = render.localToGlobal(Offset.zero, ancestor: overlayBox);

    final ui.Image image;
    final ByteData? pixels;
    try {
      image = await render.toImage(pixelRatio: dpr);
      pixels = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    } on Object {
      if (mounted) widget.onSnapped();
      return;
    }
    if (!mounted) {
      image.dispose();
      return;
    }
    _image = image;

    final dust = _Dust.fromImage(
      image: image,
      pixels: pixels,
      pixelRatio: dpr,
      seed: identityHashCode(this),
    );

    _overlay = OverlayEntry(
      builder: (_) => Positioned(
        left: origin.dx,
        top: origin.dy - _Dust.maxRise,
        width: size.width + _Dust.maxDrift,
        height: size.height + _Dust.maxRise,
        child: IgnorePointer(
          child: CustomPaint(
            painter: _DustPainter(
              image: image,
              dust: dust,
              progress: _controller,
              pixelRatio: dpr,
            ),
          ),
        ),
      ),
    );
    overlayState.insert(_overlay!);
    setState(() => _hidden = true);

    await _controller.forward();
    _overlay?.remove();
    _overlay = null;
    if (mounted) widget.onSnapped();
  }

  @override
  Widget build(BuildContext context) {
    final above = widget.above;
    return SizeTransition(
      sizeFactor: _size,
      axisAlignment: -1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?above,
          Opacity(
            opacity: _hidden ? 0 : 1,
            child: RepaintBoundary(key: _boundaryKey, child: widget.child),
          ),
        ],
      ),
    );
  }
}

/// The grains the row breaks into: one small square of the snapshot each.
class _Dust {
  _Dust._(this.sources, this.starts, this.drifts, this.delays, this.spins);

  /// Grain size in logical pixels.
  static const double grain = 3;

  /// How far grains travel at most (sizes the overlay).
  static const double maxDrift = 90;
  static const double maxRise = 80;

  /// Part of the effect a single grain is visible for while it drifts.
  static const double life = 0.42;

  final List<Rect> sources; // in image pixels
  final List<Offset> starts; // grain centres, logical px from the row's top-left
  final List<Offset> drifts;
  final List<double> delays; // 0–1, when the grain starts to move
  final List<double> spins;

  int get length => sources.length;

  factory _Dust.fromImage({
    required ui.Image image,
    required ByteData? pixels,
    required double pixelRatio,
    required int seed,
  }) {
    final random = math.Random(seed);
    final cell = math.max(1, (grain * pixelRatio).round());
    final width = image.width;
    final height = image.height;
    final sources = <Rect>[];
    final starts = <Offset>[];
    final drifts = <Offset>[];
    final delays = <double>[];
    final spins = <double>[];

    for (var y = 0; y < height; y += cell) {
      for (var x = 0; x < width; x += cell) {
        final w = math.min(cell, width - x);
        final h = math.min(cell, height - y);
        // Skip empty (transparent) cells so only ink turns to dust.
        if (pixels != null && !_hasInk(pixels, width, x, y, w, h)) continue;

        final fx = x / width;
        sources.add(Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(),
            h.toDouble()));
        starts.add(Offset((x + w / 2) / pixelRatio, (y + h / 2) / pixelRatio));
        // Mostly up and to the right, a little spread either way.
        final angle = -math.pi / 4 + (random.nextDouble() - 0.5) * 1.3;
        final distance = 25 + random.nextDouble() * 55;
        drifts.add(Offset(math.cos(angle), math.sin(angle)) * distance);
        // Sweep left to right with some noise.
        delays.add((fx * 0.45 + random.nextDouble() * 0.12)
            .clamp(0.0, 1 - life));
        spins.add((random.nextDouble() - 0.5) * 3);
      }
    }
    return _Dust._(sources, starts, drifts, delays, spins);
  }

  static bool _hasInk(ByteData pixels, int width, int x, int y, int w, int h) {
    // Sample the centre and corners of the cell.
    final points = [
      (x + w ~/ 2, y + h ~/ 2),
      (x, y),
      (x + w - 1, y + h - 1),
    ];
    for (final (px, py) in points) {
      final alpha = pixels.getUint8((py * width + px) * 4 + 3);
      if (alpha > 12) return true;
    }
    return false;
  }
}

class _DustPainter extends CustomPainter {
  _DustPainter({
    required this.image,
    required this.dust,
    required this.progress,
    required this.pixelRatio,
  }) : super(repaint: progress);

  final ui.Image image;
  final _Dust dust;
  final Animation<double> progress;
  final double pixelRatio;

  static final Paint _paint = Paint()..filterQuality = FilterQuality.low;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    final transforms = <ui.RSTransform>[];
    final rects = <Rect>[];
    final colors = <Color>[];
    final scale = 1 / pixelRatio;

    for (var i = 0; i < dust.length; i++) {
      final local = ((t - dust.delays[i]) / _Dust.life).clamp(0.0, 1.0);
      if (local >= 1) continue;
      final eased = Curves.easeOutCubic.transform(local);
      final src = dust.sources[i];
      final centre = dust.starts[i] +
          dust.drifts[i] * eased +
          const Offset(0, _Dust.maxRise);
      transforms.add(
        ui.RSTransform.fromComponents(
          rotation: dust.spins[i] * eased,
          scale: scale * (1 - 0.35 * eased),
          anchorX: src.width / 2,
          anchorY: src.height / 2,
          translateX: centre.dx,
          translateY: centre.dy,
        ),
      );
      rects.add(src);
      colors.add(Color.fromRGBO(255, 255, 255, 1 - local));
    }
    if (rects.isEmpty) return;
    canvas.drawAtlas(
      image,
      transforms,
      rects,
      colors,
      BlendMode.modulate,
      null,
      _paint,
    );
  }

  @override
  bool shouldRepaint(_DustPainter oldDelegate) =>
      oldDelegate.image != image || oldDelegate.dust != dust;
}
