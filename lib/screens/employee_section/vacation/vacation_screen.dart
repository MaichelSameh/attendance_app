import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../api/employee_data_api.dart';
import '../../../controllers/localization_controller.dart';
import '../../../models/models.dart';
import '../../../widgets/widgets.dart';
import 'request_new_vacation_screen.dart';
import 'vacation_details_screen.dart';

class VacationScreen extends StatefulWidget {
  static const String route_name = "vacation_screen";

  @override
  _VacationScreenState createState() => _VacationScreenState();
}

class _VacationScreenState extends State<VacationScreen> {
  final EmployeeDataAPI _employeeDataAPI = EmployeeDataAPI();
  List<VacationInfo> vacations = [];
  ScrollController controller = ScrollController();
  int pageNumber = 1;

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  Widget build(BuildContext context) {
    Size _size = new Size(context);
    return Scaffold(
      body: Column(
        children: [
          CustomScreenHeader("vacation"),
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
                  .getTranslatedValue("new_vacation")
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
              RequestNewVacationScreen.route_name,
              arguments: VacationInfo.empty());
          _refreshController.requestRefresh();
        },
      ),
    );
  }

  Widget _buildEventsList(BuildContext context) {
    return Expanded(
      child: SmartRefresher(
        header: MyCustomHeader(),
        footer: MyCustomFooter(),
        enablePullUp: true,
        controller: _refreshController,
        onLoading: () async {
          List<VacationInfo> list =
              await _employeeDataAPI.fetchVacations(pageNumber + 1).catchError(
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
            pageNumber++;
          }
          list.forEach((element) {
            vacations.add(element);
          });
          setState(() {});
          _refreshController.loadComplete();
        },
        onRefresh: () async {
          pageNumber = 1;
          vacations =
              await _employeeDataAPI.fetchVacations(pageNumber).catchError(
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
        child: ListView.builder(
          controller: controller,
          padding: EdgeInsets.zero,
          itemBuilder: (ctx, index) {
            return GestureDetector(
              onTap: () async {
                await Navigator.of(context).pushNamed(
                    VacationDetailsScreen.route_name,
                    arguments: vacations[index]);
                _refreshController.requestRefresh();
              },
              child: vacations[index].id == VacationInfo.empty().id
                  ? Container()
                  : VacationCard(
                      date: vacations[index].startDate,
                      state: vacations[index].state,
                    ),
            );
          },
          itemCount: vacations.length,
        ),
      ),
    );
  }
}
