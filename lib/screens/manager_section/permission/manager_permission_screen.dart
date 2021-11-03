import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../api/manager_data_api.dart';
import '../../../models/models.dart';
import '../../../widgets/widgets.dart';
import 'manager_permission_details_screen.dart';

class ManagerPermissionScreen extends StatefulWidget {
  static const String route_name = "manager_permission_screen";

  @override
  _ManagerPermissionScreenState createState() =>
      _ManagerPermissionScreenState();
}

class _ManagerPermissionScreenState extends State<ManagerPermissionScreen> {
  final ManagerDataAPI _managerDataAPI = ManagerDataAPI();

  DateTime _selectedDate = DateTime.now();

  // ignore: unused_field
  int _pageNumber = 0;

  List<Map<String, dynamic>> _permissions = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  Widget build(BuildContext context) {
    Size _size = new Size(context);
    return Scaffold(
      body: SmartRefresher(
        enablePullUp: true,
        controller: _refreshController,
        header: MyCustomHeader(),
        footer: MyCustomFooter(),
        onRefresh: () async {
          _pageNumber = 1;
          _permissions = await _managerDataAPI
              .fetchPermissionsRequests(_selectedDate, _pageNumber)
              .catchError(
            (error) {
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.toString()),
                ),
              );
              setState(() {
                _permissions = [];
              });
              _refreshController.refreshCompleted();
            },
          );
          setState(() {});
          _refreshController.refreshCompleted();
        },
        onLoading: () async {
          List<Map<String, dynamic>> list = await _managerDataAPI
              .fetchPermissionsRequests(_selectedDate, _pageNumber + 1)
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
        child: ListView(
          children: [
            Calender(
              titleKey: "permissions",
              onChange: (date) {
                setState(
                  () {
                    _selectedDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      _selectedDate.hour,
                      _selectedDate.minute,
                      _selectedDate.second,
                    );
                  },
                );
                _refreshController.requestRefresh();
              },
              color: (date) {
                if (date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day) {
                  return Colors.white;
                }
                return Colors.transparent;
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _size.width(30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: _size.height(33)),
                  _buildEventsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return Column(
      children: _permissions.map(
        (element) {
          PermissionInfo permission = element["permission"];
          EmployeeInfo employee = element["employee"];
          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).pushNamed(
                  ManagerPermissionDetailsScreen.route_name,
                  arguments: element);
              _refreshController.requestRefresh();
              setState(() {});
            },
            child: ManagerPermissionCard(
              date: permission.dateTime,
              state: permission.state,
              permissionType: permission.permissionType,
              employee: employee,
              id: permission.id,
              refreshController: _refreshController,
            ),
          );
        },
      ).toList(),
    );
  }
}
