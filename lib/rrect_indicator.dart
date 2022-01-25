import 'package:flutter/material.dart';

class RRecTabIndicator extends Decoration {
  const RRecTabIndicator(
      {this.borderSide = const BorderSide(width: 2.0, color: Colors.white),
        this.insets = EdgeInsets.zero,
        this.radius = 0,
        this.color = Colors.white});

  final double radius;
  final Color color;
  final BorderSide borderSide;
  final EdgeInsetsGeometry insets;

  @override
  Decoration? lerpFrom(Decoration? a, double t) {
    if (a is RRecTabIndicator) {
      return RRecTabIndicator(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        insets: EdgeInsetsGeometry.lerp(a.insets, insets, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration? lerpTo(Decoration? b, double t) {
    if (b is RRecTabIndicator) {
      return RRecTabIndicator(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        insets: EdgeInsetsGeometry.lerp(insets, b.insets, t)!,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  _UnderlinePainter createBoxPainter([VoidCallback? onChanged]) {
    return _UnderlinePainter(this, onChanged);
  }

  Rect _indicatorRectFor(Rect rect, TextDirection textDirection) {
    final Rect indicator = insets.resolve(textDirection).deflateRect(rect);
    return Rect.fromLTWH(
      indicator.left,
      indicator.bottom - borderSide.width,
      indicator.width,
      borderSide.width,
    );
  }

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    return Path()..addRect(_indicatorRectFor(rect, textDirection));
  }
}

class _UnderlinePainter extends BoxPainter {
  _UnderlinePainter(this.decoration, VoidCallback? onChanged)
      : super(onChanged);

  final RRecTabIndicator decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & configuration.size!;
    final TextDirection textDirection = configuration.textDirection!;
    final Rect indicator = decoration._indicatorRectFor(rect, textDirection);
    final Paint paint = decoration.borderSide.toPaint()
      ..strokeCap = StrokeCap.square
      ..color = decoration.color;
    final RRect rRect =
    RRect.fromRectAndRadius(indicator, Radius.circular(decoration.radius));
    canvas.drawRRect(rRect, paint);
  }
}
