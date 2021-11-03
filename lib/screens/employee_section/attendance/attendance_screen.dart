import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../api/employee_data_api.dart';
import '../../../models/models.dart';
import '../../../widgets/widgets.dart';
import 'attendance_details_screen.dart';

class AttendanceScreen extends StatefulWidget {
  static const String route_name = "attendance_screen";

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final EmployeeDataAPI _employeeDataAPI = EmployeeDataAPI();

  List<AttendanceInfo> _attendances = [];

  // ignore: unused_field
  int _pageNumber = 0;

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  Widget build(BuildContext context) {
    Size _size = new Size(context);
    return Scaffold(
      body: Container(
        height: _size.screenHeight(),
        child: Column(
          children: [
            CustomScreenHeader("attendance"),
            _buildEventsList(_size),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(Size _size) {
    return Expanded(
      child: SmartRefresher(
        enablePullUp: true,
        controller: _refreshController,
        header: MyCustomHeader(),
        footer: MyCustomFooter(),
        onRefresh: () async {
          _pageNumber = 1;
          _attendances =
              await _employeeDataAPI.fetchAttendance(_pageNumber).catchError(
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
          List<AttendanceInfo> list = await _employeeDataAPI
              .fetchAttendance(_pageNumber + 1)
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
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: _size.width(30)),
          itemBuilder: (ctx, index) {
            switch (_attendances[index].state) {
              case AttendanceState.Absent:
                return GestureDetector(
                  onTap: () {
                    _attendances[index] = Navigator.of(context).pushNamed(
                        AttendanceDetailsScreen.route_name,
                        arguments: _attendances[index]) as AttendanceInfo;
                    setState(() {});
                  },
                  child: AttendanceCard.absent(
                    startDate: _attendances[index].startDate,
                  ),
                );
              case AttendanceState.Delay:
                return GestureDetector(
                  onTap: () {
                    _attendances[index] = Navigator.of(context).pushNamed(
                        AttendanceDetailsScreen.route_name,
                        arguments: _attendances[index]) as AttendanceInfo;
                    setState(() {});
                  },
                  child: AttendanceCard.delay(
                    startDate: _attendances[index].startDate,
                    finishDate: _attendances[index].endDate,
                  ),
                );
              case AttendanceState.Present:
                return GestureDetector(
                  onTap: () {
                    _attendances[index] = Navigator.of(context).pushNamed(
                        AttendanceDetailsScreen.route_name,
                        arguments: _attendances[index]) as AttendanceInfo;
                    setState(() {});
                  },
                  child: AttendanceCard.present(
                    startDate: _attendances[index].startDate,
                    finishDate: _attendances[index].endDate,
                  ),
                );
              case AttendanceState.Vacation:
                return GestureDetector(
                  onTap: () {
                    _attendances[index] = Navigator.of(context).pushNamed(
                        AttendanceDetailsScreen.route_name,
                        arguments: _attendances[index]) as AttendanceInfo;
                    setState(() {});
                  },
                  child: AttendanceCard.vacation(
                    startDate: _attendances[index].startDate,
                  ),
                );
            }
          },
          itemCount: _attendances.length,
        ),
      ),
    );
  }
}
