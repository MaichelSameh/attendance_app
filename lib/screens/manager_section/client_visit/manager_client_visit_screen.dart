import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../api/manager_data_api.dart';
import '../../../models/models.dart';
import '../../../widgets/widgets.dart';
import 'manager_client_visit_details_screen.dart';

class ManagerClientVisitScreen extends StatefulWidget {
  static const String route_name = "manager_client_visits_screen";

  @override
  _ManagerClientVisitScreenState createState() =>
      _ManagerClientVisitScreenState();
}

class _ManagerClientVisitScreenState extends State<ManagerClientVisitScreen> {
  List<Map<String, dynamic>> _visits = [];

  final ManagerDataAPI _managerDataAPI = ManagerDataAPI();

  DateTime _selectedDate = DateTime.now();

  // ignore: unused_field
  int _pageNumber = 1;

  RefreshController _refreshController = RefreshController(
    initialRefresh: true,
    initialRefreshStatus: RefreshStatus.refreshing,
    initialLoadStatus: LoadStatus.canLoading,
  );

  TextEditingController _nameController = TextEditingController();
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
          _nameController.clear();
          _pageNumber = 1;
          _visits = await _managerDataAPI
              .fetchClientVisits(_selectedDate, _pageNumber)
              .catchError(
            (error) {
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.toString()),
                ),
              );
              setState(() {
                _visits = [];
              });
              _refreshController.refreshCompleted();
            },
          );
          setState(() {});
          _refreshController.refreshCompleted();
        },
        onLoading: () async {
          List<Map<String, dynamic>> list = await _managerDataAPI
              .fetchClientVisits(_selectedDate, _pageNumber + 1)
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
            _visits.add(element);
          });
          setState(() {});
          _refreshController.loadComplete();
        },
        child: ListView(
          children: [
            Calender(
              titleKey: "client_visits",
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
              padding: EdgeInsets.only(
                left: _size.width(24),
                right: _size.width(24),
                bottom: _size.height(22),
              ),
              child: CustomTextField(
                hintKey: "search",
                hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(196, 198, 201, 1),
                    ),
                prefixIconName: "search",
                controller: _nameController,
                onChange: (name) async {
                  _visits =
                      await _managerDataAPI.searchClientVisits(name).catchError(
                    (error) {
                      FocusScope.of(context).unfocus();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error.toString()),
                        ),
                      );
                    },
                  );
                  setState(() {});
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _size.width(30)),
              child: _buildEventsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return Column(
        children: _visits.map((element) {
      ClientVisitInfo visit = element["client_visit"];
      EmployeeInfo employee = element["employee"];
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
              ManagerClientVisitDetailsScreen.route_name,
              arguments: element);
          setState(() {});
        },
        child: ManagerClientVisitCard(
          date: visit.startVisitTime,
          employee: employee,
          clientName: visit.name,
        ),
      );
    }).toList());
  }
}
