import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../api/employee_data_api.dart';
import '../../../const/const_data.dart';
import '../../../controllers/localization_controller.dart';
import '../../../models/attendance_info.dart';
import '../../../models/size.dart';
import '../../../widgets/widgets.dart';

class AttendanceDetailsScreen extends StatelessWidget {
  static const String route_name = "attendance_details_screen";

  final EmployeeDataAPI _employeeDataAPI = EmployeeDataAPI();

  @override
  Widget build(BuildContext context) {
    AttendanceInfo attendance =
        ModalRoute.of(context)!.settings.arguments as AttendanceInfo;
    Size _size = Size(context);
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
                  height: 307,
                  child: Column(
                    children: [
                      CustomTitleHeader(
                        width: 368,
                        // height: 91,
                        title: DateFormat("dd ").format(attendance.startDate) +
                            ConstData
                                .listOfMonths[attendance.startDate.month]! +
                            DateFormat(",yyy").format(attendance.startDate),
                        leading: SvgPicture.asset(
                          "assets/icons/attendance_icon.svg",
                          width: _size.width(33),
                          height: _size.height(33),
                        ),
                        backgroundColor: Color.fromRGBO(49, 200, 142, 1),
                      ),
                      SizedBox(height: _size.height(42)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: _size.width(45),
                        ),
                        child: Column(
                          children: [
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
                    ],
                  ),
                ),
                SizedBox(height: _size.height(20)),
                FutureBuilder(
                  future: _employeeDataAPI
                      .fetchDayEvents(attendance.startDate)
                      .catchError(
                    (error) {
                      FocusScope.of(context).unfocus();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error.toString()),
                        ),
                      );
                    },
                  ),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return PreLoader();
                    } else {
                      List<Map<String, Map<String, dynamic>?>> data = snapshot
                          .data as List<Map<String, Map<String, dynamic>?>>;
                      data.removeWhere(
                          (element) => element.keys.first == "attendance");
                      return AllEventsColumn(data);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
