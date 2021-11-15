import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../const/const_data.dart';
import '../../../controllers/localization_controller.dart';
import '../../../models/attendance_info.dart';
import '../../../models/size.dart';
import '../../../widgets/widgets.dart';

class ManagerAttendanceDetailsScreen extends StatelessWidget {
  static const String route_name = "manager_attendance_details_screen";

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Size _size = Size(context);
    AttendanceInfo attendance = data["attendance"];
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          CustomScreenHeader("attendance"),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _size.width(30),
            ),
            child: Column(
              children: [
                CustomCard(
                  width: 368,
                  child: Column(
                    children: [
                      CustomProfileHeader(
                        employee: data['employee'],
                      ),
                      SizedBox(height: _size.height(32)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: _size.width(45),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat("dd ").format(attendance.date) +
                                  Get.find<AppLocalizationController>()
                                      .getTranslatedValue(ConstData
                                          .listOfMonths[attendance.date.month]!)
                                      .toUpperCase() +
                                  DateFormat(", yyyy").format(attendance.date),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    color: ConstData.delay_color,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            SizedBox(height: _size.height(20)),
                            CustomProgressRow(
                              height: 77,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      Get.find<AppLocalizationController>()
                                          .getTranslatedValue("start")
                                          .toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                  Text(
                                    DateFormat(Get.find<AppLocalizationController>()
                                                    .isRTLanguage
                                                ? "mm : hh"
                                                : "hh : mm")
                                            .format(attendance.startDate) +
                                        " " +
                                        (Get.find<AppLocalizationController>()
                                            .getTranslatedValue(
                                                attendance.startDate.hour > 12
                                                    ? "pm"
                                                    : "am")),
                                  ),
                                ],
                              ),
                            ),
                            if (attendance.endDate != null)
                              CustomProgressRow(
                                height: 77,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        Get.find<AppLocalizationController>()
                                            .getTranslatedValue("finish")
                                            .toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .copyWith(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                    Text(
                                      DateFormat(Get.find<AppLocalizationController>()
                                                      .isRTLanguage
                                                  ? "mm : hh"
                                                  : "hh : mm")
                                              .format(attendance.endDate!) +
                                          " " +
                                          (Get.find<AppLocalizationController>()
                                              .getTranslatedValue(
                                                  attendance.endDate!.hour > 12
                                                      ? "pm"
                                                      : "am")),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: _size.height(36)),
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
}
