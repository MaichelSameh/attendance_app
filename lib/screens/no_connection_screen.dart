import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../controllers/localization_controller.dart';
import '../models/size.dart';
import '../widgets/custom_button.dart';

class NoConnectionScreen extends StatelessWidget {
  static const String route_name = "no_connection_screen";

  @override
  Widget build(BuildContext context) {
    final void Function(BuildContext)? onTap = ModalRoute.of(context)!
        .settings
        .arguments as void Function(BuildContext)?;
    Size _size = Size(context);
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: _size.height(71)),
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  Get.find<AppLocalizationController>()
                      .getTranslatedValue("connection_failed")
                      .toUpperCase()
                      .toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset("assets/icons/no_connection_illustrator.svg"),
              SizedBox(height: _size.height(30)),
              RichText(
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
                    ),
                  ],
                ),
              ),
              SizedBox(height: _size.height(40)),
              CustomElevatedButton(
                width: 343,
                height: 72,
                child: Text(
                  Get.find<AppLocalizationController>()
                      .getTranslatedValue("retry")
                      .toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                ),
                onTap: () {
                  onTap!(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
