import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../const/const_data.dart';
import '../controllers/localization_controller.dart';
import 'custom_pop_up_message.dart';

void showNoInternetMessage(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => CustomPopUpMessage(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                "assets/icons/cross.svg",
                color: ConstData.green_color,
                width: 15,
                height: 15,
              ),
            ),
          ),
        ],
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 43),
        child: SvgPicture.asset("assets/icons/no_connection_illustrator.svg"),
      ),
      body: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: Get.find<AppLocalizationController>()
                  .getTranslatedValue("connection_error_title")
                  .toUpperCase(),
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextSpan(text: "\n\n"),
            TextSpan(
              text: Get.find<AppLocalizationController>()
                  .getTranslatedValue("connection_error_body"),
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
            )
          ],
        ),
      ),
    ),
  );
}
