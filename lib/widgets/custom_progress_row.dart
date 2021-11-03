import 'package:flutter/material.dart';

import '../models/size.dart';

class CustomProgressRow extends StatelessWidget {
  late final double _height;
  late final Widget _child;
  CustomProgressRow({
    required double height,
    required child,
  }) {
    this._height = height;
    this._child = child;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Container(
      height: _size.height(_height),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                height: _size.height(16),
                width: _size.height(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: _size.width(3)),
                ),
              ),
              Container(
                height: _size.height(_height - 16),
                width: _size.width(3),
                color: Colors.black,
              )
            ],
          ),
          SizedBox(width: _size.width(21)),
          _child,
        ],
      ),
    );
  }
}
