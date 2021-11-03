import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../const/const_data.dart';
import '../../controllers/controllers.dart';
import '../../models/models.dart';
import '../../models/size.dart';
import '../../widgets/widgets.dart';
import '../screens.dart';

class ManagerHomeScreen extends StatefulWidget {
  static const String route_name = "manager_home_screen";

  @override
  _ManagerHomeScreenState createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  RefreshController _refreshController = RefreshController(
    initialRefresh: true,
  );
  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Scaffold(
      body: SmartRefresher(
        header: MyCustomHeader(),
        footer: MyCustomFooter(),
        controller: _refreshController,
        onRefresh: () async {
          await Get.find<ManagerHomeController>()
              .cardsData()
              .catchError((error) {
            print("MANAGER_HOME_SCREEN cardsData error: $error");
            _refreshController.refreshCompleted();
          });
          await Get.find<ManagerHomeController>()
              .fetchPendingRequests()
              .catchError((error) {
            print("MANAGER_HOME_SCREEN fetchPendingRequests error: $error");
            _refreshController.refreshCompleted();
          });
          await Get.find<ManagerHomeController>()
              .fetchNewReports()
              .catchError((error) {
            print("MANAGER_HOME_SCREEN fetchNewReports error: $error");
            _refreshController.refreshCompleted();
          });
          _refreshController.refreshCompleted();
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Stack(
              children: [
                BackgroundSheet(height: 474),
                BackgroundCircle(height: 241, width: 428),
                GetBuilder<ManagerHomeController>(
                  builder: (homeController) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: _size.height(42)),
                        _buildAppBar(_size),
                        SizedBox(height: _size.height(20)),
                        _buildWelcomeText(),
                        SizedBox(height: _size.height(65)),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: _size.width(18)),
                          child: Text(
                            Get.find<AppLocalizationController>()
                                .getTranslatedValue("today_attendance")
                                .toUpperCase(),
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                          ),
                        ),
                        SizedBox(height: _size.height(30)),
                        _buildCarousel(_size, homeController),
                        _buildRequestsCarousel(_size, homeController),
                        SizedBox(height: _size.height(36)),
                        _buildReportsCarousel(_size, homeController),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Column _buildReportsCarousel(
      Size _size, ManagerHomeController homeController) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _size.width(18)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                Get.find<AppLocalizationController>()
                    .getTranslatedValue("reports")
                    .toUpperCase(),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(ManagerReportScreen.route_name);
                },
                child: Container(
                  child: Text(
                    Get.find<AppLocalizationController>()
                        .getTranslatedValue("see_all")
                        .toUpperCase(),
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ConstData.green_color,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: _size.height(20)),
        CarouselSlider(
          items: homeController.newReports.map<Widget>(
            (element) {
              ReportInfo report = element["report"];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    ManagerPermissionDetailsScreen.route_name,
                    arguments: element,
                  );
                },
                child: ManagerReportCard(
                  date: report.date,
                  title: report.title,
                  employee: element["employee"],
                ),
              );
            },
          ).toList(),
          options: CarouselOptions(
            enlargeCenterPage: false,
            enableInfiniteScroll: false,
            height: _size.height(340),
            viewportFraction: 0.9,
          ),
        ),
      ],
    );
  }

  Column _buildRequestsCarousel(
      Size _size, ManagerHomeController homeController) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _size.width(18)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Get.find<AppLocalizationController>()
                    .getTranslatedValue("requests")
                    .toUpperCase(),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(RequestsScreen.route_name);
                },
                child: Container(
                  padding: EdgeInsets.all(_size.width(20)),
                  child: Text(
                    Get.find<AppLocalizationController>()
                        .getTranslatedValue("see_all")
                        .toUpperCase(),
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ConstData.green_color,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: _size.height(20)),
        CarouselSlider(
          items: homeController.pendingRequests.map<Widget>(
            (element) {
              VacationInfo vacation = VacationInfo.empty();
              PermissionInfo permission = PermissionInfo.empty();
              element.containsKey("permission")
                  ? permission = element["permission"] ?? PermissionInfo.empty()
                  : vacation = element["vacation"] ?? VacationInfo.empty();
              return element.containsKey("permission")
                  ? permission.id != PermissionInfo.empty().id
                      ? GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              ManagerPermissionDetailsScreen.route_name,
                              arguments: element,
                            );
                          },
                          child: ManagerPermissionCard(
                            date: permission.dateTime,
                            state: permission.state,
                            permissionType: permission.permissionType,
                            employee: element["employee"],
                            id: permission.id,
                            refreshController: _refreshController,
                          ),
                        )
                      : Container()
                  : element.containsKey("vacation")
                      ? vacation.id != VacationInfo.empty().id
                          ? GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  ManagerVacationDetailsScreen.route_name,
                                  arguments: element,
                                );
                              },
                              child: ManagerVacationCard(
                                date: vacation.startDate,
                                state: vacation.state,
                                employee: element["employee"],
                                id: vacation.id,
                                refreshController: _refreshController,
                              ),
                            )
                          : Container()
                      : Container();
            },
          ).toList(),
          options: CarouselOptions(
            enlargeCenterPage: false,
            enableInfiniteScroll: false,
            height: _size.height(340),
            viewportFraction: 0.9,
          ),
        ),
      ],
    );
  }

  CarouselSlider _buildCarousel(
      Size _size, ManagerHomeController homeController) {
    return CarouselSlider(
      items: [
        ManagerHeroCard(
          icon: SvgPicture.asset(
            "assets/icons/attendance_icon.svg",
            color: ConstData.green_color,
            width: _size.width(44),
            height: _size.height(44),
          ),
          color: ConstData.green_color,
          percent: homeController.getPercent(homeController.attendedEmployee),
          count: homeController.attendedEmployee,
          titleKey: "present",
        ),
        ManagerHeroCard(
          icon: SvgPicture.asset(
            "assets/icons/attendance_icon.svg",
            color: ConstData.delay_color,
            width: _size.width(44),
            height: _size.height(44),
          ),
          color: ConstData.delay_color,
          percent: homeController.getPercent(homeController.delayedEmployee),
          count: homeController.delayedEmployee,
          titleKey: "delay",
        ),
        ManagerHeroCard(
          icon: SvgPicture.asset(
            "assets/icons/attendance_icon.svg",
            color: ConstData.failure_color,
            width: _size.width(44),
            height: _size.height(44),
          ),
          color: ConstData.failure_color,
          percent: homeController.getPercent(homeController.absentEmployee),
          count: homeController.absentEmployee,
          titleKey: "absent",
        ),
        ManagerHeroCard(
          icon: SvgPicture.asset(
            "assets/icons/attendance_icon.svg",
            color: ConstData.pending_color,
            width: _size.width(44),
            height: _size.height(44),
          ),
          color: ConstData.pending_color,
          percent: homeController.getPercent(homeController.inVacationEmployee),
          count: homeController.inVacationEmployee,
          titleKey: "vacation",
        ),
        ManagerHeroCard(
          icon: SvgPicture.asset(
            "assets/icons/permission_icon.svg",
            color: ConstData.permission_color,
            width: _size.width(44),
            height: _size.height(34),
          ),
          color: ConstData.permission_color,
          percent: homeController.getPercent(homeController.acceptedPermission),
          count: homeController.acceptedPermission,
          titleKey: "permissions",
        ),
      ],
      options: CarouselOptions(
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Get.find<AppLocalizationController>().getTranslatedValue(
                DateTime.now().hour >= 5 && DateTime.now().hour <= 12
                    ? "good_morning"
                    : DateTime.now().hour > 12 && DateTime.now().hour <= 18
                        ? "good_afternoon"
                        : "good_evening"),
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
          ),
          GetBuilder<UserController>(
            builder: (userController) => Text(
              Get.find<AppLocalizationController>().getTranslatedValue("mr") +
                  " " +
                  userController.currentUser.name,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(Size _size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageTransition(
                child: MenuBarScreen(),
                type: ConstData.rtl_language_codes.contains(
                        Get.find<AppLocalizationController>()
                            .currentLocale
                            .languageCode)
                    ? PageTransitionType.rightToLeft
                    : PageTransitionType.leftToRight,
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.only(
              top: _size.width(50),
              bottom: _size.width(10),
              left: Get.find<AppLocalizationController>().isRTLanguage
                  ? _size.width(50)
                  : _size.width(40),
              right: !Get.find<AppLocalizationController>().isRTLanguage
                  ? _size.width(50)
                  : _size.width(40),
            ),
            color: Colors.transparent,
            child: SvgPicture.asset(
              "assets/icons/menu.svg",
              color: Colors.white,
              width: _size.width(21),
              height: _size.height(21),
              matchTextDirection: true,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Get.find<UserController>().reverseManagerMode();
            Navigator.of(context).pushReplacementNamed(HomeScreen.route_name);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Get.find<AppLocalizationController>()
                    .getTranslatedValue("manager")
                    .toUpperCase(),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              SizedBox(width: _size.width(14)),
              SvgPicture.asset(
                "assets/icons/reverse_icon.svg",
                width: _size.width(16),
                height: _size.height(23),
                color: Colors.white,
                matchTextDirection: true,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(NotificationScreen.route_name);
          },
          child: GetBuilder<ManagerHomeController>(
            builder: (homeController) {
              return NotificationIcon(homeController.notificationsCount);
            },
          ),
        ),
      ],
    );
  }
}
