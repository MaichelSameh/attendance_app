import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../api/employee_data_api.dart';
import '../../../api/employee_data_uploader_api.dart';
import '../../../models/models.dart';
import '../../../widgets/widgets.dart';
import 'client_visit_details_screen.dart';

class ClientVisitScreen extends StatefulWidget {
  static const String route_name = "client_visits_screen";

  @override
  _ClientVisitScreenState createState() => _ClientVisitScreenState();
}

class _ClientVisitScreenState extends State<ClientVisitScreen> {
  List<ClientVisitInfo> _visits = [];

  final EmployeeDataAPI _employeeDataAPI = EmployeeDataAPI();

  // ignore: unused_field
  int _pageNumber = 1;

  TextEditingController _nameController = TextEditingController();

  RefreshController _refreshController = RefreshController(
    initialRefresh: true,
    initialRefreshStatus: RefreshStatus.refreshing,
    initialLoadStatus: LoadStatus.canLoading,
  );

  @override
  Widget build(BuildContext context) {
    Size _size = new Size(context);
    return Scaffold(
      body: Column(
        children: [
          CustomScreenHeader("client_visits"),
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
                EmployeeDataUploaderAPI _employeeDataUploaderAPI =
                    EmployeeDataUploaderAPI();
                _visits = await _employeeDataUploaderAPI
                    .searchClientVisits(name)
                    .catchError(
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
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _size.width(30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventsList(),
                ],
              ),
            ),
          ),
        ],
      ),
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
          _nameController.clear();
          _pageNumber = 1;
          _visits =
              await _employeeDataAPI.fetchClientVisits(_pageNumber).catchError(
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
          List<ClientVisitInfo> list = await _employeeDataAPI
              .fetchClientVisits(_pageNumber + 1)
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
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemBuilder: (ctx, index) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                    ClientVisitDetailsScreen.route_name,
                    arguments: _visits[index]);
                setState(() {});
              },
              child: ClientVisitCard(
                date: _visits[index].startVisitTime,
                clientName: _visits[index].name,
              ),
            );
          },
          itemCount: _visits.length,
        ),
      ),
    );
  }
}
