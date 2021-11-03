import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../const/const_data.dart';
import '../controllers/controllers.dart';
import '../models/models.dart';
import '../models/size.dart';
import '../widgets/background_circle.dart';
import '../widgets/pre_loader.dart';
import '../widgets/profile_picture.dart';
import 'screens.dart';

class MenuBarScreen extends StatelessWidget {
  static const String route_name = "menu_bar_screen";

  final UserInfo currentUser = Get.find<UserController>().currentUser;
  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // padding: EdgeInsets.symmetric(horizontal: _size.width(40)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ConstData.green_gradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            BackgroundCircle(
              height: 1190,
              width: 380,
              right: Directionality.of(context) == TextDirection.rtl,
              reverse: Directionality.of(context) == TextDirection.ltr,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.only(
                        top: _size.height(78),
                        bottom: _size.height(23),
                        left:
                            !Get.find<AppLocalizationController>().isRTLanguage
                                ? _size.width(50)
                                : _size.width(40),
                        right:
                            Get.find<AppLocalizationController>().isRTLanguage
                                ? _size.width(50)
                                : _size.width(40),
                      ),
                      child: SvgPicture.asset(
                        "assets/icons/cross.svg",
                        color: Colors.white,
                        width: _size.width(24),
                        height: _size.height(24),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _size.width(40)),
                  child: Column(
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                ProfileScreen.route_name,
                                arguments: 0);
                          },
                          child: ProfilePicture(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: _size.height(40)),
                      _menuBarItem(
                        size: _size,
                        context: context,
                        iconName: "home",
                        titleKey: "home",
                        height: 24,
                        width: 25,
                        routeName:
                            !Get.find<UserController>().activeEmployeeMode
                                ? HomeScreen.route_name
                                : ManagerHomeScreen.route_name,
                      ),
                      Get.find<UserController>().activeEmployeeMode
                          ? _menuBarItem(
                              size: _size,
                              context: context,
                              iconName: "calendar",
                              titleKey: "calendar",
                              height: 25,
                              width: 23,
                              routeName: CalenderScreen.route_name,
                            )
                          : _menuBarItem(
                              size: _size,
                              context: context,
                              iconName: "visit_icon",
                              titleKey: "employees",
                              height: 25,
                              width: 23,
                              routeName: EmployeeScreen.route_name,
                            ),
                      _menuBarItem(
                        size: _size,
                        context: context,
                        iconName: "attendance_icon",
                        titleKey: "attendance",
                        height: 26,
                        width: 26,
                        routeName: Get.find<UserController>().activeEmployeeMode
                            ? AttendanceScreen.route_name
                            : ManagerAttendanceScreen.route_name,
                      ),
                      if (currentUser.isSalesman ||
                          (!Get.find<UserController>().activeEmployeeMode))
                        _menuBarItem(
                          size: _size,
                          context: context,
                          iconName: "visit_icon",
                          titleKey: "client_visits",
                          height: 22,
                          width: 31,
                          routeName:
                              Get.find<UserController>().activeEmployeeMode
                                  ? ClientVisitScreen.route_name
                                  : ManagerClientVisitScreen.route_name,
                        ),
                      _menuBarItem(
                        size: _size,
                        context: context,
                        iconName: "permission_icon",
                        titleKey: "permission",
                        height: 21,
                        width: 26,
                        routeName: Get.find<UserController>().activeEmployeeMode
                            ? PermissionScreen.route_name
                            : ManagerPermissionScreen.route_name,
                      ),
                      _menuBarItem(
                        size: _size,
                        context: context,
                        iconName: "vacation_icon",
                        titleKey: "vacation",
                        height: 21,
                        width: 26,
                        routeName: Get.find<UserController>().activeEmployeeMode
                            ? VacationScreen.route_name
                            : ManagerVacationScreen.route_name,
                      ),
                      _menuBarItem(
                        size: _size,
                        context: context,
                        iconName: "report_icon",
                        titleKey: "report",
                        height: 25,
                        width: 22,
                        routeName: Get.find<UserController>().activeEmployeeMode
                            ? ReportScreen.route_name
                            : ManagerReportScreen.route_name,
                      ),
                      _menuBarItem(
                          size: _size,
                          context: context,
                          iconName: "setting",
                          titleKey: "settings",
                          height: 24,
                          width: 23,
                          routeName: SettingScreen.route_name),
                      _menuBarItem(
                        size: _size,
                        context: context,
                        iconName: "logout",
                        titleKey: "logout",
                        height: 25,
                        width: 26,
                        routeName: "logout",
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuBarItem({
    required Size size,
    required BuildContext context,
    required String iconName,
    required String titleKey,
    required double height,
    required double width,
    required String routeName,
  }) {
    return GestureDetector(
      onTap: () async {
        if (iconName == "home") return;
        if (routeName == "logout") {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) => PreLoader(),
          );
          await Get.find<LoginController>().logout();
          Phoenix.rebirth(context);
          return;
        }
        Navigator.of(context).pushNamed(routeName);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: size.height(10)),
        child: Row(
          children: [
            SvgPicture.asset(
              "assets/icons/$iconName.svg",
              width: size.width(width),
              height: size.height(height),
              color: iconName == "home" ? Colors.white70 : Colors.white,
              matchTextDirection: true,
            ),
            SizedBox(width: size.width(13)),
            Text(
              Get.find<AppLocalizationController>()
                  .getTranslatedValue(titleKey),
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: iconName == "home" ? Colors.white70 : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
