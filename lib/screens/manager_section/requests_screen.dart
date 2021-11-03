import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../api/manager_data_api.dart';
import '../../models/models.dart';
import '../../screens/screens.dart';
import '../../widgets/widgets.dart';

class RequestsScreen extends StatefulWidget {
  static const String route_name = "requests_screen";

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  int _pageNumber = 1;

  List<Map<String, dynamic>> requests = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomScreenHeader("requests"),
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              header: MyCustomHeader(),
              footer: MyCustomFooter(),
              onRefresh: () async {
                _pageNumber = 1;
                ManagerDataAPI _managerDataAPI = ManagerDataAPI();
                requests = await _managerDataAPI
                    .fetchPendingRequests(_pageNumber)
                    .catchError(
                  (error) {
                    FocusScope.of(context).unfocus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          error.toString(),
                        ),
                      ),
                    );
                    _refreshController.refreshCompleted();
                  },
                );
                _refreshController.refreshCompleted();
                setState(() {});
              },
              onLoading: () async {
                ManagerDataAPI _managerDataAPI = ManagerDataAPI();
                List<Map<String, dynamic>> list = await _managerDataAPI
                    .fetchPendingRequests(_pageNumber + 1)
                    .catchError(
                  (error) {
                    FocusScope.of(context).unfocus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          error.toString(),
                        ),
                      ),
                    );
                    _refreshController.refreshCompleted();
                  },
                );
                if (list.isNotEmpty) {
                  _pageNumber++;
                  list.forEach((element) {
                    requests.add(element);
                  });
                }
                _refreshController.refreshCompleted();
                setState(() {});
              },
              child: ListView.builder(
                itemBuilder: (ctx, index) {
                  Map<String, dynamic> element = requests[index];
                  VacationInfo vacation = VacationInfo.empty();
                  PermissionInfo permission = PermissionInfo.empty();
                  element.containsKey("permission")
                      ? permission = element["permission"]
                      : vacation = element["vacation"];
                  return element.containsKey("permission")
                      ? GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              ManagerPermissionDetailsScreen.route_name,
                              arguments: element,
                            );
                          },
                          child: ManagerPermissionCard(
                            date: permission.dateTime,
                            state: permission.state,
                            permissionType: permission.permissionType,
                            employee: element["employee"],
                            id: permission.id,
                            refreshController: _refreshController,
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              ManagerVacationDetailsScreen.route_name,
                              arguments: element,
                            );
                          },
                          child: ManagerVacationCard(
                            date: vacation.startDate,
                            state: vacation.state,
                            employee: element["employee"],
                            id: vacation.id,
                            refreshController: _refreshController,
                          ),
                        );
                },
                itemCount: requests.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
