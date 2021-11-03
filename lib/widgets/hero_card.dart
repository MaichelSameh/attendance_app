import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../const/const_data.dart';
import '../controllers/localization_controller.dart';
import '../models/size.dart' as s;
import '../screens/screens.dart';
import 'cards.dart';

class HeroCard extends StatelessWidget {
  late final String _iconName;
  late final String _pageKey;

  late final Map<Color, double> _events;

  late final double _iconWidth;
  late final double _iconHeight;

  late final int _count;

  late final Color _color;

  late final void Function() _onTap;

  HeroCard({
    required String pageKey,
    required String iconName,
    required Map<Color, double> events,
    // required int count,
    required CardType cardType,
    required BuildContext context,
  }) {
    this._events = events;
    this._iconName = iconName;
    this._pageKey = pageKey;

    int count = 0;
    _events.forEach((key, value) {
      count += value.toInt();
    });
    this._count = count;
    switch (cardType) {
      case CardType.Attendance:
        this._iconWidth = 31.11;
        this._iconHeight = 31.11;
        this._color = ConstData.green_color;
        this._onTap = () {
          Navigator.of(context).pushNamed(AttendanceScreen.route_name);
        };
        break;
      case CardType.ClientVisit:
        this._iconWidth = 34.77;
        this._iconHeight = 25.29;
        this._color = ConstData.client_visit_color;
        this._onTap = () {
          Navigator.of(context).pushNamed(ClientVisitScreen.route_name);
        };
        break;
      case CardType.Permission:
        this._iconWidth = 36.13;
        this._iconHeight = 28.91;
        this._color = ConstData.permission_color;
        this._onTap = () {
          Navigator.of(context).pushNamed(PermissionScreen.route_name);
        };
        break;
      case CardType.Report:
        this._iconWidth = 31.44;
        this._iconHeight = 36.99;
        this._color = Color.fromRGBO(11, 81, 145, 1);
        this._onTap = () {
          Navigator.of(context).pushNamed(ReportScreen.route_name);
        };
        break;
      default:
        this._iconWidth = 36.24;
        this._iconHeight = 28.99;
        this._color = Color.fromRGBO(252, 66, 127, 1);
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    s.Size _size = s.Size(context);
    return GestureDetector(
      onTap: _onTap,
      child: Center(
        child: Container(
          width: _size.width(368),
          height: _size.height(158),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_size.width(41)),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(226, 226, 226, 0.16),
                offset: Offset(0, 4),
                blurRadius: 17,
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: _size.width(20)),
          alignment: Alignment.center,
          child: Row(
            children: [
              SvgPicture.asset(
                "assets/icons/$_iconName.svg",
                width: _size.width(_iconWidth),
                height: _size.height(_iconHeight),
                color: _color,
                matchTextDirection: true,
              ),
              SizedBox(width: _size.width(20)),
              Text(
                Get.find<AppLocalizationController>()
                    .getTranslatedValue(_pageKey),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontWeight: FontWeight.w900, fontSize: 17),
              ),
              Spacer(),
              Container(
                width: _size.height(26),
                height: _size.height(26),
                child: CustomPaint(
                  painter: _ProgressCirclePainter(_events, _size.height(26)),
                  child: Center(
                    child: Text(
                      _count.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
              SizedBox(width: _size.width(20)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCirclePainter extends CustomPainter {
  final Map<Color, double> _events;
  final double _height;

  _ProgressCirclePainter(this._events, this._height);

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 6;
    Rect myRect = Rect.fromCircle(
        center: Offset(_height / 2, _height / 2), radius: _height);

    double radianLength = 0;
    double allOccurrences = 0;

    _events.forEach((color, occurrence) {
      allOccurrences += occurrence;
    });
    if (allOccurrences == 0) {
      canvas.drawArc(
        myRect,
        0,
        2 * math.pi,
        false,
        Paint()
          ..color = Colors.grey
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke,
      );
      return;
    }
    _events.forEach((color, occurrence) {
      _events.update(color, (value) => value * 100 / allOccurrences);
    });
    allOccurrences = 100;
    double radianStart = -math.pi / 2;
    _events.forEach((color, occurrence) {
      radianLength = 2 * math.pi * occurrence / allOccurrences;
      canvas.drawArc(
        myRect,
        radianStart,
        radianLength,
        false,
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke,
      );
      radianStart += radianLength;
    });
    radianStart = -math.pi / 2;
    _events.forEach((color, occurrence) {
      radianLength = 2 * math.pi / allOccurrences;
      canvas.drawArc(
        myRect,
        radianStart - (radianLength / 2),
        radianLength / 2,
        false,
        Paint()
          ..color = Colors.white
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      radianStart += 2 * math.pi * occurrence / allOccurrences;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
