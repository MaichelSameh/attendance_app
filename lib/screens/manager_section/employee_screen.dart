import 'package:attendance_app/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../api/manager_data_api.dart';
import '../../models/models.dart';
import '../../models/size.dart';
import '../../widgets/widgets.dart';
import '../profile_screen.dart';

class EmployeeScreen extends StatefulWidget {
  static const String route_name = "employee_screen";
  @override
  _EmployeeScreenState createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  ManagerDataAPI _managerDataAPI = ManagerDataAPI();

  List<EmployeeInfo> _employees = [];

  int _pageNumber = 1;

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Scaffold(
      body: Column(
        children: [
          CustomScreenHeader("employees"),
          SizedBox(height: _size.height(14)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _size.width(24)),
            child: CustomTextField(
              hintKey: "search",
              hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(196, 198, 201, 1),
                  ),
              prefixIconName: "search",
              onChange: (name) async {
                _employees = await _managerDataAPI.searchEmployees(name);
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: _size.height(18),
                right: _size.width(24),
                left: _size.width(24),
              ),
              child: SmartRefresher(
                controller: _refreshController,
                header: MyCustomHeader(),
                footer: MyCustomFooter(),
                onRefresh: () async {
                  _employees = await _managerDataAPI
                      .fetchDepartmentEmployees()
                      .catchError(
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
                  List<EmployeeInfo> list = await _managerDataAPI
                      .fetchDepartmentEmployees(_pageNumber + 1)
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
                    _employees.add(element);
                  });
                  setState(() {});
                  _refreshController.loadComplete();
                },
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemBuilder: (ctx, index) => Padding(
                    padding: EdgeInsets.symmetric(vertical: _size.height(10)),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                            ProfileScreen.route_name,
                            arguments: _employees[index].id);
                      },
                      child: CustomProfileHeader(
                        employee: _employees[index],
                        color: Colors.white,
                        shadow: [],
                      ),
                    ),
                  ),
                  itemCount: _employees.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
