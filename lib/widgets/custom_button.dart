import 'package:flutter/material.dart';

import '../models/size.dart';
import '../const/const_data.dart';

class CustomElevatedButton extends StatelessWidget {
  late final double _width;
  late final double _height;

  late final BorderRadius? _borderRadius;

  late final Widget _child;

  late final Color? _color;

  late final List<Color>? _gradient;

  late final void Function()? _onTap;

  CustomElevatedButton({
    required double width,
    required double height,
    required Widget child,
    BorderRadius? borderRadius,
    Color? color,
    void Function()? onTap,
    List<Color>? gradient,
  }) {
    this._borderRadius = borderRadius;
    this._child = child;
    this._color = color;
    this._height = height;
    this._width = width;
    this._onTap = onTap;
    this._gradient = gradient;
  }
  @override
  Widget build(BuildContext context) {
    Size _size = new Size(context);
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        width: _size.width(_width),
        height: _size.height(_height),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: _borderRadius ?? BorderRadius.circular(_size.width(10)),
          gradient: _gradient == null
              ? null
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _gradient ?? [],
                ),
          color: _color ?? ConstData.green_color,
        ),
        child: _child,
      ),
    );
  }
}
