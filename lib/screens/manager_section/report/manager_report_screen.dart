import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../api/manager_data_api.dart';
import '../../../models/models.dart';
import '../../../widgets/widgets.dart';
import 'manager_report_details_screen.dart';

class ManagerReportScreen extends StatefulWidget {
  static const String route_name = "manager_report_screen";

  @override
  _ManagerReportScreenState createState() => _ManagerReportScreenState();
}

class _ManagerReportScreenState extends State<ManagerReportScreen> {
  final ManagerDataAPI _managerDataAPI = ManagerDataAPI();

  DateTime _selectedDate = DateTime.now();

  // ignore: unused_field
  int _pageNumber = 1;

  List<Map<String, dynamic>> _reports = [];

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
          _reports = await _managerDataAPI
              .fetchReports(_selectedDate, _pageNumber)
              .catchError(
            (error) {
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.toString()),
                ),
              );
              setState(() {
                _reports = [];
              });
              _refreshController.refreshCompleted();
            },
          );
          setState(() {});
          _refreshController.refreshCompleted();
        },
        onLoading: () async {
          List<Map<String, dynamic>> list = await _managerDataAPI
              .fetchReports(_selectedDate, _pageNumber + 1)
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
            _reports.add(element);
          });
          setState(() {});
          _refreshController.loadComplete();
        },
        child: ListView(
          children: [
            Calender(
              titleKey: "report",
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
              child: _buildEventsList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(BuildContext context) {
    return Column(
      children: _reports.map((element) {
        ReportInfo report = element["report"];
        EmployeeInfo employee = element["employee"];
        return GestureDetector(
          onTap: () async {
            await Navigator.of(context).pushNamed(
                ManagerReportDetailsScreen.route_name,
                arguments: element);
            _refreshController.requestRefresh();
          },
          child: ManagerReportCard(
            date: report.date,
            title: report.title,
            employee: employee,
          ),
        );
      }).toList(),
    );
  }
}
