import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../api/manager_data_api.dart';
import '../../../const/const_data.dart';
import '../../../controllers/localization_controller.dart';
import '../../../models/permission_info.dart';
import '../../../models/size.dart';
import '../../../widgets/widgets.dart';

class ManagerPermissionDetailsScreen extends StatefulWidget {
  static const String route_name = "manager_permission_details_screen";

  @override
  _ManagerPermissionDetailsScreenState createState() =>
      _ManagerPermissionDetailsScreenState();
}

class _ManagerPermissionDetailsScreenState
    extends State<ManagerPermissionDetailsScreen> {
  late Map<String, dynamic> data;

  late PermissionInfo permission;

  bool _firstTime = true;

  @override
  Widget build(BuildContext context) {
    if (_firstTime) {
      data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      permission = data["permission"];
      _firstTime = false;
    }
    Size _size = Size(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomScreenHeader("permission_request"),
            CustomCard(
              width: 368,
              child: Column(
                children: [
                  CustomProfileHeader(
                    employee: data["employee"],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _size.width(31),
                      vertical: _size.height(37),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 0, width: double.infinity),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            PermissionStateCard(permission.state, false)
                          ],
                        ),
                        SizedBox(height: _size.height(26)),
                        _buildFieldName(
                          _size,
                          "vacation_icon",
                          "reason",
                          11,
                          14,
                        ),
                        _buildField(_size, permission.permissionType),
                        _buildFieldName(
                          _size,
                          "calendar",
                          "date",
                          13,
                          12,
                        ),
                        _buildField(
                          _size,
                          DateFormat("dd MM, yyyy").format(permission.dateTime),
                        ),
                        _buildFieldName(
                          _size,
                          "delay_icon",
                          "time",
                          14,
                          14,
                        ),
                        _buildField(
                          _size,
                          DateFormat(Get.find<AppLocalizationController>()
                                          .isRTLanguage
                                      ? "mm : hh"
                                      : "hh : mm")
                                  .format(permission.dateTime) +
                              " " +
                              (Get.find<AppLocalizationController>()
                                  .getTranslatedValue(
                                      permission.dateTime.hour > 12
                                          ? "pm"
                                          : "am")),
                        ),
                        _buildFieldName(
                          _size,
                          "description",
                          "description",
                          12,
                          12,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: _size.height(3),
                            left: Get.find<AppLocalizationController>()
                                    .isRTLanguage
                                ? 0
                                : _size.width(20),
                            right: !Get.find<AppLocalizationController>()
                                    .isRTLanguage
                                ? 0
                                : _size.width(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText(
                                permission.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                      color: Color.fromRGBO(168, 167, 167, 1),
                                      fontSize: 12,
                                    ),
                              ),
                              SizedBox(height: _size.height(25)),
                            ],
                          ),
                        ),
                        _buildDecisionButtons(_size, permission.state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: _size.height(50)),
          ],
        ),
      ),
    );
  }

  Padding _buildField(Size _size, String text) {
    return Padding(
      padding: EdgeInsets.only(
        left: Get.find<AppLocalizationController>().isRTLanguage
            ? 0
            : _size.width(20),
        right: !Get.find<AppLocalizationController>().isRTLanguage
            ? 0
            : _size.width(20),
        top: _size.height(3),
        bottom: _size.height(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
              color: Color.fromRGBO(168, 167, 167, 1),
            ),
      ),
    );
  }

  Widget _buildFieldName(
    Size _size,
    String iconName,
    String titleKey,
    double height,
    double width,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          "assets/icons/$iconName.svg",
          color: Colors.black,
          height: _size.height(height),
          width: _size.height(width),
        ),
        SizedBox(width: _size.width(10)),
        Text(
          Get.find<AppLocalizationController>()
              .getTranslatedValue(titleKey)
              .toUpperCase(),
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
        ),
      ],
    );
  }

  Widget _buildDecisionButtons(Size _size, PermissionState state) {
    ManagerDataAPI _managerDataAPI = ManagerDataAPI();
    return state == PermissionState.Pending
        ? Padding(
            padding: EdgeInsets.only(
              top: _size.height(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomElevatedButton(
                  onTap: () {
                    _managerDataAPI
                        .updatePermission(
                      permission.id,
                      RequestStatus.Accepted,
                    )
                        .catchError(
                      (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error.toString()),
                          ),
                        );
                        Navigator.pop(context);
                      },
                    );
                  },
                  width: 134,
                  height: 52,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Get.find<AppLocalizationController>()
                            .getTranslatedValue("Accept")
                            .toUpperCase(),
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(width: _size.width(9)),
                      SvgPicture.asset(
                        "assets/icons/true_sign.svg",
                        color: Colors.white,
                        width: _size.width(20),
                        height: _size.height(12),
                      ),
                    ],
                  ),
                ),
                CustomElevatedButton(
                  onTap: () async {
                    _managerDataAPI
                        .updatePermission(
                      permission.id,
                      RequestStatus.Rejected,
                    )
                        .catchError(
                      (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error.toString()),
                          ),
                        );
                        Navigator.pop(context);
                      },
                    );
                  },
                  width: 134,
                  height: 52,
                  color: ConstData.failure_color,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Get.find<AppLocalizationController>()
                            .getTranslatedValue("reject")
                            .toUpperCase(),
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(width: _size.width(9)),
                      SvgPicture.asset(
                        "assets/icons/cross.svg",
                        color: Colors.white,
                        width: _size.width(14),
                        height: _size.height(14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }
}
