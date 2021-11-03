import 'package:attendance_app/screens/manager_section/attendance/manager_attendance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controllers/localization_controller.dart';
import '../controllers/user_controller.dart';
import '../models/size.dart';
import '../screens/screens.dart';

class ProfileWorkCard extends StatelessWidget {
  late final String _iconName;
  late final String _titleKey;
  late final String _subTitle;
  late final Color _color;

  late final double _height;
  late final double _width;

  late final void Function(BuildContext) _onTap;
  ProfileWorkCard({
    required String titleKey,
    required String subTitle,
  }) {
    this._subTitle = subTitle;
    this._titleKey = titleKey;
    switch (titleKey) {
      case "delay":
        _color = Color.fromRGBO(143, 30, 30, 1);
        _iconName = "delay_icon";
        _height = 37;
        _width = 37;
        _onTap = (BuildContext context) {
          Navigator.pushNamed(
            context,
            Get.find<UserController>().activeEmployeeMode
                ? AttendanceScreen.route_name
                : ManagerAttendanceScreen.route_name,
          );
        };
        break;
      case "work":
        _color = Color.fromRGBO(49, 200, 142, 1);
        _iconName = "attendance_icon";
        _height = 52;
        _width = 52;
        _onTap = (BuildContext context) {
          Navigator.pushNamed(
            context,
            Get.find<UserController>().activeEmployeeMode
                ? AttendanceScreen.route_name
                : ManagerAttendanceScreen.route_name,
          );
        };
        break;
      case "vacation":
        _color = Color.fromRGBO(4, 162, 174, 1);
        _iconName = "vacation_icon";
        _height = 35;
        _width = 44;
        _onTap = (BuildContext context) {
          Navigator.pushNamed(
            context,
            Get.find<UserController>().activeEmployeeMode
                ? VacationScreen.route_name
                : ManagerVacationScreen.route_name,
          );
        };
        break;
      case "absent":
        _color = Color.fromRGBO(237, 30, 84, 1);
        _iconName = "vacation_icon";
        _height = 35;
        _width = 44;
        _onTap = (BuildContext context) {
          Navigator.pushNamed(
            context,
            Get.find<UserController>().activeEmployeeMode
                ? AttendanceScreen.route_name
                : ManagerAttendanceScreen.route_name,
          );
        };
        break;
      case "permission":
        _color = Color.fromRGBO(38, 70, 83, 1);
        _iconName = "permission_icon";
        _height = 35;
        _width = 44;
        _onTap = (BuildContext context) {
          Navigator.pushNamed(
            context,
            Get.find<UserController>().activeEmployeeMode
                ? PermissionScreen.route_name
                : ManagerPermissionScreen.route_name,
          );
        };
        break;
      case "report":
        _color = Color.fromRGBO(11, 81, 145, 1);
        _iconName = "report_icon";
        _height = 59;
        _width = 50;
        _onTap = (BuildContext context) {
          Navigator.pushNamed(
            context,
            Get.find<UserController>().activeEmployeeMode
                ? ReportScreen.route_name
                : ManagerReportScreen.route_name,
          );
        };
        break;
      case "client_visit":
        _color = Color.fromRGBO(249, 143, 103, 1);
        _iconName = "visit_icon";
        _height = 36;
        _width = 44;
        _onTap = (BuildContext context) {
          Navigator.pushNamed(
            context,
            Get.find<UserController>().activeEmployeeMode
                ? ClientVisitScreen.route_name
                : ManagerAttendanceScreen.route_name,
          );
        };
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Center(
      child: GestureDetector(
        onTap: () => _onTap(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_size.width(36)),
          child: Container(
            width: _size.width(160),
            height: _size.height(202),
            color: _color,
            child: Column(
              children: [
                Flexible(
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/icons/$_iconName.svg",
                      width: _size.width(_width),
                      height: _size.height(_height),
                    ),
                  ),
                ),
                Container(
                  height: _size.height(100),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.elliptical(
                          _size.height(235), _size.width(100)),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: _size.height(20)),
                      Text(
                        Get.find<AppLocalizationController>()
                            .getTranslatedValue(_titleKey),
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: _size.height(9)),
                      Text(
                        _subTitle,
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
