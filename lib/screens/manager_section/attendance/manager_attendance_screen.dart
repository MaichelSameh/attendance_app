import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../api/manager_data_api.dart';
import '../../../controllers/controllers.dart';
import '../../../models/models.dart';
import '../../../widgets/widgets.dart';
import 'manager_attendance_details_screen.dart';

class ManagerAttendanceScreen extends StatefulWidget {
  static const String route_name = "manager_attendance_screen";

  @override
  _ManagerAttendanceScreenState createState() =>
      _ManagerAttendanceScreenState();
}

class _ManagerAttendanceScreenState extends State<ManagerAttendanceScreen> {
  final ManagerDataAPI _managerDataAPI = ManagerDataAPI();

  DateTime _selectedDate = DateTime.now();

  List<Map<String, dynamic>> _attendances = [];

  // ignore: unused_field
  int _pageNumber = 0;

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  List<String> filterList = ["all", "present", "absent", "delay", "vacation"];

  String selectedFilter = "all";

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
          _attendances = await _managerDataAPI
              .fetchAttendance(_selectedDate,
                  page: _pageNumber, filter: selectedFilter)
              .catchError(
            (error) {
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.toString()),
                ),
              );
              setState(() {
                _attendances = [];
              });
              _refreshController.refreshCompleted();
            },
          );
          setState(() {});
          _refreshController.refreshCompleted();
        },
        onLoading: () async {
          List<Map<String, dynamic>> list = await _managerDataAPI
              .fetchAttendance(_selectedDate,
                  page: _pageNumber + 1, filter: selectedFilter)
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
            _attendances.add(element);
          });
          setState(() {});
          _refreshController.loadComplete();
        },
        child: ListView(
          children: [
            Calender(
              titleKey: "attendance",
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
            _buildFilterDropdownList(_size),
            SizedBox(height: _size.height(20)),
            _buildEventsList(_size),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(Size _size) {
    return Column(
        children: _attendances.map<Widget>((element) {
      AttendanceInfo attendance = element["attendance"];
      EmployeeInfo employee = element["employee"];
      switch (attendance.state) {
        case AttendanceState.Absent:
          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).pushNamed(
                  ManagerAttendanceDetailsScreen.route_name,
                  arguments: element);
            },
            child: ManagerAttendanceCard.absent(
              startDate: attendance.startDate,
              employee: employee,
            ),
          );
        case AttendanceState.Delay:
          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).pushNamed(
                  ManagerAttendanceDetailsScreen.route_name,
                  arguments: element);
            },
            child: ManagerAttendanceCard.delay(
              startDate: attendance.startDate,
              finishDate: attendance.endDate,
              employee: employee,
            ),
          );
        case AttendanceState.Present:
          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).pushNamed(
                  ManagerAttendanceDetailsScreen.route_name,
                  arguments: element);
            },
            child: ManagerAttendanceCard.present(
              startDate: attendance.startDate,
              finishDate: attendance.endDate,
              employee: employee,
            ),
          );
        case AttendanceState.Vacation:
          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).pushNamed(
                  ManagerAttendanceDetailsScreen.route_name,
                  arguments: element);
            },
            child: ManagerAttendanceCard.vacation(
              startDate: attendance.startDate,
              employee: employee,
            ),
          );
      }
    }).toList());
  }

  Widget _buildFilterDropdownList(Size _size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _size.width(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomDropdownButton<String>(
            padding: EdgeInsets.symmetric(horizontal: _size.width(20)),
            value: selectedFilter,
            height: _size.height(61),
            width: _size.width(162),
            buttonColor: Color.fromRGBO(234, 235, 239, 1),
            borderRadius: _size.width(17),
            items: filterList
                .map<CustomDropdownButtonItem<String>>(
                  (element) => _buildDropdownItem(element, element),
                )
                .toList(),
            onChange: (dynamic value) {
              selectedFilter = value;
              setState(() {});
              _refreshController.requestRefresh();
            },
            icon: SvgPicture.asset(
              "assets/icons/arrow_down.svg",
              color: Color.fromRGBO(196, 198, 204, 1),
            ),
          ),
        ],
      ),
    );
  }

  CustomDropdownButtonItem<String> _buildDropdownItem(
      String value, String textKey) {
    return CustomDropdownButtonItem<String>(
      value: value,
      child: Text(
        Get.find<AppLocalizationController>()
            .getTranslatedValue(textKey)
            .toUpperCase(),
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(112, 112, 112, 0.7),
            ),
      ),
    );
  }
}
