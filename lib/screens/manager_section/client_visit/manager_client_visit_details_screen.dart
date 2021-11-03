import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/localization_controller.dart';
import '../../../models/client_visit_info.dart';
import '../../../models/size.dart';
import '../../../widgets/widgets.dart';

class ManagerClientVisitDetailsScreen extends StatelessWidget {
  static const String route_name = "manager_client_visit_details_screen";

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Size _size = Size(context);
    ClientVisitInfo clientVisit = data["client_visit"];

    return Scaffold(
      body: Column(
        children: [
          CustomScreenHeader("client_visits"),
          SizedBox(height: _size.height(40)),
          CustomCard(
            width: 368,
            child: Column(
              children: [
                CustomProfileHeader(
                  employee: data["employee"],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: _size.width(47), vertical: _size.height(45)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomProgressRow(
                        height: 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Get.find<AppLocalizationController>()
                                  .getTranslatedValue("start_visit")
                                  .toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            _buildField(
                              _size,
                              DateFormat(Get.find<AppLocalizationController>()
                                              .isRTLanguage
                                          ? "mm : hh"
                                          : "hh : mm")
                                      .format(clientVisit.startVisitTime) +
                                  " " +
                                  (Get.find<AppLocalizationController>()
                                      .getTranslatedValue(
                                    clientVisit.startVisitTime.hour > 12
                                        ? "pm"
                                        : "am",
                                  )),
                              "clock_outline",
                              context,
                            ),
                            _buildField(
                              _size,
                              clientVisit.name,
                              "person",
                              context,
                              isDark: true,
                            ),
                          ],
                        ),
                      ),
                      clientVisit.startMeetingTime != null
                          ? CustomProgressRow(
                              height: 170,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Get.find<AppLocalizationController>()
                                        .getTranslatedValue("meet_the_client")
                                        .toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  _buildField(
                                    _size,
                                    DateFormat(Get.find<AppLocalizationController>()
                                                    .isRTLanguage
                                                ? "mm : hh"
                                                : "hh : mm")
                                            .format(
                                                clientVisit.startMeetingTime!) +
                                        " " +
                                        (Get.find<AppLocalizationController>()
                                            .getTranslatedValue(clientVisit
                                                        .startMeetingTime!
                                                        .hour >
                                                    12
                                                ? "pm"
                                                : "am")),
                                    "clock_outline",
                                    context,
                                  ),
                                  _buildField(
                                    _size,
                                    clientVisit.address,
                                    "location_icon",
                                    context,
                                  ),
                                  if (clientVisit.capturedImageLink.isNotEmpty)
                                    _buildField(
                                      _size,
                                      "photo_captured",
                                      "photo_icon",
                                      context,
                                      isDark: true,
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => CustomPopUpMessage(
                                            title: InteractiveViewer(
                                              child: Image.network(
                                                clientVisit.capturedImageLink,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                ],
                              ),
                            )
                          : Container(),
                      clientVisit.endMeetingTime != null
                          ? CustomProgressRow(
                              height: 110,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Get.find<AppLocalizationController>()
                                        .getTranslatedValue(
                                            "action_after_visit")
                                        .toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: _size.height(10)),
                                  _buildField(
                                    _size,
                                    clientVisit.nextAction,
                                    "target_icon",
                                    context,
                                  ),
                                  SizedBox(height: _size.height(6)),
                                  _buildField(
                                    _size,
                                    DateFormat(Get.find<AppLocalizationController>()
                                                    .isRTLanguage
                                                ? "mm : hh"
                                                : "hh : mm")
                                            .format(
                                                clientVisit.endMeetingTime!) +
                                        " " +
                                        (Get.find<AppLocalizationController>()
                                            .getTranslatedValue(clientVisit
                                                        .endMeetingTime!.hour >
                                                    12
                                                ? "pm"
                                                : "am")),
                                    "clock_outline",
                                    context,
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    Size _size,
    String text,
    String iconName,
    BuildContext context, {
    bool isDark = false,
    void Function()? onTap,
  }) {
    Color color = isDark
        ? Color.fromRGBO(88, 88, 88, 1)
        : Color.fromRGBO(168, 167, 167, 1);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(top: _size.height(10)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: _size.height(3)),
              child: iconName != "target_icon"
                  ? SvgPicture.asset(
                      "assets/icons/$iconName.svg",
                      height: _size.height(17),
                      width: _size.width(17),
                      color: color,
                      matchTextDirection: true,
                    )
                  : SvgPicture.asset(
                      "assets/icons/$iconName.svg",
                      height: _size.height(17),
                      width: _size.width(17),
                      matchTextDirection: true,
                    ),
            ),
            SizedBox(width: _size.width(10)),
            Container(
              width: _size.width(170),
              child: Text(
                Get.find<AppLocalizationController>().getTranslatedValue(text),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: color,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
