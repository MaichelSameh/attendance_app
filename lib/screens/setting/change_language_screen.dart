import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';

import '../../const/const_data.dart';
import '../../controllers/localization_controller.dart';
import '../../models/language_info.dart';
import '../../models/size.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_screen_header.dart';

class ChangeLanguageScreen extends StatefulWidget {
  static const String route_name = "change_language_screen";

  @override
  _ChangeLanguageScreenState createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Scaffold(
      body: Column(
        children: [
          CustomScreenHeader("settings"),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              separatorBuilder: (ctx, index) =>
                  SizedBox(height: _size.height(20)),
              itemBuilder: (ctx, index) {
                return _buildCustomCard(
                  size: _size,
                  language: ConstData.supportedLanguages[index],
                );
              },
              itemCount: ConstData.supportedLanguages.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCard(
      {required Size size, required LanguageInfo language}) {
    return GestureDetector(
      onTap: () {
        if (Get.find<AppLocalizationController>().currentLocale.languageCode !=
            language.languageCode)
          Get.find<AppLocalizationController>().setLocale(
            Locale(language.languageCode, language.countryCode),
          );
        Phoenix.rebirth(context);
      },
      child: CustomCard(
        width: 398,
        height: 119,
        shadows: [],
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width(30)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: size.width(20),
                height: size.width(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color.fromRGBO(235, 235, 235, 1),
                    width: size.width(3),
                  ),
                  color: Get.find<AppLocalizationController>()
                              .currentLocale
                              .languageCode ==
                          language.languageCode
                      ? ConstData.green_color
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: size.width(18)),
              Text(
                language.flag,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(width: size.width(11)),
              Text(
                Get.find<AppLocalizationController>()
                    .getTranslatedValue(language.title),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
