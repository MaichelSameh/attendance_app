import 'package:flutter/material.dart';

class StartWorkButtonBackground extends StatelessWidget {
  late final double _maxRadius;
  late final double _minRadius;
  late final double _layersCount;

  late final List<Color> _colors;

  late final Widget _child;
  StartWorkButtonBackground({
    required double maxRadius,
    required double minRadius,
    //how many layers are in the background
    required double layersCount,
    required List<Color> colors,
    required Widget child,
  }) {
    this._maxRadius = maxRadius;
    this._minRadius = minRadius;
    this._layersCount = layersCount;
    this._colors = colors;
    this._child = child;
  }

  List<Widget> _generateLayers() {
    List<Widget> layers = [];
    for (int i = 0; i < _layersCount; i++) {
      layers.add(
        CircleAvatar(
          radius:
              _maxRadius - (i * (_maxRadius - _minRadius).abs() / _layersCount),
          backgroundColor:
              _colors[i <= _colors.length ? i : _colors.length - 1],
        ),
      );
    }
    layers.add(_child);
    return layers;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: _generateLayers(),
    );
  }
}
