import 'package:flutter/material.dart';

import '../models/size.dart';

class CustomCard extends StatelessWidget {
  late final double? _height;
  late final double? _width;
  late final Widget? _child;
  late final Color? _backgroundColor;
  late final List<BoxShadow>? _shadows;
  CustomCard({
    double? height,
    double? width,
    Widget? child,
    Color? backgroundColor,
    List<BoxShadow>? shadows,
  }) {
    this._backgroundColor = backgroundColor;
    this._child = child;
    this._height = height;
    this._shadows = shadows;
    this._width = width;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Container(
      height: _height == null ? null : _size.height(_height!),
      width: _width == null ? null : _size.width(_width!),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_size.width(41)),
        boxShadow: _shadows == null
            ? [
                BoxShadow(
                  color: Color.fromRGBO(226, 226, 226, 0.5),
                  blurRadius: 8,
                  offset: Offset(0, 11),
                ),
              ]
            : _shadows,
        color: _backgroundColor == null ? Colors.white : _backgroundColor,
      ),
      child: _child,
    );
  }
}
