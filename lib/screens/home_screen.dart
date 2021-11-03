import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../const/const_data.dart';
import '../controllers/controllers.dart';
import '../models/models.dart';
import '../screens/manager_section/manager_home_screen.dart';
import '../widgets/widgets.dart';
import 'menu_bar_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String route_name = "home_screen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Scaffold(
      body: SmartRefresher(
        controller: _refreshController,
        header: MaterialClassicHeader(
          color: ConstData.green_color,
        ),
        onRefresh: () async {
          var connectivityResult = await (Connectivity().checkConnectivity());
          if (ConnectivityResult.none == connectivityResult) {
            showNoInternetMessage(context);
            _refreshController.refreshCompleted();
            return;
          }
          await Get.find<HomeController>().fetchHomeData().catchError(
            (error) {
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.toString()),
                ),
              );
              Navigator.pop(context);
            },
          );
          Get.find<LoginController>().flushUserData();
          _refreshController.refreshCompleted();
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Stack(
              children: [
                BackgroundSheet(height: 616),
                BackgroundCircle(height: 341, width: 428),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: _size.height(45)),
                    _buildAppBar(_size),
                    SizedBox(height: _size.height(8)),
                    _buildWelcomeText(),
                    SizedBox(height: _size.height(16)),
                    Center(
                      child: Container(
                        height: _size.height(330),
                        child: StartWorkButton(),
                      ),
                    ),
                    _buildPageCarousel(_size),
                    _buildRecentActivity(_size)
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageCarousel(Size _size) {
    return GetBuilder<HomeController>(
      builder: (homeController) => CarouselSlider(
        items: [
          HeroCard(
            context: context,
            pageKey: "attendance",
            iconName: "attendance_icon",
            events: {
              ConstData.success_color:
                  (homeController.heroData["attend_count"] ?? 0).toDouble(),
              ConstData.pending_color:
                  (homeController.heroData["vacation_count"] ?? 0).toDouble(),
              ConstData.failure_color:
                  (homeController.heroData["absent_count"] ?? 0).toDouble(),
              ConstData.delay_color:
                  (homeController.heroData["delay_count"] ?? 0).toDouble(),
            },
            cardType: CardType.Attendance,
          ),
          HeroCard(
            context: context,
            pageKey: "permission",
            iconName: "permission_icon",
            events: {
              ConstData.success_color: (homeController
                          .heroData["accepted_permission_requests_count"] ??
                      0)
                  .toDouble(),
              ConstData.pending_color: (homeController
                          .heroData["pending_permission_requests_count"] ??
                      0)
                  .toDouble(),
              ConstData.failure_color: (homeController
                          .heroData["refused_permission_requests_count"] ??
                      0)
                  .toDouble(),
            },
            cardType: CardType.Permission,
          ),
          HeroCard(
            context: context,
            pageKey: "report",
            iconName: "report_icon",
            events: {
              ConstData.success_color:
                  (homeController.heroData["reports_count"] ?? 0).toDouble(),
            },
            cardType: CardType.Report,
          ),
          if (Get.find<UserController>().currentUser.isSalesman)
            HeroCard(
              context: context,
              pageKey: "client_visit",
              iconName: "visit_icon",
              events: {
                ConstData.success_color:
                    (homeController.heroData["client_visit_count"] ?? 0)
                        .toDouble(),
              },
              cardType: CardType.ClientVisit,
            ),
        ],
        options: CarouselOptions(
          enableInfiniteScroll: false,
          viewportFraction: 0.9,
          enlargeCenterPage: true,
          height: _size.height(160),
        ),
      ),
    );
  }

  Padding _buildRecentActivity(Size _size) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _size.width(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: _size.height(30)),
          Text(
            Get.find<AppLocalizationController>()
                .getTranslatedValue("recent_activity"),
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
          ),
          SizedBox(height: _size.height(25)),
          GetBuilder<HomeController>(
            builder: (homeController) {
              return AllEventsColumn(
                homeController.recentActivity,
                refresher: _refreshController,
              );
            },
          ),
        ],
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
    return GetBuilder<UserController>(
      builder: (userController) => Row(
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
          if (userController.currentUser.isManager)
            GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(ManagerHomeScreen.route_name);
                Get.find<UserController>().reverseManagerMode();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Get.find<AppLocalizationController>()
                        .getTranslatedValue("employee")
                        .toUpperCase(),
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
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
            child: GetBuilder<HomeController>(builder: (homeController) {
              return NotificationIcon(homeController.notificationsCount);
            }),
          ),
        ],
      ),
    );
  }
}
