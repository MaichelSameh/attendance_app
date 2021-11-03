import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../controllers/localization_controller.dart';
import '../models/size.dart';
import '../const/const_data.dart';

class NotificationIcon extends StatelessWidget {
  late final int _count;

  NotificationIcon(int count) {
    this._count = count;
  }
  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Stack(
      alignment: Get.find<AppLocalizationController>().isRTLanguage
          ? Alignment.topLeft
          : Alignment.topRight,
      children: [
        Container(
          padding: EdgeInsets.only(
            top: _size.width(50),
            left: !Get.find<AppLocalizationController>().isRTLanguage
                ? _size.width(50)
                : _size.width(40),
            right: Get.find<AppLocalizationController>().isRTLanguage
                ? _size.width(50)
                : _size.width(40),
          ),
          color: Colors.transparent,
          child: SvgPicture.asset(
            "assets/icons/notification_icon.svg",
            color: Colors.white,
            width: _size.width(25),
            height: _size.height(30),
          ),
        ),
        if (_count > 0)
          Container(
            height: _size.width(20),
            width: _size.width(20),
            decoration: BoxDecoration(
              color: ConstData.failure_color,
              shape: BoxShape.circle,
            ),
            margin: EdgeInsets.only(
              top: _size.width(40),
              left: !Get.find<AppLocalizationController>().isRTLanguage
                  ? _size.width(42)
                  : _size.width(32),
              right: Get.find<AppLocalizationController>().isRTLanguage
                  ? _size.width(42)
                  : _size.width(32),
            ),
            child: Center(
              child: Text(
                _count.toString(),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}
