import 'package:flutter/material.dart';

import '../../api/employee_data_api.dart';
import '../../const/const_data.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class CalenderScreen extends StatefulWidget {
  static const String route_name = "calender_screen";

  @override
  _CalenderScreenState createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  EmployeeDataAPI _employeeDataAPI = EmployeeDataAPI();

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder(
            future:
                _employeeDataAPI.fetchMonthAttendance(_selectedDate).catchError(
              (error) {
                FocusScope.of(context).unfocus();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.toString()),
                  ),
                );
              },
            ),
            builder: (ctx, snapshot) => Calender(
              titleKey: "calendar",
              onChange: (date) => setState(() {
                _selectedDate = DateTime(
                  date.year,
                  date.month,
                  date.day,
                );
              }),
              color: (date) {
                if (snapshot.hasData) {
                  Map<DateTime, String> attendance =
                      snapshot.data as Map<DateTime, String>;
                  if (date == _selectedDate) {
                    return Colors.white;
                  }
                  if (attendance.containsKey(date)) {
                    if (attendance[date] == "attend") {
                      return Color.fromRGBO(255, 255, 255, 0.5);
                    }
                    if (attendance[date] == "delay") {
                      return ConstData.delay_color;
                    }
                    if (attendance[date] == "absent") {
                      return Colors.red;
                    }
                    if (attendance[date] == "vacation") {
                      return ConstData.pending_color;
                    }
                  }
                }
                return Colors.transparent;
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _size.width(30)),
            child: FutureBuilder(
              future: _employeeDataAPI.fetchDayEvents(_selectedDate).catchError(
                (error) {
                  FocusScope.of(context).unfocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error.toString()),
                    ),
                  );
                },
              ),
              builder: (ctx, snapShot) {
                if (snapShot.connectionState == ConnectionState.waiting) {
                  return PreLoader();
                }
                if (snapShot.hasData) {
                  List<Map<String, Map<String, dynamic>?>> list =
                      snapShot.data as List<Map<String, Map<String, dynamic>?>>;
                  return AllEventsColumn(list);
                }

                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
