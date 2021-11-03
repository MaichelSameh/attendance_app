import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../api/employee_data_api.dart';
import '../api/manager_data_api.dart';
import '../const/const_data.dart';
import '../controllers/user_controller.dart';
import '../models/models.dart';
import '../screens/screens.dart';
import 'pre_loader.dart';

class NotificationCard extends StatelessWidget {
  late final NotificationInfo _notification;
  late final RefreshController? _refreshController;
  NotificationCard({
    required NotificationInfo notification,
    RefreshController? refreshController,
  }) {
    this._refreshController = refreshController;
    this._notification = notification;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return GestureDetector(
      onTap: () async {
        showDialog(
          context: context,
          builder: (_) => PreLoader(),
          barrierDismissible: false,
        );
        EmployeeDataAPI _employeeDataAPI = EmployeeDataAPI();
        if (_notification.requestType == NotificationRequestTypes.Permission) {
          Map<String, dynamic> element = await _employeeDataAPI
              .getPermissionByID(_notification.requestID,
                  getEmployee: !Get.find<UserController>().activeEmployeeMode)
              .catchError((error) {
            FocusScope.of(context).unfocus();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(error, style: Theme.of(context).textTheme.bodyText1),
              ),
            );
            Navigator.pop(context);
          });
          await Navigator.of(context).pushNamed(
            Get.find<UserController>().activeEmployeeMode
                ? PermissionDetailsScreen.route_name
                : ManagerPermissionDetailsScreen.route_name,
            arguments: Get.find<UserController>().activeEmployeeMode
                ? element['permission']
                : element,
          );
          Navigator.pop(context);
          if (_refreshController != null) _refreshController!.requestRefresh();
        } else if (_notification.requestType ==
            NotificationRequestTypes.Vacation) {
          Map<String, dynamic> element = await _employeeDataAPI
              .getVacationByID(_notification.requestID,
                  getEmployee: !Get.find<UserController>().activeEmployeeMode)
              .catchError((error) {
            FocusScope.of(context).unfocus();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(error, style: Theme.of(context).textTheme.bodyText1),
              ),
            );
            Navigator.pop(context);
          });
          await Navigator.of(context).pushNamed(
            Get.find<UserController>().activeEmployeeMode
                ? VacationDetailsScreen.route_name
                : ManagerVacationDetailsScreen.route_name,
            arguments: Get.find<UserController>().activeEmployeeMode
                ? element['vacation']
                : element,
          );

          Navigator.pop(context);
          if (_refreshController != null) _refreshController!.requestRefresh();
        }
      },
      child: Container(
        width: _size.width(398),
        height: _size.height(125),
        padding: EdgeInsets.symmetric(
          vertical: _size.height(20),
          horizontal: _size.width(32),
        ),
        margin: EdgeInsets.symmetric(vertical: _size.height(10)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_size.width(40)),
        ),
        child: Row(
          children: [
            Container(
              width: _size.width(78),
              height: _size.width(78),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_size.width(39)),
                child: Image.network(
                  _notification.imageURL,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, _, __) {
                    return Image.asset(
                      "assets/images/profile_avatar.png",
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: _size.width(21)),
            Container(
              width: _size.width(160),
              height: _size.height(90),
              alignment: Alignment.center,
              child: RichText(
                overflow: TextOverflow.clip,
                softWrap: true,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _notification.name,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Color.fromRGBO(145, 145, 145, 1),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    TextSpan(text: " "),
                    TextSpan(
                      text: _notification.description,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Color.fromRGBO(145, 145, 145, 1),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            if (!Get.find<UserController>().activeEmployeeMode)
              Container(
                height: _size.height(105),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        ManagerDataAPI _managerDataAPI = ManagerDataAPI();
                        if (_notification.requestType ==
                            NotificationRequestTypes.Permission) {
                          showDialog(
                            context: context,
                            builder: (_) => PreLoader(),
                            barrierDismissible: false,
                          );
                          await _managerDataAPI
                              .updatePermission(_notification.requestID,
                                  RequestStatus.Accepted)
                              .catchError(
                            (error) {
                              FocusScope.of(context).unfocus();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error.toString()),
                                ),
                              );
                              Navigator.pop(context);
                            },
                          );
                          if (_refreshController != null)
                            _refreshController!.requestRefresh();
                        } else if (_notification.requestType ==
                            NotificationRequestTypes.Vacation) {
                          showDialog(
                            context: context,
                            builder: (_) => PreLoader(),
                            barrierDismissible: false,
                          );
                          await _managerDataAPI
                              .updateVacation(_notification.requestID,
                                  RequestStatus.Accepted)
                              .catchError(
                            (error) {
                              FocusScope.of(context).unfocus();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error.toString()),
                                ),
                              );
                              Navigator.pop(context);
                            },
                          );
                          if (_refreshController != null)
                            _refreshController!.requestRefresh();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("No suitable action available!"),
                            ),
                          );
                        }
                      },
                      child: CircleAvatar(
                        radius: _size.width(18),
                        backgroundColor: ConstData.green_color,
                        child: SvgPicture.asset(
                          "assets/icons/true_sign.svg",
                          color: Colors.white,
                          height: _size.height(15),
                          width: _size.width(10),
                        ),
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () async {
                        ManagerDataAPI _managerDataAPI = ManagerDataAPI();
                        if (_notification.requestType ==
                            NotificationRequestTypes.Permission) {
                          showDialog(
                            context: context,
                            builder: (_) => PreLoader(),
                            barrierDismissible: false,
                          );
                          await _managerDataAPI
                              .updatePermission(_notification.requestID,
                                  RequestStatus.Rejected)
                              .catchError(
                            (error) {
                              FocusScope.of(context).unfocus();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error.toString()),
                                ),
                              );
                              Navigator.pop(context);
                            },
                          );
                          if (_refreshController != null)
                            _refreshController!.requestRefresh();
                        } else if (_notification.requestType ==
                            NotificationRequestTypes.Vacation) {
                          showDialog(
                            context: context,
                            builder: (_) => PreLoader(),
                            barrierDismissible: false,
                          );
                          await _managerDataAPI
                              .updateVacation(_notification.requestID,
                                  RequestStatus.Rejected)
                              .catchError(
                            (error) {
                              FocusScope.of(context).unfocus();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error.toString()),
                                ),
                              );
                              Navigator.pop(context);
                            },
                          );
                          if (_refreshController != null)
                            _refreshController!.requestRefresh();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("No suitable action available!"),
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: _size.width(36),
                        width: _size.width(36),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ConstData.failure_color,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/icons/thin_cross_sign.svg",
                            color: ConstData.failure_color,
                            height: _size.height(20),
                            width: _size.width(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
