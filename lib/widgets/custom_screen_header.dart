import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controllers/localization_controller.dart';
import '../models/size.dart';
import 'background_circle.dart';
import 'background_sheet.dart';

class CustomScreenHeader extends StatelessWidget {
  late final String _pageTitleKey;
  CustomScreenHeader(this._pageTitleKey);
  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Stack(
      children: [
        BackgroundSheet(height: _size.height(265)),
        BackgroundCircle(
          height: _size.height(200),
          width: Size.modelWidth,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: _size.height(30)),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.only(
                  top: _size.width(50),
                  bottom: _size.width(10),
                  left: Get.find<AppLocalizationController>().isRTLanguage
                      ? _size.width(74)
                      : _size.width(37),
                  right: !Get.find<AppLocalizationController>().isRTLanguage
                      ? _size.width(47)
                      : _size.width(37),
                ),
                color: Colors.transparent,
                child: SvgPicture.asset(
                  "assets/icons/back_arrow.svg",
                  color: Colors.white,
                  width: _size.width(25),
                  height: _size.height(20),
                ),
              ),
            ),
            SizedBox(height: _size.height(12)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _size.width(37)),
              child: Text(
                Get.find<AppLocalizationController>()
                    .getTranslatedValue(_pageTitleKey),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
              ),
            ),
            SizedBox(height: _size.height(130)),
          ],
        ),
      ],
    );
  }
}
