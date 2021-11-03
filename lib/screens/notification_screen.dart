import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../api/employee_data_api.dart';
import '../api/manager_data_api.dart';
import '../controllers/controllers.dart';
import '../models/notification_info.dart';
import '../models/size.dart';
import '../widgets/widgets.dart';

class NotificationScreen extends StatefulWidget {
  static const String route_name = "notification_Screen";

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final EmployeeDataAPI _employeeDataAPI = EmployeeDataAPI();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  int pageNumber = 1;

  List<NotificationInfo> notifications = [];
  bool _firstBuild = true;
  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Scaffold(
      body: Stack(
        children: [
          BackgroundSheet(height: _size.height(265)),
          BackgroundCircle(
            height: _size.height(200),
            width: Size.modelWidth,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _size.width(30)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: _size.height(85)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _size.width(7)),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: _size.height(16),
                      child: SvgPicture.asset(
                        "assets/icons/back_arrow.svg",
                        width: _size.width(20),
                        height: _size.height(16),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: _size.height(27)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _size.width(7)),
                  child: Text(
                    Get.find<AppLocalizationController>()
                        .getTranslatedValue("notification"),
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                  ),
                ),
                SizedBox(height: _size.height(130)),
                _buildNotificationList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return Expanded(
      child: SmartRefresher(
        controller: _refreshController,
        onRefresh: () async {
          pageNumber = 1;
          List<NotificationInfo> temp = [];
          notifications.clear();
          setState(() {});
          if (Get.find<UserController>().activeEmployeeMode) {
            temp =
                await _employeeDataAPI.fetchNotification(pageNumber).catchError(
              (error) {
                FocusScope.of(context).unfocus();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.toString()),
                  ),
                );
                _refreshController.refreshCompleted();
              },
            );
          } else {
            ManagerDataAPI _managerDataAPI = ManagerDataAPI();
            temp =
                await _managerDataAPI.fetchNotification(pageNumber).catchError(
              (error) {
                FocusScope.of(context).unfocus();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.toString()),
                  ),
                );

                _refreshController.refreshCompleted();
              },
            );
            _refreshController.refreshCompleted();
          }
          if (temp.isEmpty) {
            _refreshController.refreshCompleted();
            if (_firstBuild) {
              if (Get.find<UserController>().activeEmployeeMode) {
                Get.find<HomeController>().resetNotificationCount();
              } else {
                Get.find<ManagerHomeController>().resetNotificationCount();
              }
              _firstBuild = false;
            }
            return;
          }
          notifications = temp;
          setState(() {});
          _refreshController.refreshCompleted();
          if (_firstBuild) {
            if (Get.find<UserController>().activeEmployeeMode) {
              Get.find<HomeController>().resetNotificationCount();
            } else {
              Get.find<ManagerHomeController>().resetNotificationCount();
            }
            _firstBuild = false;
          }
        },
        onLoading: () async {
          pageNumber++;
          List<NotificationInfo> temp = [];
          if (Get.find<UserController>().activeEmployeeMode) {
            temp =
                await _employeeDataAPI.fetchNotification(pageNumber).catchError(
              (error) {
                FocusScope.of(context).unfocus();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.toString()),
                  ),
                );
              },
            );
          } else {
            ManagerDataAPI _managerDataAPI = ManagerDataAPI();
            temp =
                await _managerDataAPI.fetchNotification(pageNumber).catchError(
              (error) {
                FocusScope.of(context).unfocus();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.toString()),
                  ),
                );
              },
            );
          }
          if (temp.isEmpty) {
            return;
          }
          temp.forEach((element) {
            notifications.add(element);
          });
          setState(() {});
          _refreshController.loadComplete();
        },
        header: MyCustomHeader(),
        footer: MyCustomFooter(),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemBuilder: (ctx, index) {
            return NotificationCard(
              notification: notifications[index],
              refreshController: Get.find<UserController>().activeEmployeeMode
                  ? null
                  : _refreshController,
            );
          },
          itemCount: notifications.length,
        ),
      ),
    );
  }
}
