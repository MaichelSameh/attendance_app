import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../api/employee_data_api.dart';
import '../../../controllers/localization_controller.dart';
import '../../../models/models.dart';
import '../../../widgets/widgets.dart';
import 'permission_details_screen.dart';
import 'request_new_permission_screen.dart';

class PermissionScreen extends StatefulWidget {
  static const String route_name = "permission_screen";

  @override
  _PermissionScreenState createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final EmployeeDataAPI _employeeDataAPI = EmployeeDataAPI();

  // ignore: unused_field
  int _pageNumber = 0;

  List<PermissionInfo> _permissions = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  Widget build(BuildContext context) {
    Size _size = new Size(context);
    return Scaffold(
      body: Column(
        children: [
          CustomScreenHeader("permission"),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _size.width(30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNewEventButton(_size, context),
                  SizedBox(height: _size.height(33)),
                  _buildEventsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewEventButton(Size _size, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomElevatedButton(
          width: 172,
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SvgPicture.asset(
                "assets/icons/add.svg",
                width: _size.width(14),
                height: _size.height(14),
              ),
              Text(
                Get.find<AppLocalizationController>()
                    .getTranslatedValue("new_permission")
                    .toUpperCase(),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          onTap: () async {
            await Navigator.of(context).pushNamed(
                RequestNewPermissionScreen.route_name,
                arguments: PermissionInfo.empty());
            _refreshController.requestRefresh();
          },
        ),
      ],
    );
  }

  Widget _buildEventsList() {
    return Expanded(
      child: SmartRefresher(
        enablePullUp: true,
        controller: _refreshController,
        header: MyCustomHeader(),
        footer: MyCustomFooter(),
        onRefresh: () async {
          _pageNumber = 1;
          _permissions =
              await _employeeDataAPI.fetchPermissions(_pageNumber).catchError(
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
          setState(() {});
          _refreshController.refreshCompleted();
        },
        onLoading: () async {
          List<PermissionInfo> list = await _employeeDataAPI
              .fetchPermissions(_pageNumber + 1)
              .catchError(
            (error) {
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.toString()),
                ),
              );
              _refreshController.loadComplete();
            },
          );
          if (list.isNotEmpty) {
            _pageNumber++;
          }
          list.forEach((element) {
            _permissions.add(element);
          });
          setState(() {});
          _refreshController.loadComplete();
        },
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemBuilder: (ctx, index) {
            return GestureDetector(
              onTap: () async {
                await Navigator.of(context).pushNamed(
                    PermissionDetailsScreen.route_name,
                    arguments: _permissions[index]);
                _refreshController.requestRefresh();
                setState(() {});
              },
              child: PermissionCard(
                date: _permissions[index].dateTime,
                state: _permissions[index].state,
                permissionType: _permissions[index].permissionType,
              ),
            );
          },
          itemCount: _permissions.length,
        ),
      ),
    );
  }
}
