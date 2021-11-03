import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../api/employee_data_api.dart';
import '../../../controllers/controllers.dart';
import '../../../models/models.dart';
import '../../../widgets/widgets.dart';
import 'add_report_screen.dart';
import 'report_details_screen.dart';

class ReportScreen extends StatefulWidget {
  static const String route_name = "report_screen";

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final EmployeeDataAPI _employeeDataAPI = EmployeeDataAPI();

  // ignore: unused_field
  int _pageNumber = 1;

  List<ReportInfo> _reports = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  Widget build(BuildContext context) {
    Size _size = new Size(context);
    return Scaffold(
      body: Column(
        children: [
          CustomScreenHeader("report"),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _size.width(30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNewEventButton(_size, context),
                  SizedBox(height: _size.height(33)),
                  _buildEventsList(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewEventButton(Size _size, BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: CustomElevatedButton(
        width: 172,
        height: 52,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SvgPicture.asset(
              "assets/icons/add.svg",
              width: _size.width(14),
              height: _size.height(14),
            ),
            Text(
              Get.find<AppLocalizationController>()
                  .getTranslatedValue("new_report")
                  .toUpperCase(),
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        onTap: () async {
          await Navigator.of(context).pushNamed(
            AddReportScreen.route_name,
            arguments: ReportInfo.empty(),
          );
          _refreshController.requestRefresh();
        },
      ),
    );
  }

  Widget _buildEventsList(BuildContext context) {
    return Expanded(
      child: SmartRefresher(
        enablePullUp: true,
        controller: _refreshController,
        header: MyCustomHeader(),
        footer: MyCustomFooter(),
        onRefresh: () async {
          _pageNumber = 1;
          _reports =
              await _employeeDataAPI.fetchReports(_pageNumber).catchError(
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
          List<ReportInfo> list =
              await _employeeDataAPI.fetchReports(_pageNumber + 1).catchError(
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
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemBuilder: (ctx, index) {
            return GestureDetector(
              onTap: () async {
                await Navigator.of(context).pushNamed(
                    ReportDetailsScreen.route_name,
                    arguments: _reports[index]);
                _refreshController.requestRefresh();
              },
              child: ReportCard(
                date: _reports[index].date,
                title: _reports[index].title,
              ),
            );
          },
          itemCount: _reports.length,
        ),
      ),
    );
  }
}
