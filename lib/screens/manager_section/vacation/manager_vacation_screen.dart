import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../api/manager_data_api.dart';
import '../../../models/models.dart';
import '../../../widgets/widgets.dart';
import 'manager_vacation_details_screen.dart';

class ManagerVacationScreen extends StatefulWidget {
  static const String route_name = "manager_vacation_screen";

  @override
  _ManagerVacationScreenState createState() => _ManagerVacationScreenState();
}

class _ManagerVacationScreenState extends State<ManagerVacationScreen> {
  final ManagerDataAPI _managerDataAPI = ManagerDataAPI();

  DateTime _selectedDate = DateTime.now();

  List<Map<String, dynamic>> _vacations = [];
  int _pageNumber = 1;

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  Widget build(BuildContext context) {
    Size _size = new Size(context);
    return Scaffold(
      body: SmartRefresher(
        header: MyCustomHeader(),
        footer: MyCustomFooter(),
        enablePullUp: true,
        controller: _refreshController,
        onLoading: () async {
          List<Map<String, dynamic>> list = await _managerDataAPI
              .fetchVacationRequests(_selectedDate, _pageNumber + 1)
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
            _vacations.add(element);
          });
          setState(() {});
          _refreshController.loadComplete();
        },
        onRefresh: () async {
          _pageNumber = 1;
          _vacations = await _managerDataAPI
              .fetchVacationRequests(_selectedDate, _pageNumber)
              .catchError(
            (error) {
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.toString()),
                ),
              );
              setState(() {
                _vacations = [];
              });
              _refreshController.loadComplete();
            },
          );
          setState(() {});
          _refreshController.refreshCompleted();
        },
        child: ListView(
          children: [
            Calender(
              titleKey: "vacation",
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
      children: _vacations.map(
        (element) {
          VacationInfo vacation = element["vacation"];
          EmployeeInfo employee = element["employee"];
          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).pushNamed(
                  ManagerVacationDetailsScreen.route_name,
                  arguments: element);
              _refreshController.requestRefresh();
            },
            child: vacation.id == VacationInfo.empty().id
                ? Container()
                : ManagerVacationCard(
                    date: vacation.startDate,
                    state: vacation.state,
                    employee: employee,
                    id: vacation.id,
                    refreshController: _refreshController,
                  ),
          );
        },
      ).toList(),
    );
  }
}
