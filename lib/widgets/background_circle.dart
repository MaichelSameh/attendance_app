import 'package:flutter/material.dart';

import '../const/const_data.dart';
import '../models/size.dart' as s;

class BackgroundCircle extends StatelessWidget {
  late final double _height;
  late final double _width;

  late final bool _right;
  late final bool _reverse;

  BackgroundCircle({
    required double height,
    required double width,
    bool right = true,
    bool reverse = false,
  }) {
    this._height = height;
    this._right = right;
    this._width = width;
    this._reverse = reverse;
  }

  @override
  Widget build(BuildContext context) {
    s.Size _size = new s.Size(context);
    return Opacity(
      opacity: 0.9,
      child: Container(
        height: _size.height(_height),
        width: _size.width(_width),
        child: CustomPaint(
          painter: _CirclePainter(
            _size.height(_height),
            _size.width(_width),
            _right,
            _reverse,
          ),
        ),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double _radius = 313;
  final double _height;
  final double _width;
  final bool _right;
  final bool _reverse;
  _CirclePainter(this._height, this._width, this._right, this._reverse);
  @override
  void paint(Canvas canvas, Size size) {
    Offset center = _right
        ? Offset((s.Size.modelWidth - _width) + _radius, _height - _radius)
        : Offset(_width - _radius, _height - _radius);
    canvas.drawCircle(
      center,
      _radius,
      Paint()
        ..shader = LinearGradient(
          colors: _reverse
              ? ConstData.green_gradient.reversed.toList()
              : ConstData.green_gradient,
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ).createShader(
          Rect.fromCircle(center: center, radius: _radius),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
