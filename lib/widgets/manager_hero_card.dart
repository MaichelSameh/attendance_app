import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/localization_controller.dart';
import '../models/size.dart' as s;

class ManagerHeroCard extends StatelessWidget {
  late final Widget _icon;
  late final Color _color;
  late final double _percent;
  late final int _count;
  late final String _titleKey;
  final double _height = 28;
  ManagerHeroCard({
    required Widget icon,
    required Color color,
    required double percent,
    required int count,
    required String titleKey,
  }) {
    this._color = color;
    this._count = count;
    this._icon = icon;
    this._percent = percent;
    this._titleKey = titleKey;
  }

  @override
  Widget build(BuildContext context) {
    s.Size _size = s.Size(context);
    return Center(
      child: Container(
        height: _size.height(158),
        width: _size.width(368),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(226, 226, 226, 0.16),
              offset: Offset(0, 4),
              blurRadius: 17,
            ),
          ],
          borderRadius: BorderRadius.circular(_size.width(41)),
        ),
        child: Row(
          children: [
            SizedBox(width: _size.width(25)),
            _icon,
            SizedBox(width: _size.width(20)),
            Text(
              Get.find<AppLocalizationController>()
                  .getTranslatedValue(_titleKey)
                  .toUpperCase(),
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            Spacer(),
            Container(
              height: _size.height(_height),
              width: _size.height(_height),
              child: CustomPaint(
                painter: _PaintProgressCircle(
                    _percent, _size.height(_height), _color),
                child: Center(
                  child: Text(
                    _count.toString(),
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ),
            ),
            SizedBox(width: _size.width(42)),
          ],
        ),
      ),
    );
  }
}

class _PaintProgressCircle extends CustomPainter {
  final double percent;
  final double height;
  final Color color;
  final double stroke = 7;
  _PaintProgressCircle(this.percent, this.height, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      Rect.fromCircle(center: Offset(height / 2, height / 2), radius: height),
      -math.pi / 2,
      percent * math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color,
    );
    canvas.drawCircle(
      Offset(height / 2, height / 2),
      height,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color.withOpacity(0.4),
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(height / 2, height / 2), radius: height),
      -math.pi / 2,
      0.005 * math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = Colors.white
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(height / 2, height / 2), radius: height),
      (percent * math.pi * 2) + (-math.pi / 2),
      0.005 * math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = Colors.white
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
