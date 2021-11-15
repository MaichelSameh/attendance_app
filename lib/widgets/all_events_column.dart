import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../controllers/user_controller.dart';
import '../models/models.dart';
import '../screens/screens.dart';
import 'cards.dart';

class AllEventsColumn extends StatelessWidget {
  final List<Map<String, Map<String, dynamic>?>> list;
  late final RefreshController _refresher;
  AllEventsColumn(this.list, {RefreshController? refresher}) {
    _refresher = refresher ?? RefreshController();
  }
  @override
  Widget build(BuildContext context) {
    final UserInfo currentUser = Get.find<UserController>().currentUser;
    return Column(
      children: list.map((item) {
        if (item.keys.first == "attendance") {
          AttendanceInfo attendance =
              AttendanceInfo.fromJSON(item["attendance"]);
          if (attendance.id == AttendanceInfo.empty().id) {
            return Container();
          }
          switch (attendance.state) {
            case AttendanceState.Present:
              return GestureDetector(
                onTap: () async {
                  await Navigator.of(context).pushNamed(
                      AttendanceScreen.route_name,
                      arguments: attendance);
                  item["attendance"] = attendance.toJson();
                  _refresher.requestRefresh();
                },
                child: AttendanceCard.present(
                  startDate: attendance.startDate,
                  finishDate: attendance.endDate,
                ),
              );
            case AttendanceState.Absent:
              return GestureDetector(
                onTap: () async {
                  await Navigator.of(context).pushNamed(
                      AttendanceScreen.route_name,
                      arguments: attendance);
                  _refresher.requestRefresh();
                },
                child: AttendanceCard.absent(
                  startDate: attendance.date,
                ),
              );
            case AttendanceState.Delay:
              return GestureDetector(
                onTap: () async {
                  await Navigator.of(context).pushNamed(
                      AttendanceScreen.route_name,
                      arguments: attendance);
                  _refresher.requestRefresh();
                },
                child: AttendanceCard.delay(
                  startDate: attendance.startDate,
                  finishDate: attendance.endDate,
                ),
              );
            case AttendanceState.Vacation:
              return GestureDetector(
                onTap: () async {
                  await Navigator.of(context).pushNamed(
                      AttendanceScreen.route_name,
                      arguments: attendance);
                  _refresher.requestRefresh();
                },
                child: AttendanceCard.vacation(startDate: attendance.date),
              );
          }
        }
        if (item.keys.first == "vacation_request") {
          VacationInfo vacation =
              VacationInfo.fromJSON(item["vacation_request"]);
          if (vacation.id == VacationInfo.empty().id) {
            return Container();
          }
          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).pushNamed(
                  VacationDetailsScreen.route_name,
                  arguments: vacation);
              _refresher.requestRefresh();
            },
            child: VacationCard(
              date: vacation.startDate,
              state: vacation.state,
            ),
          );
        }
        if (item.keys.first == "client_visit") {
          ClientVisitInfo visit =
              ClientVisitInfo.fromJSON(item["client_visit"]);
          if (visit.id == ClientVisitInfo.empty().id) {
            return Container();
          }
          return (currentUser.canStartClientMeeting ||
                  currentUser.canEndClientVisit ||
                  currentUser.canStartClientVisit)
              ? GestureDetector(
                  onTap: () async {
                    await Navigator.of(context).pushNamed(
                        ClientVisitDetailsScreen.route_name,
                        arguments: visit);
                    _refresher.requestRefresh();
                  },
                  child: ClientVisitCard(
                    date: visit.startVisitTime,
                    clientName: visit.name,
                  ),
                )
              : Container();
        }
        if (item.keys.first == "report") {
          ReportInfo report = ReportInfo.fromJSON(item["report"]);
          if (report.id == ReportInfo.empty().id) {
            return Container();
          }
          return GestureDetector(
            onTap: () async {
              await Navigator.of(context)
                  .pushNamed(ReportDetailsScreen.route_name, arguments: report);
              _refresher.requestRefresh();
            },
            child: ReportCard(
              date: report.date,
              title: report.title,
            ),
          );
        }
        if (item.keys.first == "permission_request") {
          PermissionInfo permission =
              PermissionInfo.fromJSON(item["permission_request"]);
          if (permission.id == PermissionInfo.empty().id) {
            return Container();
          }
          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).pushNamed(
                  PermissionDetailsScreen.route_name,
                  arguments: permission);
              _refresher.requestRefresh();
            },
            child: PermissionCard(
              date: permission.dateTime,
              state: permission.state,
              permissionType: permission.permissionType,
            ),
          );
        }
        return Container();
      }).toList(),
    );
  }
}
